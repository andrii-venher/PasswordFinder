let create_threads pool hashes =
  let out_ch = Domainslib.Chan.make_unbounded () in
  let rec aux acc = function
  | ch -> 
    if ch <= 'z' then
      let in_ch = Domainslib.Chan.make_unbounded () in
      print_char ch;
      let _ = Domainslib.Task.async pool (fun _ -> Worker_core.run_worker in_ch out_ch (Hashtbl.copy hashes) 6 ch) in
      aux (in_ch::acc) (Utils.char_add ch 1)
    else
      acc in
  (out_ch, aux [] 'a')

let run data =
  let pool = Domainslib.Task.setup_pool ~num_domains:7 () in
  Printf.printf "Created task pool\n";
  flush stdout;
  let hashes = Worker_helper.create_hashes data in
  let threads = create_threads pool hashes in
  Printf.printf "Created workers\n";
  flush stdout;
  let message_hub_promise = Domainslib.Task.async pool (fun _ -> Worker_communication.run_hub (fst threads) (snd threads)) in
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