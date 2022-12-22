# Benchmarking

The command-line tool [`hyperfine`](https://github.com/sharkdp/hyperfine) is used to benchmark the program. Install it if you would like to run the following script yourself.

Script `benchmark.sh` automatically performs a benchmarking of the program using different parallelism setups.

To run a simple (not very accurate) benchmark:
```
./benchmark.sh
```

The more accurate benchmark that takes time (1h on my machine):
```
./benchmark.sh passwords_bench_long.txt
```

## Results

The following results are obtained on the machine with AMD Ryzen 5800H (3.2 GHz - 4.4 GHz, 8 cores / 16 threads) and 16 GB of RAM:

| Command | Mean [s] | Min [s] | Max [s] | Relative |
|:---|---:|---:|---:|---:|
| `./password_finder.exe passwords_bench_long.txt 1` | 127.338 ± 6.511 | 115.937 | 138.516 | 8.34 ± 0.63 |
| `./password_finder.exe passwords_bench_long.txt 2` | 140.442 ± 13.576 | 110.433 | 154.860 | 9.20 ± 1.03 |
| `./password_finder.exe passwords_bench_long.txt 4` | 44.231 ± 3.321 | 40.215 | 49.686 | 2.90 ± 0.27 |
| `./password_finder.exe passwords_bench_long.txt 8` | 21.294 ± 0.795 | 20.286 | 22.841 | 1.40 ± 0.09 |
| `./password_finder.exe passwords_bench_long.txt 16` | 15.261 ± 0.854 | 14.702 | 17.551 | 1.00 |
