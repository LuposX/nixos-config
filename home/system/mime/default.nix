# Sets the default programs that should be used for a given file format;
# Useful command for debugging: `XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query default application/pdf`
{
  pkgs,
  lib,
  ...
}:
with lib; let
  defaultApps = {
    browser = ["firefox.desktop"];
    text = ["org.gnome.TextEditor.desktop"];
    image = ["imv-dir.desktop"];
    audio = ["mpv.desktop"];
    video = ["mpv.desktop"];
    directory = ["thunar.desktop"];
    office = ["libreoffice.desktop"];
    pdf = ["org.pwmt.zathura-pdf-mupdf.desktop"];
    terminal = ["kitty.desktop"];
    archive = ["xarchiver.desktop"];
  };

  mimeMap = {
    text = ["text/plain"];
    image = [
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/jpg"
      "image/png"
      "image/svg+xml"
      "image/tiff"
      "image/vnd.microsoft.icon"
      "image/webp"
    ];
    audio = [
      "audio/aac"
      "audio/mpeg"
      "audio/ogg"
      "audio/opus"
      "audio/wav"
      "audio/webm"
      "audio/x-matroska"
    ];
    video = [
      "video/mp2t"
      "video/mp4"
      "video/mpeg"
      "video/ogg"
      "video/webm"
      "video/x-flv"
      "video/x-matroska"
      "video/x-msvideo"
    ];
    directory = ["inode/directory"];
    browser = [
      "text/html"
      "x-scheme-handler/about"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/unknown"
    ];
    office = [
      "application/vnd.oasis.opendocument.text"
      "application/vnd.oasis.opendocument.spreadsheet"
      "application/vnd.oasis.opendocument.presentation"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "application/msword"
      "application/vnd.ms-excel"
      "application/vnd.ms-powerpoint"
      "application/rtf"
    ];
    pdf = ["application/pdf"];
    terminal = [
      "terminal"
      "x-scheme-handler/terminal"
    ];
    archive = [
      "application/zip"
      "application/rar"
      "application/7z"
      "application/*tar"
    ];
  };

  associations = with lists;
    listToAttrs (flatten (mapAttrsToList
      (key: map (type: attrsets.nameValuePair type defaultApps."${key}"))
      mimeMap));
in {
  xdg = {
    mimeApps = {
      enable = true;
      associations.added = associations;
      defaultApplications = associations;
    };
  };
}
