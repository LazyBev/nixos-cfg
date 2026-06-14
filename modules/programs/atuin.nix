{ ... }: {
  programs.atuin = {
    enable = true;
    settings = {
      dialect = "uk";
      style = "compact";
      show_preview = true;
      secret_key = "";
    };
  };
}
