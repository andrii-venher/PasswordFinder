let _ = Dotenv.export ()

let filename =
  try
    Sys.argv.(1)
  with _ -> 
    match Sys.getenv_opt "FILENAME" with
    | None -> "passwords.txt"
    | Some(filename) -> filename

let num_domains = 
  try
    int_of_string (Sys.argv.(2))
  with _ -> 
    match Sys.getenv_opt "NUM_DOMAINS" with
    | None -> 8
    | Some(num_domains) -> int_of_string num_domains

let debug_logs =
  match Sys.getenv_opt "DEBUG_LOGS" with
  | None -> false
  | Some(num_domains) -> bool_of_string num_domains