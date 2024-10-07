# ------------------------------------------------------------------------------#
#
# rocprof-sys object library
#
# ------------------------------------------------------------------------------#

add_library(rocprof-sys-object-library OBJECT)
add_library(rocprof-sys::rocprof-sys-object-library ALIAS rocprof-sys-object-library)

target_sources(
    rocprof-sys-object-library
    PRIVATE ${CMAKE_CURRENT_LIST_DIR}/library.cpp ${CMAKE_CURRENT_LIST_DIR}/regions.cpp
            ${CMAKE_CURRENT_LIST_DIR}/progress.cpp ${CMAKE_CURRENT_LIST_DIR}/api.cpp
            ${CMAKE_CURRENT_LIST_DIR}/timeout.cpp ${CMAKE_CURRENT_LIST_DIR}/api.hpp)

add_subdirectory(library)

target_link_libraries(rocprof-sys-object-library
                      PRIVATE rocprof-sys::rocprof-sys-interface-library)

# ------------------------------------------------------------------------------#
#
# rocprof-sys static library
#
# ------------------------------------------------------------------------------#

add_library(rocprof-sys-static-library STATIC
            $<TARGET_OBJECTS:rocprof-sys-object-library>)
add_library(rocprof-sys::librocprof-sys-static ALIAS rocprof-sys-static-library)

target_link_libraries(
    rocprof-sys-static-library
    PRIVATE rocprof-sys::rocprof-sys-interface-library rocprof-sys::rocprof-sys-core
            rocprof-sys::rocprof-sys-binary)

set_target_properties(rocprof-sys-static-library PROPERTIES OUTPUT_NAME rocprof-sys)

# ------------------------------------------------------------------------------#
#
# rocprof-sys shared library
#
# ------------------------------------------------------------------------------#

add_library(rocprof-sys-shared-library SHARED
            $<TARGET_OBJECTS:rocprof-sys-object-library>)
add_library(rocprof-sys::librocprof-sys-shared ALIAS rocprof-sys-shared-library)
add_library(rocprof-sys::rocprof-sys-library ALIAS rocprof-sys-shared-library)

target_link_libraries(
    rocprof-sys-shared-library
    PRIVATE rocprof-sys::rocprof-sys-interface-library rocprof-sys::rocprof-sys-core
            rocprof-sys::rocprof-sys-binary)

set_target_properties(
    rocprof-sys-shared-library
    PROPERTIES OUTPUT_NAME rocprof-sys
               VERSION ${PROJECT_VERSION}
               SOVERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
               INSTALL_RPATH "${ROCPROFSYS_LIB_INSTALL_RPATH}")

rocprof_sys_strip_target(rocprof-sys-shared-library)

install(
    TARGETS rocprof-sys-shared-library
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
    OPTIONAL)
