#    FindIntelMKL.cmake
#
#    Finds Intel(R) MKL and exports its linkange as
#    CMake TARGETS
#
#    This module is meant to serve as part of FindLinAlg.
#    It can also be used by itself.
#
#    The module will define the following variables:
#    
#      IntelMKL_FOUND       - Found MKL installation
#      IntelMKL_INCLUDE_DIR - Location of MKL headers (mkl.h)
#      IntelMKL_LIBRARIES   - MKL libraries
#
#    This module will export the following CMake TARGETS if possible
#
#      IntelMKL::mkl
#      IntelMKL::lp64_sequential
#      IntelMKL::lp64_openmp_intel
#      IntelMKL::lp64_openmp_gnu
#      IntelMKL::lp64_openmp_pgi
#      IntekMKL::lp64_tbb
#      IntelMKL::ilp64_sequential
#      IntelMKL::ilp64_openmp_intel
#      IntelMKL::ilp64_openmp_gnu
#      IntelMKL::ilp64_openmp_pgi
#      IntekMKL::ilp64_tbb
#
#      intelmkl_PREFERS_STATIC          - default ON
#      intelmkl_PREFERS_ILP64           - default OFF
#      intelmkl_PREFERED_THREAD_LEVEL   - ( sequential, openmp, tbb ) default: openmp
#      intelmkl_PREFERED_THREAD_LIBRARY - ( intel, gnu, pgi )         default: depends on compiler

# MKL lib names
if( intelmkl_PREFERS_STATIC )
  set( intelmkl_LP64_LIBRARY_NAME       "libmkl_intel_lp64.a"   )
  set( intelmkl_ILP64_LIBRARY_NAME      "libmkl_intel_ilp64.a"  )
  set( intelmkl_SEQUENTIAL_LIBRARY_NAME "libmkl_sequential.a"   )
  set( intelmkl_OMP_INTEL_LIBRARY_NAME  "libmkl_intel_thread.a" )
  set( intelmkl_OMP_GNU_LIBRARY_NAME    "libmkl_gnu_thread.a"   )
  set( intelmkl_OMP_PGI_LIBRARY_NAME    "libmkl_pgi_thread.a"   )
  set( intelmkl_TBB_LIBRARY_NAME        "libmkl_tbb_thread.a"   )
  set( intelmkl_CORE_LIBRARY_NAME       "libmkl_core.a"         )
else()
  set( intelmkl_LP64_LIBRARY_NAME       "mkl_intel_lp64"   )
  set( intelmkl_ILP64_LIBRARY_NAME      "mkl_intel_ilp64"  )
  set( intelmkl_SEQUENTIAL_LIBRARY_NAME "mkl_sequential"   )
  set( intelmkl_OMP_INTEL_LIBRARY_NAME  "mkl_intel_thread" )
  set( intelmkl_OMP_GNU_LIBRARY_NAME    "mkl_gnu_thread"   )
  set( intelmkl_OMP_PGI_LIBRARY_NAME    "mkl_pgi_thread"   )
  set( intelmkl_TBB_LIBRARY_NAME        "mkl_tbb_thread"   )
  set( intelmkl_CORE_LIBRARY_NAME       "mkl_core"         )
endif()


# Defaults
if( NOT intelmkl_PREFERED_THREAD_LEVEL )
  set( intelmkl_PREFERED_THREAD_LEVEL "openmp" )
endif()

# MKL Library
if( intelmkl_PREFERS_ILP64 )
  set( IntelMKL_COMPILE_DEFINITIONS "MKL_ILP64" )
  if( CMAKE_C_COMPILER_ID MATCHES "GNU" )
    set( IntelMKL_C_COMPILE_FLAGS        "-m64" )
    set( IntelMKL_Fortran_COMPILE_FLAGS  "-m64" "-fdefault-integer-8" )
  elseif( CMAKE_C_COMPILER_ID MATCHES "PGI" )
    set( IntelMKL_Fortran_COMPILE_FLAGS "-i8" )
  endif()
  set( intelmkl_LIBRARY_NAME ${intelmkl_ILP64_LIBRARY_NAME} )
else()
  set( intelmkl_LIBRARY_NAME ${intelmkl_LP64_LIBRARY_NAME} )
endif()

# MKL Threads
if( intelmkl_PREFERED_THREAD_LEVEL MATCHES "sequential" )
  set( intelmkl_THREAD_LIBRARY_NAME ${intelmkl_SEQUENTIAL_LIBRARY_NAME} )
elseif( intelmkl_PREFERED_THREAD_LEVEL MATCHES "tbb" )
  set( intelmkl_THREAD_LIBRARY_NAME ${intelmkl_TBB_LIBRARY_NAME} )
