let create_threads out_ch hashes suffix_channel_list_chunk =
  let rec aux = function
  | h::t -> (
    match h with
    | (suffix, in_ch) ->
      (* Printf.printf "Running worker %c\n" suffix;
      flush stdout; *)
      let _ = Thread.create (Worker_core.run_worker in_ch out_ch (Hashtbl.copy hashes) 6) suffix in
      aux t
  )
  | [] -> () in
  aux suffix_channel_list_chunk

let distribute_threads num_domains pool hashes =
  let out_ch = Domainslib.Chan.make_unbounded () in
  let suffix_channel_list = Worker_helper.create_suffix_channel_list 'a' 'z' in
  let chunks = Utils.distribute_list suffix_channel_list num_domains in
  let rec aux = function
  | h::t ->
    let _ = Domainslib.Task.async pool (fun _ -> create_threads out_ch hashes h) in
    aux t
  | [] -> () in
  aux chunks;
  (out_ch, List.map (fun x -> snd x) suffix_channel_list)

let run data =
  let num_domains = 16 in
  let pool = Domainslib.Task.setup_pool ~num_domains:(num_domains - 1) () in
  Printf.printf "Created task pool\n";
  flush stdout;
  let hashes = Worker_helper.create_hashes data in
  let threads = distribute_threads (num_domains - 2) pool hashes in
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