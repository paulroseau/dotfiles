# Nix syntax

- To escape `$` in a multi-line string, you prefix it by '' (same characters as the ones used to open and close the multi-line string, confusing...):
  ```
  ''
  I need ''$10
  ''
  ```

# Bash syntax

- Bash reference for default variables: https://unix.stackexchange.com/questions/122845/using-a-b-for-variable-assignment-in-scripts/122848#122848 
  `"${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"` means if `LD_LIBRARY_PATH` is set, then print and substitute `":$LD_LIBRARY_PATH"`
