/*
 * aversion-chip — small overlay showing the remaining work-access time.
 *
 * Bottom-right layer-shell surface, non-interactive, self-exits when the
 * grant expires. Spawned by the daemon while a work-access grant is active.
 * Uses a plain GMainLoop (GtkApplication quits immediately on this system).
 */
#include <gtk/gtk.h>
#include <gtk4-layer-shell.h>

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static const char *CSS =
    "window.chip { background-color: rgba(0, 40, 20, 0.92); border-radius: 14px; }\n"
    "window.chip label { color: #d8ffe8; }\n"
    ".chip-main { font-size: 15px; font-weight: bold; }\n"
    ".chip-stats { font-size: 11px; opacity: 0.85; }\n";

static GMainLoop *loop;
static double until_ts;
static int stats_attempts, stats_total;
static GtkLabel *main_label;

static gboolean tick(gpointer data) {
  double rem = until_ts - time(NULL);
  char buf[64];
  if (rem <= 0) {
    g_main_loop_quit(loop);
    return G_SOURCE_REMOVE;
  }
  snprintf(buf, sizeof buf, "Work access: %02d:%02d remaining",
           (int)rem / 60, (int)rem % 60);
  gtk_label_set_text(main_label, buf);
  return G_SOURCE_CONTINUE;
}

int main(int argc, char **argv) {
  double until = 0;
  int attempts = 0, total = 0;
  for (int i = 1; i < argc; i++) {
    if (!strcmp(argv[i], "--until") && i + 1 < argc) until = atof(argv[++i]);
    else if (!strcmp(argv[i], "--attempts") && i + 1 < argc) attempts = atoi(argv[++i]);
    else if (!strcmp(argv[i], "--total") && i + 1 < argc) total = atoi(argv[++i]);
  }

  g_setenv("GDK_BACKEND", "wayland", TRUE);
  g_setenv("NO_AT_BRIDGE", "1", TRUE);

  until_ts = until;
  stats_attempts = attempts;
  stats_total = total;

  char *gtk_argv[] = { argv[0], NULL };
  gtk_init();

  GtkCssProvider *provider = gtk_css_provider_new();
  gtk_css_provider_load_from_string(provider, CSS);
  gtk_style_context_add_provider_for_display(
      gdk_display_get_default(), GTK_STYLE_PROVIDER(provider),
      GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);

  GtkWidget *win = gtk_window_new();
  gtk_widget_add_css_class(win, "chip");
  gtk_layer_init_for_window(GTK_WINDOW(win));
  gtk_layer_set_layer(GTK_WINDOW(win), GTK_LAYER_SHELL_LAYER_OVERLAY);
  gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_BOTTOM, TRUE);
  gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_RIGHT, TRUE);
  gtk_layer_set_margin(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_BOTTOM, 18);
  gtk_layer_set_margin(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_RIGHT, 18);
  gtk_layer_set_exclusive_zone(GTK_WINDOW(win), 0);
  gtk_layer_set_keyboard_mode(GTK_WINDOW(win),
                              GTK_LAYER_SHELL_KEYBOARD_MODE_NONE);

  GtkWidget *box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 2);
  gtk_widget_set_margin_top(box, 10);
  gtk_widget_set_margin_bottom(box, 10);
  gtk_widget_set_margin_start(box, 16);
  gtk_widget_set_margin_end(box, 16);

  main_label = GTK_LABEL(gtk_label_new(""));
  gtk_widget_add_css_class(GTK_WIDGET(main_label), "chip-main");
  gtk_box_append(GTK_BOX(box), GTK_WIDGET(main_label));

  char stats[128];
  snprintf(stats, sizeof stats, "Attempts today: %d   ·   Total: %d",
           stats_attempts, stats_total);
  GtkWidget *stats_label = gtk_label_new(stats);
  gtk_widget_add_css_class(stats_label, "chip-stats");
  gtk_box_append(GTK_BOX(box), stats_label);

  gtk_window_set_child(GTK_WINDOW(win), box);
  gtk_window_present(GTK_WINDOW(win));

  tick(NULL);
  g_timeout_add(200, tick, NULL);
  loop = g_main_loop_new(NULL, FALSE);
  g_main_loop_run(loop);
  return 0;
}
