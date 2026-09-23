{
  # Android in an LXC container on Wayland, for the handful of apps that will
  # never ship for Linux (banking, 2FA, signed-contract viewers, ...).
  #
  # The nixpkgs module handles the plumbing: binderfs, the gbinder.conf gift
  # to /etc, opening waydroid0 in the firewall, and a `waydroid-container`
  # systemd service. Bring it up with:
  #
  #   systemctl start waydroid-container
  #   waydroid session start
  #   waydroid show-full-ui
  #
  # Caveat for THIS host: waydroid's Android userspace does its own DNS inside
  # its netns (plaintext upstreams by default), so it bypasses the adguard
  # chain entirely — app-network isolation, but not DNS filtering. Routing
  # waydroid DNS through adguard needs a custom netd config + a route to
  # 10.254.0.1 in the waydroid container; say the word if you want that block.
  virtualisation.waydroid = {
    enable = true;
  };
}
