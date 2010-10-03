
PROJECT(libjpeg C)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
INCLUDE(dist.cmake)

# generating config.h file:
MESSAGE("Configure: JPEG - generating jconfig.h:")
	INCLUDE(CheckIncludeFile)
	
	CHECK_INCLUDE_FILE(stddef.h HAVE_STDDEF_H)
	CHECK_INCLUDE_FILE(stdlib.h HAVE_STDLIB_H)
	
	IF(WIN32)
		# This is for jpeg binaries and is #defined in jconfig.h
		SET(TWO_FILE_COMMANDLINE true)
	ENDIF()
	
	CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/jconfig.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/jconfig.h)

MESSAGE("Configure: JPEG - done.")
# end of generating jconfig.h file:


INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR})

IF(MSVC)
    SET(CMAKE_DEBUG_POSTFIX "D")
ENDIF()

SET(JPEG_PUBLIC_HDRS
    jerror.h
    jmorecfg.h
    jpeglib.h
    ${CMAKE_CURRENT_BINARY_DIR}/jconfig.h
)
SET(JPEG_PRIVATE_HDRS
    cderror.h
    cdjpeg.h
    jdct.h
    jinclude.h
    jmemsys.h
    jpegint.h
    jversion.h
    transupp.h
)

# memmgr back ends: compile only one of these into a working library
# (For now, let's use the mode that requires the image fit into memory.
# This is the recommended mode for Win32 anyway.)
SET(JPEG_systemdependent_SRCS jmemnobs.c)

SET(JPEG_SRCS
    jaricom.c jcapimin.c jcapistd.c jcarith.c jccoefct.c jccolor.c
    jcdctmgr.c jchuff.c jcinit.c jcmainct.c jcmarker.c jcmaster.c
    jcomapi.c jcparam.c jcprepct.c jcsample.c jctrans.c jdapimin.c
    jdapistd.c jdarith.c jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c
    jddctmgr.c jdhuff.c jdinput.c jdmainct.c jdmarker.c jdmaster.c
    jdmerge.c jdpostct.c jdsample.c jdtrans.c jerror.c jfdctflt.c
    jfdctfst.c jfdctint.c jidctflt.c jidctfst.c jidctint.c jquant1.c
    jquant2.c jutils.c jmemmgr.c)

ADD_LIBRARY(jpeg SHARED ${JPEG_systemdependent_SRCS} ${JPEG_SRCS} ${JPEG_PUBLIC_HDRS} ${JPEG_PRIVATE_HDRS})
#~ SET_TARGET_PROPERTIES(jpeg PROPERTIES VERSION 7.0.0)
#~ SET_TARGET_PROPERTIES(jpeg PROPERTIES SOVERSION 7)

if(WIN32 AND BUILD_SHARED_LIBS)
    # We add JPEG_DLL only to building of this target because bad things
    # happen if it's enabled on all binary targets owing to the macros
    # defined in jmorecfg.h
    SET_TARGET_PROPERTIES(jpeg PROPERTIES COMPILE_FLAGS -DJPEG_DLL)
ENDIF()


#~ SET(JPEG_MANPAGES cjpeg.1 djpeg.1 jpegtran.1 rdjpgcom.1 wrjpgcom.1)

ADD_EXECUTABLE(cjpeg cjpeg.c rdppm.c rdgif.c rdtarga.c rdrle.c rdbmp.c rdswitch.c cdjpeg.c)
TARGET_LINK_LIBRARIES(cjpeg jpeg)

ADD_EXECUTABLE(djpeg djpeg.c wrppm.c wrgif.c wrtarga.c wrrle.c wrbmp.c rdcolmap.c cdjpeg.c)
TARGET_LINK_LIBRARIES(djpeg jpeg)

ADD_EXECUTABLE(jpegtran jpegtran.c rdswitch.c cdjpeg.c transupp.c)
TARGET_LINK_LIBRARIES(jpegtran jpeg)

ADD_EXECUTABLE(rdjpgcom rdjpgcom.c)
ADD_EXECUTABLE(wrjpgcom wrjpgcom.c)


INSTALL(TARGETS jpeg DESTINATION ${INSTALL_LIB})
INSTALL(FILES ${JPEG_PUBLIC_HDRS} DESTINATION ${INSTALL_INC})
INSTALL(TARGETS cjpeg djpeg jpegtran rdjpgcom wrjpgcom DESTINATION ${INSTALL_BIN})

INSTALL(FILES 
	change.log
	coderules.txt
	filelist.txt
	libjpeg.txt
	structure.txt
	usage.txt
	wizard.txt
	README
	DESTINATION ${INSTALL_DOC})
