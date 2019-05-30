cmake_minimum_required( VERSION 3.11 ) # Require CMake 3.11+

include( CMakePushCheckState )
include( CheckLibraryExists )
include( CheckSymbolExists )
include( FindPackageHandleStandardArgs )


include( ${CMAKE_CURRENT_LIST_DIR}/CommonFunctions.cmake )

fill_out_prefix( linalg )

if( NOT LinAlg_BLAS_PREFERENCE_LIST )
  set( LinAlg_BLAS_PREFERENCE_LIST "IntelMKL" "IBMESSL" "BLIS" "OpenBLAS" "ReferenceBLAS" )
endif()


if( NOT linalg_LIBRARIES )

  list( APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/linalg-modules )
  foreach( blas_type ${LinAlg_BLAS_PREFERENCE_LIST} )

    string( TOLOWER ${blas_type} blas_lower_case )
    set( ${blas_lower_case}_PREFIX      ${linalg_PREFIX}      )
    set( ${blas_lower_case}_INCLUDE_DIR ${linalg_INCLUDE_DIR} )
    set( ${blas_lower_case}_LIBRARY_DIR ${linalg_LIBRARY_DIR} )

    find_package( ${blas_type} )

    if( ${blas_type}_FOUND )

      if    ( ${blas_type} MATCHES "IntelMKL"      )
        set( linalg_LIBRARIES IntelMKL::mkl )
      elseif( ${blas_type} MATCHES "IBMESSL"       )
        set( linalg_LIBRARIES IBMESSL::essl )
      elseif( ${blas_type} MATCHES "BLIS"      )
        set( linalg_LIBRARIES BLIS::blis )
      elseif( ${blas_type} MATCHES "OpenBLAS"      )
        set( linalg_LIBRARIES OpenBLAS::openblas )
      elseif( ${blas_type} MATCHES "ReferenceBLAS" ) 
        set( linalg_LIBRARIES ReferenceBLAS::blas )
      endif()

      break()

    endif()

  endforeach()

  list(REMOVE_AT CMAKE_MODULE_PATH -1)
endif()


# Check function existance and linkage / name mangling
cmake_push_check_state( RESET )
if( linalg_LIBRARIES )
  set( CMAKE_REQUIRED_LIBRARIES ${linalg_LIBRARIES} )
endif()
set( CMAKE_REQUIRED_QUIET ON )

check_library_exists( "" dgemm       "" LinAlg_blas_NO_UNDERSCORE   ) 
check_library_exists( "" dgemm_      "" LinAlg_blas_USES_UNDERSCORE ) 
check_library_exists( "" cblas_dgemm "" LinAlg_cblas_FOUND          )

set( TEST_USES_UNDERSCORE_STR "Performing Test LinAlg_blas_USES_UNDERSCORE" )
set( TEST_NO_UNDERSCORE_STR   "Performing Test LinAlg_blas_NO_UNDERSCORE"   )
set( TEST_CBLAS_STR           "Checking CBLAS Existance"                    )

message( STATUS  ${TEST_USES_UNDERSCORE_STR} )
if( LinAlg_blas_USES_UNDERSCORE )
  message( STATUS "${TEST_USES_UNDERSCORE_STR} -- found" )
else()
  message( STATUS "${TEST_USES_UNDERSCORE_STR} -- not found" )
endif()

message( STATUS  ${TEST_NO_UNDERSCORE_STR} )
if( LinAlg_blas_NO_UNDERSCORE )
  message( STATUS "${TEST_NO_UNDERSCORE_STR} -- found" )
else()
  message( STATUS "${TEST_NO_UNDERSCORE_STR} -- not found" )
endif()

message( STATUS  ${TEST_CBLAS_STR} )
if( LinAlg_cblas_FOUND )
  message( STATUS "${TEST_CBLAS_STR} -- found" )
else()
  message( STATUS "${TEST_CBLAS_STR} -- not found" )
endif()


unset( TEST_USES_UNDERSCORE_STR )
unset( TEST_NO_UNDERSCORE_STR )
unset( TEST_CBLAS_STR )


