let hash_bytes bytes = 
  Digestif.MD5.to_hex (Digestif.MD5.digest_bytes bytes)

let char_add ch n =
  Char.chr (Char.code ch + n)
