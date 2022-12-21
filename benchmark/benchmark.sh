# build fresh .exe
BENCH_FOLDER=$PWD
EXECUTABLE=password_finder.exe
cd ..
dune build
cp $EXECUTABLE $BENCH_FOLDER
cd $BENCH_FOLDER

if [ ! -z "$1" ]
then
  PASSWORDS_FILE="$1"
else
  PASSWORDS_FILE=passwords-bench.txt
fi

TIME=$(date "+%Y.%m.%d_%H.%M.%S")

hyperfine --warmup 5 \
  "./$EXECUTABLE $PASSWORDS_FILE 1" \
  "./$EXECUTABLE $PASSWORDS_FILE 2" \
  "./$EXECUTABLE $PASSWORDS_FILE 4" \
  "./$EXECUTABLE $PASSWORDS_FILE 8" \
  "./$EXECUTABLE $PASSWORDS_FILE 16" \
  --export-json benchmark_$TIME.json \
  --export-markdown benchmark_$TIME.md