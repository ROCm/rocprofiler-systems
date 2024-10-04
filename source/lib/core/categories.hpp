// MIT License
//
// Copyright (c) 2022 Advanced Micro Devices, Inc. All Rights Reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#pragma once

#include "common/join.hpp"
#include "defines.hpp"
#include "rocprof-sys/categories.h"  // in rocprof-sys-user

#if defined(TIMEMORY_PERFETTO_CATEGORIES)
#    error "TIMEMORY_PERFETTO_CATEGORIES is already defined. Please include \"" __FILE__ "\" before including any timemory files"
#endif

#include <timemory/api.hpp>
#include <timemory/api/macros.hpp>
#include <timemory/mpl/macros.hpp>
#include <timemory/mpl/types.hpp>

#define ROCPROFSYS_DEFINE_NAME_TRAIT(NAME, DESC, ...)                                    \
    namespace tim                                                                        \
    {                                                                                    \
    namespace trait                                                                      \
    {                                                                                    \
    template <>                                                                          \
    struct perfetto_category<__VA_ARGS__>                                                \
    {                                                                                    \
        static constexpr auto value       = NAME;                                        \
        static constexpr auto description = DESC;                                        \
    };                                                                                   \
    }                                                                                    \
    }

namespace rocprofsys
{
template <size_t>
struct category_type_id;

template <typename Tp>
struct category_enum_id;

template <size_t Idx>
using category_type_id_t = typename category_type_id<Idx>::type;
}  // namespace rocprofsys

#define ROCPROFSYS_DEFINE_CATEGORY_TRAIT(TYPE, ENUM)                                     \
    namespace rocprofsys                                                                 \
    {                                                                                    \
    template <>                                                                          \
    struct category_type_id<ENUM>                                                        \
    {                                                                                    \
        using type = TYPE;                                                               \
    };                                                                                   \
    template <>                                                                          \
    struct category_enum_id<TYPE>                                                        \
    {                                                                                    \
        static constexpr auto value = ENUM;                                              \
    };                                                                                   \
    }

#define ROCPROFSYS_DECLARE_CATEGORY(NS, VALUE, ENUM, NAME, DESC)                         \
    TIMEMORY_DECLARE_NS_API(NS, VALUE)                                                   \
    ROCPROFSYS_DEFINE_NAME_TRAIT(NAME, DESC, NS::VALUE)                                  \
    ROCPROFSYS_DEFINE_CATEGORY_TRAIT(::tim::NS::VALUE, ENUM)
#define ROCPROFSYS_DEFINE_CATEGORY(NS, VALUE, ENUM, NAME, DESC)                          \
    TIMEMORY_DEFINE_NS_API(NS, VALUE)                                                    \
    ROCPROFSYS_DEFINE_NAME_TRAIT(NAME, DESC, NS::VALUE)                                  \
    ROCPROFSYS_DEFINE_CATEGORY_TRAIT(::tim::NS::VALUE, ENUM)

