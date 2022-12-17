open App_domain

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

let worker in_ch out_ch hashes password_length suffix = 

  let pool_updates () =
    match Domainslib.Chan.recv_poll in_ch with
    | None -> ()
    | Some({ username = _; password_encrypted; password_decrypted = _; }) -> Hashtbl.remove hashes password_encrypted
  in

  let check_exit () =
    Hashtbl.length hashes = 0 in

  let init_password () =
    let password = Bytes.init password_length (fun _ -> 'a') in
    Bytes.set password (password_length - 1) suffix;
    password in

  let check_password password = 
    let password_encrypted = Utils.hash_bytes password in
    match Hashtbl.find_opt hashes password_encrypted with
    | None -> ()
    | Some(username) -> 
      let password_decrypted = Bytes.to_string password in
      let result = { username; password_encrypted; password_decrypted; } in
      Domainslib.Chan.send out_ch result;
      Hashtbl.remove hashes password_encrypted;
      () in

  let rec aux password =
    pool_updates ();
    if check_exit () then 
      ()
    else
      if next_password password then (
        check_password password;
        aux password
      )
      else
        () in
  
  let password = init_password () in
  check_password password;
  aux password