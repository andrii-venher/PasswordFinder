open App_domain

let create_hashes data =
  let hashes = Hashtbl.create (List.length data) in
  List.iter (fun user_data -> 
    match user_data with
    | Encrypted({ username; password_encrypted; }) -> Hashtbl.add hashes password_encrypted username
    | _ -> failwith "Wrong data format.") data;
  hashes

(* let get_distribution num_domains =
  let length = 26 in
  let letter_pos = 97 in
  let base_part_size = length / num_domains in
  let leftover = length mod num_domains in
  let rec aux acc previous leftover =
    if previous >= (length - 1) then
      acc
    else
      let start_suffix = previous + 1 in
      let end_suffux = start_suffix + base_part_size - 1 in
      if leftover > 0 then
        let tuple = (start_suffix, end_suffux + 1) in
        aux (acc @ [tuple]) (end_suffux + 1) (leftover - 1)
      else
        let tuple = (start_suffix, end_suffux) in
        aux (acc @ [tuple]) end_suffux leftover in
  let list = aux [] (-1) leftover in
  List.map (fun tuple -> (Char.chr (fst tuple + letter_pos), Char.chr (snd tuple + letter_pos))) list *)



(* let compose_distribution distribution_list =
  let rec aux acc = function
  | h::t -> (
    match h with
    | (start_suffix, end_suffix) -> 
      let list = List.init (Char.code end_suffix - Char.code start_suffix + 1) (fun x -> (
        let in_ch = Domainslib.Chan.make_unbounded () in
        (Char.chr (x + (Char.code start_suffix)), in_ch)
      )) in
    aux (acc @ list) t
  )
  | [] -> acc in
  aux [] distribution_list *)

let create_suffix_channel_list start_suffix end_suffix =
  let rec aux acc = function
  | suffix ->
    if suffix <= end_suffix then
      let in_ch = Domainslib.Chan.make_unbounded () in
      aux (acc @ [(suffix, in_ch)]) (Utils.char_add suffix 1)
    else
      acc in
  aux [] start_suffix