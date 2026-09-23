_: {
  services.resolved = {
    enable = true;
    settings.Resolve = {
      # allow-downgrade instead of strict DNSSEC: the adguard frontend proxies
      # DoH upstreams but does not terminate DNSSEC, so `DNSSEC=true` turns
      # unvalidatable answers into SERVFAIL for everything. Validation still
      # happens when possible; it degrades instead of bricking all lookups.
      DNSSEC = "allow-downgrade";
      LLMNR = "false";
      MulticastDNS = "false";
      FallbackDNS = "1.1.1.1 1.0.0.1";
      # Real resolvers as a trailing fallback for the per-link chain, so a
      # dead local frontend (REFUSED/SERVFAIL per query) never takes the
      # whole connection down.
    };
  };
}
