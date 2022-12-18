type worker_blueprint = {
  worker : unit -> unit;
  weight : int;
  in_ch : App_domain.user_data option Domainslib.Chan.t;
}

val get_worker : worker_blueprint -> unit -> unit

val get_weight : worker_blueprint -> int

val get_in_ch :
  worker_blueprint -> App_domain.user_data option Domainslib.Chan.t

val create_worker_blueprints :
  int ->
  int ->
  char ->
  char ->
  (string, string) Hashtbl.t ->
  App_domain.user_data option Domainslib.Chan.t -> worker_blueprint list

val distribute_blueprints :
  worker_blueprint list -> int -> worker_blueprint list list

val string_of_worker_distribution :
  worker_blueprint list list -> string
