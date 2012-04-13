# LuaDist CMake utility library.
# Provides variables and utility functions common to LuaDist CMake builds.
# 
# Copyright (C) 2007-2012 LuaDist.
# by David Manura, Peter Drahos
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

## INSTALL DEFAULTS (Relative to CMAKE_INSTALL_PREFIX)
# Primary paths
set ( INSTALL_BIN bin CACHE PATH "Where to install binaries to." )
set ( INSTALL_LIB lib CACHE PATH "Where to install libraries to." )
set ( INSTALL_INC include CACHE PATH "Where to install headers to." )
set ( INSTALL_ETC etc CACHE PATH "Where to store configuration files" )
set ( INSTALL_SHARE share CACHE PATH "Directory for shared data." )

# Secondary paths
set ( INSTALL_DATA ${INSTALL_SHARE}/${PROJECT_NAME} CACHE PATH
      "Directory the package can store documentation, tests or other data in.")
set ( INSTALL_DOC  ${INSTALL_DATA}/doc CACHE PATH
      "Recommended directory to install documentation into.")
set ( INSTALL_EXAMPLE ${INSTALL_DATA}/example CACHE PATH
      "Recommended directory to install examples into.")
set ( INSTALL_TEST ${INSTALL_DATA}/test CACHE PATH
      "Recommended directory to install tests into.")
set ( INSTALL_FOO  ${INSTALL_DATA}/etc CACHE PATH
      "Where to install additional files")

# Skipable content, headers, binaries and libraries are always required
option ( SKIP_TESTING "Do not add tests." OFF)
option ( SKIP_INSTALL_DATA "Skip installing all data." OFF )
if ( NOT SKIP_INSTALL_DATA )
  option ( SKIP_INSTALL_DOC "Skip installation of documentation." OFF )  
  option ( SKIP_INSTALL_EXAMPLE "Skip installation of documentation." OFF )
  option ( SKIP_INSTALL_TEST "Skip installation of tests." OFF)
  option ( SKIP_INSTALL_FOO "Skip installation of optional package content." OFF)
endif ()

# TWEAKS
# Setting CMAKE to use loose block and search for find modules in source directory
set ( CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS true )
set ( CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH} )

# In MSVC, prevent warnings that can occur when using standard libraries.
if ( MSVC )
	add_definitions ( -D_CRT_SECURE_NO_WARNINGS )
endif ()

## MACROS
# Parser macro
macro ( parse_arguments prefix arg_names option_names)
  set ( DEFAULT_ARGS )
  foreach ( arg_name ${arg_names} )
    set ( ${prefix}_${arg_name} )
  endforeach ()
  foreach ( option ${option_names} )
    set ( ${prefix}_${option} FALSE )
  endforeach ()

  set ( current_arg_name DEFAULT_ARGS )
  set ( current_arg_list )
  foreach ( arg ${ARGN} )            
    set ( larg_names ${arg_names} )    
    list ( FIND larg_names "${arg}" is_arg_name )                   
    if ( is_arg_name GREATER -1 )
      set ( ${prefix}_${current_arg_name} ${current_arg_list} )
      set ( current_arg_name ${arg} )
      set ( current_arg_list )
    else ()
      set ( loption_names ${option_names} )    
      list ( FIND loption_names "${arg}" is_option )            
      if ( is_option GREATER -1 )
	     set ( ${prefix}_${arg} TRUE )
      else ()
	     set ( current_arg_list ${current_arg_list} ${arg} )
      endif ()
    endif ()
  endforeach ()
  set ( ${prefix}_${current_arg_name} ${current_arg_list} )
endmacro ()

# install_library
# Installs any libraries generated using "add_library" into apropriate places.
# USE: install_library ( libexpat )
macro ( install_library )
  foreach ( _file ${ARGN} )
    install ( TARGETS ${_file}
              RUNTIME DESTINATION ${INSTALL_BIN}
              LIBRARY DESTINATION ${INSTALL_LIB}
              ARCHIVE DESTINATION ${INSTALL_LIB} )
  endforeach()
endmacro ()

# install_executable
# Installs any executables generated using "add_executable".
# USE: install_executable ( lua )
macro ( install_executable )
  foreach ( _file ${ARGN} )
    install ( TARGETS ${_file} RUNTIME DESTINATION ${INSTALL_BIN} )
  endforeach()
