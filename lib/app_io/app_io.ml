open App_domain

let read_all_data filename =
  let inchan = open_in filename in
  let rec aux acc =
    try
      let line = input_line inchan in
      let chunks = String.split_on_char ' ' line in
      match chunks with
      | username::password_encrypted::[] -> aux (acc @ [{ username; password_encrypted; }])
      | _ -> failwith "Invalid input line format."
    with End_of_file -> acc in
  let data = aux [] in
  close_in inchan;
  data
