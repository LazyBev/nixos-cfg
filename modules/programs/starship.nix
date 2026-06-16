{ ... }: {
  programs.starship = {
    enable = true;
    settings = {
      format = "$all";
      palette = "dracula";
      palettes.dracula = {
        foreground = "#f8f8f2";
        background = "#282a36";
        cyan = "#8be9fd";
        green = "#50fa7b";
        orange = "#ffb86c";
        pink = "#ff79c6";
        purple = "#bd93f9";
        red = "#ff5555";
        yellow = "#f1fa8c";
      };
      character = {
        success_symbol = "[λ](purple)";
        error_symbol = "[λ](red)";
      };
      directory.style = "cyan";
      directory.truncation_length = 3;
      git_branch.style = "purple";
      git_status.style = "orange";
      nodejs.disabled = false;
      rust.style = "orange";
      python.style = "yellow";
    };
  };
}
