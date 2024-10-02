cmake_minimum_required(VERSION 3.8)

if(NOT DEFINED ROCPROFSYS_VERSION)
    file(READ "${CMAKE_CURRENT_LIST_DIR}/../VERSION" FULL_VERSION_STRING LIMIT_COUNT 1)
    string(REGEX REPLACE "(\n|\r)" "" FULL_VERSION_STRING "${FULL_VERSION_STRING}")
    string(REGEX REPLACE "([0-9]+)\.([0-9]+)\.([0-9]+)(.*)" "\\1.\\2.\\3"
                         ROCPROFSYS_VERSION "${FULL_VERSION_STRING}")
endif()

if(NOT DEFINED OUTPUT_DIR)
    set(OUTPUT_DIR ${CMAKE_CURRENT_LIST_DIR})
endif()

message(
    STATUS
        "Writing ${OUTPUT_DIR}/rocprof-sys-install.py for rocprof-sys v${ROCPROFSYS_VERSION}"
    )

configure_file(${CMAKE_CURRENT_LIST_DIR}/../cmake/Templates/rocprof-sys-install.py.in
               ${OUTPUT_DIR}/rocprof-sys-install.py @ONLY)
