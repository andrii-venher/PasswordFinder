let num_domains = 16

let main () = 
  let filename = Utils.get_filename_arg () in
  let user_data = Io.read_all_data filename in
  Pipeline.run user_data num_domains

let _ = main ()