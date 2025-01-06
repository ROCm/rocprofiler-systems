# -------------------------------------------------------------------------------------- #
#
# video decode tests
#
# -------------------------------------------------------------------------------------- #

rocprofiler_systems_add_test(
    SKIP_BASELINE SKIP_RUNTIME
    NAME videodecode
    TARGET videodecode
    RUN_ARGS -i ${ROCmVersion_DIR}/share/rocdecode/video/ -t 2
    REWRITE_ARGS
        -e
        -v
        2
        -R
        run
        --allow-overlapping
        --print-available
        functions
        --print-overlapping
        functions
        --print-excluded
        functions
        --print-instrumented
        functions
        --print-instructions
    LABELS "videodecode")

rocprofiler_systems_add_validation_test(
    NAME videodecode-perfetto-sampling
    PERFETTO_FILE "perfetto-trace.proto"
    LABELS "videodecode"
    ARGS --key-names vaInitialize --key-counts 1)
