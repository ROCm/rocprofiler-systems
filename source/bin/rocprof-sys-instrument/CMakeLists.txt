# ------------------------------------------------------------------------------#
#
# rocprof-sys-instrument target (formerly rocprof-sys-exe target prior to 1.8.1)
#
# ------------------------------------------------------------------------------#

set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF)

add_executable(rocprof-sys-instrument)

target_sources(
    rocprof-sys-instrument
    PRIVATE ${CMAKE_CURRENT_LIST_DIR}/details.cpp
            ${CMAKE_CURRENT_LIST_DIR}/function_signature.cpp
            ${CMAKE_CURRENT_LIST_DIR}/function_signature.hpp
            ${CMAKE_CURRENT_LIST_DIR}/fwd.hpp
            ${CMAKE_CURRENT_LIST_DIR}/info.hpp
            ${CMAKE_CURRENT_LIST_DIR}/internal_libs.cpp
            ${CMAKE_CURRENT_LIST_DIR}/internal_libs.hpp
            ${CMAKE_CURRENT_LIST_DIR}/log.cpp
            ${CMAKE_CURRENT_LIST_DIR}/log.hpp
            ${CMAKE_CURRENT_LIST_DIR}/module_function.cpp
            ${CMAKE_CURRENT_LIST_DIR}/module_function.hpp
            ${CMAKE_CURRENT_LIST_DIR}/rocprof-sys-instrument.cpp
            ${CMAKE_CURRENT_LIST_DIR}/rocprof-sys-instrument.hpp)

target_link_libraries(
    rocprof-sys-instrument
    PRIVATE rocprof-sys::rocprof-sys-headers
            rocprof-sys::rocprof-sys-dyninst
            rocprof-sys::rocprof-sys-compile-options
            rocprof-sys::rocprof-sys-compile-definitions
            rocprof-sys::rocprof-sys-sanitizer
            timemory::timemory-headers
            timemory::timemory-extensions
            timemory::timemory-core)

set_target_properties(
    rocprof-sys-instrument
    PROPERTIES BUILD_RPATH "\$ORIGIN:\$ORIGIN/../${CMAKE_INSTALL_LIBDIR}"
               INSTALL_RPATH "${ROCPROFSYS_EXE_INSTALL_RPATH}"
               INSTALL_RPATH_USE_LINK_PATH ON
               OUTPUT_NAME "rocprof-sys-instrument")

if(ROCPROFSYS_BUILD_DYNINST)
    target_compile_definitions(rocprof-sys-instrument PRIVATE ROCPROFSYS_BUILD_DYNINST=1)
endif()

add_target_flag_if_avail(rocprof-sys-instrument "-Wno-deprecated-declarations")

rocprof_sys_strip_target(rocprof-sys-instrument)

if(CMAKE_BUILD_TYPE MATCHES "^(DEBUG|Debug)")
    string(REPLACE " " ";" _FLAGS "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
    target_compile_options(rocprof-sys-instrument PRIVATE ${_FLAGS})
endif()

install(
    TARGETS rocprof-sys-instrument
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    OPTIONAL)
