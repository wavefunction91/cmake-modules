#    FindLinAlg.cmake
#
#    Finds Serial / SMP Linear Algebra Libraries ( BLAS/LAPACK )
#    and export them as separate targets
#
#    This module is meant to serve as a replacement for the 
#    standard FindBLAS / FindLAPACK CMake modules which are
#    packaged with every CMake distribution. As a result,
#    and due to limited man power, this module does not
#    support as many BLA_VENDOR's as the original modules.
#
#    If FindLinAlg.cmake does not support a desired BLA_VENDOR
#    (aliased as LinAlg_VENDOR), please open an Issue or submit
#    a Pull Request on GitHub
#
#    The module will define the following variables:
#
#      LinAlg_<BLAS/LAPACK>_FOUND        - System has found Linear Algebra installation
#      LinAlg_<BLAS/LAPACK>_INCLUDE_DIR  - Location of Linear Algebra headers
#      LinAlg_<BLAS/LAPACK>_LIBRARIES    - Linear Algebra libraries
#
#     This module can handle the following COMPONENTS
#
#       BLAS     - BLAS library
#       LAPACK   - LAPACK library
#       
#     This module will export the following targets if certain
#     criteria are met
#
#       LinAlg::BLAS     if LinAlg_BLAS_FOUND
#       LinAlg::LAPACK   if LinAlg_LAPACK_FOUND
#
#
#
#     This module will use the following variable to change
#     default behaviour if set:
#
#       linalg_PREFIX
#       linalg_INCLUDE_DIR
#       linalg_LIBRARY_DIR
#       linalg_LIBRARIES
#
#
#       linalg_BLAS_PREFIX
#       linalg_LAPACK_PREFIX
#       linalg_BLAS_INCLUDE_DIR
#       linalg_LAPACK_INCLUDE_DIR
#       linalg_BLAS_LIBRARY_DIR
#       linalg_LAPACK_LIBRARY_DIR
#       linalg_BLAS_LIBRARIES
#       linalg_LAPACK_LIBRARIES
#
#==================================================================
#   Copyright (c) 2018 The Regents of the University of California,
#   through Lawrence Berkeley National Laboratory.  
#
#   Author: David Williams-Young
#   
#   This file is part of cmake-modules. All rights reserved.
#   
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are met:
#   
#   (1) Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#   (2) Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#   (3) Neither the name of the University of California, Lawrence Berkeley
#   National Laboratory, U.S. Dept. of Energy nor the names of its contributors may
#   be used to endorse or promote products derived from this software without
#   specific prior written permission.
#   
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#   DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#   ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
#   ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#   
#   You are under no obligation whatsoever to provide any bug fixes, patches, or
#   upgrades to the features, functionality or performance of the source code
#   ("Enhancements") to anyone; however, if you choose to make your Enhancements
#   available either publicly, or directly to Lawrence Berkeley National
#   Laboratory, without imposing a separate written license agreement for such
#   Enhancements, then you hereby grant the following license: a non-exclusive,
#   royalty-free perpetual license to install, use, modify, prepare derivative
#   works, incorporate into other computer software, distribute, and sublicense
#   such enhancements or derivative works thereof, in binary and source code form.
#
#==================================================================

cmake_minimum_required( VERSION 3.11 ) # Require CMake 3.11+

include( CMakePushCheckState )
include( CheckLibraryExists )
include( CheckSymbolExists )
include( FindPackageHandleStandardArgs )


include( ${CMAKE_CURRENT_LIST_DIR}/CommonFunctions.cmake )

fill_out_prefix( linalg )

copy_meta_data( linalg linalg_BLAS   )
copy_meta_data( linalg linalg_LAPACK )

fill_out_prefix( linalg_BLAS   )
fill_out_prefix( linalg_LAPACK )

# Handle BLAS

if( NOT linalg_BLAS_LIBRARIES )

  message( STATUS "Will attempt to find BLAS using FindBLAS" )

  # Attempt to find BLAS using FindBLAS
  find_package( BLAS QUIET )

  if( BLAS_LIBRARIES )
    set( LinAlg_BLAS_LIBRARIES ${BLAS_LIBRARIES} )
  endif()

else()

  message( STATUS "linalg_BLAS_LIBRARIES = ${linalg_BLAS_LIBRARIES}" )

  # Override with user specified BLAS libs
  set( LinAlg_BLAS_LIBRARIES ${linalg_BLAS_LIBRARIES} )

endif()


# Check function existance and linkage / name mangling

cmake_push_check_state( RESET )

