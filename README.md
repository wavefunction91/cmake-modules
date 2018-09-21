A collection of CMake files for commonly used HPC libraries which export targets for simple
dependency tracking and linking.

For example, consider a software which has to link to ParMETIS. ParMETIS has a linkage
dependency on METIS, which must also be installed. The traditional manner of handling
this would be to find both packages and handle the linkage separately,

```cmake
  find_package( METIS    )
  find_package( ParMETIS )

  include_directories( ${METIS_INCLUDE_DIR} )
  include_directories( ${PARMETIS_INCLUDE_DIR} )

  add_executable( test test.cxx )
  target_link_libraries( test ${PARMETIS_LIBRARIES} )
  target_link_libraries( test ${METIS_LIBRARIES} )
```
  

Here the order matters if linking statically, METIS must be linked *after*
ParMETIS. 


The included CMake files handle this is a more coherent manner through the use
of CMake targets. See [this article](https://pabloariasal.github.io/2018/02/19/its-time-to-do-cmake-right/)
for more details.

```cmake
  find_package( ParMETIS )

  add_executable( test test.cxx )
  target_link_libraries( test PatMETIS::parmetis )
```

This not only handles the dependency of ParMETIS on METIS, but also removes
the need to explicitly pass anything to `include_directories`. 
