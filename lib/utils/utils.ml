(** Makes a string MD5 digest out of provided bytes. *)
let hash_bytes bytes = 
  Digestif.MD5.to_hex (Digestif.MD5.digest_bytes bytes)

(** Adds a number to a char and returns the resulting char. *)
let char_add ch n =
  Char.chr (Char.code ch + n)