if( LinAlg_BLAS_LIBRARIES )
  set( CMAKE_REQUIRED_LIBRARIES ${LinAlg_BLAS_LIBRARIES} )
endif()
set( CMAKE_REQUIRED_QUIET ON )

check_library_exists( "" dgemm  "" LinAlg_BLAS_NO_UNDERSCORE   ) 
check_library_exists( "" dgemm_ "" LinAlg_BLAS_USES_UNDERSCORE ) 

set( TEST_USES_UNDERSCORE_STR "Performing Test LinAlg_BLAS_USES_UNDERSCORE" )
set( TEST_NO_UNDERSCORE_STR "Performing Test LinAlg_BLAS_NO_UNDERSCORE" )

message( STATUS  ${TEST_USES_UNDERSCORE_STR} )
if( LinAlg_BLAS_USES_UNDERSCORE )
  message( STATUS "${TEST_USES_UNDERSCORE_STR} -- found" )
else()
  message( STATUS "${TEST_USES_UNDERSCORE_STR} -- not found" )
endif()

message( STATUS  ${TEST_NO_UNDERSCORE_STR} )
if( LinAlg_BLAS_NO_UNDERSCORE )
  message( STATUS "${TEST_NO_UNDERSCORE_STR} -- found" )
else()
  message( STATUS "${TEST_NO_UNDERSCORE_STR} -- not found" )
endif()


unset( TEST_USES_UNDERSCORE_STR )
unset( TEST_NO_UNDERSCORE_STR )


if( LinAlg_BLAS_NO_UNDERSCORE OR LinAlg_BLAS_USES_UNDERSCORE )
  set( LinAlg_BLAS_LINK_OK TRUE )
endif()

cmake_pop_check_state()
  


# Check that we found BLAS
mark_as_advanced( LinAlg_BLAS_FOUND LinAlg_BLAS_LIBRARIES LinAlg_BLAS_LINK_OK )

find_package_handle_standard_args( LinAlg_BLAS
  REQUIRED_VARS LinAlg_BLAS_LINK_OK
  HANDLE_COMPONENTS
)

# Create BLAS TARGET
if( LinAlg_BLAS_FOUND AND NOT TARGET LinAlg::BLAS )

  add_library( LinAlg::BLAS INTERFACE IMPORTED )
  set_target_properties( LinAlg::BLAS PROPERTIES
    INTERFACE_LINK_LIBRARIES "${LinAlg_BLAS_LIBRARIES}"
  )

  # TODO: Add property to use a definition for "_" mangling
  # TODO: Add headers if found

endif()







# Handle LAPACK

if( NOT linalg_LAPACK_LIBRARIES )

  message( STATUS "Will attempt to find LAPACK using FindLAPACK" )

  # Attempt to find LAPACK using FindLAPACK
  find_package( LAPACK QUIET )

  if( LAPACK_LIBRARIES )
    set( LinAlg_LAPACK_LIBRARIES ${LAPACK_LIBRARIES} )
  endif()

else()

  message( STATUS "linalg_LAPACK_LIBRARIES = ${linalg_LAPACK_LIBRARIES}" )

  # Override with user specified LAPACK libs
  set( LinAlg_LAPACK_LIBRARIES ${linalg_LAPACK_LIBRARIES} )

endif()

# Remove BLAS libs from LAPACK libs
if( LinAlg_LAPACK_LIBRARIES )

  foreach( blas_lib ${LinAlg_LAPACK_LIBRARIES} )

    # determine if shared or static based on .a or .so
    string( REGEX MATCH ".*\\.so.*" LIB_IS_SHARED ${blas_lib} )

    if( LIB_IS_SHARED )
      exec_program( 
        "objdump -TC ${blas_lib}" 
        OUTPUT_VARIABLE   LIB_OBJ_OUTPUT
      )
    else()
      exec_program( 
        "nm -nC ${blas_lib}" 
        OUTPUT_VARIABLE   LIB_OBJ_OUTPUT
      )
    endif()

    string( REGEX REPLACE "\n" "${Esc};" LIB_OBJ_OUTPUT_LIST 
            "${LIB_OBJ_OUTPUT}" )

    message( STATUS "Looking for BLAS in ${blas_lib}" )
    foreach( line ${LIB_OBJ_OUTPUT_LIST} )

      if( NOT LIB_HAS_DGEMM )
        if( LIB_IS_SHARED )
          string( REGEX MATCH ".*text.*dgemm.*" LIB_HAS_DGEMM 
                  ${line} )
        else()
          string( REGEX MATCH ".*T dgemm.*" LIB_HAS_DGEMM 
                  ${line} )
        endif()
      endif()

    endforeach()

    if( LIB_HAS_DGEMM )
      message( STATUS "Looking for BLAS in ${blas_lib} - found" )
      list(APPEND LAPACK_BLAS_LIBS ${blas_lib} )
    else()
      message( STATUS "Looking for BLAS in ${blas_lib} - not found" )
    endif()

    unset( LIB_OBJ_OUTPUT )
    unset( LIB_HAS_DGEMM )

  endforeach()



  # Strip BLAS libraies

  message( STATUS "Stripping BLAS from LAPACK linkage" )

  # First check if any of the libs specifed in BLAS are in the 
  # LAPACK linkage, they'll be linked in target
  if( LinAlg_BLAS_LIBRARIES )  
    foreach( lib ${LinAlg_BLAS_LIBRARIES} )
      list( REMOVE_ITEM LinAlg_LAPACK_LIBRARIES ${lib} )
    endforeach()
  endif()

  # Next strip the found libraries
  if( LAPACK_BLAS_LIBS )
    foreach( lib ${LAPACK_BLAS_LIBS} )
      list( REMOVE_ITEM LinAlg_LAPACK_LIBRARIES ${lib} )
    endforeach()
  endif() 

  unset( LAPACK_BLAS_LIBS )

