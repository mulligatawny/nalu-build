#!/bin/sh
################################################################################
# THIS SCRIPT IS TO COMPILE NALU LOCALLY ON ME469 COURSE CLUSTER
# me469-login.stanford.edu
# THE ENVIRONMENT VARIABLES:
# nalu_build_dir and nalu_install_dir
# NEED TO BE ASSIGNED TO VALID LOCAL DIRECTORIES UNDER $HOME.
#
# Test environment:
# cmake 3.12.3, Intel19
################################################################################

# ==============================================================================
# THE FOLLOWING FUNCTION SHOULD BE ADDED TO "~/.bashrc" FILE
#
# function setup_nalu_local {
#     export I_MPI_CC=icc
#     export I_MPI_CXX=icpc
#     export I_MPI_F90=ifort
#     export I_MPI_F77=ifort
#     export nalu_build_dir=$HOME/codes/nalu/build
#     export nalu_install_dir=$HOME/codes/nalu/install
#     export superlu_dir=$nalu_install_dir/SuperLU_4.3
#     export libxml2_dir=$nalu_install_dir/libxml2/2.9.2
#     export boost_dir=$nalu_install_dir/boost/1.68.0
#     export yaml_cpp_dir=$nalu_install_dir/yaml/0.6.2
#     export zlib_dir=$nalu_install_dir/zlib/1.2.11
#     export hdf5_dir=$nalu_install_dir/hdf5/1.10.4
#     export pnetcdf_dir=$nalu_install_dir/pnetcdf/1.10.0
#     export netcdf_dir=$nalu_install_dir/netcdf/4.6.1
#     export trilinos_dir=$nalu_install_dir/Trilinos_stable_release
#     export mpi_base_dir=/opt/ohpc/pub/compiler/intel-19/compilers_and_libraries_2019.3.199/linux/mpi/intel64
# }
#
# THEN RELOAD THE "~/.bashrc" FILE BY
#     $ source ~/.bashrc
#
# BEFORE BUILDING NALU APPLICATION, LOAD ALL THE ENVIRONMENT VARIABLES
# USING THE FUNCTION ABOVE:
#     $ setup_nalu_local
# ==============================================================================

#################### DO NOT CHANGE THE SCRIPT BELOW ############################

###################
### Preparation ###
###################
mkdir -p $nalu_install_dir;
mkdir -p $nalu_build_dir/packages;



#######################
### Install SuperLU ###
#######################

### Preparations ####
cd $nalu_build_dir/packages &&
cp /opt/ohpc/pub/examples/superlu_4.3.tar.gz . &&
tar -zxvf superlu_4.3.tar.gz &&
cd $nalu_build_dir/packages/SuperLU_4.3;

### Configure makefile ###
touch make.inc &&
echo 'PLAT = _x86_64' >> make.inc &&
echo 'SuperLUroot	= $(superlu_dir)' >> make.inc &&
echo 'SUPERLULIB   	= $(SuperLUroot)/lib/libsuperlu_4.3.a' >> make.inc &&
echo 'BLASDEF 	= -DUSE_VENDOR_BLAS' >> make.inc &&
echo 'BLASLIB 	= -L/usr/lib -lblas' >> make.inc &&
echo 'TMGLIB       = libtmglib.a' >> make.inc &&
echo 'LIBS		   = $(SUPERLULIB) $(BLASLIB)' >> make.inc &&
echo 'ARCH         = ar' >> make.inc &&
echo 'ARCHFLAGS    = cr' >> make.inc &&
echo 'RANLIB       = ranlib' >> make.inc &&
echo 'CC           = mpiicc' >> make.inc &&
echo 'CFLAGS       = -O3' >> make.inc &&
echo 'NOOPTS       = ' >> make.inc &&
echo 'FORTRAN	   = mpiifort' >> make.inc &&
echo 'FFLAGS       = -O2' >> make.inc &&
echo 'LOADER       = $(CC)' >> make.inc &&
echo 'LOADOPTS     = ' >> make.inc &&
echo 'CDEFS        = -DAdd_' >> make.inc &&
echo 'MATLAB	   = /usr/sww/matlab' >> make.inc &&
echo '' >> make.inc;

