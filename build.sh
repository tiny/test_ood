#!/bin/bash
# Build script for Visual-AI - Unix/Linux/macOS
# Usage: ./build.sh [PLATFORM] [BUILD_TYPE]
#
# PLATFORM (default: linux):
#   linux       - Linux with raylib (primary implementation)
#   windows     - Windows (stub implementation)
#   android     - Android (stub implementation)
#   ios         - iOS (stub implementation)
#   wasm        - WebAssembly (Emscripten) build
#   clean       - Remove configured build directories (keeps external dependencies)
#   clean-all   - Remove all build directories and .deps/ (full clean)
#
# BUILD_TYPE (default: release):
#   release     - Optimized release build
#   debug       - Debug build with symbols
#
# Examples:
#   ./build.sh                    # Linux Release (default)
#   ./build.sh linux debug        # Linux Debug
#   ./build.sh windows release    # Windows Release
#   ./build.sh android            # Android Release (default)
#   ./build.sh wasm               # WebAssembly Release
#   ./build.sh clean              # Clean build artifacts
#   ./build.sh clean-all          # Full cleanup including deps
#
# External dependencies are cached in .deps/ directory to persist across
# clean builds. This avoids redundant re-fetching of libraries.

set -e

# Default values
PLATFORM="linux"
BUILD_TYPE="release"

show_help() {
    echo "Visual AI Build Script"
    echo ""
    echo "Usage: $0 [PLATFORM] [BUILD_TYPE]"
    echo ""
    echo "PLATFORM Options:"
    echo "  linux       - Linux with raylib (primary implementation, default)"
    echo "  windows     - Windows (stub implementation)"
    echo "  android     - Android (stub implementation)"
    echo "  ios         - iOS (stub implementation)"
    echo "  wasm        - WebAssembly (Emscripten) build"
    echo "  clean       - Remove configured build directories (keeps .deps/)"
    echo "  clean-all   - Remove all build directories and .deps/"
    echo ""
    echo "BUILD_TYPE Options:"
    echo "  release     - Optimized release build (default)"
    echo "  debug       - Debug build with symbols"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build for Linux (Release)"
    echo "  $0 linux debug        # Build for Linux (Debug)"
    echo "  $0 windows            # Build for Windows (Release)"
    echo "  $0 android debug      # Build for Android (Debug)"
    echo "  $0 clean              # Clean build artifacts"
    echo "  $0 clean-all          # Full cleanup"
    echo ""
    echo "Dependency Cache:"
    echo "  External dependencies are stored in ./.deps/"
    echo "  This directory persists across 'clean' operations"
    echo "  Use 'clean-all' to rebuild everything from scratch"
}

# Normalize platform name to CMake format
normalize_platform() {
    case "${1,,}" in
        linux)
            echo "Linux"
            ;;
        windows|win|win32)
            echo "Windows"
            ;;
        android)
            echo "Android"
            ;;
        ios|iphone)
            echo "iOS"
            ;;
        wasm|webassembly|emscripten)
            echo "WebAssembly"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Normalize build type
normalize_build_type() {
    case "${1,,}" in
        release|rel)
            echo "Release"
            ;;
        debug|dbg)
            echo "Debug"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Map a platform to its output directory
get_build_dir() {
    case "${1,,}" in
        linux)
            echo "build"
            ;;
        windows|win|win32)
            echo "build-win"
            ;;
        android)
            echo "build-android"
            ;;
        ios|iphone)
            echo "build-ios"
            ;;
        wasm|webassembly|emscripten)
            echo "build-wasm"
            ;;
        *)
            echo "build"
            ;;
    esac
}

