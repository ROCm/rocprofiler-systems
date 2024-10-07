# -------------------------------------------------------------------------------------- #
#
# binary-rewrite and runtime-instrumentation tests
#
# -------------------------------------------------------------------------------------- #

rocprof_sys_add_test(
    NAME parallel-overhead-locks
    TARGET parallel-overhead-locks
    LABELS "locks"
    REWRITE_ARGS -e -i 256
    RUNTIME_ARGS -e -i 256
    RUN_ARGS 30 4 1000
    ENVIRONMENT
        "${_lock_environment};ROCPROFSYS_PROFILE=ON;ROCPROFSYS_TRACE=ON;ROCPROFSYS_COLLAPSE_THREADS=OFF;ROCPROFSYS_SAMPLING_REALTIME=ON;ROCPROFSYS_SAMPLING_REALTIME_FREQ=10;ROCPROFSYS_SAMPLING_REALTIME_TIDS=0;ROCPROFSYS_SAMPLING_KEEP_INTERNAL=OFF"
    REWRITE_RUN_PASS_REGEX
        "wall_clock .*\\|_pthread_create .* 4 .*\\|_pthread_mutex_lock .* 1000 .*\\|_pthread_mutex_unlock .* 1000 .*\\|_pthread_mutex_lock .* 1000 .*\\|_pthread_mutex_unlock .* 1000 .*\\|_pthread_mutex_lock .* 1000 .*\\|_pthread_mutex_unlock .* 1000 .*\\|_pthread_mutex_lock .* 1000 .*\\|_pthread_mutex_unlock .* 1000"
    RUNTIME_PASS_REGEX
        "wall_clock .*\\|_pthread_create .* 4 .*\\|_pthread_mutex_lock .* 1000 .*\\|_pthread_mutex_unlock .* 1000 .*\\|_pthread_mutex_lock .* 1000 .*\\|_pthread_mutex_unlock .* 1000 .*\\|_pthread_mutex_lock .* 1000 .*\\|_pthread_mutex_unlock .* 1000 .*\\|_pthread_mutex_lock .* 1000 .*\\|_pthread_mutex_unlock .* 1000"
    )

rocprof_sys_add_test(
    SKIP_RUNTIME
    NAME parallel-overhead-locks-timemory
    TARGET parallel-overhead-locks
    LABELS "locks"
    REWRITE_ARGS -e -v 2 --min-instructions=32 --dyninst-options InstrStackFrames SaveFPR
                 TrampRecursive
    RUN_ARGS 10 4 1000
    ENVIRONMENT
        "${_lock_environment};ROCPROFSYS_FLAT_PROFILE=ON;ROCPROFSYS_PROFILE=ON;ROCPROFSYS_TRACE=OFF;ROCPROFSYS_SAMPLING_KEEP_INTERNAL=OFF"
    REWRITE_RUN_PASS_REGEX
        "start_thread (.*) 4 (.*) pthread_mutex_lock (.*) 4000 (.*) pthread_mutex_unlock (.*) 4000"
    )
