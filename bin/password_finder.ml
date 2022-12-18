let main () = 
  let filename = Utils.get_filename_arg () in
  let user_data = Io.read_all_data filename in
  App_worker.run user_data;
  Printf.printf "Main ended\n";
  flush stdout

  (* let next_password password =
    let rec aux = function
    | i -> 
      if i = Bytes.length password - 1 then 
        false
      else
        let ch = Bytes.get password i in
        if ch < 'z' then (
          Bytes.set password i (Utils.char_add ch 1);
          true
        )
        else (
          Bytes.set password i 'a';
          aux (i + 1)
        ) in
    aux 0

let main () =
  let len = 5 in
  let out_ch = open_out "test.txt" in
  let i = ref 0 in
  while !i < 26 do
    let pass = Bytes.init len (fun _ -> 'a') in
    Bytes.set pass (len - 1) (Utils.char_add 'a' !i);
    i := !i + 1;
    Printf.fprintf out_ch "%s\n" (Bytes.to_string pass);
    while next_password pass do
      Printf.fprintf out_ch "%s\n" (Bytes.to_string pass)
    done;
  done;
  close_out out_ch *)

let _ = main ()