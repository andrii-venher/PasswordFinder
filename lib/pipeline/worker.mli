(** Starts the worker unit. *)
val run :
  bytes ->
  (string, string) Hashtbl.t ->
  App_domain.user_data option Domainslib.Chan.t ->
  App_domain.user_data option Domainslib.Chan.t -> unit -> unit