else()
  if( CMAKE_C_COMPILER_ID MATCHES "Intel" )
    set( intelmkl_THREAD_LIBRARY_NAME ${intelmkl_OMP_INTEL_LIBRARY_NAME} )
  elseif( CMAKE_C_COMPILER_ID MATCHES "PGI" )
    set( intelmkl_THREAD_LIBRARY_NAME ${intelmkl_OMP_PGI_LIBRARY_NAME} )
  else()
    set( intelmkl_THREAD_LIBRARY_NAME ${intelmkl_OMP_GNU_LIBRARY_NAME} )
  endif()
endif()

find_path( intelmkl_INCLUDE_DIR
  NAMES mkl.h
  HINTS ${intelmkl_PREFIX}
  PATHS ${intelmkl_INCLUDE_DIR}
  PATH_SUFFIXES include
  DOC "Intel(R) MKL header"
)

find_library( intelmkl_LIBRARY
  NAMES ${intelmkl_LIBRARY_NAME}
  HINTS ${intelmkl_PREFIX}
  PATHS ${intelmkl_LIBRARY_DIR}
  PATH_SUFFIXES lib/intel64 lib/ia32
  DOC "Intel(R) MKL Library"
)

find_library( intelmkl_THREAD_LIBRARY
  NAMES ${intelmkl_THREAD_LIBRARY_NAME}
  HINTS ${intelmkl_PREFIX}
  PATHS ${intelmkl_LIBRARY_DIR}
  PATH_SUFFIXES lib/intel64 lib/ia32
  DOC "Intel(R) MKL THREAD Library"
)

find_library( intelmkl_CORE_LIBRARY
  NAMES ${intelmkl_CORE_LIBRARY_NAME}
  HINTS ${intelmkl_PREFIX}
  PATHS ${intelmkl_LIBRARY_DIR}
  PATH_SUFFIXES lib/intel64 lib/ia32
  DOC "Intel(R) MKL CORE Library"
)


# Check version
if( EXISTS ${intelmkl_INCLUDE_DIR}/mkl_version.h )
  set( version_pattern 
  "^#define[\t ]+__INTEL_MKL(|_MINOR|_UPDATE)__[\t ]+([0-9\\.]+)$"
  )
  file( STRINGS ${intelmkl_INCLUDE_DIR}/mkl_version.h mkl_version
        REGEX ${version_pattern} )

  foreach( match ${mkl_version} )
  
    if(IntelMKL_VERSION_STRING)
      set(IntelMKL_VERSION_STRING "${IntelMKL_VERSION_STRING}.")
    endif()
  
    string(REGEX REPLACE ${version_pattern} 
      "${IntelMKL_VERSION_STRING}\\2" 
      IntelMKL_VERSION_STRING ${match}
    )
  
    set(IntelMKL_VERSION_${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
  
  endforeach()
  
  unset( mkl_version )
  unset( version_pattern )
endif()



if( intelmkl_INCLUDE_DIR )
  set( IntelMKL_INCLUDE_DIR ${intelmkl_INCLUDE_DIR} )
endif()



if( intelmkl_LIBRARY AND intelmkl_THREAD_LIBRARY AND intelmkl_CORE_LIBRARY )
  if( intelmkl_PREFERS_STATIC )
    set( IntelMKL_LIBRARIES "-Wl,--start-group" ${intelmkl_LIBRARY} ${intelmkl_THREAD_LIBRARY} ${intelmkl_CORE_LIBRARY} "-Wl,--end-group" )
  else()
    set( IntelMKL_LIBRARIES "-Wl,--no-as-needed" ${intelmkl_LIBRARY} ${intelmkl_THREAD_LIBRARY} ${intelmkl_CORE_LIBRARY} )
  endif()

  set( IntelMKL_LIBRARIES ${IntelMKL_LIBRARIES} "m" )
  if( intelmkl_PREFERED_THREAD_LEVEL MATCHES "openmp" )
    find_package( OpenMP QUIET )
    set( IntelMKL_LIBRARIES ${IntelMKL_LIBRARIES} OpenMP::OpenMP_C )
  elseif( intelmkl_PREFERED_THREAD_LEVEL MATCHES "tbb" )
    find_package( TBB QUIET )
    set( IntelMKL_LIBRARIES ${IntelMKL_LIBRARIES} tbb )
  endif() 
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args( IntelMKL
  REQUIRED_VARS IntelMKL_LIBRARIES IntelMKL_INCLUDE_DIR
  VERSION_VAR IntelMKL_VERSION_STRING
  HANDLE_COMPONENTS
)

if( IntelMKL_FOUND AND NOT TARGET IntelMKL::mkl )

  add_library( IntelMKL::mkl INTERFACE IMPORTED )
  set_target_properties( IntelMKL::mkl PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${IntelMKL_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES      "${IntelMKL_LIBRARIES}"
    INTERFACE_COMPILE_OPTIONS     "${IntelMKL_C_COMPILE_FLAGS}"
    INTERFACE_COMPILE_DEFINITIONS "${IntelMKL_COMPILE_DEFINITIONS}"
  )

endif()
