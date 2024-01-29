cmake_minimum_required(VERSION 3.27)
project(minisha256sum)

find_package(OpenSSL REQUIRED)
find_package(Boost REQUIRED COMPONENTS chrono)

set(CMAKE_CXX_STANDARD 20)

add_executable(minisha256sum src/main.cpp)
target_link_libraries(minisha256sum Boost::chrono OpenSSL::SSL)

install(TARGETS minisha256sum DESTINATION bin)
