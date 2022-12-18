open App_domain

type worker_blueprint =
| WithWeight of { worker: user_data option Domainslib.Chan.t -> unit -> unit; weight: int; }
| WithInChannel of { worker: unit -> unit; weight: int; in_ch: user_data option Domainslib.Chan.t; }

(* type worker_blueprint = { worker: unit -> unit; in_ch: user_data option Domainslib.Chan.t; worker_weight: int; } *)

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

let create_initial_passwords start_length end_length start_suffix end_suffix =
  let rec aux acc length suffix =
    if length > end_length then
      acc
    else
      if suffix > end_suffix then
        aux acc (length + 1) start_suffix
      else
        let password = Worker_pipeline.init_password length suffix in
        aux (acc @ [password]) length (Utils.char_add suffix 1) in
  aux [] start_length start_suffix

let create_empty_workers initial_passwords hashes out_ch =
  List.map (fun password -> WithWeight({ worker = (Worker_core.run_worker password (Hashtbl.copy hashes) out_ch); weight = (Bytes.length password)})) initial_passwords

(* let inject_hashes workers hashes =
  List.map (fun worker -> worker (Hashtbl.copy hashes)) workers *)

(* let inject_out_channel workers out_ch =
  List.map (fun worker -> 
    match worker with 
    | WithWeight({ worker; weight; }) -> WithWeight({ worker = (worker out_ch); weight; })
    | _ -> failwith "Wrong worker state.") workers *)

let inject_in_channels workers in_chs =
  List.map2 (fun worker in_ch ->
    match worker with
    | WithWeight({ worker; weight }) -> WithInChannel({ worker = (worker in_ch); weight; in_ch; })
    | _ -> failwith "Wrong worker state.") workers in_chs

let create_worker_blueprints start_length end_length start_suffix end_suffix hashes out_ch =
  let initial_passwords = create_initial_passwords start_length end_length start_suffix end_suffix in
  let workers = create_empty_workers initial_passwords hashes out_ch in
  (* let workers = inject_hashes workers hashes in *)
  (* let workers = inject_out_channel workers out_ch in *)
  let in_chs = List.init (List.length workers) (fun _ -> Domainslib.Chan.make_unbounded ()) in
  let blueprints = inject_in_channels workers in_chs in
  blueprints

let create_suffix_channel_list start_suffix end_suffix =
  let rec aux acc = function
  | suffix ->
    if suffix <= end_suffix then
      let in_ch = Domainslib.Chan.make_unbounded () in
      aux (acc @ [(suffix, in_ch)]) (Utils.char_add suffix 1)
    else
      acc in
  aux [] start_suffix