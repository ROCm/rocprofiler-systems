# ------------------------------------------------------------------------------#
#
# rocprof-sys-avail target
#
# ------------------------------------------------------------------------------#

add_executable(rocprof-sys-avail)

target_sources(
    rocprof-sys-avail
    PRIVATE ${CMAKE_CURRENT_LIST_DIR}/avail.cpp
            ${CMAKE_CURRENT_LIST_DIR}/avail.hpp
            ${CMAKE_CURRENT_LIST_DIR}/common.cpp
            ${CMAKE_CURRENT_LIST_DIR}/common.hpp
            ${CMAKE_CURRENT_LIST_DIR}/component_categories.hpp
            ${CMAKE_CURRENT_LIST_DIR}/defines.hpp
            ${CMAKE_CURRENT_LIST_DIR}/enumerated_list.hpp
            ${CMAKE_CURRENT_LIST_DIR}/generate_config.cpp
            ${CMAKE_CURRENT_LIST_DIR}/generate_config.hpp
            ${CMAKE_CURRENT_LIST_DIR}/get_availability.hpp
            ${CMAKE_CURRENT_LIST_DIR}/get_categories.hpp
            ${CMAKE_CURRENT_LIST_DIR}/info_type.cpp
            ${CMAKE_CURRENT_LIST_DIR}/info_type.hpp)

target_include_directories(rocprof-sys-avail PRIVATE ${CMAKE_CURRENT_LIST_DIR})
target_compile_definitions(rocprof-sys-avail PRIVATE ROCPROFSYS_EXTERN_COMPONENTS=0)
target_link_libraries(
    rocprof-sys-avail
    PRIVATE rocprof-sys::rocprof-sys-compile-definitions
            rocprof-sys::rocprof-sys-interface-library rocprof-sys::librocprof-sys-static)
set_target_properties(
    rocprof-sys-avail
    PROPERTIES BUILD_RPATH "\$ORIGIN:\$ORIGIN/../${CMAKE_INSTALL_LIBDIR}"
               INSTALL_RPATH "${ROCPROFSYS_EXE_INSTALL_RPATH}"
               OUTPUT_NAME rocprof-sys-avail)

rocprof_sys_strip_target(rocprof-sys-avail)

install(
    TARGETS rocprof-sys-avail
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    OPTIONAL)