endmacro ()

# install_header
# Install a directories or files into header destination.
# USE: install_header ( lua.h luaconf.h ) or install_header ( GL )
# NOTE: If headers need to be installed into subdirectories use the
# INSTALL command directly.
macro ( install_header )
  parse_arguments ( _ARG "INTO" "" ${ARGN} )
  foreach ( _file ${_ARG_DEFAULT_ARGS} )
    if ( IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_file}" )
      install ( DIRECTORY ${_file} DESTINATION ${INSTALL_INC}/${_ARG_INTO} )
    else ()
      install ( FILES ${_file} DESTINATION ${INSTALL_INC}/${_ARG_INTO} )
    endif ()
  endforeach()
endmacro ()

# install_data ( files/directories )
# This installs additional data files or directories.
# USE: install_data ( extra data.dat )
macro ( install_data )
  if ( NOT SKIP_INSTALL_DATA )
    parse_arguments ( _ARG "INTO" "" ${ARGN} )
    foreach ( _file ${_ARG_DEFAULT_ARGS} )
      if ( IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_file}" )
        install ( DIRECTORY ${_file} DESTINATION ${INSTALL_DATA}/${_ARG_INTO} )
      else ()
        install ( FILES ${_file} DESTINATION ${INSTALL_DATA}/${_ARG_INTO} )
      endif ()
    endforeach()
  endif()
endmacro ()

# INSTALL_DOC ( files/directories )
# This installs documentation content
# USE: install_doc ( doc/ )
macro ( install_doc )
  if ( NOT SKIP_INSTALL_DATA AND NOT SKIP_INSTALL_DOC )
    parse_arguments ( _ARG "INTO" "" ${ARGN} )
    foreach ( _file ${_ARG_DEFAULT_ARGS} )
      if ( IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_file}" )
        install ( DIRECTORY ${_file} DESTINATION ${INSTALL_DOC}/${_ARG_INTO} )
      else ()
        install ( FILES ${_file} DESTINATION ${INSTALL_DOC}/${_ARG_INTO} )
      endif ()
    endforeach()
  endif()
endmacro ()

# install_example ( files/directories )
# This installs additional data
# USE: install_example ( examples/ exampleA.lua )
macro ( install_example )
  if ( NOT SKIP_INSTALL_DATA AND NOT SKIP_INSTALL_EXAMPLE )
    parse_arguments ( _ARG "INTO" "" ${ARGN} )
    foreach ( _file ${_ARG_DEFAULT_ARGS} )
      if ( IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_file}" )
        install ( DIRECTORY ${_file} DESTINATION ${INSTALL_EXAMPLE}/${_ARG_INTO} )
      else ()
        install ( FILES ${_file} DESTINATION ${INSTALL_EXAMPLE}/${_ARG_INTO} )
      endif ()
    endforeach()
  endif()
endmacro ()

# install_test ( files/directories )
# This installs tests
# USE: install_example ( examples/ exampleA.lua )
macro ( install_test )
  if ( NOT SKIP_INSTALL_DATA AND NOT SKIP_INSTALL_TEST )
    parse_arguments ( _ARG "INTO" "" ${ARGN} )
    foreach ( _file ${_ARG_DEFAULT_ARGS} )
      if ( IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_file}" )
        install ( DIRECTORY ${_file} DESTINATION ${INSTALL_TEST}/${_ARG_INTO} )
      else ()
        install ( FILES ${_file} DESTINATION ${INSTALL_TEST}/${_ARG_INTO} )
      endif ()
    endforeach()
  endif()
endmacro ()

# install_foo ( files/directories )
# This installs optional content
# USE: install_foo ( examples/ exampleA.lua )
macro ( install_foo )
  if ( NOT SKIP_INSTALL_DATA AND NOT SKIP_INSTALL_FOO )
    parse_arguments ( _ARG "INTO" "" ${ARGN} )
    foreach ( _file ${_ARG_DEFAULT_ARGS} )
      if ( IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_file}" )
        install ( DIRECTORY ${_file} DESTINATION ${INSTALL_FOO}/${_ARG_INTO} )
      else ()
        install ( FILES ${_file} DESTINATION ${INSTALL_FOO}/${_ARG_INTO} )
      endif ()
    endforeach()
  endif()
endmacro ()
