# ----------------------------------------------------------------------------- #
#
# rocprof-sys: contains all instrumentation functionality
#
# rocprof-sys-dl: contains minimal symbols and dlopen's rocprof-sys
#
# rocprof-sys-user: contains symbols for user API
#
# ----------------------------------------------------------------------------- #

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.20)
    cmake_policy(SET CMP0115 NEW)
endif()

if(ROCPROFSYS_USE_ROCPROFILER
   AND rocprofiler_LIBRARY_DIR
   AND ROCmVersion_TRIPLE_VERSION VERSION_LESS 5.2.0
   AND NOT CMAKE_INSTALL_RPATH_USE_LINK_PATH)
    set(ROCPROFSYS_LIB_INSTALL_RPATH
        "\$ORIGIN:\$ORIGIN/${PROJECT_NAME}:${rocprofiler_LIBRARY_DIR}")
else()
    set(ROCPROFSYS_LIB_INSTALL_RPATH "\$ORIGIN:\$ORIGIN/${PROJECT_NAME}")
endif()

# ------------------------------------------------------------------------------#
#
# rocprof-sys interface library
#
# ------------------------------------------------------------------------------#

add_library(rocprof-sys-interface-library INTERFACE)
add_library(rocprof-sys::rocprof-sys-interface-library ALIAS rocprof-sys-interface-library)

target_include_directories(
    rocprof-sys-interface-library INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}
                                           ${CMAKE_CURRENT_SOURCE_DIR}/rocprof-sys)

target_link_libraries(
    rocprof-sys-interface-library
    INTERFACE
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-headers>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-threading>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-common-library>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-compile-options>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-compile-definitions>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-perfetto>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-timemory>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-elfutils>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-bfd>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-mpi>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-ptl>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-hip>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-roctracer>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-rocprofiler>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-rocm-smi>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-rccl>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-static-libgcc-optional>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-static-libstdcxx-optional>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-sanitizer>
        $<BUILD_INTERFACE:$<IF:$<BOOL:${ROCPROFSYS_BUILD_LTO}>,rocprof-sys::rocprof-sys-lto,>>
    )

# ------------------------------------------------------------------------------#
#
# rocprof-sys internal libraries
#
# ------------------------------------------------------------------------------#

add_subdirectory(common)
add_subdirectory(core)
add_subdirectory(binary)

# ------------------------------------------------------------------------------#
#
# rocprof-sys exported libraries
#
# ------------------------------------------------------------------------------#

add_subdirectory(rocprof-sys)
add_subdirectory(rocprof-sys-dl)
add_subdirectory(rocprof-sys-rt)
add_subdirectory(rocprof-sys-user)
