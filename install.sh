#!/bin/sh

echo export nalu_build_dir=$HOME/codes/nalu/build >> ~/.bashrc &&
echo export nalu_install_dir=$HOME/codes/nalu/install >> ~/.bashrc &&
echo export mpi_base_dir=/opt/ohpc/pub/compiler/intel-19/compilers_and_libraries/linux/mpi/intel64 >> ~/.bashrc &&
echo export boost_inc_dir=$nalu_install_dir/boost/1.68.0/include >> ~/.bashrc &&
echo export netcdf_install_dir=$nalu_install_dir/netcdf/4.7.4 >> ~/.bashrc &&
echo export hdf_install_dir=$nalu_install_dir/hdf5/1.10.6 >> ~/.bashrc &&
echo export pnetcdf_install_dir=$nalu_install_dir/pnetcdf/1.12.1 >> ~/.bashrc &&
echo export trilinos_install_dir=$nalu_install_dir/Trilinos_stable_release >> ~/.bashrc &&
echo export yaml_install_dir=$nalu_install_dir/yaml/0.6.2 >> ~/.bashrc &&
source ~/.bashrc &&

mkdir -p ~/codes/nalu/build;
mkdir -p ~/codes/nalu/install;
mkdir $nalu_build_dir/packages;

### CMake
cd $nalu_build_dir/packages &&
wget https://github.com/Kitware/CMake/releases/download/v3.17.0/cmake-3.17.0.tar.gz &&
tar -zxvf cmake-3.17.0.tar.gz &&
cd $nalu_build_dir/packages/cmake-3.17.0 &&
./configure --prefix=$nalu_install_dir/cmake/3.17.0 -- -DCMAKE_USE_OPENSSL=OFF &&
make && 
make install &&
echo 'export PATH=$HOME/codes/nalu/install/cmake/3.12.3/bin:$PATH' >> ~/.bashrc &&
source ~/.bashrc;

### Libxml2
cd $nalu_build_dir/packages &&
curl -o libxml2-2.9.2.tar.gz http://www.xmlsoft.org/sources/libxml2-2.9.2.tar.gz &&
tar -zxvf libxml2-2.9.2.tar.gz &&
cd $nalu_build_dir/packages/libxml2-2.9.2 &&
CC=mpicc CXX=mpicxx ./configure -without-python --prefix=$nalu_install_dir/libxml2/2.9.2 &&
make -j &&
make install;

### Boost
cd $nalu_build_dir/packages &&
curl -o boost_1_68_0.tar.gz http://iweb.dl.sourceforge.net/project/boost/boost/1.68.0/boost_1_68_0.tar.gz &&
tar -zxvf boost_1_68_0.tar.gz &&
mkdir -p $nalu_install_dir/boost/1.68.0 &&
cd $nalu_build_dir/packages/boost_1_68_0 &&
./bootstrap.sh --prefix=$nalu_install_dir/boost/1.68.0 --with-libraries=signals,regex,filesystem,system,mpi,serialization,thread,program_options,exception &&
echo 'using mpi : mpicxx ;' >> project-config.jam &&
./b2 -j 4 2>&1 | tee boost_build_one &&
./b2 -j 4 install 2>&1 | tee boost_build_install;

### YAML-CPP
cd $nalu_build_dir/packages &&
wget https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-0.6.2.tar.gz &&
tar -zxvf yaml-cpp-0.6.2.tar.gz &&
mv yaml-cpp-yaml-cpp-0.6.2 yaml-cpp &&
cd $nalu_build_dir/packages/yaml-cpp &&
mkdir build &&
cd build &&
cmake \
-DCMAKE_CXX_COMPILER=mpicxx \
-DCMAKE_CXX_FLAGS=-std=c++11 \
-DCMAKE_CC_COMPILER=mpicc \
-DCMAKE_INSTALL_PREFIX=$nalu_install_dir/yaml/0.6.2 .. &&
make -j &&
make install;

