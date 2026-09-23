_: {
  security = {
    lockKernelModules = true;
    forcePageTableIsolation = true;
  };
  services = {
    geoclue2.enable = false;
    avahi.enable = false;
    # Physical-security: never leave the screen unlocked. Closing the lid or
    # idling locks instead of leaving the session wide open after a suspend
    # resume. (Lock is also the right call on an external-monitor laptop where
    # lid-close shouldn't suspend the machine being used.) logind's lock action
    # targets the active session locker (niri ext-session-lock / gtklock).
    logind.settings.Login = {
      HandleLidSwitch = "lock";
      HandleLidSwitchExternalPower = "lock";
      HandleLidSwitchDocked = "lock";
      IdleAction = "lock";
      IdleActionSec = "20min";
    };
  };
}
