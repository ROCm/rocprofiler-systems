// MIT License
//
// Copyright (c) 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
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

#include "library/rocm.hpp"
#include "core/config.hpp"
#include "core/debug.hpp"
#include "core/dynamic_library.hpp"
#include "core/gpu.hpp"
#include "library/components/rocprofiler.hpp"
#include "library/components/roctracer.hpp"
#include "library/rocm/hsa_rsrc_factory.hpp"
#include "library/rocm_smi.hpp"
#include "library/rocprofiler.hpp"
#include "library/roctracer.hpp"
#include "library/runtime.hpp"
#include "library/thread_data.hpp"
#include "library/tracing.hpp"

#include <timemory/backends/cpu.hpp>
#include <timemory/backends/threading.hpp>
#include <timemory/utility/types.hpp>

#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <mutex>
#include <tuple>

using namespace rocprofsys;

namespace rocprofsys
{
namespace rocm
{
std::mutex rocm_mutex    = {};
bool       is_loaded     = false;
bool       on_load_trace = (get_env<int>("ROCP_ONLOAD_TRACE", 0) > 0);
}  // namespace rocm
}  // namespace rocprofsys

// HSA-runtime tool on-load method
extern "C"
{
    bool OnLoad(HsaApiTable* table, uint64_t runtime_version, uint64_t failed_tool_count,
                const char* const* failed_tool_names)
    {
        tim::consume_parameters(table, runtime_version, failed_tool_count,
                                failed_tool_names);

        static bool _once = false;
        if(_once) return true;
        _once = true;

        ROCPROFSYS_BASIC_VERBOSE_F(2 || rocm::on_load_trace, "Loading...\n");
        ROCPROFSYS_SCOPED_SAMPLING_ON_CHILD_THREADS(false);

        if(!tim::get_env("ROCPROFSYS_INIT_TOOLING", true)) return true;
        if(!tim::settings::enabled()) return true;

        roctracer_is_init() = true;
        ROCPROFSYS_BASIC_VERBOSE_F(1 || rocm::on_load_trace, "Loading ROCm tooling...\n");

        if(!config::settings_are_configured() && get_state() < State::Active)
            rocprofsys_init_tooling_hidden();

        ROCPROFSYS_SCOPED_THREAD_STATE(ThreadState::Internal);

        if(get_use_process_sampling() && get_use_rocm_smi())
        {
            ROCPROFSYS_VERBOSE_F(1 || rocm::on_load_trace,
                                 "Setting rocm_smi state to active...\n");
            rocm_smi::set_state(State::Active);
        }

        comp::roctracer::setup(static_cast<void*>(table), rocm::on_load_trace);

        bool _force_rocprofiler_init = false;

        bool _success = true;
        bool _is_empty =
            (config::settings_are_configured() && config::get_rocm_events().empty());
        if(!_force_rocprofiler_init && (!get_use_rocprofiler() || _is_empty))
        {
            using ::rocprofiler::util::HsaRsrcFactory;
            HsaRsrcFactory::Instance().PrintGpuAgents("ROCm");
        }

        gpu::add_hip_device_metadata();

        ROCPROFSYS_BASIC_VERBOSE_F(2 || rocm::on_load_trace, "Loading... %s\n",
                                   (_success) ? "Done" : "Failed");
        return _success;
    }

    // HSA-runtime on-unload method
    void OnUnload()
    {
        ROCPROFSYS_BASIC_VERBOSE_F(2 || rocm::on_load_trace, "Unloading...\n");
        rocprofsys_finalize_hidden();
        ROCPROFSYS_BASIC_VERBOSE_F(2 || rocm::on_load_trace, "Unloading... Done\n");
    }
}
