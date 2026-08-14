/*
 * aversion-overlay — fullscreen, unclosable layer-shell intervention (GTK4).
 *
 * Shows the escalating countdown, then forces a choice between the five exact
 * answers. Choosing "I need this for work" additionally requires typing the
 * confirmation phrase exactly (extra friction against impulse access). Prints
 * the chosen answer on stdout and exits. The daemon supervises this process
 * and respawns it if it is killed.
 *
 * Native Wayland only (wlr-layer-shell); GDK_BACKEND is forced before GTK
 * initializes. Uses a plain GMainLoop: GtkApplication exits immediately on
 * this system (GLib quirk), so it is deliberately avoided.
 */
#include <gtk/gtk.h>
#include <gtk4-layer-shell.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static const char *ANSWERS[] = {
    "I need this for work",
    "I have a specific purpose",
    "I'm bored",
    "I'm avoiding something",
    "I opened it automatically",
};
#define N_ANSWERS (int)(sizeof(ANSWERS) / sizeof(ANSWERS[0]))

typedef struct {
  GtkWidget *countdown;
  GtkWidget *question_box;
  GtkWidget *confirm_box;
  GtkEntry  *confirm_entry;
  GtkWidget *confirm_error;
  GtkWidget *feedback;
} WinWidgets;

static GMainLoop *loop;
static double end_at;
static WinWidgets *wins;
static int n_windows;
static char attempt_label[64];
static char sub_label[128];
static char stats_label[128];
static char confirm_phrase[128] = "Yes, I really need this for work";

static const char *CSS =
    "window.aversion { background-color: #4a0000; }\n"
    "window.aversion label { color: #ffffff; }\n"
    ".aversion-stats { font-size: 13px; opacity: 0.85; }\n"
    ".aversion-title { font-size: 26px; font-weight: bold; margin-top: 12px; }\n"
    ".aversion-sub { font-size: 16px; }\n"
    ".aversion-countdown { font-size: 88px; font-weight: bold; margin: 8px 0; }\n"
    ".aversion-question { font-size: 22px; margin-top: 18px; }\n"
    ".aversion-btn { font-size: 17px; padding: 10px 22px; margin: 3px; }\n"
    ".aversion-confirm { font-size: 20px; margin-top: 18px; }\n"
    ".aversion-phrase { font-size: 18px; font-family: monospace; font-weight: bold; }\n"
    ".aversion-entry { font-size: 18px; min-width: 380px; }\n"
    ".aversion-error { font-size: 15px; color: #ffb0b0; }\n"
    ".aversion-feedback { font-size: 20px; font-weight: bold; margin-top: 18px; }\n";

static gboolean quit_cb(gpointer data) {
  g_main_loop_quit(loop);
  return G_SOURCE_REMOVE;
}

static gboolean tick(gpointer data) {
  double rem = end_at - time(NULL);
  char buf[64];
  for (int i = 0; i < n_windows; i++) {
    if (rem <= 0) {
      gtk_label_set_text(GTK_LABEL(wins[i].countdown), "00:00 remaining");
      gtk_widget_set_visible(wins[i].question_box, TRUE);
    } else {
      snprintf(buf, sizeof buf, "%02d:%02d remaining", (int)rem / 60, (int)rem % 60);
      gtk_label_set_text(GTK_LABEL(wins[i].countdown), buf);
    }
  }
  return rem <= 0 ? G_SOURCE_REMOVE : G_SOURCE_CONTINUE;
}

static void finish_with_answer(const char *answer, const char *feedback_text) {
  printf("%s\n", answer);
  fflush(stdout);
  for (int i = 0; i < n_windows; i++) {
    gtk_widget_set_visible(wins[i].question_box, FALSE);
    gtk_widget_set_visible(wins[i].confirm_box, FALSE);
    gtk_label_set_text(GTK_LABEL(wins[i].feedback), feedback_text);
    gtk_widget_set_visible(wins[i].feedback, TRUE);
  }
  g_timeout_add(1600, quit_cb, NULL);
}

static void on_confirm_activate(GtkEntry *entry, gpointer user_data) {
  const char *typed = gtk_editable_get_text(GTK_EDITABLE(entry));
  if (typed == NULL) typed = "";
  char *norm = g_strdup(typed);
  g_strstrip(norm);
  gboolean ok = (g_ascii_strcasecmp(norm, confirm_phrase) == 0);
  g_free(norm);
  if (ok) {
    finish_with_answer(ANSWERS[0], "Work access granted — 10 minutes.");
  } else {
    for (int i = 0; i < n_windows; i++) {
      gtk_label_set_text(GTK_LABEL(wins[i].confirm_error),
                         "That doesn't match. Type the exact phrase:");
      gtk_editable_set_text(GTK_EDITABLE(wins[i].confirm_entry), "");
      gtk_widget_grab_focus(GTK_WIDGET(wins[i].confirm_entry));
    }
  }
}

