let get_filename_arg () =
  try 
    Sys.argv.(1)
  with _ -> "passwords.txt"

let hash_str str = 
  Digestif.MD5.to_hex (Digestif.MD5.digest_string str)

let format_output_line user password password_encrypted =
  Printf.sprintf "User: %s\tPassword: %s\tEncrypted: %s" user password password_encrypted