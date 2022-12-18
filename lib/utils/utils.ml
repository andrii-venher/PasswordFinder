let get_filename_arg () =
  try 
    Sys.argv.(1)
  with _ -> "passwords.txt"

let hash_str str = 
  Digestif.MD5.to_hex (Digestif.MD5.digest_string str)

let hash_bytes bytes = 
  Digestif.MD5.to_hex (Digestif.MD5.digest_bytes bytes)

let char_add ch n =
  Char.chr (Char.code ch + n)

let distribute_list list chunks =
  let length = List.length list in
  let chunk_size = length / chunks in
  let leftover = length mod chunks in
  let rec aux acc curr leftover i = function
  | h::t ->
    if i > 1 then
      aux acc (curr @ [h]) leftover (i - 1) t
    else
      if leftover > 0 then
        aux (acc @ [curr @ [h]]) [] (leftover - 1) (chunk_size + 1) t
      else
        aux (acc @ [curr @ [h]]) [] (leftover) (chunk_size) t
  | [] -> acc in
  if leftover > 0 then
    aux [] [] (leftover - 1) (chunk_size + 1) list
  else
    aux [] [] 0 chunk_size list