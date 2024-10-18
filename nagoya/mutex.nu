use ./lock.nu *

const DATA_FILE_NAME: string = "a.nuon"
const LOCK_FILE_NAME: string = "lock.txt"

export def new [initial_value: any]: nothing -> path {
  let mutex: path = (mktemp --directory)
  $initial_value | to nuon --raw | save --raw ($mutex | path join $DATA_FILE_NAME)
  return $mutex
}

export def get [mutex: path]: nothing -> any {
  let lockfile: path = ($mutex | path join $LOCK_FILE_NAME)
  let datafile: path = ($mutex | path join $DATA_FILE_NAME)
  await_lock $lockfile
  let raw: string = (open --raw $datafile)
  unlock $lockfile
  return ($raw | from nuon)
}

export def set [mutex: path, new_value: any]: nothing -> nothing {
  let lockfile: path = ($mutex | path join $LOCK_FILE_NAME)
  let datafile: path = ($mutex | path join $DATA_FILE_NAME)
  let new_value = ($new_value | to nuon --raw)
  await_lock $lockfile
  $new_value | save --raw $datafile
  unlock $lockfile
}

# keep a lock on the mutex while changing its value.
# Example:
#   mutex change $mutex {|data| $data | sort-by name}
export def change [
  mutex: path
  code  # a closure, which accepts one argument (current value) and returns the new value
]: nothing -> nothing {
  let lockfile: path = ($mutex | path join $LOCK_FILE_NAME)
  let datafile: path = ($mutex | path join $DATA_FILE_NAME)
  await_lock $lockfile
  let data = (open --raw $datafile | from nuon)  # ensure its not streaming
  try {
    do $code $data
    | save --raw $datafile
  } catch {|err|
    unlock $lockfile
    $err.raw  # rethrow error
  }
  unlock $lockfile
}

export def delete [mutex: path]: nothing -> nothing {
  await_lock ($mutex | path join $LOCK_FILE_NAME)
  rm --permanent --recursive --force $mutex
}
