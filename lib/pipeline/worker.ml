open App_domain

(** Checks if the input channel has any updates and if so, update the local hashmap copy. *)
let pool_updates in_ch hashes = 
  match Domainslib.Chan.recv_poll in_ch with
  | Some (Some Decrypted{ username = _; password_encrypted; password_decrypted = _; }) -> 
    Hashtbl.remove hashes password_encrypted
    | _ -> ()

(** Checks if the worker could be terminated. *)
let check_exit hashes =
  Hashtbl.length hashes = 0

(** Generates a next letter permutation based on the previous used password. *)
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

(** Checks if the local hashmap copy contains a digest of a generated password and if so,
    sends a message to the message hub. *)
let check_password password hashes out_ch = 
  let password_encrypted = Utils.hash_bytes password in
  match Hashtbl.find_opt hashes password_encrypted with
  | None -> ()
  | Some username -> 
    let password_decrypted = Bytes.to_string password in
    let user_data_decrypted = Decrypted { username; password_encrypted; password_decrypted; } in
    Io.log (fun () -> Printf.printf "%s\n" (Io.format_output_line user_data_decrypted));
    Domainslib.Chan.send out_ch (Some user_data_decrypted)

(** Starts the worker unit. *)
let run password hashes out_ch in_ch () = 

  let rec aux password =
    pool_updates in_ch hashes;
    if check_exit hashes then 
      ()
    else
      if next_password password then (
        check_password password hashes out_ch;
        aux password
      )
      else 
        (
          (* Io.log_debug (fun () -> 
            let pass_len = Bytes.length password in
            let suffix = (Bytes.get password (pass_len - 1)) in
            Printf.printf "Lastpass %d %c\n" pass_len suffix) *)
        ) in
  
  check_password password hashes out_ch;
  aux password