let get_filename_arg () =
  try 
    Sys.argv.(1)
  with _ -> "passwords.txt"

let hash_str str = 
  Digestif.MD5.to_hex (Digestif.MD5.digest_string str)

let hash_bytes bytes = 
  Digestif.MD5.to_hex (Digestif.MD5.digest_bytes bytes)

let char_add ch n =
  Char.chr (Char.code ch + n)