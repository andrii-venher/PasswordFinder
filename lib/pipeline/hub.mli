(** The message hub loop listens for incoming messages and broadcasts them to the worker channels. *)
val run :
  'a option Domainslib.Chan.t ->
  'a option Domainslib.Chan.t list -> int -> unit -> unit
