(** Reads the input file and parses lines into user data records. *)
val read_user_data : string -> App_domain.user_data list

(** Formats the log line based on provided user data. *)
val format_output_line : App_domain.user_data -> string

(** Flushed stdout after the print call. *)
val log : (unit -> unit) -> unit

(** Executed only if debug is enabled. Flushed stdout after the print call. *)
val log_debug : (unit -> unit) -> unit
