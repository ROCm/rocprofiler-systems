// MIT License
//
// Copyright (c) 2020, The Regents of the University of California,
// through Lawrence Berkeley National Laboratory (subject to receipt of any
// required approvals from the U.S. Dept. of Energy).  All rights reserved.
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

#include "common/join.hpp"
#include "core/common.hpp"
#include "core/components/fwd.hpp"
#include "core/defines.hpp"
#include "core/rccl.hpp"
#include "core/timemory.hpp"
#include "library/components/category_region.hpp"

#include <timemory/api/macros.hpp>
#include <timemory/components/gotcha/backends.hpp>
#include <timemory/components/macros.hpp>
#include <timemory/operations/types/set.hpp>
#include <timemory/utility/types.hpp>

#include <optional>

#if defined(ROCPROFSYS_USE_MPI)
#    include <mpi.h>
#endif

#include <atomic>
#include <functional>
#include <memory>
#include <set>
#include <string>
#include <utility>

ROCPROFSYS_COMPONENT_ALIAS(comm_data_tracker_t,
                           ::tim::component::data_tracker<float, project::omnitrace>)

namespace omnitrace
{
namespace component
{
using gotcha_data = ::tim::component::gotcha_data;

struct comm_data : base<comm_data, void>
{
    using value_type = void;
    using this_type  = comm_data;
    using base_type  = base<this_type, value_type>;
    using tracker_t  = tim::auto_tuple<comm_data_tracker_t>;
    using data_type  = float;

    struct mpi_recv
    {
        static constexpr auto value = "comm_data";
        static constexpr auto label = "MPI Comm Recv";
    };

    struct mpi_send
    {
        static constexpr auto value = "comm_data";
        static constexpr auto label = "MPI Comm Send";
    };

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

    ROCPROFSYS_DEFAULT_OBJECT(comm_data)

    static void preinit();
    static void configure();
    static void global_finalize();
    static void start() {}
    static void stop() {}

#if defined(ROCPROFSYS_USE_MPI)
    static int mpi_type_size(MPI_Datatype _datatype)
    {
        int _size = 0;
        PMPI_Type_size(_datatype, &_size);
        return _size;
    }

    // MPI_Send
    static void audit(const gotcha_data& _data, audit::incoming, const void*, int count,
                      MPI_Datatype datatype, int dst, int tag, MPI_Comm);

    // MPI_Recv
    static void audit(const gotcha_data& _data, audit::incoming, void*, int count,
                      MPI_Datatype datatype, int dst, int tag, MPI_Comm, MPI_Status*);

    // MPI_Isend
    static void audit(const gotcha_data& _data, audit::incoming, const void*, int count,
                      MPI_Datatype datatype, int dst, int tag, MPI_Comm, MPI_Request*);

    // MPI_Irecv
    static void audit(const gotcha_data& _data, audit::incoming, void*, int count,
                      MPI_Datatype datatype, int dst, int tag, MPI_Comm, MPI_Request*);

    // MPI_Bcast
    static void audit(const gotcha_data& _data, audit::incoming, void*, int count,
                      MPI_Datatype datatype, int root, MPI_Comm);

    // MPI_Allreduce
    static void audit(const gotcha_data& _data, audit::incoming, const void*, void*,
                      int count, MPI_Datatype datatype, MPI_Op, MPI_Comm);

    // MPI_Sendrecv
    static void audit(const gotcha_data& _data, audit::incoming, const void*,
                      int sendcount, MPI_Datatype sendtype, int, int sendtag, void*,
                      int recvcount, MPI_Datatype recvtype, int, int recvtag, MPI_Comm,
                      MPI_Status*);

    // MPI_Gather
    // MPI_Scatter
    static void audit(const gotcha_data& _data, audit::incoming, const void*,
                      int sendcount, MPI_Datatype sendtype, void*, int recvcount,
                      MPI_Datatype recvtype, int root, MPI_Comm);

    // MPI_Alltoall
    static void audit(const gotcha_data& _data, audit::incoming, const void*,
                      int sendcount, MPI_Datatype sendtype, void*, int recvcount,
                      MPI_Datatype recvtype, MPI_Comm);
#endif

#if defined(ROCPROFSYS_USE_RCCL)
    static auto rccl_type_size(ncclDataType_t datatype)
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
            default: return 0;
        };
    }

    // ncclReduce
    static void audit(const gotcha_data& _data, audit::incoming, const void*, const void*,
                      size_t count, ncclDataType_t datatype, ncclRedOp_t, int root,
                      ncclComm_t, hipStream_t);

    // ncclSend
    // ncclGather
    // ncclBcast
    // ncclRecv
    static void audit(const gotcha_data& _data, audit::incoming, const void*,
                      size_t count, ncclDataType_t datatype, int peer, ncclComm_t,
                      hipStream_t);

    // ncclBroadcast
    static void audit(const gotcha_data& _data, audit::incoming, const void*, const void*,
                      size_t count, ncclDataType_t datatype, int root, ncclComm_t,
                      hipStream_t);

    // ncclAllReduce
    // ncclReduceScatter
    static void audit(const gotcha_data& _data, audit::incoming, const void*, const void*,
                      size_t count, ncclDataType_t datatype, ncclRedOp_t, ncclComm_t,
                      hipStream_t);

    // ncclAllGather
    // ncclAlltoAll
    static void audit(const gotcha_data& _data, audit::incoming, const void*, const void*,
                      size_t count, ncclDataType_t datatype, ncclComm_t, hipStream_t);

#endif

private:
    static auto& add(tracker_t& _t, data_type value)
    {
        if(omnitrace::get_state() != omnitrace::State::Active)
        {
            _t.invoke<operation::set_is_invalid>(true);
            return _t;
        }
        _t.store(std::plus<data_type>{}, value);
        return _t;
    }

    static auto add(const gotcha_data& _data, data_type value)
    {
        tracker_t _t{ std::string_view{ _data.tool_id.c_str() } };
        return add(_t, value);
    }

    static auto add(std::string&& _name, data_type value)
    {
        tracker_t _t{ _name };
        return add(_t, value);
    }

    static auto add(std::string_view _name, data_type value)
    {
        tracker_t _t{ _name };
        return add(_t, value);
    }
};
}  // namespace component
}  // namespace omnitrace

#if !defined(ROCPROFSYS_EXTERN_COMPONENTS) ||                                            \
    (defined(ROCPROFSYS_EXTERN_COMPONENTS) && ROCPROFSYS_EXTERN_COMPONENTS > 0)

#    include <timemory/components/base.hpp>
#    include <timemory/components/data_tracker/components.hpp>
#    include <timemory/operations.hpp>

ROCPROFSYS_DECLARE_EXTERN_COMPONENT(
    TIMEMORY_ESC(data_tracker<float, tim::project::omnitrace>), true, float)

ROCPROFSYS_DECLARE_EXTERN_COMPONENT(comm_data, false, void)
#endif
