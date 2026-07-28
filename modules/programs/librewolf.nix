{ config, pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;

    policies = {
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      FirefoxHome = {
        Pocket = false;
        Snippets = false;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        SkipOnboarding = true;
      };
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
      };
      Preferences = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = { Value = true; Status = "default"; };
        "ui.systemUsesDarkTheme" = { Value = 1; Status = "default"; };
        "widget.content.allow-gtk-dark-theme" = { Value = true; Status = "default"; };
        "privacy.sanitize.sanitizeOnShutdown" = { Value = false; Status = "default"; };
        "privacy.clearOnShutdown.cookies" = { Value = false; Status = "default"; };
        "privacy.clearOnShutdown.sessions" = { Value = false; Status = "default"; };
        "network.cookie.lifetimePolicy" = { Value = 0; Status = "default"; };
        "network.cookie.lifetime.days" = { Value = 5; Status = "default"; };
        "network.cookie.cookieBehavior" = { Value = 1; Status = "default"; };
        "network.cookie.thirdparty.sessionOnly" = { Value = false; Status = "default"; };
        "identity.fxaccounts.enabled" = { Value = false; Status = "locked"; };
        "privacy.trackingprotection.enabled" = { Value = true; Status = "locked"; };
        "privacy.trackingprotection.socialtracking.enabled" = { Value = true; Status = "locked"; };
        "privacy.donottrackheader.enabled" = { Value = false; Status = "default"; };
        "privacy.globalprivacycontrol.enabled" = { Value = true; Status = "locked"; };
        "media.autoplay.blocking_policy" = { Value = 2; Status = "locked"; };
        "dom.battery.enabled" = { Value = false; Status = "locked"; };
        "dom.vr.enabled" = { Value = false; Status = "locked"; };
        "media.peerconnection.enabled" = { Value = false; Status = "locked"; };
        "media.peerconnection.ice.default_address_only" = { Value = true; Status = "locked"; };
        "media.peerconnection.ice.no_host" = { Value = true; Status = "locked"; };
        "media.peerconnection.ice.proxy_only" = { Value = true; Status = "locked"; };
        "media.peerconnection.ice.proxy_only_if_behind_proxy" = { Value = true; Status = "locked"; };
        "webgl.disabled" = { Value = true; Status = "default"; };
        "dom.security.https_only_mode" = { Value = true; Status = "locked"; };
        "dom.security.https_only_mode_ever_enabled" = { Value = true; Status = "locked"; };
        "network.http.sendRefererHeader" = { Value = 0; Status = "default"; };
        "network.http.referer.XOriginPolicy" = { Value = 2; Status = "default"; };
        "network.http.referer.XOriginTrimmingPolicy" = { Value = 2; Status = "default"; };
      };
      SearchEngines = {
        Add = [{
          Name = "Omnisearch";
          URLTemplate = "http://localhost:8087/search?q={searchTerms}";
          Method = "GET";
        }];
        Default = "Omnisearch";
      };
    };
  };

  environment.etc."firefox/policies/policies.json".target = "librewolf/policies/policies.json";

  # uBlock Origin default settings with security filter lists
  environment.etc."ublock-defaults/ublock-settings.json".text = builtins.toJSON {
    version = 1;
    userSettings = [
      [ "advancedUserEnabled" "true" ]
      [ "contextMenuEnabled" "true" ]
      [ "dynamicFilteringEnabled" "true" ]
      [ "tooltipsDisabled" "false" ]
      [ "showIconBadge" "true" ]
    ];
    selectedFilterLists = [
      # Default lists
      "ublock-filters"
      "ublock-badware"
      "ublock-privacy"
      "ublock-abuse"
      "ublock-unbreak"
      # Ad blocking
      "easylist"
      "easyprivacy"
      # Malware/phishing protection
      "urlhaus-0"
      "malware-0"
      "malware domains"
      "phishing-0"
      # Annoyances
      "easylist-chat"
      "easylist-newsletters"
      "easylist-notifications"
      "easylist-annoyances"
    ];
  };
}
