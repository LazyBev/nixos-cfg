{
  programs.starship = {
    enable = true;
    settings = {
      format = "$all";
      palette = "oxocarbon";
      palettes.oxocarbon = {
        foreground = "#f2f4f8";
        background = "#2d2a2e";
        cyan = "#35bdd8";
        green = "#addb67";
        orange = "#f58c52";
        pink = "#d68cf8";
        purple = "#b692f6";
        red = "#ec5f67";
        yellow = "#f8c555";
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