if( LinAlg_blas_NO_UNDERSCORE OR LinAlg_blas_USES_UNDERSCORE )
  set( LinAlg_blas_FOUND TRUE )
endif()

cmake_pop_check_state()
  

list( FIND LinAlg_FIND_COMPONENTS "lapack"  linalg_lapack_indx  )
list( FIND LinAlg_FIND_COMPONENTS "lapacke" linalg_lapacke_indx )



if( ${linalg_lapack_indx} GREATER -1 )
  set( linalg_WANTS_LAPACK TRUE )
endif()
if( ${linalg_lapacke_indx} GREATER -1 )
  set( linalg_WANTS_LAPACKE TRUE )
endif()

if( linalg_WANTS_LAPACK OR linalg_WANTS_LAPACKE )

  list( APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/linalg-modules )
  if( NOT TARGET IntelMKL::mkl AND NOT TARGET OpenBLAS::openblas )
    if( linalg_WANTS_LAPACK )
      find_package( ReferenceLAPACK )
      list( INSERT linalg_LIBRARIES 0 ReferenceLAPACK::lapack )
    endif()
  endif()
  list(REMOVE_AT CMAKE_MODULE_PATH -1)

  
  # Check function existance and linkage / name mangling
  cmake_push_check_state( RESET )
  if( linalg_LIBRARIES )
    set( CMAKE_REQUIRED_LIBRARIES ${linalg_LIBRARIES} )
  endif()
  set( CMAKE_REQUIRED_QUIET ON )
  
  check_library_exists( "" dsyev         "" LinAlg_lapack_NO_UNDERSCORE   ) 
  check_library_exists( "" dsyev_        "" LinAlg_lapack_USES_UNDERSCORE ) 
  check_library_exists( "" LAPACKE_dsyev "" LinAlg_lapacke_FOUND          )
  
  set( TEST_USES_UNDERSCORE_STR "Performing Test LinAlg_lapack_USES_UNDERSCORE" )
  set( TEST_NO_UNDERSCORE_STR   "Performing Test LinAlg_lapack_NO_UNDERSCORE"   )
  set( TEST_LAPACKE_STR           "Checking LAPACKE Existance"                    )
  
  message( STATUS  ${TEST_USES_UNDERSCORE_STR} )
  if( LinAlg_lapack_USES_UNDERSCORE )
    message( STATUS "${TEST_USES_UNDERSCORE_STR} -- found" )
  else()
    message( STATUS "${TEST_USES_UNDERSCORE_STR} -- not found" )
  endif()
  
  message( STATUS  ${TEST_NO_UNDERSCORE_STR} )
  if( LinAlg_lapack_NO_UNDERSCORE )
    message( STATUS "${TEST_NO_UNDERSCORE_STR} -- found" )
  else()
    message( STATUS "${TEST_NO_UNDERSCORE_STR} -- not found" )
  endif()
  
  message( STATUS  ${TEST_LAPACKE_STR} )
  if( LinAlg_lapacke_FOUND )
    message( STATUS "${TEST_LAPACKE_STR} -- found" )
  else()
    message( STATUS "${TEST_LAPACKE_STR} -- not found" )
  endif()
  
  
  unset( TEST_USES_UNDERSCORE_STR )
  unset( TEST_NO_UNDERSCORE_STR )
  unset( TEST_LAPACKE_STR )
  
  
  if( LinAlg_lapack_NO_UNDERSCORE OR LinAlg_lapack_USES_UNDERSCORE )
    set( LinAlg_lapack_FOUND TRUE )
  endif()
  
  cmake_pop_check_state()

endif()





# Validate standard args
find_package_handle_standard_args( LinAlg 
  REQUIRED_VARS LinAlg_blas_FOUND
  HANDLE_COMPONENTS 
)
if( LinAlg_FOUND AND NOT TARGET LinAlg::linalg )

  set( LinAlg_LIBRARIES ${linalg_LIBRARIES} )

  add_library( LinAlg::linalg INTERFACE IMPORTED )
  set_target_properties( LinAlg::linalg PROPERTIES
    INTERFACE_LINK_LIBRARIES "${LinAlg_LIBRARIES}"
  )

endif()
