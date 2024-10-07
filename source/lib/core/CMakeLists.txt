#
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/defines.hpp.in
               ${CMAKE_CURRENT_BINARY_DIR}/defines.hpp @ONLY)

set(core_sources
    ${CMAKE_CURRENT_LIST_DIR}/argparse.cpp
    ${CMAKE_CURRENT_LIST_DIR}/categories.cpp
    ${CMAKE_CURRENT_LIST_DIR}/config.cpp
    ${CMAKE_CURRENT_LIST_DIR}/constraint.cpp
    ${CMAKE_CURRENT_LIST_DIR}/debug.cpp
    ${CMAKE_CURRENT_LIST_DIR}/dynamic_library.cpp
    ${CMAKE_CURRENT_LIST_DIR}/exception.cpp
    ${CMAKE_CURRENT_LIST_DIR}/gpu.cpp
    ${CMAKE_CURRENT_LIST_DIR}/mproc.cpp
    ${CMAKE_CURRENT_LIST_DIR}/perf.cpp
    ${CMAKE_CURRENT_LIST_DIR}/perfetto.cpp
    ${CMAKE_CURRENT_LIST_DIR}/state.cpp
    ${CMAKE_CURRENT_LIST_DIR}/timemory.cpp
    ${CMAKE_CURRENT_LIST_DIR}/utility.cpp)

set(core_headers
    ${CMAKE_CURRENT_LIST_DIR}/argparse.hpp
    ${CMAKE_CURRENT_LIST_DIR}/categories.hpp
    ${CMAKE_CURRENT_LIST_DIR}/common.hpp
    ${CMAKE_CURRENT_LIST_DIR}/concepts.hpp
    ${CMAKE_CURRENT_LIST_DIR}/config.hpp
    ${CMAKE_CURRENT_LIST_DIR}/constraint.hpp
    ${CMAKE_CURRENT_LIST_DIR}/debug.hpp
    ${CMAKE_CURRENT_LIST_DIR}/dynamic_library.hpp
    ${CMAKE_CURRENT_LIST_DIR}/exception.hpp
    ${CMAKE_CURRENT_LIST_DIR}/gpu.hpp
    ${CMAKE_CURRENT_LIST_DIR}/hip_runtime.hpp
    ${CMAKE_CURRENT_LIST_DIR}/locking.hpp
    ${CMAKE_CURRENT_LIST_DIR}/mproc.hpp
    ${CMAKE_CURRENT_LIST_DIR}/perf.hpp
    ${CMAKE_CURRENT_LIST_DIR}/perfetto.hpp
    ${CMAKE_CURRENT_LIST_DIR}/rccl.hpp
    ${CMAKE_CURRENT_LIST_DIR}/redirect.hpp
    ${CMAKE_CURRENT_LIST_DIR}/state.hpp
    ${CMAKE_CURRENT_LIST_DIR}/timemory.hpp
    ${CMAKE_CURRENT_LIST_DIR}/utility.hpp)

add_library(rocprof-sys-core-library STATIC)
add_library(rocprof-sys::rocprof-sys-core ALIAS rocprof-sys-core-library)

target_sources(rocprof-sys-core-library PRIVATE ${core_sources} ${core_headers}
                                                ${CMAKE_CURRENT_BINARY_DIR}/defines.hpp)
add_subdirectory(binary)
add_subdirectory(components)
add_subdirectory(containers)

target_include_directories(rocprof-sys-core-library BEFORE
                           PRIVATE ${CMAKE_CURRENT_LIST_DIR})

target_link_libraries(rocprof-sys-core-library
                      PRIVATE rocprof-sys::rocprof-sys-interface-library)
target_link_libraries(
    rocprof-sys-core-library
    PRIVATE
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-headers>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-threading>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-common-library>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-compile-definitions>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-compile-options>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-perfetto>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-timemory>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-mpi>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-hip>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-rocm-smi>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-static-libgcc-optional>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-static-libstdcxx-optional>
        $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-sanitizer>
        $<BUILD_INTERFACE:$<IF:$<BOOL:${ROCPROFSYS_BUILD_LTO}>,rocprof-sys::rocprof-sys-lto,>>
    )

set_target_properties(rocprof-sys-core-library PROPERTIES OUTPUT_NAME rocprof-sys-core)