### Compile SuperLU ###
mkdir -p $superlu_dir/lib &&
mkdir -p $superlu_dir/include &&
cd $nalu_build_dir/packages/SuperLU_4.3 &&
make &&
cp SRC/*.h $superlu_dir/include;



#######################
### Install Libxml2 ###
#######################
cd $nalu_build_dir/packages &&
curl -o libxml2-2.9.2.tar.gz http://www.xmlsoft.org/sources/libxml2-2.9.2.tar.gz &&
tar -zxvf libxml2-2.9.2.tar.gz &&
cd $nalu_build_dir/packages/libxml2-2.9.2 &&
CC=mpiicc CXX=mpiicpc ./configure -without-python --prefix=$libxml2_dir &&
make -j &&
make install;


#####################
### Install Boost ###
#####################
cd $nalu_build_dir/packages &&
curl -o boost_1_68_0.tar.gz http://iweb.dl.sourceforge.net/project/boost/boost/1.68.0/boost_1_68_0.tar.gz &&
tar -zxvf boost_1_68_0.tar.gz &&
mkdir -p $boost_dir;

cd $nalu_build_dir/packages/boost_1_68_0 &&
./bootstrap.sh \
 --prefix=$boost_dir \
 --with-toolset=intel-linux \
 --with-libraries=signals,regex,filesystem,system,mpi,serialization,thread,program_options,exception &&
echo 'using mpi : mpiicpc ;' >> project-config.jam &&
./b2 -j 4 2>&1 | tee boost_build_one &&
./b2 -j 4 install 2>&1 | tee boost_build_install;


########################
### Install YAML-CPP ###
########################
cd $nalu_build_dir/packages &&
wget https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-0.6.2.tar.gz &&
tar -zxvf yaml-cpp-0.6.2.tar.gz &&
mv yaml-cpp-yaml-cpp-0.6.2 yaml-cpp;

cd $nalu_build_dir/packages/yaml-cpp &&
mkdir build &&
cd build &&
cmake \
-DCMAKE_CXX_COMPILER=mpiicpc \
-DCMAKE_CXX_FLAGS=-std=c++11 \
-DCMAKE_CC_COMPILER=mpiicc \
-DCMAKE_INSTALL_PREFIX=$yaml_cpp_dir \
.. &&
make -j &&
make install;


####################
### Install Zlib ###
####################
cd $nalu_build_dir/packages &&
curl -o zlib-1.2.11.tar.gz http://zlib.net/zlib-1.2.11.tar.gz &&
tar -zxvf zlib-1.2.11.tar.gz &&
cd $nalu_build_dir/packages/zlib-1.2.11 &&
CC=mpicc CXX=mpiicpc CFLAGS=-O3 CXXFLAGS=-O3 ./configure --prefix=$zlib_dir &&
make -j &&
make install;


####################
### Install HDF5 ###
####################
cd $nalu_build_dir/packages/ &&
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.4/src/hdf5-1.10.4.tar.gz &&
tar -zxvf hdf5-1.10.4.tar.gz &&
cd $nalu_build_dir/packages/hdf5-1.10.4 &&
./configure CC=mpiicc FC=mpiifort CXX=mpiicpc \
CXXFLAGS="-fPIC -O3" \
CFLAGS="-fPIC -O3" \
FCFLAGS="-fPIC -O3" \
--enable-parallel \
--with-zlib=$zlib_dir \
--prefix=$hdf5_dir &&
make -j &&
make install;




###############################
### Install Parallel NetCDF ###
###############################
cd $nalu_build_dir/packages/ &&
wget http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.10.0.tar.gz &&
tar -zxvf parallel-netcdf-1.10.0.tar.gz &&
cd $nalu_build_dir/packages/parallel-netcdf-1.10.0 &&
./configure \
--prefix=$pnetcdf_dir \
CC=mpiicc FC=mpiifort CXX=mpiicpc \
CFLAGS="-I$pnetcdf_dir/include -O3" \
LDFLAGS=-L$pnetcdf_dir/lib \
--disable-fortran &&
make -j &&
make install;



######################
### Install NetCDF ###
######################
cd $nalu_build_dir/packages/ &&
curl -o netcdf-c-4.6.1.tar.gz https://codeload.github.com/Unidata/netcdf-c/tar.gz/v4.6.1 &&
tar -zxvf netcdf-c-4.6.1.tar.gz &&
cd netcdf-c-4.6.1/ &&
./configure \
--prefix=$netcdf_dir \
CC=mpiicc FC=mpiifort CXX=mpiicpc \
CFLAGS="-I$hdf5_dir/include \
-I$pnetcdf_dir/include \
-O3" CPPFLAGS=${CFLAGS} LDFLAGS="-L$hdf5_dir/lib \
-L$pnetcdf_dir/lib -Wl,\
--rpath=$hdf5_dir/lib" \
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
# Note: make -j does not work!!!



########################
### Install Trilinos ###
########################
cd $nalu_build_dir/packages/ &&
git clone https://github.com/trilinos/Trilinos.git &&
cd $nalu_build_dir/packages/Trilinos &&
git checkout develop &&
git checkout 4442eef9d9a9e670a5fb6eea5be8972cf0a4a3f1 &&
mkdir build &&
cd build &&
cmake \
-DCMAKE_INSTALL_PREFIX=$trilinos_dir \
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
-DTPL_ENABLE_SuperLU=ON \
-DSuperLU_INCLUDE_DIRS:PATH=$superlu_dir/include \
-DSuperLU_LIBRARY_DIRS:PATH=$superlu_dir/lib \
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
-DTPL_ENABLE_BoostLib:BOOL=ON \
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
-DNetCDF_ROOT:PATH=${netcdf_dir} \
-DHDF5_ROOT:PATH=${hdf5_dir} \
-DHDF5_NO_SYSTEM_PATHS=ON \
-DPNetCDF_ROOT:PATH=${pnetcdf_dir} \
-DZlib_ROOT:PATH=${zlib_dir} \
-DBoostLib_INCLUDE_DIRS:PATH="$boost_dir/include" \
-DBoostLib_LIBRARY_DIRS:PATH="$boost_dir/lib" \
-DTrilinos_ASSERT_MISSING_PACKAGES=OFF \
../ &&
make -j &&
make install;



####################
### Install NALU ###
####################
cd $nalu_install_dir &&
git clone https://github.com/NaluCFD/Nalu.git &&
cd Nalu/build &&
git checkout 4c93d0388d49f33835a6c24ede45c46d542383d7 &&
find . -name "CMakeFiles" -exec rm -rf {} \; &&
rm -f CMakeCache.txt &&
cmake \
-DTrilinos_DIR:PATH=$trilinos_dir \
-DYAML_DIR:PATH=$yaml_cpp_dir \
-DENABLE_INSTALL:BOOL=OFF \
-DCMAKE_BUILD_TYPE=RELEASE \
-DENABLE_TESTS:BOOL=OFF \
-DCMAKE_CXX_FLAGS:STRING="-Wall" \
-DENABLE_TESTS:BOOL=OFF \
-DENABLE_HYPRE:BOOL=OFF \
-DENABLE_TIOGA:BOOL=OFF \
../ &&
make -j;


### THE END ###
