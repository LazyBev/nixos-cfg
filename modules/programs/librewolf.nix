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
}
