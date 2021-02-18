The Nalu manual is located here:
https://github.com/NaluCFD/Nalu/blob/master/docs/source/user/build_manually.rst

Nalu GNU project instructions below:

Create build and install directory

```
mkdir -p ~/codes/nalu/build
mkdir -p ~/codes/nalu/install
echo export nalu_build_dir=$HOME/codes/nalu/build >> ~/.bashrc
echo export nalu_install_dir=$HOME/codes/nalu/install >> ~/.bashrc
source ~/.bashrc
mkdir $nalu_build_dir/packages

```

## CMake

```
cd $nalu_build_dir/packages
wget https://github.com/Kitware/CMake/releases/download/v3.17.0/cmake-3.17.0.tar.gz
tar -zxvf cmake-3.17.0.tar.gz
cd $nalu_build_dir/packages/cmake-3.17.0
./configure --prefix=$nalu_install_dir/cmake/3.17.0 -- -DCMAKE_USE_OPENSSL=OFF
make
make install
echo 'export PATH=$HOME/codes/nalu/install/cmake/3.12.3/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

## Libxml2

```
cd $nalu_build_dir/packages
curl -o libxml2-2.9.2.tar.gz http://www.xmlsoft.org/sources/libxml2-2.9.2.tar.gz
tar -zxvf libxml2-2.9.2.tar.gz
cd $nalu_build_dir/packages/libxml2-2.9.2
CC=mpicc CXX=mpicxx ./configure -without-python --prefix=$nalu_install_dir/libxml2/2.9.2
make
make install
```

## Boost

```
cd $nalu_build_dir/packages
curl -o boost_1_68_0.tar.gz http://iweb.dl.sourceforge.net/project/boost/boost/1.68.0/boost_1_68_0.tar.gz
tar -zxvf boost_1_68_0.tar.gz
mkdir -p $nalu_install_dir/boost/1.68.0
cd $nalu_build_dir/packages/boost_1_68_0
./bootstrap.sh --prefix=$nalu_install_dir/boost/1.68.0 --with-libraries=signals,regex,filesystem,system,mpi,serialization,thread,program_options,exception
echo 'using mpi : mpicxx ;' >> project-config.jam
./b2 -j 4 2>&1 | tee boost_build_one
./b2 -j 4 install 2>&1 | tee boost_build_install
```

## YAML-CPP

```
cd $nalu_build_dir/packages
wget https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-0.6.2.tar.gz
tar -zxvf yaml-cpp-0.6.2.tar.gz
mv yaml-cpp-yaml-cpp-0.6.2 yaml-cpp
cd $nalu_build_dir/packages/yaml-cpp
mkdir build
cd build
cmake -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_CXX_FLAGS=-std=c++11 -DCMAKE_CC_COMPILER=mpicc -DCMAKE_INSTALL_PREFIX=$nalu_install_dir/yaml/0.6.2 ..
make
make install
```

## Zlib

```
cd $nalu_build_dir/packages
curl -o zlib-1.2.11.tar.gz http://zlib.net/zlib-1.2.11.tar.gz
tar -zxvf zlib-1.2.11.tar.gz
cd $nalu_build_dir/packages/zlib-1.2.11
CC=gcc CXX=g++ CFLAGS=-O3 CXXFLAGS=-O3 ./configure --prefix=$nalu_install_dir/zlib/1.2.11
make
make install
```

## HDF5

```
cd $nalu_build_dir/packages/
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.6/src/hdf5-1.10.6.tar.gz
tar -zxvf hdf5-1.10.6.tar.gz
cd $nalu_build_dir/packages/hdf5-1.10.6
./configure CC=mpicc FC=mpif90 CXX=mpicxx CXXFLAGS="-fPIC -O3" CFLAGS="-fPIC -O3" FCFLAGS="-fPIC -O3" --enable-parallel --with-zlib=$nalu_install_dir/zlib/1.2.11 --prefix=$nalu_install_dir/hdf5/1.10.6
make
make install
```

## Parallel NetCDF
```
cd $nalu_build_dir/packages/
wget http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/pnetcdf-1.12.1.tar.gz
tar -zxvf pnetcdf-1.12.1.tar.gz
cd pnetcdf-1.12.1
./configure --prefix=$nalu_install_dir/pnetcdf/1.12.1 CC=mpicc FC=mpif90 CXX=mpicxx CFLAGS="-I$nalu_install_dir/pnetcdf/1.12.1/include -O3" LDFLAGS=-L$nalu_install_dir/pnetcdf/1.12.1/lib --disable-fortran
make
make install
```

## NetCDF
```
cd $nalu_build_dir/packages/
curl -o netcdf-c-4.7.4.tar.gz https://codeload.github.com/Unidata/netcdf-c/tar.gz/v4.7.4
tar -zxvf netcdf-c-4.7.4.tar.gz
cd netcdf-c-4.7.4/
./configure --prefix=$nalu_install_dir/netcdf/4.7.4 CC=mpicc FC=mpif90 CXX=mpicxx CFLAGS="-I$nalu_install_dir/hdf5/1.10.6/include -I$nalu_install_dir/pnetcdf/1.12.1/include -O3" CPPFLAGS=${CFLAGS} LDFLAGS="-L$nalu_install_dir/hdf5/1.10.6/lib -L$nalu_install_dir/pnetcdf/1.12.1/lib -Wl,--rpath=$nalu_install_dir/hdf5/1.10.6/lib" --enable-pnetcdf --enable-parallel-tests --enable-netcdf-4 --disable-shared --disable-fsync --disable-cdmremote --disable-dap --disable-doxygen --disable-v2
make -j 4
make install
```

# Trilinos
```
cd $nalu_build_dir/packages/
git clone https://github.com/trilinos/Trilinos.git
cd $nalu_build_dir/packages/Trilinos
git checkout develop
mkdir build
curl -o $nalu_build_dir/packages/Trilinos/build/do-configTrilinos_release https://raw.githubusercontent.com/NaluCFD/Nalu/master/build/do-configTrilinos_release
cd $nalu_build_dir/packages/Trilinos/build
```
Now edit do-configTrilinos_release to modify the paths so they point to the proper TPL $mpi_base_dir and $nalu_install_dir:

vi do-configTrilinos_release

mpi_base_dir=/opt/ohpc/pub/compiler/intel-19/compilers_and_libraries/linux/mpi/intel64
nalu_install_dir=$HOME/codes/nalu/install

chmod +x do-configTrilinos_release
./do-configTrilinos_release
make
make install

# Nalu
```
cd $nalu_build_dir
git clone https://github.com/NaluCFD/Nalu.git
cd $nalu_build_dir/Nalu
cd $nalu_build_dir/Nalu/build
cp do-configNalu_release do-configNaluNonTracked
```

Edit the paths at the top of the files by defining the nalu_install_dir variable:

vi do-configNaluNonTracked
```
nalu_install_dir=$HOME/codes/nalu/install
trilinos_install_dir=$nalu_install_dir/Trilinos_stable_release
yaml_install_dir=$nalu_install_dir/yaml/0.6.2
#tioga_install_dir=$nalu_install_dir/tioga
```

Within Nalu/build, execute the following commands:
```
./do-configNaluNonTracked
make
```
