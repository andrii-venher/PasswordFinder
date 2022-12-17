let worker in_ch out_ch hashes password_length suffix = 

  let rec aux password =
    (* if true then
      Printf.printf "%c" suffix;
      flush stdout; *)
    Worker_pipeline.pool_updates in_ch hashes;
    if Worker_pipeline.check_exit hashes then 
      ()
    else
      if Worker_pipeline.next_password password then (
        Worker_pipeline.check_password password hashes suffix out_ch;
        aux password
      )
      else
        () in
  
  let password = Worker_pipeline.init_password password_length suffix in
  Worker_pipeline.check_password password hashes suffix out_ch;
  aux password