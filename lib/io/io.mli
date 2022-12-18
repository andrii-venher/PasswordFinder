val read_user_data : string -> App_domain.user_data list

val format_output_line : App_domain.user_data -> string

val log : (unit -> unit) -> unit

val log_debug : (unit -> unit) -> unit