### Zlib
cd $nalu_build_dir/packages &&
curl -o zlib-1.2.11.tar.gz http://zlib.net/zlib-1.2.11.tar.gz &&
tar -zxvf zlib-1.2.11.tar.gz &&
cd $nalu_build_dir/packages/zlib-1.2.11 &&
CC=gcc CXX=g++ CFLAGS=-O3 CXXFLAGS=-O3 ./configure --prefix=$nalu_install_dir/zlib/1.2.11 &&
make -j &&
make install;

### HDF5
cd $nalu_build_dir/packages/ &&
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.6/src/hdf5-1.10.6.tar.gz &&
tar -zxvf hdf5-1.10.6.tar.gz &&
cd $nalu_build_dir/packages/hdf5-1.10.6 &&
./configure CC=mpicc FC=mpif90 CXX=mpicxx \
CXXFLAGS="-fPIC -O3" \
CFLAGS="-fPIC -O3" \
FCFLAGS="-fPIC -O3" \
--enable-parallel \
--with-zlib=$nalu_install_dir/zlib/1.2.11 \
--prefix=$nalu_install_dir/hdf5/1.10.6 &&
make -j &&
make install;

### PnetCDF
cd $nalu_build_dir/packages/ &&
wget http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.12.1.tar.gz &&
tar -zxvf parallel-netcdf-1.12.1.tar.gz &&
cd parallel-netcdf-1.12.1 &&
./configure \
--prefix=$nalu_install_dir/pnetcdf/1.12.1 \
CC=mpicc FC=mpif90 CXX=mpicxx \
CFLAGS="-I$nalu_install_dir/pnetcdf/1.12.1/include -O3" \
LDFLAGS=-L$nalu_install_dir/pnetcdf/1.12.1/lib \
--disable-fortran &&
make -j &&
make install;

### NetCDF
cd $nalu_build_dir/packages/ &&
curl -o netcdf-c-4.7.4.tar.gz https://codeload.github.com/Unidata/netcdf-c/tar.gz/v4.7.4 &&
tar -zxvf netcdf-c-4.7.4.tar.gz &&
cd netcdf-c-4.7.4/ &&
./configure \
--prefix=$nalu_install_dir/netcdf/4.7.4 \
CC=mpicc FC=mpif90 CXX=mpicxx \
CFLAGS="-I$nalu_install_dir/hdf5/1.10.6/include \
-I$nalu_install_dir/pnetcdf/1.12.1/include \
-O3" CPPFLAGS=${CFLAGS} LDFLAGS="-L$nalu_install_dir/hdf5/1.10.6/lib \
-L$nalu_install_dir/pnetcdf/1.12.1/lib -Wl, \
--rpath=$nalu_install_dir/hdf5/1.10.6/lib" \
--enable-pnetcdf \
--enable-parallel-tests \
--enable-netcdf-4 \
--disable-shared \
--disable-fsync \
--disable-cdmremote \
--disable-dap \
--disable-doxygen \
--disable-v2 &&
make &&
make install;
# (Hang) Note: make -j does not work

### Trilinos
cd $nalu_build_dir/packages/ &&
git clone https://github.com/trilinos/Trilinos.git &&
cd $nalu_build_dir/packages/Trilinos &&
git checkout develop &&
mkdir build &&
curl -o $nalu_build_dir/packages/Trilinos/build/do-configTrilinos_release https://raw.githubusercontent.com/NaluCFD/Nalu/master/build/do-configTrilinos_release &&
cd $nalu_build_dir/packages/Trilinos/build;
find . -name "CMakeFiles" -exec rm -rf {} \;
rm -f CMakeCache.txt &&
cmake \
-DCMAKE_INSTALL_PREFIX=$trilinos_install_dir \
-DTrilinos_ENABLE_CXX11=ON \
-DCMAKE_BUILD_TYPE=RELEASE \
-DTrilinos_ENABLE_EXPLICIT_INSTANTIATION:BOOL=ON \
-DTpetra_INST_DOUBLE:BOOL=ON \
-DTpetra_INST_INT_LONG:BOOL=ON \
-DTpetra_INST_INT_LONG_LONG:BOOL=OFF \
-DTpetra_INST_COMPLEX_DOUBLE=OFF \
-DTrilinos_ENABLE_TESTS:BOOL=OFF \
-DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF \
-DTrilinos_ALLOW_NO_PACKAGES:BOOL=OFF \
-DTPL_ENABLE_MPI=ON \
  -DMPI_BASE_DIR:PATH=$mpi_base_dir \
