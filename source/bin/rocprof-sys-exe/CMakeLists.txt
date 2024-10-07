# ------------------------------------------------------------------------------#
#
# TODO: [DFG] Remove this file after 'rocprofsys' rebranding is complete
# rocprof-sys-exe target (deprecated 'omnitrace' executable, now 'rocprof-sys-instrument')
#
# ------------------------------------------------------------------------------#

add_executable(rocprof-sys-exe ${CMAKE_CURRENT_LIST_DIR}/rocprof-sys.cpp)

target_link_libraries(rocprof-sys-exe PRIVATE rocprof-sys::rocprof-sys-threading)

set_target_properties(
    rocprof-sys-exe
    PROPERTIES OUTPUT_NAME rocprof-sys
               BUILD_RPATH "\$ORIGIN:\$ORIGIN/../${CMAKE_INSTALL_LIBDIR}"
               INSTALL_RPATH "${ROCPROFSYS_EXE_INSTALL_RPATH}"
               INSTALL_RPATH_USE_LINK_PATH ON)

rocprof_sys_strip_target(rocprof-sys-exe)

install(
    TARGETS rocprof-sys-exe
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    OPTIONAL)
