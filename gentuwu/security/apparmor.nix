_:
{
  # AppArmor is DISABLED: it was enabled but shipping zero profiles, so it
  # provided false confidence rather than isolation. Profile rules are
  # coarse and easily bypassed (exec inheritance of unconfined parents);
  # the actual confinement here is firejail (seccomp + namespaces), which
  # is more precise. Re-enable only with real, tested profiles per app.
  security.apparmor = {
    enable = false;
    killUnconfinedConfinables = false;
  };
}