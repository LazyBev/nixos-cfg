{
  rum.programs.alacritty = {
    enable = true;
    settings =
      let
        font.family = "Monocraft";
        normal = {
          black = "#222222";
          red = "#5f8787";
          green = "#99bbaa";
          yellow = "#ddeecc";
          blue = "#888888";
          magenta = "#999999";
          cyan = "#aaaaaa";
          white = "#c1c1c1";
        };
      in
      {
        window.opacity = 0.70;
        terminal.shell.program = "fish";
        scrolling.history = 10000;
        selection.save_to_clipboard = true;
        mouse.hide_when_typing = true;
        cursor = {
          style = "Beam";
          blink_interval = 1000;
        };

        font = {
          size = 15;
          normal = font;
          bold = font;
          italic = font;
          bold_italic = font;
        };

        colors = {
          primary = {
            background = "#000000";
            foreground = "#c1c1c1";
          };
          inherit normal;
          bright = normal // {
            black = "#333333";
          };
        };
      };
  };
}
