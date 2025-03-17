# -------------------------------------------------------------------------------------- #
#
# NIC performance tests
#
# -------------------------------------------------------------------------------------- #

add_test(
    NAME nic-performance-profiling
    COMMAND
    ${PROJECT_BINARY_DIR}/tests/run-sample.sh
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/tests
    )

configure_file(
    ${PROJECT_SOURCE_DIR}/tests/prog.cfg.in
    ${PROJECT_BINARY_DIR}/tests/prog.cfg.in
    COPYONLY)

configure_file(
    ${PROJECT_SOURCE_DIR}/tests/run-sample.sh
    ${PROJECT_BINARY_DIR}/tests/run-sample.sh
    COPYONLY)

configure_file(
    ${PROJECT_SOURCE_DIR}/tests/verify_proto.py
    ${PROJECT_BINARY_DIR}/tests/verify_proto.py
    COPYONLY)

configure_file(
    ${PROJECT_SOURCE_DIR}/tests/setenv.sh
    ${PROJECT_BINARY_DIR}/tests/setenv.sh
    COPYONLY)
