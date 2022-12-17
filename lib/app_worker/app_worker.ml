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
    | Some(None) -> Hashtbl.clear hashes;
    | Some(Some(Decrypted{ username = _; password_encrypted; password_decrypted = _; })) -> 
      Hashtbl.remove hashes password_encrypted;
    | Some(Some(Encrypted({ username = _; password_encrypted = _}))) -> failwith "Wrong data format."
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
      let decryption_result = Decrypted{ username; password_encrypted; password_decrypted; } in
      Printf.printf "Worker %c -> %s\n" suffix (App_io.format_output_line decryption_result);
      flush stdout;
      Domainslib.Chan.send out_ch (Some(decryption_result));
      (* Hashtbl.remove hashes password_encrypted; *)
      () in

  let rec aux password =
    pool_updates ();
    if check_exit () then 
      ()
    else
      if next_password password then (
        (* Printf.printf "Worker %c generated %s\n" suffix (Bytes.to_string password);
        flush stdout; *)
        check_password password;
        aux password
      )
      else
        () in
  
  let password = init_password () in
  check_password password;
  aux password

let create_hashes data =
  let hashes = Hashtbl.create (List.length data) in
  List.iter (fun user_data -> 
    match user_data with
    | Encrypted({ username; password_encrypted; }) -> Hashtbl.add hashes password_encrypted username
    | _ -> failwith "Wrong data format.") data;
  hashes

let message_hub in_ch out_chs expected_messages =
  let rec aux expected_messages =
    if expected_messages <= 0 then 
      ()
    else
      match Domainslib.Chan.recv in_ch with
      | Some(message) ->
        List.iter (fun out_ch -> Domainslib.Chan.send out_ch (Some(message))) out_chs;
        aux (expected_messages - 1)
      | None -> 
        failwith "Unexpected message." in
  aux expected_messages

let create_threads pool hashes =
  let out_ch = Domainslib.Chan.make_unbounded () in
  let rec aux acc = function
  | ch -> 
    if ch <= 'z' then
      let in_ch = Domainslib.Chan.make_unbounded () in
      let _ = Domainslib.Task.async pool (fun _ -> worker in_ch out_ch (Hashtbl.copy hashes) 6 ch) in
      aux (in_ch::acc) (Utils.char_add ch 1)
    else
      acc in
  (out_ch, aux [] 'a')

let run data =
  let pool = Domainslib.Task.setup_pool ~num_domains:15 () in
  Printf.printf "Created task pool\n";
  flush stdout;
  let hashes = create_hashes data in
  let threads = create_threads pool hashes in
  Printf.printf "Created workers\n";
  flush stdout;
  let message_hub_promise = Domainslib.Task.async pool (fun _ -> message_hub (fst threads) (snd threads)) in
  Domainslib.Task.run pool (fun _ ->
    let _ = Domainslib.Task.await pool message_hub_promise (Hashtbl.length hashes) in 
    Printf.printf "Task awaited\n";
    flush stdout;
  );
  Printf.printf "Before teardown\n";
  flush stdout;
  Domainslib.Task.teardown_pool pool;
  Printf.printf "Stopped after teardown\n";
  flush stdout