-DTPL_ENABLE_SuperLU=OFF \
-DTPL_ENABLE_Boost:BOOL=ON \
  -DBoost_INCLUDE_DIRS:PATH=$boost_inc_dir \
-DTrilinos_ENABLE_Epetra:BOOL=OFF \
-DTrilinos_ENABLE_Tpetra:BOOL=ON \
-DTrilinos_ENABLE_ML:BOOL=OFF \
-DTrilinos_ENABLE_MueLu:BOOL=ON \
-DTrilinos_ENABLE_EpetraExt:BOOL=OFF \
-DTrilinos_ENABLE_AztecOO:BOOL=OFF \
-DTrilinos_ENABLE_Belos:BOOL=ON \
-DTrilinos_ENABLE_Ifpack2:BOOL=ON \
-DTrilinos_ENABLE_Amesos2:BOOL=ON \
-DTrilinos_ENABLE_Zoltan2:BOOL=ON \
-DTrilinos_ENABLE_Ifpack:BOOL=OFF \
-DTrilinos_ENABLE_Amesos:BOOL=OFF \
-DTrilinos_ENABLE_Zoltan:BOOL=ON \
-DTrilinos_ENABLE_STKMesh:BOOL=ON \
-DTrilinos_ENABLE_STKSimd:BOOL=ON \
-DTrilinos_ENABLE_STKIO:BOOL=ON \
-DTrilinos_ENABLE_STKTransfer:BOOL=ON \
-DTrilinos_ENABLE_STKSearch:BOOL=ON \
-DTrilinos_ENABLE_STKUtil:BOOL=ON \
-DTrilinos_ENABLE_STKTopology:BOOL=ON \
-DTrilinos_ENABLE_STKBalance:BOOL=OFF \
-DTrilinos_ENABLE_STKUnit_tests:BOOL=OFF \
-DTrilinos_ENABLE_STKUnit_test_utils:BOOL=OFF \
-DTrilinos_ENABLE_Gtest:BOOL=ON \
-DTrilinos_ENABLE_SEACASExodus:BOOL=ON \
-DTrilinos_ENABLE_SEACASEpu:BOOL=ON \
-DTrilinos_ENABLE_SEACASExodiff:BOOL=ON \
-DTrilinos_ENABLE_SEACASNemspread:BOOL=ON \
-DTrilinos_ENABLE_SEACASNemslice:BOOL=ON \
-DTrilinos_ENABLE_SEACASIoss:BOOL=ON \
-DTPL_ENABLE_Netcdf:BOOL=ON \
-DNetCDF_ROOT:PATH=${netcdf_install_dir} \
-DHDF5_ROOT:PATH=${hdf_install_dir} \
-DHDF5_NO_SYSTEM_PATHS=ON \
-DPNetCDF_ROOT:PATH=${pnetcdf_install_dir} \
-DTrilinos_ASSERT_MISSING_PACKAGES=OFF \
../ &&
make -j &&
make install;

### Nalu
cd $nalu_build_dir &&
git clone https://github.com/NaluCFD/Nalu.git &&
cd $nalu_build_dir/Nalu &&
cd $nalu_build_dir/Nalu/build &&
find . -name "CMakeFiles" -exec rm -rf {} \; &&
rm -f CMakeCache.txt &&
cmake \
  -DTrilinos_DIR:PATH=$trilinos_install_dir \
  -DYAML_DIR:PATH=$yaml_install_dir \
  -DTIOGA_DIR:PATH=$tioga_install_dir \
  -DENABLE_INSTALL:BOOL=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DENABLE_TESTS:BOOL=ON \
  -DCMAKE_CXX_FLAGS:STRING="-Wall" \
  -DENABLE_TESTS:BOOL=ON \
  -DENABLE_HYPRE:BOOL=OFF \
  -DENABLE_TIOGA:BOOL=OFF \
../ &&
make -j;

### Fin
