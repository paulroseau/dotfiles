# Linker

- Source:
  - https://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html

- On GNU glibc-based systems, including all Linux systems, starting up an ELF
  binary executable automatically causes the program loader to be loaded and run.
  On Linux systems, this loader is named `/lib/ld-linux.so.X` (where X is a
  version number). This loader, in turn, finds and loads all other shared
  libraries used by the program.

- The list of directories to be searched is stored in the file `/etc/ld.so.conf`.
  Many Red Hat-derived distributions don't normally include `/usr/local/lib` in
  the file `/etc/ld.so.conf`. I consider this a bug, and adding `/usr/local/lib`
  to `/etc/ld.so.conf` is a common "fix" required to run many programs on Red
  Hat-derived systems.

- If you want to just override a few functions in a library, but keep the rest of
  the library, you can enter the names of overriding libraries (.o files) in
  `/etc/ld.so.preload`; these "preloading" libraries will take precedence over
  the standard set. This preloading file is typically used for emergency patches;
  a distribution usually won't include such a file when delivered.

- Searching all of these directories at program start-up would be grossly
  inefficient, so a caching arrangement is actually used. The program ldconfig(8)
  by default reads in the file `/etc/ld.so.conf`, sets up the appropriate
  symbolic links in the dynamic link directories (so they'll follow the standard
  conventions), and then writes a cache to `/etc/ld.so.cache` that's then used by
  other programs. This greatly speeds up access to libraries. The implication is
  that ldconfig must be run whenever a DLL is added, when a DLL is removed, or
  when the set of DLL directories changes; running ldconfig is often one of the
  steps performed by package managers when installing a library. On start-up,
  then, the dynamic loader actually uses the file `/etc/ld.so.cache` and then
  loads the libraries it needs.

- By the way, FreeBSD uses slightly different filenames for this cache. In
  FreeBSD, the ELF cache is `/var/run/ld-elf.so.hints` and the a.out cache is
  `/var/run/ld.so.hints`. These are still updated by `ldconfig(8)`, so this
  difference in location should only matter in a few exotic situations.
