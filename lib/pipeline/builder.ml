(** Worker blueprint record. *)
type worker_blueprint = {
  worker : unit -> unit;
  weight : int;
  in_ch : App_domain.user_data option Domainslib.Chan.t;
}

(** Selects the worker function from a worker blueprint. *)
let get_worker = function
| { worker; weight = _; in_ch = _; } -> worker

(** Selects the weight from a worker blueprint. *)
let get_weight = function
| { worker = _; weight; in_ch = _; } -> weight

(** Selects the input channel from a worker blueprint. *)
let get_in_ch = function
| { worker = _; weight =_; in_ch; } -> in_ch

(** Creates a list of initial passwords that produce disjoint sets of letter permitations. *)
let create_initial_passwords start_length end_length start_suffix end_suffix =
  
  let init_password length suffix =
    let password = Bytes.init length (fun _ -> 'a') in
    Bytes.set password (length - 1) suffix;
    password in

  let rec aux acc length suffix =
    if length > end_length then
      acc
    else
      if suffix > end_suffix then
        aux acc (length + 1) start_suffix
      else
        let password = init_password length suffix in
        aux (acc @ [password]) length (Utils.char_add suffix 1) in
  aux [] start_length start_suffix

(** Initializes the worker blueprints. *)
let init_and_weight_workers initial_passwords hashes out_ch =
  List.map (fun password -> 
    let injected_worker = Worker.run password (Hashtbl.copy hashes) out_ch in
    let weight = Bytes.length password in
    (injected_worker, weight)) initial_passwords

(** Injects in channels in the worker blueprints. *)
let inject_in_channels workers in_chs =
  List.map2 (fun worker in_ch ->
    match worker with
    | (worker, weight ) -> { worker = (worker in_ch); weight; in_ch; }) 
  workers in_chs

(** Creates and injects the worker blueprints. *)
let create_worker_blueprints start_length end_length start_suffix end_suffix hashes out_ch =
  let initial_passwords = create_initial_passwords start_length end_length start_suffix end_suffix in
  let weighted_workers = init_and_weight_workers initial_passwords hashes out_ch in
  let in_chs = List.init (List.length weighted_workers) (fun _ -> Domainslib.Chan.make_unbounded ()) in
  let blueprints = inject_in_channels weighted_workers in_chs in
  blueprints

(** Evenly distributes workers into similarly weighted groups. *)
let distribute_blueprints worker_blueprints chunks = 
  if chunks < 1 then
    [worker_blueprints]
  else
    let result = Array.init chunks (fun _ -> []) in

    let sum_list list = List.fold_left (fun acc x -> acc + x) 0 (List.map get_weight list) in

    let minumim_value_index () =
      let rec aux res_i res_v = function
      | i -> 
        if i >= chunks then
          res_i
        else
          let curr = sum_list result.(i) in
          if curr < res_v then
            aux i curr (i + 1)
          else
            aux res_i res_v (i + 1) in
      aux (0) Int.max_int 0 in

    let rec aux = function
    | [] -> ()
    | h::t -> 
      let index = minumim_value_index () in
      match h with
      | { worker; weight; in_ch; } -> 
        let curr = result.(index) in
        Array.set result index (curr @ [{ worker; weight; in_ch; }]);
        aux t in
    
    aux (List.rev worker_blueprints);
    Array.to_list result

(** Makes a description of a given worker groups distribution. *)
let string_of_worker_distribution groups =
  let result = ref (Printf.sprintf "Workers are distributed into %d groups:\n" (List.length groups)) in
  List.iteri (fun i group -> 
    let weight_sum = ref 0 in
    result := !result ^ Printf.sprintf "Group%d\t[" (i + 1);
    List.iteri (fun j weight -> 
      weight_sum := !weight_sum + weight;
      if j = List.length group - 1 then
        result := !result ^ Printf.sprintf "%d] \t(%d)\n" weight !weight_sum
      else
        result := !result ^ Printf.sprintf "%d; " weight
      ) (List.map get_weight group)) groups;
  !result