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
  PASSWORDS_FILE=passwords-bench2.txt
fi

TIME=$(date "+%Y.%m.%d_%H.%M.%S")

hyperfine --warmup 5 \
  "./$EXECUTABLE $PASSWORDS_FILE 1" \
  "./$EXECUTABLE $PASSWORDS_FILE 2" \
  "./$EXECUTABLE $PASSWORDS_FILE 3" \
  "./$EXECUTABLE $PASSWORDS_FILE 4" \
  "./$EXECUTABLE $PASSWORDS_FILE 5" \
  "./$EXECUTABLE $PASSWORDS_FILE 6" \
  "./$EXECUTABLE $PASSWORDS_FILE 8" \
  "./$EXECUTABLE $PASSWORDS_FILE 10" \
  "./$EXECUTABLE $PASSWORDS_FILE 12" \
  "./$EXECUTABLE $PASSWORDS_FILE 14" \
  "./$EXECUTABLE $PASSWORDS_FILE 16" \
  "./$EXECUTABLE $PASSWORDS_FILE 20" \
  --export-json benchmark_$TIME.json \
  --export-markdown benchmark_$TIME.md
