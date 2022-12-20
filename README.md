# Password finder

## Prerequisites

You should have [`OCaml 5.0.0~beta1+`](https://github.com/ocaml-multicore/awesome-multicore-ocaml#installation) and [`dune 3.6+`](https://dune.build/install) installed.

Install required packages:
```
opam install domainslib digestif dotenv
```

Check if project builds correctly (no errors in the output or it is empty):
```
dune build
```

## Structure

Main codebase:
- `bin/password_finder.ml` - program entry point.
- `lib/app_domian` - user data entities (encrypted and decrypted payload).
- `lib/config` - configuration loader.
- `lib/io` - input/output functions.
- `lib/pipeline` - app pipeline logic.
  - `lib/pipeline/builder.ml` - creates worker blueprints and evenly distributes them by weight into domain groups.
  - `lib/pipeline/hub.ml` - message hub that routes messages around workers.
  - `lib/pipeline/pipeline.ml` - pipeline creation entry point.
  - `lib/pipeline/scheduler.ml` - runs worker groups in parallel.
  - `lib/pipeline/worker.ml` - worker unit of the app.
- `lib/utils` - utility functions.

Other files:
- `crack.sh` - archive cracking script that recursively cracks the archive.
- `.env` - file with program settings that are dynamically loaded during execution time (may be changed after build as well).
- `open_me.zip` - archive to crack (contains other archives inside).
- `passwords.txt` - hashes passwords to the first archive.
- [`poc_shared_out_channel`](poc_shared_out_channel) - PoC of single shared output channel pipeline. Please take a look if you would like to see executable proof of why this pipeline works correctly.