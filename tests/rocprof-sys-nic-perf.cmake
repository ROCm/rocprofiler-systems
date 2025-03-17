# -------------------------------------------------------------------------------------- #
#
# NIC performance tests
#
# -------------------------------------------------------------------------------------- #

# run-sample.sh will run the test.
add_test(
    NAME nic-performance-profiling
    COMMAND ${PROJECT_BINARY_DIR}/tests/run-sample.sh
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/tests)

# prog.cfg.in will be transformed by setenv.sh to generate prog.cfg.
configure_file(
    ${PROJECT_SOURCE_DIR}/tests/prog.cfg.in
    ${PROJECT_BINARY_DIR}/tests/prog.cfg.in
    COPYONLY)

# Copy run-sample.sh to tests directory.
configure_file(${PROJECT_SOURCE_DIR}/tests/run-sample.sh
               ${PROJECT_BINARY_DIR}/tests/run-sample.sh COPYONLY)

# Copy verify-proto.py to tests directory.
configure_file(${PROJECT_SOURCE_DIR}/tests/verify_proto.py
    ${PROJECT_BINARY_DIR}/tests/verify_proto.py COPYONLY)

# Copy setenv.sh to test directory.
configure_file(${PROJECT_SOURCE_DIR}/tests/setenv.sh
               ${PROJECT_BINARY_DIR}/tests/setenv.sh COPYONLY)
