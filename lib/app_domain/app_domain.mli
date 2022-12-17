type user_data_encrypted = { username: string; password_encrypted: string; }

type user_data_decrypted = { username: string; password_encrypted: string; password_decrypted: string; }

type user_data =
| Encrypted of { username: string; password_encrypted: string; }
| Decrypted of { username: string; password_encrypted: string; password_decrypted: string; }