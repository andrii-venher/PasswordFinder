open App_domain

let create_pool num_domains =
  let pool = Domainslib.Task.setup_pool ~num_domains:(num_domains - 1) () in
  Printf.printf "Created task pool of %d domains.\n" num_domains;
  flush stdout;
  pool

let teardown_pool pool =
  Domainslib.Task.teardown_pool pool;
  Printf.printf "Task pool is torn down.\n";
  flush stdout

let create_hashes data =
  let hashes = Hashtbl.create (List.length data) in
  List.iter (fun user_data -> 
    match user_data with
    | Encrypted({ username; password_encrypted; }) -> Hashtbl.add hashes password_encrypted username
    | _ -> failwith "Wrong data format.") data;
  hashes

let create_out_ch () = Domainslib.Chan.make_unbounded ()

let run_hub pool hub =
  Domainslib.Task.async pool (fun _ -> hub ())

let await_hub pool hub_promise =
  Domainslib.Task.run pool (fun _ ->
    Domainslib.Task.await pool hub_promise
  )

let run data num_domains =
  let pool = create_pool num_domains in
  let hashes = create_hashes data in
  let out_ch = create_out_ch () in
  let worker_channels = Scheduler.run_parallel (num_domains - 1) pool hashes out_ch in
  let hub_promise = run_hub pool (Hub.run out_ch worker_channels (Hashtbl.length hashes)) in
  await_hub pool hub_promise;
  teardown_pool pool