endif()

# Check function existance and linkage / name mangling
cmake_push_check_state( RESET )

if( LinAlg_LAPACK_LIBRARIES )
  set( CMAKE_REQUIRED_LIBRARIES ${LinAlg_LAPACK_LIBRARIES} )
endif()

if( LinAlg_BLAS_LIBRARIES )
  list( APPEND CMAKE_REQUIRED_LIBRARIES ${LinAlg_BLAS_LIBRARIES} )
endif()



set( CMAKE_REQUIRED_QUIET ON )

check_library_exists( "" dsyev  "" LinAlg_LAPACK_NO_UNDERSCORE   ) 
check_library_exists( "" dsyev_ "" LinAlg_LAPACK_USES_UNDERSCORE ) 

set( TEST_USES_UNDERSCORE_STR "Performing Test LinAlg_LAPACK_USES_UNDERSCORE" )
set( TEST_NO_UNDERSCORE_STR "Performing Test LinAlg_LAPACK_NO_UNDERSCORE" )

message( STATUS  ${TEST_USES_UNDERSCORE_STR} )
if( LinAlg_LAPACK_USES_UNDERSCORE )
  message( STATUS "${TEST_USES_UNDERSCORE_STR} -- found" )
else()
  message( STATUS "${TEST_USES_UNDERSCORE_STR} -- not found" )
endif()

message( STATUS  ${TEST_NO_UNDERSCORE_STR} )
if( LinAlg_LAPACK_NO_UNDERSCORE )
  message( STATUS "${TEST_NO_UNDERSCORE_STR} -- found" )
else()
  message( STATUS "${TEST_NO_UNDERSCORE_STR} -- not found" )
endif()


unset( TEST_USES_UNDERSCORE_STR )
unset( TEST_NO_UNDERSCORE_STR )


if( LinAlg_LAPACK_NO_UNDERSCORE OR LinAlg_LAPACK_USES_UNDERSCORE )
  set( LinAlg_LAPACK_LINK_OK TRUE )
endif()

cmake_pop_check_state()






# Check that we found LAPACK
mark_as_advanced( LinAlg_LAPACK_FOUND LinAlg_LAPACK_LIBRARIES LinAlg_LAPACK_LINK_OK )

find_package_handle_standard_args( LinAlg_LAPACK
  REQUIRED_VARS LinAlg_LAPACK_LINK_OK
  HANDLE_COMPONENTS
)

# Create LAPACK TARGET
if( LinAlg_LAPACK_FOUND AND NOT TARGET LinAlg::LAPACK )

  add_library( LinAlg::LAPACK INTERFACE IMPORTED )

  if( TARGET LinAlg::BLAS )
    if( LinAlg_LAPACK_LIBRARIES )
      list( APPEND LinAlg_LAPACK_LIBRARIES LinAlg::BLAS )
    else()
      set( LinAlg_LAPACK_LIBRARIES LinAlg::BLAS )
    endif()
  endif()

  if( LinAlg_LAPACK_LIBRARIES )
    set_target_properties( LinAlg::LAPACK PROPERTIES
      INTERFACE_LINK_LIBRARIES "${LinAlg_LAPACK_LIBRARIES}"
    )
  endif()

  # TODO: Add property to use a definition for "_" mangling
  # TODO: Add headers if found

endif()
