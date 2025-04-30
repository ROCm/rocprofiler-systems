include(MacroUtilities)

# Set BUILD_BOOST to ON if ROCPROFSYS_BUILD_BOOST is ON
if(ROCPROFSYS_BUILD_BOOST)
    ROCPROFILER_SYSTEMS_ADD_OPTION(BUILD_BOOST "Enable building Boost internally" ON)
endif()

# Set BUILD_TBB to ON if ROCPROFSYS_BUILD_TBB is ON
if(ROCPROFSYS_BUILD_TBB)
    ROCPROFILER_SYSTEMS_ADD_OPTION(BUILD_TBB "Enable building TBB internally" ON)
endif()

# Set BUILD_ELFUTILS to ON if ROCPROFSYS_BUILD_ELFUTILS is ON
if(ROCPROFSYS_BUILD_ELFUTILS)
    ROCPROFILER_SYSTEMS_ADD_OPTION(BUILD_ELFUTILS "Enable building elfutils internally" ON)
endif()

# Set BUILD_LIBIBERTY to ON if ROCPROFSYS_BUILD_LIBIBERTY is ON
if(ROCPROFSYS_BUILD_LIBIBERTY)
    ROCPROFILER_SYSTEMS_ADD_OPTION(BUILD_LIBIBERTY "Enable building libiberty internally" ON)
endif()

set(TPL_STAGING_PREFIX "${PROJECT_BINARY_DIR}/tpls" 
    CACHE PATH "Third-party library build-tree install prefix")
file(MAKE_DIRECTORY "${TPL_STAGING_PREFIX}")
file(MAKE_DIRECTORY "${TPL_STAGING_PREFIX}/include")


# Add external dependencies to be built
include(DyninstBoost)
if(TARGET Boost-External)
    # Make Boost build serially
    set_target_properties(Boost-External PROPERTIES
        JOB_POOL_COMPILE external_deps_pool
        JOB_POOL_LINK external_deps_pool)
    # Create a prebuild target that depends on Boost
    add_custom_target(external-prebuild)
    add_dependencies(external-prebuild Boost-External)
endif()

include(DyninstTBB)
if(TARGET TBB-External AND TARGET external-prebuild)
    # Make TBB build serially and wait for Boost
    set_target_properties(TBB-External PROPERTIES
        JOB_POOL_COMPILE external_deps_pool
        JOB_POOL_LINK external_deps_pool)
    add_dependencies(external-prebuild TBB-External)
endif()

include(DyninstElfUtils)
if(TARGET ElfUtils-External AND TARGET external-prebuild)
    set_target_properties(ElfUtils-External PROPERTIES
        JOB_POOL_COMPILE external_deps_pool
        JOB_POOL_LINK external_deps_pool)
    add_dependencies(external-prebuild ElfUtils-External)
endif()

include(DyninstLibIberty)
if(TARGET LibIberty-External AND TARGET external-prebuild)
    set_target_properties(LibIberty-External PROPERTIES
        JOB_POOL_COMPILE external_deps_pool
        JOB_POOL_LINK external_deps_pool)
    add_dependencies(external-prebuild LibIberty-External)
endif()

# Final dependency check
if(NOT TARGET external-prebuild)
    message(WARNING "Not all dyninst external dependencies found. Build may fail.")
endif()

# Create a dummy target to ensure external dependencies are fully built
add_custom_target(external-deps-complete)
if(TARGET external-prebuild)
    add_dependencies(external-deps-complete external-prebuild)
endif()

if(NOT TARGET Dyninst::Boost AND TARGET Boost)
    add_library(Dyninst::Boost INTERFACE IMPORTED)
    set_target_properties(Dyninst::Boost PROPERTIES INTERFACE_LINK_LIBRARIES Boost)
    message(STATUS "Created imported target Dyninst::Boost linked to Boost")
endif()

if(NOT TARGET Dyninst::ElfUtils AND TARGET ElfUtils)
    add_library(Dyninst::ElfUtils INTERFACE IMPORTED)
    set_target_properties(Dyninst::ElfUtils PROPERTIES INTERFACE_LINK_LIBRARIES ElfUtils)
    message(STATUS "Created imported target Dyninst::ElfUtils linked to ElfUtils")
endif()

if(NOT TARGET Dyninst::TBB AND TARGET TBB)
    add_library(Dyninst::TBB INTERFACE IMPORTED)
    set_target_properties(Dyninst::TBB PROPERTIES INTERFACE_LINK_LIBRARIES TBB)
    message(STATUS "Created imported target Dyninst::TBB linked to TBB")
endif()

if(NOT TARGET Dyninst::LibIberty AND TARGET LibIberty)
    add_library(Dyninst::LibIberty INTERFACE IMPORTED)
    set_target_properties(Dyninst::LibIberty PROPERTIES INTERFACE_LINK_LIBRARIES LibIberty)
    message(STATUS "Created imported target Dyninst::LibIberty linked to LibIberty")
endif()

# for packaging
install(
    DIRECTORY ${TPL_STAGING_PREFIX}/lib/
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}
    FILES_MATCHING
    PATTERN "*${CMAKE_SHARED_LIBRARY_SUFFIX}*"
    PATTERN "*${CMAKE_STATIC_LIBRARY_SUFFIX}*"
    PATTERN "*.so*"
    PATTERN "*.a*"
    PATTERN "*.dylib*"
    PATTERN "*.dll*"
    PATTERN "*.lib*"
)