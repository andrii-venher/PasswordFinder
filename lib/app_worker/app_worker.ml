let run data =
  let num_domains = 16 in
  let pool = Domainslib.Task.setup_pool ~num_domains:(num_domains - 1) () in
  Printf.printf "Created task pool\n";
  flush stdout;
  let hashes = Worker_helper.create_hashes data in
  let out_ch = Domainslib.Chan.make_unbounded () in
  (* let threads = Scheduler.distribute_threads (num_domains - 2) pool hashes in *)
  let threads = Scheduler.distribute_threads (num_domains - 2) pool hashes out_ch in
  Printf.printf "Created workers\n";
  flush stdout;
  let message_hub_promise = Domainslib.Task.async pool (fun _ -> Worker_communication.run_hub out_ch threads (Hashtbl.length hashes)) in
  Domainslib.Task.run pool (fun _ ->
    let _ = Domainslib.Task.await pool message_hub_promise in 
    Printf.printf "Task awaited\n";
    flush stdout;
  );
  Printf.printf "Before teardown\n";
  flush stdout;
  Domainslib.Task.teardown_pool pool;
  Printf.printf "Stopped after teardown\n";
  flush stdout


let test () =
  let passwords = Worker_helper.create_initial_passwords 3 6 'a' 'z' in
  let passwords = List.map (fun x -> Bytes.to_string x) passwords in
  List.iter (fun x -> Printf.printf "%s\n" x) passwords