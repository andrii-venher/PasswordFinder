let _ = Dotenv.export ()

(** Input file name to read data from. *)
let filename =
  try
    Sys.argv.(1)
  with _ -> 
    match Sys.getenv_opt "FILENAME" with
    | None -> "passwords.txt"
    | Some filename -> filename

(** Number of domains (cores) to use. *)
let num_domains = 
  try
    int_of_string (Sys.argv.(2))
  with _ -> 
    match Sys.getenv_opt "NUM_DOMAINS" with
    | None -> 8
    | Some num_domains -> int_of_string num_domains

(** The difference between the number of worker groups and the number of domains. *)
let groups_diff = 
  try
    int_of_string (Sys.argv.(3))
  with _ -> 
    match Sys.getenv_opt "GROUPS_DIFF" with
    | None -> -1
    | Some groups_diff -> int_of_string groups_diff

(** Whether to show debug logs. *)
let debug_logs =
  match Sys.getenv_opt "DEBUG_LOGS" with
  | None -> false
  | Some num_domains -> bool_of_string num_domains

(** Minimum length of the password in the input file. *)
let password_length_min =
  match Sys.getenv_opt "PASSWORD_LENGTH_MIN" with
  | None -> 3
  | Some length -> int_of_string length

(** Maximum length of the password in the input file. *)  
let password_length_max =
  match Sys.getenv_opt "PASSWORD_LENGTH_MAX" with
  | None -> 6
  | Some length -> int_of_string length

(** The lexicographically smallest letter (symbol) in the input file. *)  
let password_smallest_letter =
  match Sys.getenv_opt "PASSWORD_SMALLEST_LETTER" with
  | None -> 'a'
  | Some str -> String.get str 0

(** The lexicographically greatest letter (Symbol) in the input file. *)    
let password_greatest_letter =
  match Sys.getenv_opt "PASSWORD_GREATEST_LETTER" with
  | None -> 'z'
  | Some str -> String.get str 0