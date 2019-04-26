#   FindSuperLUDist.cmake
#
#   Finds the SuperLU_Dist library.
#
#   This module will define the following variables:
#   
#     SuperLU_Dist_FOUND        - System has found SuperLU_Dist installation
#     SuperLU_Dist_INCLUDE_DIR  - Location of SuperLU_Dist headers
#     SuperLU_Dist_LIBRARIES    - SuperLU_Dist libraries
#
#   This module will export the following targets if SuperLU_FOUND
#
#     SuperLU::superlu_dist
#
#
#
#
#   Proper usage:
#
#     project( TEST_FIND_SuperLUDist C )
#     find_package( SuperLUDist )
#
#     if( SuperLU_Dist_FOUND )
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

cmake_minimum_required( VERSION 3.11 ) # Require CMake 3.11+

include( CMakePushCheckState )
include( CheckLibraryExists )
include( CheckSymbolExists )
include( FindPackageHandleStandardArgs )

include( ${CMAKE_CURRENT_LIST_DIR}/CommonFunctions.cmake )

fill_out_prefix( superlu_dist )



# Dependencies
include(CMakeFindDependencyMacro)
if( NOT TARGET LinAlg::BLAS )
  find_dependency( LinAlg REQUIRED )
endif()

# Inherits MPI from ParMETIS
if( NOT TARGET ParMETIS::parmetis )
  find_package( ParMETIS REQUIRED )
endif()


# Try to find headers
find_path( SuperLU_Dist_INCLUDE_DIR
  NAMES superlu_defs.h
  HINTS ${superlu_dist_PREFIX}
  PATHS ${superlu_dist_INCLUDE_DIR}
  PATH_SUFFIXES include
  DOC "Local of SuperLU_Dist Headers"
)



# Try to find libraries if not already set
if( NOT superlu_dist_LIBRARIES )

  find_library( SuperLU_Dist_LIBRARIES
    NAMES superlu_dist
    HINTS ${superlu_dist_PREFIX}
    PATHS ${superlu_dist_LIBRARY_DIR}
    PATH_SUFFIXES lib lib64 lib32
    DOC "SuperLU_Dist Libraries"
  )

else()

  # FIXME: Check if files exists at least?
  set( SuperLU_Dist_LIBRARIES ${superlu_dist_LIBRARIES} )

endif()

# Check version
if( EXISTS ${SuperLU_Dist_INCLUDE_DIR}/superlu_defs.h )
  set( version_pattern 
  "^#define[\t ]+SuperLU_Dist_(MAJOR|MINOR|PATCH)_VERSION[\t ]+([0-9\\.]+)$"
  )
  file( STRINGS ${SuperLU_Dist_INCLUDE_DIR}/superlu_defs.h superlu_dist_version
        REGEX ${version_pattern} )
  
  foreach( match ${superlu_dist_version} )
  
    if(SuperLU_Dist_VERSION_STRING)
      set(SuperLU_Dist_VERSION_STRING "${SuperLU_Dist_VERSION_STRING}.")
    endif()
  
    string(REGEX REPLACE ${version_pattern} 
      "${SuperLU_Dist_VERSION_STRING}\\2" 
      SuperLU_Dist_VERSION_STRING ${match}
    )
  
    set(SuperLU_Dist_VERSION_${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
  
  endforeach()
  
  unset( superlu_dist_version )
  unset( version_pattern )
endif()



# Determine if we've found SuperLU_Dist
mark_as_advanced( SuperLU_Dist_FOUND SuperLU_Dist_INCLUDE_DIR SuperLU_Dist_LIBRARIES )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args( SuperLU_Dist
  REQUIRED_VARS SuperLU_Dist_LIBRARIES SuperLU_Dist_INCLUDE_DIR
  VERSION_VAR SuperLU_Dist_VERSION_STRING
)

# Export target
if( SuperLU_Dist_FOUND AND NOT TARGET SuperLU::superlu_dist )

  add_library( SuperLU::superlu_dist INTERFACE IMPORTED )
  set_target_properties( SuperLU::superlu_dist PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${SuperLU_Dist_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES      "${SuperLU_Dist_LIBRARIES};ParMETIS::parmetis;LinAlg::BLAS" 
  )

endif()
