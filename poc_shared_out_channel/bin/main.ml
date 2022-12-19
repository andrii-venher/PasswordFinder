let num_domains = 8
let messages = 10
let threads = 30

let producer ch id =
  for _ = 1 to messages do
    Domainslib.Chan.send ch id
  done;
  Printf.printf "%s-exit\n" id;
  flush stdout

let rec consumer ch =
  let id = Domainslib.Chan.recv ch in
  if id = "stop" then
    ()
  else (
    Printf.printf "%s\n" id;
    flush stdout;
    consumer ch
  )

let launch prefix ch =
  for i = 1 to threads do
    let _ = Thread.create (producer ch) (Printf.sprintf "%s%d" prefix i) in ()
  done

let main () =
  let ch = Domainslib.Chan.make_unbounded () in
  let pool = Domainslib.Task.setup_pool ~num_domains:(num_domains - 1) () in
  let receiver = Domainslib.Task.async pool (fun _ -> consumer ch) in
  let _ = Domainslib.Task.async pool (fun _ -> launch "aaa" ch) in
  let _ = Domainslib.Task.async pool (fun _ -> launch "bbb" ch) in
  let _ = Domainslib.Task.async pool (fun _ -> launch "ccc" ch) in
  Thread.delay (1.0 +. float_of_int(messages * threads) /. 2000.0);
  Domainslib.Chan.send ch "stop";
  Domainslib.Task.run pool (fun _ -> 
    let _ = Domainslib.Task.await pool receiver in ()
  );
  Domainslib.Task.teardown_pool pool
  

let _ = main ()