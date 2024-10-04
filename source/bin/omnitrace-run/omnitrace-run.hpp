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

#include "core/argparse.hpp"

#include <csignal>
#include <map>
#include <sched.h>
#include <set>
#include <string>
#include <string_view>
#include <vector>

using parser_data_t = rocprofsys::argparse::parser_data;

void
print_command(const parser_data_t&, std::string_view);

void
print_updated_environment(parser_data_t&, std::string_view);

void
prepare_command_for_run(char*, parser_data_t&);

void
prepare_environment_for_run(parser_data_t&);

parser_data_t&
parse_args(int argc, char** argv, parser_data_t&, bool&);

parser_data_t&
parse_command(int argc, char** argv, parser_data_t&);
