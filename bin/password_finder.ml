let main () = 
  let filename = Utils.get_filename_arg () in
  let user_data = App_io.read_all_data filename in
  App_worker.run user_data

let _ = main ()