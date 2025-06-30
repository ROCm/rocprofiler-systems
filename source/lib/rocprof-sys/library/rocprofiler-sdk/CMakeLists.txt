#
set(rocprofiler_sdk_sources
    ${CMAKE_CURRENT_LIST_DIR}/counters.cpp
    ${CMAKE_CURRENT_LIST_DIR}/fwd.cpp
)

set(rocprofiler_sdk_headers
    ${CMAKE_CURRENT_LIST_DIR}/counters.hpp
    ${CMAKE_CURRENT_LIST_DIR}/fwd.hpp
)

if(NOT (ROCPROFSYS_ROCM_VERSION_MAJOR EQUAL 6 AND ROCPROFSYS_ROCM_VERSION_MINOR EQUAL 2))
    list(APPEND rocprofiler_sdk_sources ${CMAKE_CURRENT_LIST_DIR}/rccl.cpp)
    list(APPEND rocprofiler_sdk_headers ${CMAKE_CURRENT_LIST_DIR}/rccl.hpp)
endif()

target_sources(
    rocprofiler-systems-object-library
    PRIVATE ${rocprofiler_sdk_sources} ${rocprofiler_sdk_headers}
)
