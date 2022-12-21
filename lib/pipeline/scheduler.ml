let run_worker_groups_parallel pool worker_groups =

  let run_workers pool workers =

    let rec aux = function
    | [] -> ()
    | h::t -> 
      let _ = Thread.create h () in
      aux t in

    let _ = Domainslib.Task.async pool (fun _ -> aux workers) in () in

  let rec run_groups = function
  | [] -> ()
  | h::t ->
    let workers = List.map Builder.get_worker h in
    run_workers pool workers;
    run_groups t in

  run_groups worker_groups

let rec run_workers_single_domain = function
| [] -> ()
| h::t -> 
  let _ = Thread.create h () in
  run_workers_single_domain t


let run_parallel pool hashes out_ch =
  let worker_blueprints = Builder.create_worker_blueprints 
    Config.password_length_min 
    Config.password_length_max 
    Config.password_smallest_letter 
    Config.password_greatest_letter 
    hashes out_ch in
  let in_chs = List.map Builder.get_in_ch worker_blueprints in
  let worker_groups = Builder.distribute_blueprints worker_blueprints (Config.num_domains + Config.groups_diff) in
  Io.log_debug (fun () -> Printf.printf "%s" (Builder.string_of_worker_distribution worker_groups));
  run_worker_groups_parallel pool worker_groups;
  in_chs

let run_single_domain hashes out_ch =
  let worker_blueprints = Builder.create_worker_blueprints 
    Config.password_length_min 
    Config.password_length_max 
    Config.password_smallest_letter 
    Config.password_greatest_letter 
    hashes out_ch in
  let in_chs = List.map Builder.get_in_ch worker_blueprints in
  let workers = List.map Builder.get_worker worker_blueprints in
  Io.log_debug (fun () -> Printf.printf "Run %d workers in the single domain.\n" (List.length workers));
  run_workers_single_domain workers;
  in_chs