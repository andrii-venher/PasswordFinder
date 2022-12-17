let password = "abc" in
let hash = Digestif.MD5.to_hex (Digestif.MD5.digest_string password) in
Printf.printf "%s = %s\n" password hash