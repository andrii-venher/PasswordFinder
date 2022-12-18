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

  let get_workers worker_blueprints =
    List.map (fun blueprint -> match blueprint with
    | WithInChannel({ worker; weight = _; in_ch = _; }) -> worker
    | _ -> failwith "Wrong worker state.") worker_blueprints

let get_in_channels worker_blueprints =
  List.map (fun blueprint -> match blueprint with
  | WithInChannel({ worker = _; weight = _; in_ch; }) -> in_ch
  | _ -> failwith "Wrong worker state.") worker_blueprints

let get_weights worker_blueprints =
  List.map (fun blueprint -> match blueprint with
  | WithInChannel({ worker = _; weight; in_ch = _; }) -> weight
  | _ -> failwith "Wrong worker state.") worker_blueprints

let distribute_by_weight worker_blueprints chunks = 
  if chunks < 1 then
    [worker_blueprints]
  else
    let result = Array.init chunks (fun _ -> []) in

    let sum_list list = List.fold_left (fun acc x -> acc + x) 0 (List.map (fun blueprint -> 
      match blueprint with 
      | WithInChannel({ worker = _; weight; in_ch = _; }) -> 
        weight
      | _ -> failwith "Wrong worker state.") list) in

    let minumim_value_index () =
      let rec aux res_i res_v = function
      | i -> 
        if i >= chunks then
          res_i
        else
          let curr = sum_list result.(i) in
          if curr < res_v then
            aux i curr (i + 1)
          else
            aux res_i res_v (i + 1) in
      aux (0) Int.max_int 0 in

    let rec aux = function
    | [] -> ()
    | h::t -> 
      let index = minumim_value_index () in
      Printf.printf "minindex = %d\n" index;
      match h with
      | WithInChannel({ worker; weight; in_ch; }) -> 
        let curr = result.(index) in
        Array.set result index (curr @ [(WithInChannel({ worker; weight; in_ch; }))]);
        aux t
      | _ -> failwith "Wrong worker state." in
    
    aux (List.rev worker_blueprints);
    Array.to_list result

let distribute_threads num_domains pool hashes out_ch =
  let worker_blueprints = Worker_helper.create_worker_blueprints 3 6 'a' 'z' hashes out_ch in
  (* let workers = get_workers worker_blueprints in *)
  let in_chs = get_in_channels worker_blueprints in
  (* let weights = get_weights worker_blueprints in
  List.iter (fun x -> print_int x) weights; *)
  (* let worker_chunks = Utils.distribute_list workers num_domains in *)
  let worker_chunks = distribute_by_weight worker_blueprints num_domains in
  Printf.printf "Distributing threads to %d cores\n" (List.length worker_chunks);
  flush stdout;

  List.iter (fun blueprint_group -> 
    print_endline "-----------------";

    List.iter (fun blueprint -> match blueprint with
    | WithInChannel({ worker = _; weight; in_ch =_; }) -> Printf.printf "%d\n" weight;
      | _ -> failwith "Wrong worker state.") blueprint_group;

    let sum = List.fold_left (fun acc blueprint -> match blueprint with
      | WithInChannel({ worker = _; weight; in_ch =_; }) -> acc + weight
      | _ -> failwith "Wrong worker state.") 0 blueprint_group in
    Printf.printf "sum = %d\n" sum;

    print_endline "-----------------";) worker_chunks;

  let rec aux = function
  | h::t ->
    let workers = List.map (fun blueprint -> 
      match blueprint with
      | WithInChannel({ worker; weight =_; in_ch =_; }) -> worker
      | _ -> failwith "Wrong worker state.") h in
    let _ = Domainslib.Task.async pool (fun _ -> create_threads workers) in
    aux t
  | [] -> () in
  aux worker_chunks;
  in_chs