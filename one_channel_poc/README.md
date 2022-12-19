## Shared channel usage PoC

This code proofs that it is possible to use one unbound channel to deliver data streams from multiple producers that run in parallel on different cores to the single consumer. This pipeline does not lead to producer blocks or data loss.

### How to run it?

```
dune exec one_channel_poc
```

### What to expect?

You can find the following predefined settings in `bin/one_channel_poc.ml`:
```ocaml
let messages = 10
let threads = 30
```
After you run the project, you should see in the console stream of messages. Each message starts with either `aaa`, `bbb` or `ccc` with is the prefix of the group of producers (each group is run on a different domain). Each producer sends a message to the shared channel appending its id to the group prefix. After it sends a number of messages (== `messages` variable), it finished sending a message with `-exit` suffix. In each group the number of producers == `threads`. In other words, after the program is finished, you have to see `threads * 3 * (messages + 1)` messages (3 is the number of groups and we add 1 to messages because of the exit message). You will find `threads * (messages + 1)` messages containing each group prefix. Note that some lines of the output overlap because of the concurrent console writes.

You may find the example output in `output.txt` file. 


### Proof

All the messages are delivered to the consumer so there is no data loss. Also, notice that `-exit` messages are shown very early. That proofs that producers are not blocked by send calls and they are finished independently of the consumer. In conclusion, usage of one shared unbound channel is suitable in parallel (and therefore concurrent) programs to deliver multiple streams of data from different producers to the one consumer.