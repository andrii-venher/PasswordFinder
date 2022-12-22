# Password finder

## Idea

It is possible to find a password from an encrypted password by a brute-force attack. The idea is to generate all the possible strings and encrypt them using the same encryption as the original password. Once we find two encrypted strings which are the same, we have a good chance that the non-encrypted strings are the same.

In this case, the assumption is that all the passwords are between 3 and 6 characters long and only contain lowercase letters. Also, all passwords have been encrypted in MD5.

To achieve the best performance, parallel computations are used. You may read more info about it in the [`report`](report/report.pdf) document.

## Prerequisites

You should have [`OCaml 5.0.0~beta1+`](https://github.com/ocaml-multicore/awesome-multicore-ocaml#installation) installed.

Install required packages:
```
opam install dune domainslib digestif dotenv
```

Check if the project builds correctly (no errors in the output or it is empty):
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
- [`report`](report) - project report.
- [`benchmarking`](benchmarking) - results of the benchmarking.
- [`poc_shared_out_channel`](poc_shared_out_channel) - PoC of single shared output channel pipeline.

## Usage

The simplest way to run the project is:
```
dune exec password_finder
```

If you do not want to rebuild the project on every run, you need to build it using `dune` once:
```
dune build
```

Then you may run it with the default configuration like this:
```
./password_finder.exe
```

To clean up build artifacts use:
```
dune clean
```

### Configuration

You may need to change the default configuration. In this case, take a look at the `.env` file that is dynamically loaded to the program during the execution:
```
FILENAME=passwords.txt      # input file name
NUM_DOMAINS=16              # number of cores to use
GROUPS_DIFF=-1              # difference between the number of groups and number of domains
DEBUG_LOGS=false            # show debug logs
PASSWORD_LENGTH_MIN=3
PASSWORD_LENGTH_MAX=6
PASSWORD_SMALLEST_LETTER=a
PASSWORD_GREATEST_LETTER=z
```

Currently, only lowercase letters are supported.

You may also call the executable with overriding parameters:
```
./password_finder.exe passwords.txt 8 -1 # that means FILENAME=passwords.txt, NUM_DOMAINS=16, GROUPS_DIFF=-1
```

### Input file format

Input files should be in the format of two space-separated columns. The first one is a username (any string without spaces) and the other one is an MD5 digest of a password. Example:
```
billy 08f8e0260c64418510cefb2b06eee5cd
lola 47bce5c74f589f4867dbd57e9ca9f808
henry f3abb86bd34cf4d52698f14c0da1dc60
```

### Crack script

To see a full-fledged example, you may run the `crack.sh` script:
```
./crack.sh
```
It cracks the archive called `open_me.zip` recursively and prints a descriptive output to the console. The first input file it uses is called `passwords.txt`.

Note that the script looks for the specific input file pattern in the inner archives, namely the structure should be the same on every level of the zipped folder (unless it is the last level where there is no input file).

## Analysis

You may find more info about the pipeline architecture and the solved problems in the [`report`](report/report.pdf) document.

The performance [`benchmarking`](benchmarking) was done as well.
