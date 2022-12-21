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

if [ ! -z "$2" ]
then
  GROUPS_DIFF="$2"
else
  GROUPS_DIFF=-1
fi

TIME=$(date "+%Y.%m.%d_%H.%M.%S")

hyperfine --warmup 5 \
  "./$EXECUTABLE $PASSWORDS_FILE 1 $GROUPS_DIFF" \
  "./$EXECUTABLE $PASSWORDS_FILE 2 $GROUPS_DIFF" \
  "./$EXECUTABLE $PASSWORDS_FILE 3 $GROUPS_DIFF" \
  "./$EXECUTABLE $PASSWORDS_FILE 4 $GROUPS_DIFF" \
  "./$EXECUTABLE $PASSWORDS_FILE 5 $GROUPS_DIFF" \
  "./$EXECUTABLE $PASSWORDS_FILE 6 $GROUPS_DIFF" \
  "./$EXECUTABLE $PASSWORDS_FILE 8 $GROUPS_DIFF" \
  "./$EXECUTABLE $PASSWORDS_FILE 10 $GROUPS_DIFF" \
  "./$EXECUTABLE $PASSWORDS_FILE 12 $GROUPS_DIFF" \
  "./$EXECUTABLE $PASSWORDS_FILE 14 $GROUPS_DIFF" \
  "./$EXECUTABLE $PASSWORDS_FILE 16 $GROUPS_DIFF" \
  "./$EXECUTABLE $PASSWORDS_FILE 20 $GROUPS_DIFF" \
  --export-json benchmark_$TIME.json \
  --export-markdown benchmark_$TIME.md