static void on_confirm_cancel(GtkButton *btn, gpointer user_data) {
  for (int i = 0; i < n_windows; i++) {
    gtk_widget_set_visible(wins[i].confirm_box, FALSE);
    gtk_label_set_text(GTK_LABEL(wins[i].confirm_error), "");
    gtk_widget_set_visible(wins[i].question_box, TRUE);
  }
}

static void on_answer(GtkButton *btn, gpointer user_data) {
  const char *answer = (const char *)user_data;
  if (strcmp(answer, ANSWERS[0]) == 0) {
    /* "I need this for work": require typing the confirmation phrase first */
    for (int i = 0; i < n_windows; i++) {
      gtk_widget_set_visible(wins[i].question_box, FALSE);
      gtk_label_set_text(GTK_LABEL(wins[i].confirm_error),
                         "Type the exact phrase to confirm:");
      gtk_widget_set_visible(wins[i].confirm_box, TRUE);
      gtk_widget_grab_focus(GTK_WIDGET(wins[i].confirm_entry));
    }
    return;
  }
  finish_with_answer(answer, "Access remains blocked.");
}

static void add_monitor(GdkMonitor *monitor) {
  GtkWidget *win = gtk_window_new();
  gtk_widget_add_css_class(win, "aversion");

  gtk_layer_init_for_window(GTK_WINDOW(win));
  gtk_layer_set_layer(GTK_WINDOW(win), GTK_LAYER_SHELL_LAYER_OVERLAY);
  gtk_layer_set_monitor(GTK_WINDOW(win), monitor);
  gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_TOP, TRUE);
  gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_BOTTOM, TRUE);
  gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_LEFT, TRUE);
  gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_RIGHT, TRUE);
  gtk_layer_set_exclusive_zone(GTK_WINDOW(win), 0);
  gtk_layer_set_keyboard_mode(GTK_WINDOW(win),
                              GTK_LAYER_SHELL_KEYBOARD_MODE_EXCLUSIVE);

  GtkWidget *box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 6);
  gtk_widget_set_halign(box, GTK_ALIGN_CENTER);
  gtk_widget_set_valign(box, GTK_ALIGN_CENTER);
  gtk_widget_set_margin_top(box, 24);
  gtk_widget_set_margin_bottom(box, 24);
  gtk_widget_set_margin_start(box, 48);
  gtk_widget_set_margin_end(box, 48);

  GtkWidget *stats = gtk_label_new(stats_label);
  gtk_widget_add_css_class(stats, "aversion-stats");
  gtk_box_append(GTK_BOX(box), stats);

  GtkWidget *title = gtk_label_new(attempt_label);
  gtk_widget_add_css_class(title, "aversion-title");
  gtk_box_append(GTK_BOX(box), title);

  GtkWidget *sub = gtk_label_new(sub_label);
  gtk_widget_add_css_class(sub, "aversion-sub");
  gtk_box_append(GTK_BOX(box), sub);

  wins = g_realloc(wins, sizeof(WinWidgets) * (n_windows + 1));
  WinWidgets *w = &wins[n_windows];
  memset(w, 0, sizeof(*w));

  w->countdown = gtk_label_new("");
  gtk_widget_add_css_class(w->countdown, "aversion-countdown");
  gtk_box_append(GTK_BOX(box), w->countdown);

  w->question_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 4);
  GtkWidget *q = gtk_label_new("What exactly am I going to do on this website/app?");
  gtk_widget_add_css_class(q, "aversion-question");
  gtk_box_append(GTK_BOX(w->question_box), q);
  for (int i = 0; i < N_ANSWERS; i++) {
    GtkWidget *btn = gtk_button_new_with_label(ANSWERS[i]);
    gtk_widget_add_css_class(btn, "aversion-btn");
    g_signal_connect(btn, "clicked", G_CALLBACK(on_answer), (gpointer)ANSWERS[i]);
    gtk_box_append(GTK_BOX(w->question_box), btn);
  }
  gtk_widget_set_visible(w->question_box, FALSE);
  gtk_box_append(GTK_BOX(box), w->question_box);

  /* Confirmation box: shown only after choosing "I need this for work" */
  w->confirm_box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 8);
  GtkWidget *cq = gtk_label_new("Are you sure?");
  gtk_widget_add_css_class(cq, "aversion-confirm");
  gtk_box_append(GTK_BOX(w->confirm_box), cq);

  char phrase_hint[192];
  snprintf(phrase_hint, sizeof phrase_hint, "\"%s\"", confirm_phrase);
  GtkWidget *phrase_label = gtk_label_new(phrase_hint);
  gtk_widget_add_css_class(phrase_label, "aversion-phrase");
  gtk_box_append(GTK_BOX(w->confirm_box), phrase_label);

  w->confirm_entry = GTK_ENTRY(gtk_entry_new());
  gtk_widget_set_size_request(GTK_WIDGET(w->confirm_entry), 420, -1);
  gtk_entry_set_max_length(w->confirm_entry, 96);
  gtk_widget_add_css_class(GTK_WIDGET(w->confirm_entry), "aversion-entry");
  g_signal_connect(w->confirm_entry, "activate",
                   G_CALLBACK(on_confirm_activate), NULL);
  gtk_box_append(GTK_BOX(w->confirm_box), GTK_WIDGET(w->confirm_entry));

  w->confirm_error = gtk_label_new("");
  gtk_widget_add_css_class(w->confirm_error, "aversion-error");
  gtk_box_append(GTK_BOX(w->confirm_box), w->confirm_error);

  GtkWidget *cancel = gtk_button_new_with_label("Cancel — I don't need it");
  gtk_widget_add_css_class(cancel, "aversion-btn");
  g_signal_connect(cancel, "clicked", G_CALLBACK(on_confirm_cancel), NULL);
  gtk_box_append(GTK_BOX(w->confirm_box), cancel);

  gtk_widget_set_visible(w->confirm_box, FALSE);
  gtk_box_append(GTK_BOX(box), w->confirm_box);

  w->feedback = gtk_label_new("");
  gtk_widget_add_css_class(w->feedback, "aversion-feedback");
  gtk_widget_set_visible(w->feedback, FALSE);
  gtk_box_append(GTK_BOX(box), w->feedback);

  gtk_window_set_child(GTK_WINDOW(win), box);
  gtk_window_present(GTK_WINDOW(win));
  n_windows++;
}

