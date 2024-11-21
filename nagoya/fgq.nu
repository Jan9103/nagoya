use ./lock.nu *

export def create []: nothing -> path {
  let fgq: path = (mktemp --directory)
  "" | save ($fgq | path join "a.txt")
  return $fgq
}

export def delete [fgq: path]: nothing -> nothing {
  await_lock ($fgq | path join "lock.txt")
  rm --permanent --force --recursive $fgq
}

export def push [fgq: path, value: any]: nothing -> nothing {
  let fifo_file: path = ($fgq | path join "a.txt")
  let c: string = (($value | to nuon --raw) + "\n")

  let lockfile: path = ($fgq | path join "lock.txt")
  await_lock $lockfile
  $c | save --append $fifo_file
  unlock $lockfile
}

export def push_all [fgq: path, values: list<any>]: nothing -> nothing {
  let fifo_file: path = ($fgq | path join "a.txt")
  let c: string = (
    $values
    | each {|i| ($i | to nuon --raw) + "\n"}
    | str join ''  # not "\n" here since we want a trailing one
  )

  let lockfile: path = ($fgq | path join "lock.txt")
  await_lock $lockfile
  $c | save --append $fifo_file
  unlock $lockfile
}

# returns the next entry from the que and removes it
# returns null if its currently empty
export def pop [fgq: path]: nothing -> any {
  let fifo_file: path = ($fgq | path join "a.txt")

  let lockfile: path = ($fgq | path join "lock.txt")
  await_lock $lockfile
  let lines: list<string> = (open --raw $fifo_file | lines)
  $lines
  | range 1..
  | str join "\n"
  | save --force $fifo_file
  unlock $lockfile

  if ($lines | length) < 1 {return null}
  if ($lines | first) == "" {return null}
  return ($lines | first | from nuon)
}

# returns a list of all entries and removes them from the que
export def pop_all [fgq: path]: nothing -> list<any> {
  let fifo_file: path = ($fgq | path join "a.txt")

  let lockfile: path = ($fgq | path join "lock.txt")
  await_lock $lockfile
  let raw = (open --raw $fifo_file)
  "" | save --force $fifo_file
  unlock $lockfile
  $raw | lines | each {|i| $i | from nuon}
}
