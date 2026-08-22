cmake_minimum_required(VERSION 3.26)
project(test_ood LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# #embed requires GCC 15+ or Clang 19+; validate early so the error is clear.
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "15")
    message(FATAL_ERROR "#embed requires GCC 15+. Active compiler: GCC ${CMAKE_CXX_COMPILER_VERSION}")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "19")
    message(FATAL_ERROR "#embed requires Clang 19+. Active compiler: Clang ${CMAKE_CXX_COMPILER_VERSION}")
endif()

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

if(NOT DEFINED TARGET_PLATFORM)
    set(TARGET_PLATFORM "Linux")
endif()

string(TOLOWER "${TARGET_PLATFORM}" TARGET_PLATFORM_LOWER)

if(CMAKE_SYSTEM_NAME STREQUAL "Emscripten" OR TARGET_PLATFORM_LOWER STREQUAL "wasm" OR TARGET_PLATFORM_LOWER STREQUAL "webassembly" OR TARGET_PLATFORM_LOWER STREQUAL "emscripten")
    message(STATUS "Configuring for WebAssembly")
    set(RAYLIB_WASM_ROOT "" CACHE PATH "Installation prefix containing the WebAssembly raylib build")
    if(RAYLIB_WASM_ROOT)
        list(PREPEND CMAKE_PREFIX_PATH "${RAYLIB_WASM_ROOT}")
        if(NOT raylib_DIR)
            set(raylib_DIR "${RAYLIB_WASM_ROOT}/lib/cmake/raylib")
        endif()
    endif()
    find_package(raylib CONFIG REQUIRED)
else()
    find_package(RAYLIB REQUIRED)
endif()

add_executable(test_ood
    src/main.cpp
)

# Allow #embed "assets/..." to resolve from the project root.

target_include_directories(test_ood PUBLIC ${CMAKE_SOURCE_DIR}/src)

if(CMAKE_SYSTEM_NAME STREQUAL "Emscripten" OR TARGET_PLATFORM_LOWER STREQUAL "wasm" OR TARGET_PLATFORM_LOWER STREQUAL "webassembly" OR TARGET_PLATFORM_LOWER STREQUAL "emscripten")
    target_link_options(test_ood PRIVATE
        -sASYNCIFY=1
        -sASSERTIONS=1
        -sUSE_GLFW=3
        -sENVIRONMENT=web
    )
    target_link_libraries(test_ood PRIVATE raylib)
else()
    target_include_directories(test_ood PUBLIC ${RAYLIB_INCLUDE_DIR})
    target_link_libraries(test_ood PRIVATE ${RAYLIB_LIBRARY})
    if(UNIX)
        find_package(X11 REQUIRED)
        target_link_libraries(test_ood PRIVATE X11::X11)
    endif()
endif()
