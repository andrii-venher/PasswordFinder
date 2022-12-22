(** Prepares and distributes workers, and runs them in parallel in the task pool.
    Returns a list of the channels of workers. *)
val run_parallel :
  Domainslib.Task.pool ->
  (string, string) Hashtbl.t ->
  App_domain.user_data option Domainslib.Chan.t ->
  App_domain.user_data option Domainslib.Chan.t list

(** Prepares workers and runs them in the single (same) domain.
    Returns a list of the channels of workers. *)
val run_single_domain :
  (string, string) Hashtbl.t ->
  App_domain.user_data option Domainslib.Chan.t ->
  App_domain.user_data option Domainslib.Chan.t list
