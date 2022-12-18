val run_parallel :
  Domainslib.Task.pool ->
  (string, string) Hashtbl.t ->
  App_domain.user_data option Domainslib.Chan.t ->
  App_domain.user_data option Domainslib.Chan.t list
