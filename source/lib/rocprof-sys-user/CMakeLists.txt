# ------------------------------------------------------------------------------#
#
# rocprof-sys user library
#
# ------------------------------------------------------------------------------#

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_SKIP_RPATH OFF)
set(BUILD_RPATH_USE_ORIGIN ON)
set(CMAKE_CXX_VISIBILITY_PRESET "hidden")
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

add_library(rocprof-sys-user-library SHARED)
add_library(rocprof-sys::rocprof-sys-user-library ALIAS rocprof-sys-user-library)

set(_user_headers
    ${CMAKE_CURRENT_SOURCE_DIR}/rocprof-sys/user.h
    ${CMAKE_CURRENT_SOURCE_DIR}/rocprof-sys/types.h
    ${CMAKE_CURRENT_SOURCE_DIR}/rocprof-sys/causal.h
    ${CMAKE_CURRENT_SOURCE_DIR}/rocprof-sys/categories.h)

set(_user_sources ${CMAKE_CURRENT_SOURCE_DIR}/user.cpp)

target_sources(rocprof-sys-user-library PRIVATE ${_user_sources} ${_user_headers})
target_include_directories(
    rocprof-sys-user-library PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                                   $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
target_link_libraries(
    rocprof-sys-user-library
    PRIVATE $<BUILD_INTERFACE:rocprof-sys::rocprof-sys-compile-definitions>)

set_target_properties(
    rocprof-sys-user-library
    PROPERTIES OUTPUT_NAME rocprof-sys-user
               VERSION ${PROJECT_VERSION}
               SOVERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
               POSITION_INDEPENDENT_CODE ON
               BUILD_RPATH "\$ORIGIN"
               INSTALL_RPATH "\$ORIGIN")

rocprof_sys_strip_target(rocprof-sys-user-library)

foreach(_HEADER ${_user_headers})
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/rocprof-sys/"
                   "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}/" _DEST ${_HEADER})
    string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/"
                   "${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/" _DEST "${_DEST}")

    configure_file(${_HEADER} ${_DEST} COPYONLY)
endforeach()

install(FILES ${_user_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME})

install(
    TARGETS rocprof-sys-user-library
    EXPORT rocprof-sys-library-targets
    DESTINATION ${CMAKE_INSTALL_LIBDIR})
