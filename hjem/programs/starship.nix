{
  rum.programs.starship = {
    enable = true;
    settings = {
      palette = "oxocarbon";
      palettes.oxocarbon = {
        cyan = "#35bdd8";
        orange = "#f58c52";
        purple = "#b692f6";
        red = "#ec5f67";
        yellow = "#f8c555";
      };

      character = {
        success_symbol = "[λ](purple)";
        error_symbol = "[λ](red)";
      };
      directory.style = "cyan";
      git_branch.style = "purple";
      git_status.style = "orange";
      rust.style = "orange";
      python.style = "yellow";
    };
  };
}
