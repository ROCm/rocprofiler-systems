# ------------------------------------------------------------------------------#
#
# rocprof-sys-sample target
#
# ------------------------------------------------------------------------------#

add_executable(rocprof-sys-sample ${CMAKE_CURRENT_LIST_DIR}/rocprof-sys-sample.cpp
                                 ${CMAKE_CURRENT_LIST_DIR}/impl.cpp)

target_compile_definitions(rocprof-sys-sample PRIVATE TIMEMORY_CMAKE=1)
target_include_directories(rocprof-sys-sample PRIVATE ${CMAKE_CURRENT_LIST_DIR})
target_link_libraries(
    rocprof-sys-sample
    PRIVATE rocprof-sys::rocprof-sys-compile-definitions rocprof-sys::rocprof-sys-headers
            rocprof-sys::rocprof-sys-common-library)
set_target_properties(
    rocprof-sys-sample
    PROPERTIES BUILD_RPATH "\$ORIGIN:\$ORIGIN/../${CMAKE_INSTALL_LIBDIR}"
               INSTALL_RPATH "${ROCPROFSYS_EXE_INSTALL_RPATH}"
               OUTPUT_NAME "rocprof-sys-sample")

rocprof_sys_strip_target(rocprof-sys-sample)

install(
    TARGETS rocprof-sys-sample
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    OPTIONAL)
