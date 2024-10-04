# ======================================================================================
# Perfetto.cmake
#
# Configure perfetto for rocprofsys
#
# ======================================================================================

include_guard(GLOBAL)

include(ExternalProject)
include(ProcessorCount)

# ---------------------------------------------------------------------------------------#
#
# executables and libraries
#
# ---------------------------------------------------------------------------------------#

find_program(
    ROCPROFSYS_COPY_EXECUTABLE
    NAMES cp
    PATH_SUFFIXES bin)

find_program(
    ROCPROFSYS_NINJA_EXECUTABLE
    NAMES ninja
    PATH_SUFFIXES bin)

mark_as_advanced(ROCPROFSYS_COPY_EXECUTABLE)
mark_as_advanced(ROCPROFSYS_NINJA_EXECUTABLE)

# ---------------------------------------------------------------------------------------#
#
# variables
#
# ---------------------------------------------------------------------------------------#

processorcount(NUM_PROCS_REAL)
math(EXPR _NUM_THREADS "${NUM_PROCS_REAL} - (${NUM_PROCS_REAL} / 2)")
if(_NUM_THREADS GREATER 8)
    set(_NUM_THREADS 8)
elseif(_NUM_THREADS LESS 1)
    set(_NUM_THREADS 1)
endif()

set(ROCPROFSYS_PERFETTO_SOURCE_DIR ${PROJECT_BINARY_DIR}/external/perfetto/source)
set(ROCPROFSYS_PERFETTO_TOOLS_DIR ${PROJECT_BINARY_DIR}/external/perfetto/source/tools)
set(ROCPROFSYS_PERFETTO_BINARY_DIR
    ${PROJECT_BINARY_DIR}/external/perfetto/source/out/linux)
set(ROCPROFSYS_PERFETTO_INSTALL_DIR
    ${PROJECT_BINARY_DIR}/external/perfetto/source/out/linux/stripped)
set(ROCPROFSYS_PERFETTO_LINK_FLAGS
    "-static-libgcc"
    CACHE STRING "Link flags for perfetto")
set(ROCPROFSYS_PERFETTO_BUILD_THREADS
    ${_NUM_THREADS}
    CACHE STRING "Number of threads to use when building perfetto tools")

if(CMAKE_CXX_COMPILER_IS_CLANG)
    set(PERFETTO_IS_CLANG true)
    set(ROCPROFSYS_PERFETTO_C_FLAGS
        ""
        CACHE STRING "Perfetto C flags")
    set(ROCPROFSYS_PERFETTO_CXX_FLAGS
        ""
        CACHE STRING "Perfetto C++ flags")
else()
    set(PERFETTO_IS_CLANG false)
    set(ROCPROFSYS_PERFETTO_C_FLAGS
        "-static-libgcc -Wno-maybe-uninitialized -Wno-stringop-overflow"
        CACHE STRING "Perfetto C flags")
    set(ROCPROFSYS_PERFETTO_CXX_FLAGS
        "-static-libgcc -Wno-maybe-uninitialized -Wno-stringop-overflow -Wno-mismatched-new-delete"
        CACHE STRING "Perfetto C++ flags")
endif()

mark_as_advanced(ROCPROFSYS_PERFETTO_C_FLAGS)
mark_as_advanced(ROCPROFSYS_PERFETTO_CXX_FLAGS)
mark_as_advanced(ROCPROFSYS_PERFETTO_LINK_FLAGS)

if(NOT ROCPROFSYS_NINJA_EXECUTABLE)
    set(ROCPROFSYS_NINJA_EXECUTABLE
        ${ROCPROFSYS_PERFETTO_TOOLS_DIR}/ninja
        CACHE FILEPATH "Ninja" FORCE)
endif()

# ---------------------------------------------------------------------------------------#
#
# source tree
#
# ---------------------------------------------------------------------------------------#

