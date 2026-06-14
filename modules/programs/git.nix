{ ... }: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      user.name = "yari";
      user.email = "yari@ari.lt";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
    };
  };
}
