open App_domain

(** Reads the input file and parses lines into user data records. *)
let read_user_data filename =
  let in_ch = open_in filename in
  let rec aux acc =
    try
      let line = input_line in_ch in
      let chunks = String.split_on_char ' ' line in
      match chunks with
      | username::password_encrypted::[] -> aux (acc @ [Encrypted { username; password_encrypted; }])
      | _ -> failwith "Invalid input line format."
    with End_of_file -> acc in
  let data = aux [] in
  close_in in_ch;
  data

(** Formats the log line based on provided user data. *)
let format_output_line = function
| Decrypted({ username; password_encrypted; password_decrypted; }) -> 
  Printf.sprintf "User: %s\tPassword: %s\tEncrypted: %s" username password_decrypted password_encrypted
| _ -> failwith "Wrong data format."
 
(** Flushed stdout after the print call. *)
let log print =
  print ();
  flush stdout

(** Executed only if debug is enabled. Flushed stdout after the print call. *)
let log_debug print =
  if Config.debug_logs then (
    print ();
    flush stdout
  )
