open App_domain

let pool_updates in_ch hashes = 
  match Domainslib.Chan.recv_poll in_ch with
  | Some(Some(Decrypted{ username = _; password_encrypted; password_decrypted = _; })) -> 
    Hashtbl.remove hashes password_encrypted
    | _ -> ()

let check_exit hashes =
  Hashtbl.length hashes = 0

let next_password password =
  let rec aux = function
  | i -> 
    if i = Bytes.length password - 1 then 
      false
    else
      let ch = Bytes.get password i in
      if ch < 'z' then (
        Bytes.set password i (Utils.char_add ch 1);
        true
      )
      else (
        Bytes.set password i 'a';
        aux (i + 1)
      ) in
  aux 0

let check_password password hashes out_ch = 
  let password_encrypted = Utils.hash_bytes password in
  match Hashtbl.find_opt hashes password_encrypted with
  | None -> ()
  | Some(username) -> 
    let password_decrypted = Bytes.to_string password in
    let decryption_result = Decrypted{ username; password_encrypted; password_decrypted; } in
    (* Printf.printf "Worker %c -> %s\n" suffix (Io.format_output_line decryption_result);
    flush stdout; *)
    Printf.printf "%s\n" (Io.format_output_line decryption_result);
    flush stdout;
    Domainslib.Chan.send out_ch (Some(decryption_result))

let run password hashes out_ch in_ch () = 

  let rec aux password =
    (* if true then
      Printf.printf "%c" suffix;
      flush stdout; *)
    pool_updates in_ch hashes;
    if check_exit hashes then 
      (
        (* Printf.printf "Exit with pass %c: %s\n" suffix (Bytes.to_string password);
        flush stdout; *)
        ()
      )
    else
      if next_password password then (
        check_password password hashes out_ch;
        aux password
      )
      else (
        (* Printf.printf "Last %c\n" suffix;
        flush stdout; *)
        ()
       ) in
  
  (* let password = Worker_pipeline.init_password password_length suffix in *)
  check_password password hashes out_ch;
  aux password