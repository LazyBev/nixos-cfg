{ ... }: {
  programs.starship = {
    enable = true;
    settings = {
      format = "$all";
      palette = "catppuccin_mocha";
      palettes.catppuccin_mocha = {
        foreground = "#cdd6f4";
        background = "#1e1e2e";
        cyan = "#94e2d5";
        green = "#a6e3a1";
        orange = "#fab387";
        pink = "#f5c2e7";
        purple = "#cba6f7";
        red = "#f38ba8";
        yellow = "#f9e2af";
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
