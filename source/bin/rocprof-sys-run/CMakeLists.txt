# ------------------------------------------------------------------------------#
#
# rocprof-sys-run target
#
# ------------------------------------------------------------------------------#

add_executable(
    rocprof-sys-run
    ${CMAKE_CURRENT_LIST_DIR}/rocprof-sys-run.cpp
    ${CMAKE_CURRENT_LIST_DIR}/rocprof-sys-run.hpp ${CMAKE_CURRENT_LIST_DIR}/impl.cpp)

target_compile_definitions(rocprof-sys-run PRIVATE TIMEMORY_CMAKE=1)
target_include_directories(rocprof-sys-run PRIVATE ${CMAKE_CURRENT_LIST_DIR})
target_link_libraries(
    rocprof-sys-run
    PRIVATE rocprof-sys::rocprof-sys-compile-definitions rocprof-sys::rocprof-sys-headers
            rocprof-sys::rocprof-sys-common-library rocprof-sys::rocprof-sys-core
            rocprof-sys::rocprof-sys-sanitizer)
set_target_properties(
    rocprof-sys-run
    PROPERTIES BUILD_RPATH "\$ORIGIN:\$ORIGIN/../${CMAKE_INSTALL_LIBDIR}"
               INSTALL_RPATH "${ROCPROFSYS_EXE_INSTALL_RPATH}"
               OUTPUT_NAME "rocprof-sys-run")

rocprof_sys_strip_target(rocprof-sys-run)

install(
    TARGETS rocprof-sys-run
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    OPTIONAL)
