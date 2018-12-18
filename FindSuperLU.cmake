#   FindSuperLU.cmake
#
#   Finds the SuperLU library.
#
#   This module will define the following variables:
#   
#     SUPERLU_FOUND        - System has found SuperLU installation
#     SUPERLU_INCLUDE_DIR  - Location of SuperLU headers
#     SUPERLU_LIBRARIES    - SuperLU libraries
#
#   This module will export the following targets if SUPERLU_FOUND
#
#     SUPERLU::superlu
#
#
#
#
#   Proper usage:
#
#     project( TEST_FIND_SUPERLU C )
#     find_package( SUPERLU )
#
#     if( SUPERLU_FOUND )
#       add_executable( test test.cxx )
#       target_link_libraries( test SUPERLU::superlu )
#     endif()
#
#
#
#
#   This module will use the following variables to change
#   default behaviour if set
#
#     superlu_PREFIX
#     superlu_INCLUDE_DIR
#     superlu_LIBRARY_DIR
#     superlu_LIBRARIES
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

fill_out_prefix( superlu )



# Dependencies
if( NOT TARGET LinAlg::BLAS )

  include(CMakeFindDependencyMacro)
  find_dependency( LinAlg REQUIRED )

endif()


# Try to find headers
find_path( SUPERLU_INCLUDE_DIR
  NAMES slu_util.h
  HINTS ${superlu_PREFIX}
  PATHS ${superlu_INCLUDE_DIR}
  PATH_SUFFIXES include
  DOC "Local of SuperLU Headers"
)



# Try to find libraries if not already set
if( NOT superlu_LIBRARIES )

  find_library( SUPERLU_LIBRARIES
    NAMES superlu
    HINTS ${superlu_PREFIX}
    PATHS ${superlu_LIBRARY_DIR}
    PATH_SUFFIXES lib lib64 lib32
    DOC "SUPERLU Libraries"
  )

else()

  # FIXME: Check if files exists at least?
  set( SUPERLU_LIBRARIES ${superlu_LIBRARIES} )

endif()

# Check version
if( EXISTS ${SUPERLU_INCLUDE_DIR}/slu_util.h )
  set( version_pattern 
  "^#define[\t ]+SUPERLU_(MAJOR|MINOR|PATCH)_VERSION[\t ]+([0-9\\.]+)$"
  )
  file( STRINGS ${SUPERLU_INCLUDE_DIR}/slu_util.h superlu_version
        REGEX ${version_pattern} )
  
  foreach( match ${superlu_version} )
  
    if(SUPERLU_VERSION_STRING)
      set(SUPERLU_VERSION_STRING "${SUPERLU_VERSION_STRING}.")
    endif()
  
    string(REGEX REPLACE ${version_pattern} 
      "${SUPERLU_VERSION_STRING}\\2" 
      SUPERLU_VERSION_STRING ${match}
    )
  
    set(SUPERLU_VERSION_${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
  
  endforeach()
  
  unset( superlu_version )
  unset( version_pattern )
endif()



# Determine if we've found SUPERLU
mark_as_advanced( SUPERLU_FOUND SUPERLU_INCLUDE_DIR SUPERLU_LIBRARIES )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args( SUPERLU
  REQUIRED_VARS SUPERLU_LIBRARIES SUPERLU_INCLUDE_DIR
  VERSION_VAR SUPERLU_VERSION_STRING
)

# Export target
if( SUPERLU_FOUND AND NOT TARGET SuperLU::superlu )

  add_library( SuperLU::superlu INTERFACE IMPORTED )
  set_target_properties( SuperLU::superlu PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${SUPERLU_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES      "${SUPERLU_LIBRARIES};LinAlg::BLAS" 
  )

endif()