if(NOT EXISTS "${ROCPROFSYS_PERFETTO_SOURCE_DIR}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory
                            ${PROJECT_BINARY_DIR}/external/perfetto)
    # cmake -E copy_directory fails for some reason
    execute_process(
        COMMAND ${ROCPROFSYS_COPY_EXECUTABLE} -r ${PROJECT_SOURCE_DIR}/external/perfetto/
                ${ROCPROFSYS_PERFETTO_SOURCE_DIR})
endif()

file(READ ${PROJECT_SOURCE_DIR}/external/perfetto/sdk/perfetto.h _PERFETTO_HEADER)

string(
    REGEX
    REPLACE " perfetto::internal::ValidateEventNameType"
            " ::perfetto::internal::ValidateEventNameType" _PERFETTO_HEADER
            "${_PERFETTO_HEADER}")

if(ROCPROFSYS_USE_SANITIZER AND ROCPROFSYS_SANITIZER_TYPE MATCHES "address")
    string(REPLACE "__asan_poison_memory_region((a), (s))" "" _PERFETTO_HEADER
                   "${_PERFETTO_HEADER}")
    string(REPLACE "__asan_unpoison_memory_region((a), (s))" "" _PERFETTO_HEADER
                   "${_PERFETTO_HEADER}")
endif()

file(WRITE ${ROCPROFSYS_PERFETTO_SOURCE_DIR}/sdk/perfetto.h.tmp "${_PERFETTO_HEADER}")

configure_file(${ROCPROFSYS_PERFETTO_SOURCE_DIR}/sdk/perfetto.h.tmp
               ${ROCPROFSYS_PERFETTO_SOURCE_DIR}/sdk/perfetto.h COPYONLY)
configure_file(${PROJECT_SOURCE_DIR}/external/perfetto/sdk/perfetto.cc
               ${ROCPROFSYS_PERFETTO_SOURCE_DIR}/sdk/perfetto.cc COPYONLY)
configure_file(${PROJECT_SOURCE_DIR}/cmake/Templates/args.gn.in
               ${ROCPROFSYS_PERFETTO_BINARY_DIR}/args.gn @ONLY)

# ---------------------------------------------------------------------------------------#
#
# build tools
#
# ---------------------------------------------------------------------------------------#

if(ROCPROFSYS_INSTALL_PERFETTO_TOOLS)
    find_program(
        ROCPROFSYS_CURL_EXECUTABLE
        NAMES curl
        PATH_SUFFIXES bin)

    if(NOT ROCPROFSYS_CURL_EXECUTABLE)
        rocprofsys_message(
            SEND_ERROR
            "curl executable cannot be found. install-build-deps script for perfetto will fail"
            )
    endif()

    externalproject_add(
        rocprofsys-perfetto-build
        PREFIX ${PROJECT_BINARY_DIR}/external/perfetto
        SOURCE_DIR ${ROCPROFSYS_PERFETTO_SOURCE_DIR}
        BUILD_IN_SOURCE 1
        PATCH_COMMAND ${ROCPROFSYS_PERFETTO_TOOLS_DIR}/install-build-deps
        CONFIGURE_COMMAND ${ROCPROFSYS_PERFETTO_TOOLS_DIR}/gn gen
                          ${ROCPROFSYS_PERFETTO_BINARY_DIR}
        BUILD_COMMAND ${ROCPROFSYS_NINJA_EXECUTABLE} -C ${ROCPROFSYS_PERFETTO_BINARY_DIR} -j
                      ${ROCPROFSYS_PERFETTO_BUILD_THREADS}
        INSTALL_COMMAND ""
        BUILD_BYPRODUCTS ${ROCPROFSYS_PERFETTO_BINARY_DIR}/args.gn)

    add_custom_target(
        rocprofsys-perfetto-clean
        COMMAND ${ROCPROFSYS_NINJA_EXECUTABLE} -t clean
        COMMAND
            ${CMAKE_COMMAND} -E rm -rf
            ${PROJECT_BINARY_DIR}/external/perfetto/src/rocprofsys-perfetto-build-stamp
        WORKING_DIRECTORY ${ROCPROFSYS_PERFETTO_BINARY_DIR}
        COMMENT "Cleaning Perfetto...")

    install(
        DIRECTORY ${ROCPROFSYS_PERFETTO_INSTALL_DIR}/
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/${PACKAGE_NAME}
        COMPONENT perfetto
        FILES_MATCHING
        PATTERN "*libperfetto.so*")

    foreach(_FILE perfetto traced tracebox traced_probes traced_perf trigger_perfetto)
        if("${_FILE}" STREQUAL "perfetto")
            string(REPLACE "_" "-" _INSTALL_FILE "rocprof-sys-${_FILE}")
        else()
            string(REPLACE "_" "-" _INSTALL_FILE "rocprof-sys-perfetto-${_FILE}")
        endif()
        install(
            PROGRAMS ${ROCPROFSYS_PERFETTO_INSTALL_DIR}/${_FILE}
            DESTINATION ${CMAKE_INSTALL_BINDIR}
            COMPONENT perfetto
            RENAME ${_INSTALL_FILE}
            OPTIONAL)
    endforeach()
