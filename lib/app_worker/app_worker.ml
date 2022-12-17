open App_domain

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
      print_char ch;
      let _ = Domainslib.Task.async pool (fun _ -> Worker_core.worker in_ch out_ch (Hashtbl.copy hashes) 6 ch) in
      aux (in_ch::acc) (Utils.char_add ch 1)
    else
      acc in
  (out_ch, aux [] 'a')

let run data =
  let pool = Domainslib.Task.setup_pool ~num_domains:7 () in
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