open App_domain

let read_all_data filename =
  let in_ch = open_in filename in
  let rec aux acc =
    try
      let line = input_line in_ch in
      let chunks = String.split_on_char ' ' line in
      match chunks with
      | username::password_encrypted::[] -> aux (acc @ [Encrypted{ username; password_encrypted; }])
      | _ -> failwith "Invalid input line format."
    with End_of_file -> acc in
  let data = aux [] in
  close_in in_ch;
  data

let format_output_line = function
| Decrypted({ username; password_encrypted; password_decrypted; }) -> 
  Printf.sprintf "User: %s\tPassword: %s\tEncrypted: %s" username password_decrypted password_encrypted
| _ -> failwith "Wrong data format."