// clang-format off
// these are defined by rocprofsys
ROCPROFSYS_DEFINE_CATEGORY(project, rocprofsys, ROCPROFSYS_CATEGORY_NONE, "rocprofsys", "ROCm Systems Profiler project")
ROCPROFSYS_DEFINE_CATEGORY(category, host, ROCPROFSYS_CATEGORY_HOST, "host", "Host-side function tracing")
ROCPROFSYS_DEFINE_CATEGORY(category, user, ROCPROFSYS_CATEGORY_USER, "user", "User-defined regions")
ROCPROFSYS_DEFINE_CATEGORY(category, python, ROCPROFSYS_CATEGORY_PYTHON, "python", "Python regions")
ROCPROFSYS_DEFINE_CATEGORY(category, device_hip, ROCPROFSYS_CATEGORY_DEVICE_HIP, "device_hip", "Device-side functions submitted via HIP API")
ROCPROFSYS_DEFINE_CATEGORY(category, device_hsa, ROCPROFSYS_CATEGORY_DEVICE_HSA, "device_hsa", "Device-side functions submitted via HSA API")
ROCPROFSYS_DEFINE_CATEGORY(category, rocm_hip, ROCPROFSYS_CATEGORY_ROCM_HIP, "rocm_hip", "Host-side HIP functions")
ROCPROFSYS_DEFINE_CATEGORY(category, rocm_hsa, ROCPROFSYS_CATEGORY_ROCM_HSA, "rocm_hsa", "Host-side HSA functions")
ROCPROFSYS_DEFINE_CATEGORY(category, rocm_roctx, ROCPROFSYS_CATEGORY_ROCM_ROCTX, "rocm_roctx", "ROCTx labels")
ROCPROFSYS_DEFINE_CATEGORY(category, rocm_smi, ROCPROFSYS_CATEGORY_ROCM_SMI, "rocm_smi", "rocm-smi data")
ROCPROFSYS_DEFINE_CATEGORY(category, rocm_smi_busy, ROCPROFSYS_CATEGORY_ROCM_SMI_BUSY, "device_busy", "Busy percentage of a GPU device")
ROCPROFSYS_DEFINE_CATEGORY(category, rocm_smi_temp, ROCPROFSYS_CATEGORY_ROCM_SMI_TEMP, "device_temp",   "Temperature of a GPU device")
ROCPROFSYS_DEFINE_CATEGORY(category, rocm_smi_power, ROCPROFSYS_CATEGORY_ROCM_SMI_POWER, "device_power", "Power consumption of a GPU device")
ROCPROFSYS_DEFINE_CATEGORY(category, rocm_smi_memory_usage, ROCPROFSYS_CATEGORY_ROCM_SMI_MEMORY_USAGE, "device_memory_usage", "Memory usage of a GPU device")
ROCPROFSYS_DEFINE_CATEGORY(category, rocm_rccl, ROCPROFSYS_CATEGORY_ROCM_RCCL, "rccl", "ROCm Communication Collectives Library (RCCL) regions")
ROCPROFSYS_DEFINE_CATEGORY(category, roctracer, ROCPROFSYS_CATEGORY_ROCTRACER, "roctracer", "Kernel tracing provided by roctracer")
ROCPROFSYS_DEFINE_CATEGORY(category, rocprofiler, ROCPROFSYS_CATEGORY_ROCPROFILER, "rocprofiler", "HW counter data provided by rocprofiler")
ROCPROFSYS_DEFINE_CATEGORY(category, pthread, ROCPROFSYS_CATEGORY_PTHREAD, "pthread", "POSIX threading functions")
ROCPROFSYS_DEFINE_CATEGORY(category, kokkos, ROCPROFSYS_CATEGORY_KOKKOS, "kokkos", "KokkosTools regions")
ROCPROFSYS_DEFINE_CATEGORY(category, mpi, ROCPROFSYS_CATEGORY_MPI, "mpi", "MPI regions")
ROCPROFSYS_DEFINE_CATEGORY(category, ompt, ROCPROFSYS_CATEGORY_OMPT, "ompt", "OpenMP tools regions")
ROCPROFSYS_DEFINE_CATEGORY(category, process_sampling, ROCPROFSYS_CATEGORY_PROCESS_SAMPLING, "process_sampling", "Process-level data")
ROCPROFSYS_DEFINE_CATEGORY(category, comm_data, ROCPROFSYS_CATEGORY_COMM_DATA, "comm_data", "MPI/RCCL counters for tracking amount of data sent or received")
ROCPROFSYS_DEFINE_CATEGORY(category, causal, ROCPROFSYS_CATEGORY_CAUSAL, "causal", "Causal profiling data")
ROCPROFSYS_DEFINE_CATEGORY(category, cpu_freq, ROCPROFSYS_CATEGORY_CPU_FREQ, "cpu_frequency", "CPU frequency (collected in background thread)")
ROCPROFSYS_DEFINE_CATEGORY(category, process_page, ROCPROFSYS_CATEGORY_PROCESS_PAGE, "process_page_fault", "Memory page faults in process (collected in background thread)")
ROCPROFSYS_DEFINE_CATEGORY(category, process_virt, ROCPROFSYS_CATEGORY_PROCESS_VIRT, "process_virtual_memory", "Virtual memory usage in process in MB (collected in background thread)")
ROCPROFSYS_DEFINE_CATEGORY(category, process_peak, ROCPROFSYS_CATEGORY_PROCESS_PEAK, "process_memory_hwm", "Memory High-Water Mark i.e. peak memory usage (collected in background thread)")
ROCPROFSYS_DEFINE_CATEGORY(category, process_context_switch, ROCPROFSYS_CATEGORY_PROCESS_CONTEXT_SWITCH, "process_context_switch", "Context switches in process (collected in background thread)")
ROCPROFSYS_DEFINE_CATEGORY(category, process_page_fault, ROCPROFSYS_CATEGORY_PROCESS_PAGE_FAULT, "process_page_fault", "Memory page faults in process (collected in background thread)")
ROCPROFSYS_DEFINE_CATEGORY(category, process_user_mode_time, ROCPROFSYS_CATEGORY_PROCESS_USER_MODE_TIME, "process_user_cpu_time", "CPU time of functions executing in user-space in process in seconds (collected in background thread)")
ROCPROFSYS_DEFINE_CATEGORY(category, process_kernel_mode_time, ROCPROFSYS_CATEGORY_PROCESS_KERNEL_MODE_TIME, "process_kernel_cpu_time", "CPU time of functions executing in kernel-space in process in seconds (collected in background thread)")
ROCPROFSYS_DEFINE_CATEGORY(category, thread_wall_time, ROCPROFSYS_CATEGORY_THREAD_WALL_TIME, "thread_wall_time", "Wall-clock time on thread (derived from sampling)")
ROCPROFSYS_DEFINE_CATEGORY(category, thread_cpu_time, ROCPROFSYS_CATEGORY_THREAD_CPU_TIME, "thread_cpu_time", "CPU time on thread (derived from sampling)")
ROCPROFSYS_DEFINE_CATEGORY(category, thread_page_fault, ROCPROFSYS_CATEGORY_THREAD_PAGE_FAULT, "thread_page_fault", "Memory page faults on thread (derived from sampling)")
ROCPROFSYS_DEFINE_CATEGORY(category, thread_peak_memory, ROCPROFSYS_CATEGORY_THREAD_PEAK_MEMORY, "thread_peak_memory", "Peak memory usage on thread in MB (derived from sampling)")
ROCPROFSYS_DEFINE_CATEGORY(category, thread_context_switch, ROCPROFSYS_CATEGORY_THREAD_CONTEXT_SWITCH, "thread_context_switch", "Context switches on thread (derived from sampling)")
ROCPROFSYS_DEFINE_CATEGORY(category, thread_hardware_counter, ROCPROFSYS_CATEGORY_THREAD_HARDWARE_COUNTER, "thread_hardware_counter", "Hardware counter value on thread (derived from sampling)")
ROCPROFSYS_DEFINE_CATEGORY(category, kernel_hardware_counter, ROCPROFSYS_CATEGORY_KERNEL_HARDWARE_COUNTER, "kernel_hardware_counter", "Hardware counter value for kernel (deterministic)")
ROCPROFSYS_DEFINE_CATEGORY(category, numa, ROCPROFSYS_CATEGORY_NUMA, "numa", "Non-unified memory architecture")
ROCPROFSYS_DEFINE_CATEGORY(category, timer_sampling, ROCPROFSYS_CATEGORY_TIMER_SAMPLING, "timer_sampling", "Sampling based on a timer")
ROCPROFSYS_DEFINE_CATEGORY(category, overflow_sampling, ROCPROFSYS_CATEGORY_OVERFLOW_SAMPLING, "overflow_sampling", "Sampling based on a counter overflow")

