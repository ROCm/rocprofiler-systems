# -------------------------------------------------------------------------------------- #
#
# openmp tests
#
# -------------------------------------------------------------------------------------- #

if(ROCPROFSYS_OPENMP_USING_LIBOMP_LIBRARY AND ROCPROFSYS_USE_OMPT)
    set(_OMPT_PASS_REGEX "\\|_ompt_")
else()
    set(_OMPT_PASS_REGEX "")
endif()

rocprofiler_systems_add_test(
    NAME openmp-cg
    TARGET openmp-cg
    LABELS "openmp"
    REWRITE_ARGS -e -v 2 --instrument-loops
    RUNTIME_ARGS -e -v 1 --label return args
    REWRITE_TIMEOUT 180
    RUNTIME_TIMEOUT 360
    ENVIRONMENT
        "${_ompt_environment};ROCPROFSYS_USE_SAMPLING=OFF;ROCPROFSYS_COUT_OUTPUT=ON"
    REWRITE_RUN_PASS_REGEX "${_OMPT_PASS_REGEX}"
    RUNTIME_PASS_REGEX "${_OMPT_PASS_REGEX}"
    REWRITE_FAIL_REGEX "0 instrumented loops in procedure")

rocprofiler_systems_add_test(
    SKIP_RUNTIME
    NAME openmp-lu
    TARGET openmp-lu
    LABELS "openmp"
    REWRITE_ARGS -e -v 2 --instrument-loops
    RUNTIME_ARGS -e -v 1 --label return args -E ^GOMP
    REWRITE_TIMEOUT 180
    RUNTIME_TIMEOUT 360
    ENVIRONMENT
        "${_ompt_environment};ROCPROFSYS_USE_SAMPLING=ON;ROCPROFSYS_SAMPLING_FREQ=50;ROCPROFSYS_COUT_OUTPUT=ON"
    REWRITE_RUN_PASS_REGEX "${_OMPT_PASS_REGEX}"
    REWRITE_FAIL_REGEX "0 instrumented loops in procedure")

set(_ompt_sampling_environ
    "${_ompt_environment}"
    "ROCPROFSYS_VERBOSE=2"
    "ROCPROFSYS_USE_OMPT=OFF"
    "ROCPROFSYS_USE_SAMPLING=ON"
    "ROCPROFSYS_USE_PROCESS_SAMPLING=OFF"
    "ROCPROFSYS_SAMPLING_FREQ=100"
    "ROCPROFSYS_SAMPLING_DELAY=0.1"
    "ROCPROFSYS_SAMPLING_DURATION=0.25"
    "ROCPROFSYS_SAMPLING_CPUTIME=ON"
    "ROCPROFSYS_SAMPLING_REALTIME=ON"
    "ROCPROFSYS_SAMPLING_CPUTIME_FREQ=1000"
    "ROCPROFSYS_SAMPLING_REALTIME_FREQ=500"
    "ROCPROFSYS_MONOCHROME=ON")

set(_ompt_sample_no_tmpfiles_environ
    "${_ompt_environment}"
    "ROCPROFSYS_VERBOSE=2"
    "ROCPROFSYS_USE_OMPT=OFF"
    "ROCPROFSYS_USE_SAMPLING=ON"
    "ROCPROFSYS_USE_PROCESS_SAMPLING=OFF"
    "ROCPROFSYS_SAMPLING_CPUTIME=ON"
    "ROCPROFSYS_SAMPLING_REALTIME=OFF"
    "ROCPROFSYS_SAMPLING_CPUTIME_FREQ=700"
    "ROCPROFSYS_USE_TEMPORARY_FILES=OFF"
    "ROCPROFSYS_MONOCHROME=ON")

set(_ompt_sampling_samp_regex
    "Sampler for thread 0 will be triggered 1000.0x per second of CPU-time(.*)Sampler for thread 0 will be triggered 500.0x per second of wall-time(.*)Sampling will be disabled after 0.250000 seconds(.*)Sampling duration of 0.250000 seconds has elapsed. Shutting down sampling"
    )
set(_ompt_sampling_file_regex
    "sampling-duration-sampling/sampling_percent.(json|txt)(.*)sampling-duration-sampling/sampling_cpu_clock.(json|txt)(.*)sampling-duration-sampling/sampling_wall_clock.(json|txt)"
    )
set(_notmp_sampling_file_regex
    "sampling-no-tmp-files-sampling/sampling_percent.(json|txt)(.*)sampling-no-tmp-files-sampling/sampling_cpu_clock.(json|txt)(.*)sampling-no-tmp-files-sampling/sampling_wall_clock.(json|txt)"
    )

rocprofiler_systems_add_test(
    SKIP_BASELINE SKIP_RUNTIME SKIP_REWRITE
    NAME openmp-cg-sampling-duration
    TARGET openmp-cg
    LABELS "openmp;sampling-duration"
    ENVIRONMENT "${_ompt_sampling_environ}"
    SAMPLING_PASS_REGEX "${_ompt_sampling_samp_regex}(.*)${_ompt_sampling_file_regex}")

rocprofiler_systems_add_test(
    SKIP_BASELINE SKIP_RUNTIME SKIP_REWRITE
    NAME openmp-lu-sampling-duration
    TARGET openmp-lu
    LABELS "openmp;sampling-duration"
    ENVIRONMENT "${_ompt_sampling_environ}"
    SAMPLING_PASS_REGEX "${_ompt_sampling_samp_regex}(.*)${_ompt_sampling_file_regex}")

rocprofiler_systems_add_test(
    SKIP_BASELINE SKIP_RUNTIME SKIP_REWRITE
    NAME openmp-cg-sampling-no-tmp-files
    TARGET openmp-cg
    LABELS "openmp;no-tmp-files"
    ENVIRONMENT "${_ompt_sample_no_tmpfiles_environ}"
    SAMPLING_PASS_REGEX "${_notmp_sampling_file_regex}")
