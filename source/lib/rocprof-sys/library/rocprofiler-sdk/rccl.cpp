// MIT License
//
// Copyright (c) 2025 Advanced Micro Devices, Inc. All Rights Reserved.
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

#include "library/rocprofiler-sdk/rccl.hpp"

#include "core/config.hpp"
#include "core/debug.hpp"
#include "core/perfetto.hpp"

#include "library/tracing.hpp"

namespace rocprofsys
{
namespace rocprofiler_sdk
{
namespace
{
struct rccl_recv
{
    static constexpr auto value = "comm_data";
    static constexpr auto label = "RCCL Comm Recv";
};

struct rccl_send
{
    static constexpr auto value = "comm_data";
    static constexpr auto label = "RCCL Comm Send";
};

template <typename Tp, typename... Args>
void
write_perfetto_counter_track(uint64_t _val, uint64_t _begin_ts, uint64_t _end_ts)
{
    using counter_track = rocprofsys::perfetto_counter_track<Tp>;

    if(rocprofsys::get_use_perfetto() &&
       rocprofsys::get_state() == rocprofsys::State::Active)
    {
        const size_t _idx = 0;

        if(!counter_track::exists(_idx))
        {
            std::string _label =
                (_idx > 0) ? JOIN(" ", Tp::label, JOIN("", '[', _idx, ']')) : Tp::label;
            counter_track::emplace(_idx, _label, "bytes");
        }

        TRACE_COUNTER(Tp::value, counter_track::at(_idx, 0), _begin_ts, _val);
        TRACE_COUNTER(Tp::value, counter_track::at(_idx, 0), _end_ts, 0);
    }
}

static auto
rccl_type_size(ncclDataType_t datatype)
{
    switch(datatype)
    {
        case ncclInt8:
        case ncclUint8: return 1;
        case ncclFloat16: return 2;
        case ncclInt32:
        case ncclUint32:
        case ncclFloat32: return 4;
        case ncclInt64:
        case ncclUint64:
        case ncclFloat64: return 8;
        default:
            ROCPROFSYS_CI_ABORT(true, "Unsupported RCCL datatype: %i", datatype);
            return 0;
    };
}

}  // namespace

/*
 * @brief RCCL callback tracing handler
 *
 * This function processes RCCL API calls and writes the data transfer size to
 * the Perfetto counter track.
 *
 * @param record   The tracing record containing the RCCL API call information.
 * @param begin_ts The timestamp when the operation started.
 * @param end_ts   The timestamp when the operation ended.
 */
void
tool_tracing_callback_rccl(rocprofiler_callback_tracing_record_t record,
                           uint64_t begin_ts, uint64_t end_ts)
{
    if(record.kind == ROCPROFILER_CALLBACK_TRACING_RCCL_API)
    {
        auto* payload =
            static_cast<rocprofiler_callback_tracing_rccl_api_data_t*>(record.payload);

        int  size     = 0;
        int  count    = 0;
        int  datatype = 0;
        bool is_send  = false;

        switch(record.operation)
        {
            // RCCL Data Receive
            case ROCPROFILER_RCCL_API_ID_ncclAllGather:
            {
                count    = payload->args.ncclAllGather.sendcount;
                datatype = payload->args.ncclAllGather.datatype;
                is_send  = false;
                size     = count * rccl_type_size(payload->args.ncclAllGather.datatype);
            }
            break;
            case ROCPROFILER_RCCL_API_ID_ncclAllReduce:
            {
                count    = payload->args.ncclAllReduce.count;
                datatype = payload->args.ncclAllReduce.datatype;
                is_send  = false;
                size     = count * rccl_type_size(payload->args.ncclAllReduce.datatype);
            }
            break;
            case ROCPROFILER_RCCL_API_ID_ncclGather:
            {
                count    = payload->args.ncclGather.sendcount;
                datatype = payload->args.ncclGather.datatype;
                is_send  = false;
                size     = count * rccl_type_size(payload->args.ncclGather.datatype);
            }
            break;
            case ROCPROFILER_RCCL_API_ID_ncclRecv:
            {
                count    = payload->args.ncclRecv.count;
                datatype = payload->args.ncclRecv.datatype;
                is_send  = false;
                size     = count * rccl_type_size(payload->args.ncclRecv.datatype);
            }
            break;
            case ROCPROFILER_RCCL_API_ID_ncclReduce:
            {
                count    = payload->args.ncclReduce.count;
                datatype = payload->args.ncclReduce.datatype;
                is_send  = false;
                size     = count * rccl_type_size(payload->args.ncclReduce.datatype);
            }
            break;

            // RCCL Data Send
            case ROCPROFILER_RCCL_API_ID_ncclBroadcast:
            {
                is_send  = true;
                count    = payload->args.ncclBroadcast.count;
                datatype = payload->args.ncclBroadcast.datatype;
                size     = count * rccl_type_size(payload->args.ncclBroadcast.datatype);
            }
            break;
            case ROCPROFILER_RCCL_API_ID_ncclReduceScatter:
            {
                is_send  = true;
                count    = payload->args.ncclReduceScatter.recvcount;
                datatype = payload->args.ncclReduceScatter.datatype;
                size = count * rccl_type_size(payload->args.ncclReduceScatter.datatype);
            }
            break;
            case ROCPROFILER_RCCL_API_ID_ncclSend:
            {
                is_send  = true;
                count    = payload->args.ncclSend.count;
                datatype = payload->args.ncclSend.datatype;
                size     = count * rccl_type_size(payload->args.ncclSend.datatype);
            }
            break;

            default:
            {
                // Skip other RCCL operations
                break;
            }
        }

        if(config::get_use_perfetto() && size > 0)
        {
            if(is_send)
            {
                write_perfetto_counter_track<rccl_send>(size, begin_ts, end_ts);
            }
            else
            {
                write_perfetto_counter_track<rccl_recv>(size, begin_ts, end_ts);
            }
        }
    }
}

}  // namespace rocprofiler_sdk
}  // namespace rocprofsys
