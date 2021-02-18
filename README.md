# nalu-build

Instructions to build Nalu and dependencies on Yellowstone/Armstrong.

1. Use `instructions.md'
2. Have removed all unused TPLs, including Hypre and SuperLU
3. Updated cmake to build without OpenSSL (not available on Armstrong)
4. Corrected `Trilinos_stable_release` dir name

### To-do
Put this in a bash script.

### files

`do-configNaluNonTracked` is the cmake file.

`NALU_install_local` is Hang's script (did not work on Yellowstone last tried).
