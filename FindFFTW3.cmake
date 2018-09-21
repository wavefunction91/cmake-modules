#   FindFFTW3.cmake
#
#   Finds the FFTW3 library
#
#   This module will define the following variables:
#
#     FFTW3_FOUND         - System has found FFTW3 installation
#     FFTW3_INCLUDE_DIR   - Location of FFTW3 headers
#     FFTW3_LIBRARIES     - FFTW3 libraries
#
#   This module can handle the following COMPONENTS
#
#     MPI     - MPI version
#
#    This module will export the following targets if FFTW3_FOUND
#
#      FFTW3::fftw3
#
#    This module will export the following targets if 
#    FFTW3_MPI_FOUND
#
#      FFTW3::fftw3_mpi
#
#
#    Proper usage:
#
#      project( TEST_FIND_FFTW3 C )
#      find_package( FFTW3 )
#
#      if( FFTW3_FOUND )
#        add_executable( test test.cxx )
#        target_link_libraries( test FFTW3::fftw3 )
#      endif()
#
#   This module will use the following variables to change
#   default behaviour if set
#
#     fftw3_PREFIX
#     fftw3_INCLUDE_DIR
#     fftw3_LIBRARY_DIR
#     fftw3_LIBRARIES
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
include(FindPackageHandleStandardArgs)


# Set up some auxillary vars if hints have been set

if( fftw3_PREFIX AND NOT fftw3_INCLUDE_DIR )
  set( fftw3_INCLUDE_DIR ${fftw3_PREFIX}/include )
endif()


if( fftw3_PREFIX AND NOT fftw3_LIBRARY_DIR )
  set( fftw3_LIBRARY_DIR 
    ${fftw3_PREFIX}/lib 
    ${fftw3_PREFIX}/lib32 
    ${fftw3_PREFIX}/lib64 
  )
endif()







# Try to find the header
find_path( FFTW3_INCLUDE_DIR 
  NAMES fftw3.h
  HINTS ${fftw3_PREFIX}
  PATHS ${fftw3_INCLUDE_DIR}
  PATH_SUFFIXES include
  DOC "Location of FFTW header"
)



# Try to serial find libraries if not already set
if( NOT fftw3_LIBRARIES )

  find_library( FFTW3_LIBRARIES
    NAMES fftw3 
    HINTS ${fftw3_PREFIX}
    PATHS ${fftw3_LIBRARY_DIR}
    PATH_SUFFIXES lib lib64 lib32
    DOC "FFTW3 Library"
  )

else()

  # fiXME
  set( FFTW3_LIBRARIES ${fftw3_LIBRARIES} )

endif()


# fftw3-MPI
if( "MPI" IN_LIST FFTW3_FIND_COMPONENTS )


  # Try to find the header
  find_path( FFTW3_MPI_INCLUDE_DIR 
    NAMES fftw3-mpi.h
    HINTS ${fftw3_PREFIX} ${fftw3_MPI_PREFIX}
    PATHS ${fftw3_INCLUDE_DIR} ${fftw3_MPI_INCLUDE_DIR}
    PATH_SUFFIXES include
    DOC "Location of FFTW3-MPI header"
  )
  
  
  
  # Try to serial find libraries if not already set
  if( NOT fftw3_MPI_LIBRARIES )
  
    find_library( FFTW3_MPI_LIBRARIES
      NAMES fftw3_mpi 
      HINTS ${fftw3_PREFIX} ${fftw3_MPI_PREFIX}
      PATHS ${fftw3_LIBRARY_DIR} ${fftw3_MPI_LIBRARY_DIR}
      PATH_SUFFIXES lib lib64 lib32
      DOC "FFTW3 of FFTW3-MPI Library"
    )
  
  else()
  
    # FIXME
    set( FFTW3_MPI_LIBRARIES ${fftw3_MPI_LIBRARIES} )
  
  endif()
  

  if( FFTW3_MPI_INCLUDE_DIR AND FFTW3_MPI_LIBRARIES )
    set( FFTW3_MPI_FOUND TRUE )
  endif()

  # MPI
  if( NOT TARGET MPI::MPI_C )
    find_package( MPI REQUIRED )
  endif()

endif()


mark_as_advanced( FFTW3_FOUND FFTW3_MPI_FOUND FFTW3_INCLUDE_DIR
                  FFTW3_MPI_INCLUDE_DIR FFTW3_LIBRARIES 
                  FFTW3_MPI_LIBRARIES )

find_package_handle_standard_args( FFTW3
  REQUIRED_VARS FFTW3_INCLUDE_DIR FFTW3_LIBRARIES
  HANDLE_COMPONENTS 
)


if( FFTW3_FOUND AND NOT TARGET FFTW3::fftw3 )

  add_library( FFTW3::fftw3 INTERFACE IMPORTED )
  set_target_properties( FFTW3::fftw3 PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES      "${FFTW3_LIBRARIES}"
  )

endif()


if( FFTW3_MPI_FOUND AND NOT TARGET FFTW3::fftw3_mpi )

  add_library( FFTW3::fftw3_mpi INTERFACE IMPORTED )
  set_target_properties( FFTW3::fftw3_mpi PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${FFTW3_MPI_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES      "${FFTW3_MPI_LIBRARIES};FFTW3::fftw3;MPI::MPI_C"
  )

endif()


