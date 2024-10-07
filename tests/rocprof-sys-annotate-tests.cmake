# -------------------------------------------------------------------------------------- #
#
# papi tests
#
# -------------------------------------------------------------------------------------- #

if(ROCPROFSYS_USE_PAPI
   AND (rocprof_sys_perf_event_paranoid LESS_EQUAL 3
        OR rocprof_sys_cap_sys_admin EQUAL 0
        OR rocprof_sys_cap_perfmon EQUAL 0))
    set(_annotate_environment
        "${_base_environment}"
        "ROCPROFSYS_TIMEMORY_COMPONENTS=thread_cpu_clock papi_array"
        "ROCPROFSYS_PAPI_EVENTS=perf::PERF_COUNT_SW_CPU_CLOCK"
        "ROCPROFSYS_USE_SAMPLING=OFF")

    rocprof_sys_add_test(
        SKIP_BASELINE SKIP_RUNTIME
        NAME annotate
        TARGET parallel-overhead
        RUN_ARGS 30 2 200
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
        ENVIRONMENT "${_annotate_environment}"
        LABELS "annotate;papi")

    rocprof_sys_add_validation_test(
        NAME annotate-binary-rewrite
        PERFETTO_FILE "perfetto-trace.proto"
        LABELS "annotate;papi"
        ARGS --key-names perf::PERF_COUNT_SW_CPU_CLOCK thread_cpu_clock --key-counts 8 8)

    rocprof_sys_add_validation_test(
        NAME annotate-sampling
        PERFETTO_FILE "perfetto-trace.proto"
        LABELS "papi"
        ARGS --key-names thread_cpu_clock --key-counts 6)
else()
    set(_annotate_environment
        "${_base_environment}" "ROCPROFSYS_TIMEMORY_COMPONENTS=thread_cpu_clock"
        "ROCPROFSYS_USE_SAMPLING=OFF")

    rocprof_sys_add_test(
        SKIP_BASELINE SKIP_RUNTIME
        NAME annotate
        TARGET parallel-overhead
        RUN_ARGS 30 2 200
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
        ENVIRONMENT "${_annotate_environment}"
        LABELS "annotate")

    rocprof_sys_add_validation_test(
        NAME annotate-binary-rewrite
        PERFETTO_FILE "perfetto-trace.proto"
        LABELS "annotate"
        ARGS --key-names thread_cpu_clock --key-counts 8)

    rocprof_sys_add_validation_test(
        NAME annotate-sampling
        PERFETTO_FILE "perfetto-trace.proto"
        LABELS "annotate"
        ARGS --key-names thread_cpu_clock --key-counts 6)
endif()
