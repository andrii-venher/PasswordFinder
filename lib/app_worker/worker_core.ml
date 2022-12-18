let run_worker password hashes out_ch in_ch () = 

  let rec aux password =
    (* if true then
      Printf.printf "%c" suffix;
      flush stdout; *)
    Worker_pipeline.pool_updates in_ch hashes;
    if Worker_pipeline.check_exit hashes then 
      (
        (* Printf.printf "Exit with pass %c: %s\n" suffix (Bytes.to_string password);
        flush stdout; *)
        ()
      )
    else
      if Worker_pipeline.next_password password then (
        Worker_pipeline.check_password password hashes out_ch;
        aux password
      )
      else (
        (* Printf.printf "Last %c\n" suffix;
        flush stdout; *)
        ()
       ) in
  
  (* let password = Worker_pipeline.init_password password_length suffix in *)
  Worker_pipeline.check_password password hashes out_ch;
  aux password