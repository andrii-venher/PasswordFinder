(** Makes a string MD5 digest out of provided bytes. *)
val hash_bytes: bytes -> string

(** Adds a number to a char and returns the resulting char. *)
val char_add: char -> int -> char