# -------------------------------------------------------------------------------------- #
#
# general config file tests
#
# -------------------------------------------------------------------------------------- #

file(
    WRITE ${CMAKE_CURRENT_BINARY_DIR}/invalid.cfg
    "
ROCPROFSYS_CONFIG_FILE =
FOOBAR = ON
")

if(TARGET parallel-overhead)
    set(_CONFIG_TEST_EXE $<TARGET_FILE:parallel-overhead>)
else()
    set(_CONFIG_TEST_EXE ls)
endif()

add_test(
    NAME rocprof-sys-invalid-config
    COMMAND $<TARGET_FILE:rocprof-sys-instrument> -- ${_CONFIG_TEST_EXE}
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR})

set_tests_properties(
    rocprof-sys-invalid-config
    PROPERTIES
        ENVIRONMENT
        "ROCPROFSYS_CONFIG_FILE=${CMAKE_CURRENT_BINARY_DIR}/invalid.cfg;ROCPROFSYS_CI=ON;ROCPROFSYS_CI_TIMEOUT=120"
        TIMEOUT
        120
        LABELS
        "config"
        WILL_FAIL
        ON)

add_test(
    NAME rocprof-sys-missing-config
    COMMAND $<TARGET_FILE:rocprof-sys-instrument> -- ${_CONFIG_TEST_EXE}
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR})

set_tests_properties(
    rocprof-sys-missing-config
    PROPERTIES
        ENVIRONMENT
        "ROCPROFSYS_CONFIG_FILE=${CMAKE_CURRENT_BINARY_DIR}/missing.cfg;ROCPROFSYS_CI=ON;ROCPROFSYS_CI_TIMEOUT=120"
        TIMEOUT
        120
        LABELS
        "config"
        WILL_FAIL
        ON)
