{
  rum.programs.git = {
    enable = true;
    settings = {
      user = {
        name = "yari";
        email = "yari@ari.lt";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "hx";
      safe.directory = "/home/yari/finix-cfg";
    };
  };
}
