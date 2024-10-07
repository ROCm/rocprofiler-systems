cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

project(rocprof-sys-fork LANGUAGES CXX)

set(CMAKE_BUILD_TYPE "RelWithDebInfo")
string(REPLACE " " ";" _FLAGS "${CMAKE_CXX_FLAGS_DEBUG}")

find_package(Threads REQUIRED)
find_package(rocprof-sys REQUIRED COMPONENTS user)
add_executable(fork-example fork.cpp)
target_link_libraries(fork-example PRIVATE Threads::Threads rocprof-sys::rocprof-sys)
target_compile_options(fork-example PRIVATE ${_FLAGS})

if(ROCPROFSYS_INSTALL_EXAMPLES)
    install(
        TARGETS fork-example
        DESTINATION bin
        COMPONENT rocprof-sys-examples)
endif()
