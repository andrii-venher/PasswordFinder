open Worker_helper

(* let create_threads out_ch hashes suffix_channel_list_chunk =
  let rec aux = function
  | h::t -> (
    match h with
    | (suffix, in_ch) ->
      (* Printf.printf "Running worker %c\n" suffix;
      flush stdout; *)
      let password = Worker_pipeline.init_password 3 suffix in
      let _ = Thread.create (Worker_core.run_worker password (Hashtbl.copy hashes) out_ch in_ch) () in
      aux t
  )
  | [] -> () in
  aux suffix_channel_list_chunk *)

let rec create_threads = function
| h::t -> 
  let _ = Thread.create h () in
  create_threads t
| [] -> ()

(* let distribute_threads num_domains pool hashes =
  let out_ch = Domainslib.Chan.make_unbounded () in
  let suffix_channel_list = Worker_helper.create_suffix_channel_list 'a' 'z' in
  let chunks = Utils.distribute_list suffix_channel_list num_domains in
  let rec aux = function
  | h::t ->
    let _ = Domainslib.Task.async pool (fun _ -> create_threads out_ch hashes h) in
    aux t
  | [] -> () in
  aux chunks;
  (out_ch, List.map (fun x -> snd x) suffix_channel_list) *)

let distribute_threads num_domains pool hashes out_ch =
  let worker_blueprints = Worker_helper.create_worker_blueprints 3 6 'a' 'z' hashes out_ch in
  let workers = List.map (fun blueprint -> match blueprint with | { worker; in_ch = _} -> worker) worker_blueprints in
  let in_chs = List.map (fun blueprint -> match blueprint with | { worker = _; in_ch} -> in_ch) worker_blueprints in
  let worker_chunks = Utils.distribute_list workers num_domains in
  Printf.printf "Distributing threads to %d cores\n" (List.length worker_chunks);
  flush stdout;
  let rec aux = function
  | h::t ->
    let _ = Domainslib.Task.async pool (fun _ -> create_threads h) in
    aux t
  | [] -> () in
  aux worker_chunks;
  in_chs