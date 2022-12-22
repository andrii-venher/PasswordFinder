(** Worker blueprint record. *)
type worker_blueprint = {
  worker : unit -> unit;
  weight : int;
  in_ch : App_domain.user_data option Domainslib.Chan.t;
}

(** Selects the worker function from a worker blueprint. *)
val get_worker : worker_blueprint -> unit -> unit

(** Selects the weight from a worker blueprint. *)
val get_weight : worker_blueprint -> int

(** Selects the input channel from a worker blueprint. *)
val get_in_ch :
  worker_blueprint -> App_domain.user_data option Domainslib.Chan.t

(** Creates and injects the worker blueprints. *)
val create_worker_blueprints :
  int ->
  int ->
  char ->
  char ->
  (string, string) Hashtbl.t ->
  App_domain.user_data option Domainslib.Chan.t -> worker_blueprint list

(** Evenly distributes workers into similarly weighted groups. *)
val distribute_blueprints :
  worker_blueprint list -> int -> worker_blueprint list list

(** Makes a description of a given worker groups distribution. *)
val string_of_worker_distribution :
  worker_blueprint list list -> string
