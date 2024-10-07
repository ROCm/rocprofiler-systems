# ------------------------------------------------------------------------------#
#
# rocprof-sys-causal target
#
# ------------------------------------------------------------------------------#

add_executable(
    rocprof-sys-causal
    ${CMAKE_CURRENT_LIST_DIR}/rocprof-sys-causal.cpp
    ${CMAKE_CURRENT_LIST_DIR}/rocprof-sys-causal.hpp ${CMAKE_CURRENT_LIST_DIR}/impl.cpp)

target_compile_definitions(rocprof-sys-causal PRIVATE TIMEMORY_CMAKE=1)
target_include_directories(rocprof-sys-causal PRIVATE ${CMAKE_CURRENT_LIST_DIR})
target_link_libraries(
    rocprof-sys-causal
    PRIVATE rocprof-sys::rocprof-sys-compile-definitions rocprof-sys::rocprof-sys-headers
            rocprof-sys::rocprof-sys-common-library rocprof-sys::rocprof-sys-core)
set_target_properties(
    rocprof-sys-causal
    PROPERTIES BUILD_RPATH "\$ORIGIN:\$ORIGIN/../${CMAKE_INSTALL_LIBDIR}"
               INSTALL_RPATH "${ROCPROFSYS_EXE_INSTALL_RPATH}"
               OUTPUT_NAME "rocprof-sys-causal")

rocprof_sys_strip_target(rocprof-sys-causal)

install(
    TARGETS rocprof-sys-causal
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    OPTIONAL)
