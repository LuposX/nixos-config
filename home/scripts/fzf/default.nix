{pkgs, ...}: let
  preview-fish-src = pkgs.fetchFromGitHub {
    owner = "kidonng";
    repo = "preview.fish";
    rev = "ba3fbef3a9f23840b25764be2e1c82da5b205d42";
    hash = "sha256-dxG9Drbmy0M5c4lCzeJ4k7BnkrJwmpI4IpkeRP6CYFk=";
  };

  # Dispatch functions — proper function definitions.
  # (Repo's mime files are fragments, not valid fish functions.)
  dispatch_text = pkgs.writeTextFile {
    name = "_preview_mime_text.fish";
    text = ''
      function _preview_mime_text --description "Preview text files with bat"
          _preview_viewer_bat $argv
      end
    '';
  };

  dispatch_image = pkgs.writeTextFile {
    name = "_preview_mime_image.fish";
    text = ''
      function _preview_mime_image --description "Preview images with timg"
          if command -q timg
              timg -g 80x40 --frames 1 $argv
          else
              echo "image: $argv[1]"
          end
      end
    '';
  };

  dispatch_video = pkgs.writeTextFile {
    name = "_preview_mime_video.fish";
    text = ''
      function _preview_mime_video --description "Preview video thumbnails with timg"
          if command -q timg
              timg -g 80x40 --frames 1 $argv
          else
              echo "video: $argv[1]"
          end
      end
    '';
  };

  dispatch_pdf = pkgs.writeTextFile {
    name = "_preview_ext_pdf.fish";
    text = ''
      function _preview_ext_pdf --description "Preview PDFs with pdftotext"
          if command -q pdftotext
              pdftotext $argv - 2>/dev/null | head -200
          else
              bat --color=always $argv 2>/dev/null | head -200
          end
      end
    '';
  };

  dispatch_pdf_mime = pkgs.writeTextFile {
    name = "_preview_mime_application_pdf.fish";
    text = ''
      function _preview_mime_application_pdf --description "Preview PDFs with pdftotext (mime)"
          if command -q pdftotext
              pdftotext $argv - 2>/dev/null | head -200
          else
              bat --color=always $argv 2>/dev/null | head -200
          end
      end
    '';
  };

  dispatch_markdown = pkgs.writeTextFile {
    name = "_preview_ext_md.fish";
    text = ''
      function _preview_ext_md --description "Preview markdown files"
          if command -q glow
              glow $argv
          else
              _preview_viewer_bat $argv
          end
      end
    '';
  };

in {
  home.packages = with pkgs; [
    kitty bat eza ripgrep-all
    perl5Packages.FileMimeInfo
    pkgs.poppler-utils timg glow
  ];

  # Main preview.fish function
  home.file.".config/fish/functions/preview.fish".source =
    "${preview-fish-src}/functions/preview.fish";

  # Viewer functions from repo (these define functions properly via status basename)
  home.file.".config/fish/functions/_preview_viewer_bat.fish".source =
    "${preview-fish-src}/functions/_preview_viewer_bat.fish";
  home.file.".config/fish/functions/_preview_viewer_glow.fish".source =
    "${preview-fish-src}/functions/_preview_viewer_glow.fish";
  home.file.".config/fish/functions/_preview_viewer_timg.fish".source =
    "${preview-fish-src}/functions/_preview_viewer_timg.fish";

  # Dispatch functions (proper function defs, not repo's fragments)
  home.file.".config/fish/functions/_preview_mime_text.fish".source = dispatch_text;
  home.file.".config/fish/functions/_preview_mime_image.fish".source = dispatch_image;
  home.file.".config/fish/functions/_preview_mime_video.fish".source = dispatch_video;
  home.file.".config/fish/functions/_preview_ext_pdf.fish".source = dispatch_pdf;
  home.file.".config/fish/functions/_preview_mime_application_pdf.fish".source = dispatch_pdf_mime;
  home.file.".config/fish/functions/_preview_ext_md.fish".source = dispatch_markdown;
}
