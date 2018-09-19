#   FindSuperLUDist.cmake
#
#   Finds the SuperLU_Dist library.
#
#   This module will define the following variables:
#   
#     SUPERLU_DIST_FOUND        - System has found SuperLU_Dist installation
#     SUPERLU_DIST_INCLUDE_DIR  - Location of SuperLU_Dist headers
#     SUPERLU_DIST_LIBRARIES    - SuperLU_Dist libraries
#
#   This module will export the following targets if SUPERLU_FOUND
#
#     SuperLU::superlu_dist
#
#
#
#
#   Proper usage:
#
#     project( TEST_FIND_SUPERLUDIST C )
#     find_package( SuperLUDist )
#
#     if( SUPERLU_DIST_FOUND )
#       add_executable( test test.cxx )
#       target_link_libraries( test SuperLUDist::superlu_dist )
#     endif()
#
#
#
#
#   This module will use the following variables to change
#   default behaviour if set
#
#     superlu_dist_PREFIX
#     superlu_dist_INCLUDE_DIR
#     superlu_dist_LIBRARY_DIR
#     superlu_dist_LIBRARIES
#
#
#   This module also calls FindLinAlg.cmake if no LinAlg::BLAS
#   TARGET is found. If this behaviour is not desired, ensure 
#   that there is a proper definition of LinAlg::BLAS prior
#   to invokation by either calling find_package( LinAlg ) 
#   or creating a user defined target which properly links to
#   blas
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

include( CMakePushCheckState )
include( CheckLibraryExists )
include( CheckSymbolExists )
include( FindPackageHandleStandardArgs )

function( fill_out_prefix name )

  if( ${name}_PREFIX AND NOT ${name}_INCLUDE_DIR )
    set( ${name}_INCLUDE_DIR ${${name}_PREFIX}/include PARENT_SCOPE )
  endif()

  if( ${name}_PREFIX AND NOT ${name}_LIBRARY_DIR )
    set( ${name}_LIBRARY_DIR 
         "${${name}_PREFIX}/lib;${${name}_PREFIX}/lib32;${${name}_PREFIX}/lib64"
         PARENT_SCOPE
    )
  endif()

endfunction()

fill_out_prefix( superlu_dist )



# Dependencies
if( NOT TARGET SuperLU::BLAS )

  find_package( LinAlg QUIET )

  add_library( SuperLU::BLAS INTERFACE IMPORTED )
  target_link_libraries( SuperLU::BLAS INTERFACE LinAlg::BLAS )

endif()

if( NOT TARGET SuperLU::parmetis )

  find_package( ParMETIS QUIET )

  add_library( SuperLU::parmetis INTERFACE IMPORTED )
  target_link_libraries( SuperLU::parmetis INTERFACE ParMETIS::parmetis )

endif()


# Try to find headers
find_path( SUPERLU_DIST_INCLUDE_DIR
  NAMES superlu_defs.h
  HINTS ${superlu_dist_PREFIX}
  PATHS ${superlu_dist_INCLUDE_DIE}
  PATH_SUFFIXES include
  DOC "Local of SuperLU_DIST Headers"
)



# Try to find libraries if not already set
if( NOT superlu_dist_LIBRARIES )

  find_library( SUPERLU_DIST_LIBRARIES
    NAMES superlu_dist
    HINTS ${superlu_dist_PREFIX}
    PATHS ${superlu_dist_LIBRARY_DIR}
    PATH_SUFFIXES lib lib64 lib32
    DOC "SuperLU_DIST Libraries"
  )

else()

  # FIXME: Check if files exists at least?
  set( SUPERLU_DIST_LIBRARIES ${superlu_dist_LIBRARIES} )

endif()

# Check version
if( EXISTS ${SUPERLU_DIST_INCLUDE_DIR}/superlu_defs.h )
  set( version_pattern 
  "^#define[\t ]+SUPERLU_DIST_(MAJOR|MINOR|PATCH)_VERSION[\t ]+([0-9\\.]+)$"
  )
  file( STRINGS ${SUPERLU_DIST_INCLUDE_DIR}/superlu_defs.h superlu_dist_version
        REGEX ${version_pattern} )
  
  foreach( match ${superlu_dist_version} )
  
    if(SUPERLU_DIST_VERSION_STRING)
      set(SUPERLU_DIST_VERSION_STRING "${SUPERLU_DIST_VERSION_STRING}.")
    endif()
  
    string(REGEX REPLACE ${version_pattern} 
      "${SUPERLU_DIST_VERSION_STRING}\\2" 
      SUPERLU_DIST_VERSION_STRING ${match}
    )
  
    set(SUPERLU_DIST_VERSION_${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
  
  endforeach()
  
  unset( superlu_dist_version )
  unset( version_pattern )
endif()



# Determine if we've found SUPERLU_DIST
mark_as_advanced( SUPERLU_DIST_FOUND SUPERLU_DIST_INCLUDE_DIR SUPERLU_DIST_LIBRARIES )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args( SUPERLU_DIST
  REQUIRED_VARS SUPERLU_DIST_LIBRARIES SUPERLU_DIST_INCLUDE_DIR
  VERSION_VAR SUPERLU_DIST_VERSION_STRING
)

# Export target
if( SUPERLU_DIST_FOUND AND NOT TARGET SuperLU::superlu_dist )

  add_library( SuperLU::superlu_dist INTERFACE IMPORTED )
  set_target_properties( SuperLU::superlu_dist PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${SUPERLU_DIST_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES      "${SUPERLU_DIST_LIBRARIES};SuperLU::parmetis;SuperLU::BLAS" 
  )

endif()
