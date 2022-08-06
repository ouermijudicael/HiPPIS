# HiPPIS
HiPPIS is a polynomial-based data-bounded and positivity-preserving interpolation software for function approximation and mapping data values between meshes.


## Getting Started

### Dependencies

* Matlab is required for the version of the software implemented in Matlab. No special toolboxes are required.
  The core files used for the implementation of the data-bounded and positivity-preserving interpolation methods are
```
  Matlab
  |  adaptiveInterpolation1D.m
  |  adaptiveInterpolation2D.m
  |  adaptiveInterpolation3D.m
  |  divdiff.m
  |  newtonPolyVal.m
```
  The remaining folders and files in the folder *Matlab* are drivers, examples, data, and scripts for using the data-bounded and positivity interpolation methods.
* The Fortran version requires the installation of Intel (ifort), or gnu (gfortran) compilers with OpenMP4.
  The vectorized version of the code required the use of Intel compilers. 
  The Make files can be modified for different compilers including Intel, gnu, HPE cray.
  The core file used for the implementation of the data-bounded and positivity-preserving interpolation methods is
```
  Fortran
  |  Mapping
  |  |  mod_adaptiveInterpolation.F90
  The remaining folders and files in the folder *Fortran* are drivers, examples, data, and scripts for using the data-bounded and positivity interpolation methods.
```

### Installing
* Downloading HiPPIS (Matlab and/or Fortran) is sufficient for installation. 

### Executing program
* Fortran
```
cd Fortran/Mapping/
make 
./tutorial
``` 
* Matlab
Open Matlab and run the script *tutorial.m* in folder *Matlab*.
```
 tutorial
```

### Help

The file *tutorial.m* (in *Matlab*)or *tutorial.F90* (in *Fortran/Mapping*) is a good place to start. 
*tutorial.m* or *tutorial.F90* provides simple examples showing how to use HiPPIS with 1D, 2D, and 3D structured tensor product meshes.

## Manuscript Examples
More examples can be found in */Matlab/main.m* or */Fortran/Mapping/main.F90*.
These examples are used to produce the results presented in a manuscript submitted for publication that is entitled "HiPPIS:A High-Order Positivity-Preserving Mapping Software for Structured Meshes". 

## Testting
