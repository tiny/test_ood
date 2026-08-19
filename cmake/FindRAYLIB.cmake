# FindRAYLIB.cmake - Find Raylib library
# Sets:
#   RAYLIB_FOUND
#   RAYLIB_LIBRARY
#   RAYLIB_INCLUDE_DIR

# Check if RAYLIB_INCLUDE_DIR is already set (passed from parent CMake or CMAKE_ARGS)
if(RAYLIB_INCLUDE_DIR AND EXISTS "${RAYLIB_INCLUDE_DIR}/raylib.h")
    message(STATUS "RAYLIB_INCLUDE_DIR set: ${RAYLIB_INCLUDE_DIR}")
    set(RAYLIB_FOUND TRUE)
    
    # Try to find the library in RAYLIB_LIBRARY_DIR or RAYLIB_DIR
    find_library(RAYLIB_LIBRARY NAMES raylib
        PATHS 
            "${RAYLIB_LIBRARY_DIR}"
            "${RAYLIB_DIR}"
            "${RAYLIB_DIR}/lib"
            /usr/lib 
            /usr/local/lib
            ${CMAKE_BINARY_DIR}/external/raylib-build/raylib
            ${CMAKE_BINARY_DIR}/external/raylib-build/raylib/lib
        NO_DEFAULT_PATH
    )
    
    if(NOT RAYLIB_LIBRARY)
        # Library file not found yet - use target/library name for deferred resolution
        set(RAYLIB_LIBRARY raylib)
        message(STATUS "RAYLIB library file not found yet, using target name: ${RAYLIB_LIBRARY}")
    else()
        message(STATUS "Found RAYLIB library: ${RAYLIB_LIBRARY}")
    endif()
    return()
endif()

# Manual search for headers and library (fallback)
find_path(RAYLIB_INCLUDE_DIR raylib.h
    PATHS 
        ${CMAKE_SOURCE_DIR}/../raylib/src
        ${CMAKE_SOURCE_DIR}/../raylib/include
        ${CMAKE_SOURCE_DIR}/../raylib/build-wasm/raylib/include
        ${CMAKE_SOURCE_DIR}/../raylib/build-wasm/include
        ${CMAKE_SOURCE_DIR}/../raylib/build/wasm/raylib/include
        ${CMAKE_SOURCE_DIR}/../raylib/build/wasm/include
        /usr/include 
        /usr/local/include
        ${CMAKE_SOURCE_DIR}/external/raylib-src/src
        ${CMAKE_BINARY_DIR}/external/raylib-src/src
        ${CMAKE_BINARY_DIR}/external/raylib-build/raylib/include
        "${RAYLIB_DIR}/include"
)

find_library(RAYLIB_LIBRARY NAMES raylib
    PATHS 
        ${CMAKE_SOURCE_DIR}/../raylib/build/raylib
        ${CMAKE_SOURCE_DIR}/../raylib/build/raylib/lib
        ${CMAKE_SOURCE_DIR}/../raylib/build/lib
        ${CMAKE_SOURCE_DIR}/../raylib/build-wasm/raylib
        ${CMAKE_SOURCE_DIR}/../raylib/build-wasm/raylib/lib
        ${CMAKE_SOURCE_DIR}/../raylib/build/wasm/raylib
        ${CMAKE_SOURCE_DIR}/../raylib/build/wasm/raylib/lib
        ${CMAKE_SOURCE_DIR}/../raylib/lib
        /usr/lib 
        /usr/local/lib
        ${CMAKE_BINARY_DIR}/external/raylib-build/raylib
        ${CMAKE_BINARY_DIR}/external/raylib-build/raylib/lib
        "${RAYLIB_LIBRARY_DIR}"
        "${RAYLIB_DIR}/lib"
)

if(RAYLIB_INCLUDE_DIR AND RAYLIB_LIBRARY)
    set(RAYLIB_FOUND TRUE)
    message(STATUS "Found RAYLIB: ${RAYLIB_LIBRARY}")
else()
    # Even if library not found, if header exists we can proceed
    if(RAYLIB_INCLUDE_DIR)
        set(RAYLIB_FOUND TRUE)
        # Use target name as library reference
        set(RAYLIB_LIBRARY raylib)
        message(STATUS "Found RAYLIB headers at ${RAYLIB_INCLUDE_DIR}, using target name for library")
    else()
        set(RAYLIB_FOUND FALSE)
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(RAYLIB DEFAULT_MSG RAYLIB_FOUND)



