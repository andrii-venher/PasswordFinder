(lang dune 3.6)

(name password_finder)

(generate_opam_files true)

(source
 (github andrii-venher/PasswordFinder))

(authors "Andrii Venher")

(license MIT)

(package
 (name password_finder)
 (synopsis "Brute force password attack in multicore OCaml.")
 (description "")
 (depends ocaml dune digestif)
 )