# Parse first argument
if [[ -n "${1}" ]]; then
    case "${1,,}" in
        help|-h|--help)
            show_help
            exit 0
            ;;
        clean)
            echo "Cleaning configured build directories..."
            echo "Note: External dependencies cached in .deps/ will be preserved"
            rm -rf build build-win build-android build-ios build-wasm
            echo "Clean complete. Cached dependencies in ./.deps/"
            exit 0
            ;;
        clean-all)
            echo "Full cleanup (all build directories and .deps/)..."
            rm -rf build build-win build-android build-ios build-wasm .deps
            echo "Full cleanup complete. Next build will fetch all dependencies fresh."
            exit 0
            ;;
        linux|windows|android|ios|wasm|webassembly|emscripten|win|win32|iphone)
            PLATFORM=$(normalize_platform "$1")
            if [[ -z "$PLATFORM" ]]; then
                echo "Error: Unknown platform '$1'"
                show_help
                exit 1
            fi
            ;;
        release|debug|rel|dbg)
            # First arg is build type (no platform specified, use default)
            BUILD_TYPE=$(normalize_build_type "$1")
            if [[ -z "$BUILD_TYPE" ]]; then
                echo "Error: Unknown build type '$1'"
                show_help
                exit 1
            fi
            ;;
        *)
            echo "Error: Unknown option '$1'"
            show_help
            exit 1
            ;;
    esac
fi

# Parse second argument (if provided)
if [[ -n "${2}" ]]; then
    BUILD_TYPE=$(normalize_build_type "$2")
    if [[ -z "$BUILD_TYPE" ]]; then
        echo "Error: Unknown build type '$2'"
        show_help
        exit 1
    fi
fi

# Use defaults if not specified
: ${BUILD_TYPE:="Release"}
BUILD_DIR="$(get_build_dir "$PLATFORM")"

if [[ "${PLATFORM,,}" == "webassembly" || "${PLATFORM,,}" == "wasm" ]]; then
    if ! command -v emcmake >/dev/null 2>&1; then
        echo "Error: Emscripten is required for the wasm target."
        echo "Install emscripten and ensure 'emcmake' is on your PATH."
        echo "Example: source /path/to/emsdk/emsdk_env.sh"
        exit 1
    fi
fi

echo ""
echo "=========================================="
echo "Visual AI Build Configuration"
echo "=========================================="
echo "Platform:     $PLATFORM"
echo "Build Type:   $BUILD_TYPE"
echo "Build Dir:    ./$BUILD_DIR"
echo "Cache Dir:    ./.deps/"
echo ""

# Check dependencies first
echo "Checking dependencies..."
if [[ -f ./check_deps.sh ]]; then
    ./check_deps.sh || echo "⚠ Some dependencies missing - see above for installation instructions"
fi
echo ""

# Create platform build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# Configure with CMake
echo "Configuring CMake..."
echo "  Platform: $PLATFORM"
echo "  Build type: $BUILD_TYPE"
echo "  Build dir: ./$BUILD_DIR"
echo "  Dependency cache: ./.deps/"

if [[ "${PLATFORM,,}" == "webassembly" || "${PLATFORM,,}" == "wasm" ]]; then
    emcmake cmake -B "$BUILD_DIR" \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DTARGET_PLATFORM=$PLATFORM \
        -Draylib_DIR="/mnt/drive_e/wrk/raylib/install-wasm/lib/cmake/raylib" \
        -DCMAKE_PREFIX_PATH="/mnt/drive_e/wrk/raylib/install-wasm"
else
    cmake -B "$BUILD_DIR" \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DTARGET_PLATFORM=$PLATFORM
fi

# Build
echo ""
echo "Building..."
cmake --build "$BUILD_DIR"

echo ""
echo "=========================================="
echo "Build successful!"
echo "=========================================="
echo "Platform:     $PLATFORM"
echo "Build Type:   $BUILD_TYPE"
echo "Build Dir:    ./$BUILD_DIR"
echo "Executable:   ./$BUILD_DIR/hell_rocks"
echo "To run:       ./$BUILD_DIR/hell_rocks"
echo ""
echo "Dependency Cache: ./.deps/"
echo "  (persists across 'clean' builds)"
echo ""

