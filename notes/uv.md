# libuv

- `libuv` is the implementation of an event loop implemented in C to be used in NodeJS. `luvit` is a wrapper around `libuv` for lua.

- It provides an event loop (`uv_loop_t`) which is executed in one single thread and drives callbacks.

- The event loop under the hood delegates to an OS construct to watch a series of file descriptors, on Linux it uses `epoll`.

- One of the core abstraction is a `uv_pipe`, which confusingly on Linux does not map to a pipe, but a unix socket. Those `uv_pipe` end up creating file descriptors that are monitored by the underlying `epoll`.

- `epoll` watches file descriptors, not PIDs. A process exiting is not an epoll event. Hence for processes related callbacks, you would use `uv_spawn` which before forking a child process would create a file descriptor through `signalfd` (which is a file descriptor from which you can read which signals were sent to the caller process) such that it can be read when the `SIGCHL` signal is delivered (this signal is delivered to a parent process when one of its child process completes). It then registers `wait` as a callback to the corresponding handle to cleanup that child process.

- Man page of `signalfd` for context:
  ```
  signalfd() creates a file descriptor that can be used to accept
  signals targeted at the caller.  This provides an alternative to
  the use of a signal handler or sigwaitinfo(2), and has the
  advantage that the file descriptor may be monitored by select(2),
  poll(2), and epoll(7).  
  ...

  read(2)
        If one or more of the signals specified in mask is pending
        for the process, then the buffer supplied to read(2) is
        used to return one or more signalfd_siginfo structures (see
        below) that describe the signals.  The read(2) returns
        information for as many signals as are pending and will fit
        in the supplied buffer.  The buffer must be at least
        sizeof(struct signalfd_siginfo) bytes.  The return value of
        the read(2) is the total number of bytes read.

        As a consequence of the read(2), the signals are consumed,
        so that they are no longer pending for the process (i.e.,
        will not be caught by signal handlers, and cannot be
        accepted using sigwaitinfo(2)).

        If none of the signals in mask is pending for the process,
        then the read(2) either blocks until one of the signals in
        mask is generated for the process, or fails with the error
        EAGAIN if the file descriptor has been made nonblocking.
  ```
  
## Side note on signal handling

- There is a syscall that allows to register the address of a function to jump to when a signal is delivered to that process

- When a signal is delivered to a process (from another process, or through hardware interrupt, etc.) the Kernel will add it to the process data structure

- The next time the kernel switches to that process, instead of
restoring the whole context of the process, it will set the ra (return address  register ) to `sigreturn` (another syscall) and jump to the handler. When the handler returns it will call `sigreturn` which will cause the Kernel to cleanup the stack frame and restore the old context.

- man `sigreturn` says it all:
  ```
  If the Linux kernel determines that an unblocked signal is
  pending for a process, then, at the next transition back to user
  mode in that process (e.g., upon return from a system call or
  when the process is rescheduled onto the CPU), it creates a new
  frame on the user-space stack where it saves various pieces of
  process context (processor status word, registers, signal mask,
  and signal stack settings).

  The kernel also arranges that, during the transition back to user
  mode, the signal handler is called, and that, upon return from
  the handler, control passes to a piece of user-space code
  commonly called the "signal trampoline".  The signal trampoline
  code in turn calls sigreturn().

  This sigreturn() call undoes everything that was done—changing
  the process's signal mask, switching signal stacks (see
  sigaltstack(2))—in order to invoke the signal handler.  Using the
  information that was earlier saved on the user-space stack
  sigreturn() restores the process's signal mask, switches stacks,
  and restores the process's context (processor flags and
  registers, including the stack pointer and instruction pointer),
  so that the process resumes execution at the point where it was
  interrupted by the signal.
  ```
