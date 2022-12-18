let run data =
  let num_domains = 16 in
  let pool = Domainslib.Task.setup_pool ~num_domains:(num_domains - 1) () in
  Printf.printf "Created task pool\n";
  flush stdout;
  let hashes = Worker_helper.create_hashes data in
  let threads = Scheduler.distribute_threads (num_domains - 2) pool hashes in
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