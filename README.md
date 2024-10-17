# Nagoya

A multithreading helper library for nushell.

The goal here is not to recreate [tokio][], but to create smaller-scale
helpers like [locking][def_lock] and message-channel systems.

[numng][] package name: `jan9103/nagoya`.


## Documentation

The documentation is formatted as usage-examples with additional
information were needed.

<!------------------------------------------------------------------>

<details><summary><h3>Lock</h3></summary>

A filebased [lock][def_lock], which can be shared across threads.

```nu
# import library
use nagoya/lock.nu *

# select a lockfile-path (`mktemp` + delete)
let lockfile: path = (create_lockfile)

# wait until the lock is released, and then lock it
await_lock $lockfile

do_something

# release the lock
unlock $lockfile

# await_lock, run the code, unlock
# but with handling for errors, etc
with_lock $lockfile {
  do_something
}
```

</details>

<!------------------------------------------------------------------>

<details><summary><h3>FGQ: Fifo Global Queue</h3></summary>

A filebased cross-thread [queue][def_queue] with [locking][def_lock].

```nu
# import library
use nagoya/fgq.nu

# create a fgq-que
let que: path = (fgq create)

fgq push $que {"name": "alice"}
fgq push_all $que [{"name": "bob"}, {"name": "eve"}, {"name": "mallory"}]

loop {
  let value = (fgq pop $que)
  if $value == null { break }  # que is (currently) empty
  print $"Hello, ($value.name)!"
}

# delete the que when we no longer need it
fgq delete $que
```

</details>

<!------------------------------------------------------------------>

[tokio]: https://github.com/tokio-rs/tokio
[def_lock]: https://en.wikipedia.org/wiki/Lock_%28computer_science%29
[def_queue]: https://en.wikipedia.org/wiki/Queue_%28abstract_data_type%29
[numng]: https://github.com/Jan9103/numng