endif()

# ---------------------------------------------------------------------------------------#
#
# perfetto static library
#
# ---------------------------------------------------------------------------------------#

add_library(rocprofsys-perfetto-library STATIC)
add_library(rocprofsys::rocprofsys-perfetto-library ALIAS rocprofsys-perfetto-library)
target_sources(
    rocprofsys-perfetto-library PRIVATE ${ROCPROFSYS_PERFETTO_SOURCE_DIR}/sdk/perfetto.cc
                                        ${ROCPROFSYS_PERFETTO_SOURCE_DIR}/sdk/perfetto.h)
target_link_libraries(
    rocprofsys-perfetto-library
    PRIVATE rocprofsys::rocprofsys-threading rocprofsys::rocprofsys-static-libgcc
            rocprofsys::rocprofsys-static-libstdcxx)
set_target_properties(
    rocprofsys-perfetto-library
    PROPERTIES OUTPUT_NAME perfetto
               ARCHIVE_OUTPUT_DIRECTORY ${ROCPROFSYS_PERFETTO_BINARY_DIR}
               POSITION_INDEPENDENT_CODE ON
               CXX_VISIBILITY_PRESET "internal")

set(perfetto_DIR ${ROCPROFSYS_PERFETTO_SOURCE_DIR})
set(PERFETTO_ROOT_DIR
    ${ROCPROFSYS_PERFETTO_SOURCE_DIR}
    CACHE PATH "Root Perfetto installation" FORCE)
set(PERFETTO_INCLUDE_DIR
    ${ROCPROFSYS_PERFETTO_SOURCE_DIR}/sdk
    CACHE PATH "Perfetto include folder" FORCE)
set(PERFETTO_LIBRARY
    ${ROCPROFSYS_PERFETTO_BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}perfetto${CMAKE_STATIC_LIBRARY_SUFFIX}
    CACHE FILEPATH "Perfetto library" FORCE)

mark_as_advanced(PERFETTO_ROOT_DIR)
mark_as_advanced(PERFETTO_INCLUDE_DIR)
mark_as_advanced(PERFETTO_LIBRARY)

# ---------------------------------------------------------------------------------------#
#
# perfetto interface library
#
# ---------------------------------------------------------------------------------------#

rocprofsys_target_compile_definitions(rocprofsys-perfetto INTERFACE ROCPROFSYS_USE_PERFETTO)
target_include_directories(rocprofsys-perfetto SYSTEM
                           INTERFACE $<BUILD_INTERFACE:${PERFETTO_INCLUDE_DIR}>)
target_link_libraries(
    rocprofsys-perfetto INTERFACE $<BUILD_INTERFACE:${PERFETTO_LIBRARY}>
                                  $<BUILD_INTERFACE:rocprofsys::rocprofsys-threading>)