ROCPROFSYS_DECLARE_CATEGORY(category, sampling, ROCPROFSYS_CATEGORY_SAMPLING, "sampling", "Host-side call-stack sampling")
// clang-format on

namespace tim
{
namespace trait
{
template <typename... Tp>
using name = perfetto_category<Tp...>;
}
}  // namespace tim

#define ROCPROFSYS_PERFETTO_CATEGORY(TYPE)                                               \
    ::perfetto::Category(::tim::trait::perfetto_category<::tim::TYPE>::value)            \
        .SetDescription(::tim::trait::perfetto_category<::tim::TYPE>::description)

#define ROCPROFSYS_PERFETTO_CATEGORIES                                                   \
    ROCPROFSYS_PERFETTO_CATEGORY(category::host),                                        \
        ROCPROFSYS_PERFETTO_CATEGORY(category::user),                                    \
        ROCPROFSYS_PERFETTO_CATEGORY(category::python),                                  \
        ROCPROFSYS_PERFETTO_CATEGORY(category::sampling),                                \
        ROCPROFSYS_PERFETTO_CATEGORY(category::device_hip),                              \
        ROCPROFSYS_PERFETTO_CATEGORY(category::device_hsa),                              \
        ROCPROFSYS_PERFETTO_CATEGORY(category::rocm_hip),                                \
        ROCPROFSYS_PERFETTO_CATEGORY(category::rocm_hsa),                                \
        ROCPROFSYS_PERFETTO_CATEGORY(category::rocm_roctx),                              \
        ROCPROFSYS_PERFETTO_CATEGORY(category::rocm_smi),                                \
        ROCPROFSYS_PERFETTO_CATEGORY(category::rocm_smi_busy),                           \
        ROCPROFSYS_PERFETTO_CATEGORY(category::rocm_smi_temp),                           \
        ROCPROFSYS_PERFETTO_CATEGORY(category::rocm_smi_power),                          \
        ROCPROFSYS_PERFETTO_CATEGORY(category::rocm_smi_memory_usage),                   \
        ROCPROFSYS_PERFETTO_CATEGORY(category::rocm_rccl),                               \
        ROCPROFSYS_PERFETTO_CATEGORY(category::roctracer),                               \
        ROCPROFSYS_PERFETTO_CATEGORY(category::rocprofiler),                             \
        ROCPROFSYS_PERFETTO_CATEGORY(category::pthread),                                 \
        ROCPROFSYS_PERFETTO_CATEGORY(category::kokkos),                                  \
        ROCPROFSYS_PERFETTO_CATEGORY(category::mpi),                                     \
        ROCPROFSYS_PERFETTO_CATEGORY(category::ompt),                                    \
        ROCPROFSYS_PERFETTO_CATEGORY(category::sampling),                                \
        ROCPROFSYS_PERFETTO_CATEGORY(category::process_sampling),                        \
        ROCPROFSYS_PERFETTO_CATEGORY(category::comm_data),                               \
        ROCPROFSYS_PERFETTO_CATEGORY(category::causal),                                  \
        ROCPROFSYS_PERFETTO_CATEGORY(category::cpu_freq),                                \
        ROCPROFSYS_PERFETTO_CATEGORY(category::process_page),                            \
        ROCPROFSYS_PERFETTO_CATEGORY(category::process_virt),                            \
        ROCPROFSYS_PERFETTO_CATEGORY(category::process_peak),                            \
        ROCPROFSYS_PERFETTO_CATEGORY(category::process_context_switch),                  \
        ROCPROFSYS_PERFETTO_CATEGORY(category::process_page_fault),                      \
        ROCPROFSYS_PERFETTO_CATEGORY(category::process_user_mode_time),                  \
        ROCPROFSYS_PERFETTO_CATEGORY(category::process_kernel_mode_time),                \
        ROCPROFSYS_PERFETTO_CATEGORY(category::thread_wall_time),                        \
        ROCPROFSYS_PERFETTO_CATEGORY(category::thread_cpu_time),                         \
        ROCPROFSYS_PERFETTO_CATEGORY(category::thread_page_fault),                       \
        ROCPROFSYS_PERFETTO_CATEGORY(category::thread_peak_memory),                      \
        ROCPROFSYS_PERFETTO_CATEGORY(category::thread_context_switch),                   \
        ROCPROFSYS_PERFETTO_CATEGORY(category::thread_hardware_counter),                 \
        ROCPROFSYS_PERFETTO_CATEGORY(category::kernel_hardware_counter),                 \
        ROCPROFSYS_PERFETTO_CATEGORY(category::numa),                                    \
        ROCPROFSYS_PERFETTO_CATEGORY(category::timer_sampling),                          \
        ROCPROFSYS_PERFETTO_CATEGORY(category::overflow_sampling),                       \
        ::perfetto::Category("timemory").SetDescription("Events from the timemory API")

#if defined(TIMEMORY_USE_PERFETTO)
#    define TIMEMORY_PERFETTO_CATEGORIES ROCPROFSYS_PERFETTO_CATEGORIES
#endif

#include <set>
#include <string>

namespace rocprofsys
{
inline namespace config
{
std::set<std::string>
get_enabled_categories();

std::set<std::string>
get_disabled_categories();
}  // namespace config

namespace categories
{
void
enable_categories(const std::set<std::string>& = config::get_enabled_categories());

void
disable_categories(const std::set<std::string>& = config::get_disabled_categories());

void
setup();

void
shutdown();
}  // namespace categories
}  // namespace rocprofsys
