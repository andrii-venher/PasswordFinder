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