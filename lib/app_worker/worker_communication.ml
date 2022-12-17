let run_hub in_ch out_chs expected_messages =
  let rec aux expected_messages =
    if expected_messages <= 0 then 
      ()
    else
      match Domainslib.Chan.recv in_ch with
      | Some(message) ->
        List.iter (fun out_ch -> Domainslib.Chan.send out_ch (Some(message))) out_chs;
        aux (expected_messages - 1)
      | None -> 
        failwith "Unexpected message." in
  aux expected_messages