int main(int argc, char **argv) {
  int attempt = 1;
  double remaining = 10.0;
  const char *target = "?";
  int attempts_today = 0, total = 0;

  for (int i = 1; i < argc; i++) {
    if (!strcmp(argv[i], "--attempt") && i + 1 < argc) attempt = atoi(argv[++i]);
    else if (!strcmp(argv[i], "--remaining") && i + 1 < argc) remaining = atof(argv[++i]);
    else if (!strcmp(argv[i], "--target") && i + 1 < argc) target = argv[++i];
    else if (!strcmp(argv[i], "--attempts-today") && i + 1 < argc) attempts_today = atoi(argv[++i]);
    else if (!strcmp(argv[i], "--total") && i + 1 < argc) total = atoi(argv[++i]);
    else if (!strcmp(argv[i], "--confirm-phrase") && i + 1 < argc) {
      snprintf(confirm_phrase, sizeof confirm_phrase, "%s", argv[++i]);
    }
  }

  g_setenv("GDK_BACKEND", "wayland", TRUE);
  g_setenv("NO_AT_BRIDGE", "1", TRUE);

  snprintf(attempt_label, sizeof attempt_label, "ATTEMPT #%d", attempt);
  snprintf(sub_label, sizeof sub_label,
           "You tried to access a blocked target (%s).", target);
  snprintf(stats_label, sizeof stats_label,
           "Attempts today: %d   ·   Total attempts: %d", attempts_today, total);

  end_at = time(NULL) + (remaining > 0 ? remaining : 0);

  gtk_init();

  GtkCssProvider *provider = gtk_css_provider_new();
  gtk_css_provider_load_from_string(provider, CSS);
  gtk_style_context_add_provider_for_display(
      gdk_display_get_default(), GTK_STYLE_PROVIDER(provider),
      GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);

  GdkDisplay *display = gdk_display_get_default();
  if (!display) {
    g_printerr("aversion-overlay: no Wayland display\n");
    return 1;
  }
  GListModel *monitors = gdk_display_get_monitors(display);
  guint n = g_list_model_get_n_items(monitors);
  for (guint i = 0; i < n; i++)
    add_monitor(GDK_MONITOR(g_list_model_get_item(monitors, i)));

  g_timeout_add(200, tick, NULL);
  loop = g_main_loop_new(NULL, FALSE);
  g_main_loop_run(loop);
  return 0;
}
