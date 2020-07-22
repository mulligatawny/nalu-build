While running the `make` in `/path/to/Nalu/build/`, if the following error is seen:

```
/lib/../lib64/liblapack.so: undefined reference to `_gfortran_transfer_character_write@GFORTRAN_1.4'
/lib/../lib64/liblapack.so: undefined reference to `_gfortran_transfer_integer_write@GFORTRAN_1.4'
make[2]: *** [naluX] Error 1
make[1]: *** [CMakeFiles/naluX.dir/all] Error 2
make: *** [all] Error 2
```

set the following environment variables:

```
export trilinos_install_dir=/home/iaccarino/markben/codes/nalu/install/Trilinos_stable_release
export yaml_install_dir=$nalu_install_dir/yaml/0.6.2
```

beforehand.

----

If a new file is added to the source, run make clean, then cmake (the do-configNaluNonTracked file) and make. The file will be indexed by cmake.
