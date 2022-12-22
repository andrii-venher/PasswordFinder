(** The main application domain entity. Represents the input (encrypted) data and the output (decrypted) data. *)
type user_data =
| Encrypted of { username: string; password_encrypted: string; }
| Decrypted of { username: string; password_encrypted: string; password_decrypted: string; }