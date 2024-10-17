export def create_lockfile []: nothing -> path {
  let lockfile: path = (mktemp)
  rm --permanent $lockfile
  $lockfile
}

# wait util a lock is unlocked and then lock it
export def await_lock [lockfile: path]: nothing -> nothing {
  loop {
    try {
      "" | save $lockfile
      return
    }
  }
}

export def unlock [lockfile: path]: nothing -> nothing {
  rm --permanent $lockfile
}

export def is_locked [lockfile: path]: nothing -> bool {
  $lockfile | path exists
}

# await_lock, do $codeblock, unlock, rethrow errors
export def with_lock [lockfile: path, codeblock]: nothing -> nothing {
  await_lock $lockfile
  try {
    do $codeblock
  } catch {|err|
    unlock $lockfile
    $err.raw  # rethrow error
  }
  unlock $lockfile
}
