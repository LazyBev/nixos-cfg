{ ... }: {
  services.omnisearch = {
    enable = true;
    settings = {
      server = {
        domain = "http://localhost:8087";
      };
    };
  };
}
