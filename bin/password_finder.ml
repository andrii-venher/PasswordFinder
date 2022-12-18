let main () = 
  let user_data = Io.read_user_data Config.filename in
  Pipeline.run user_data

let _ = main ()