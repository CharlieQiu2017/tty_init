# Simple program for initializing TTY

When using busybox as userspace, one frequently encounters the following message:

```text
sh: can't access tty: job control turned off
```

In most cases this is not an issue. However it prevents one from sending Ctrl-C signals to programs, which can be annoying.

## The Root Cause

Under Linux (and POSIX systems in general, see https://pubs.opengroup.org/onlinepubs/9799919799/functions/setsid.html), each TTY device is bound to a *session*.
The TTY is called the *controlling TTY* of the session.
Each session may contain one or more *process groups*. A process group is a group of processes that may use the TTY simultaneously.
The current process group using the TTY is called the *process group leader*.

When Linux boots up, the I/O interface allocated to the `init` process is `/dev/console`. However this cannot be the controlling TTY of a session.
It lacks many features of a proper TTY. This results in the error message shown by `sh`.

## The Solution

The `init` process should open another TTY device, create a session by calling `setsid()`, and bound the TTY device to this session.

We implement a minimal program `tty_init` to perform this sequence. It is intended to be built against my minimal C library (https://github.com/CharlieQiu2017/mini_libc).
