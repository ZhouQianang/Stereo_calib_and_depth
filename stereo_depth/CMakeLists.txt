cmake_minimum_required(VERSION 2.8)
project(vo1)

set(CMAKE_BUILD_TYPE "Release")
add_definitions("-DENABLE_SSE")
set(CMAKE_CXX_FLAGS "-std=c++11 -O2 ${SSE_FLAGS} -msse4")
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

find_package(OpenCV 3 REQUIRED)

include_directories(
        ${OpenCV_INCLUDE_DIRS}
)

add_executable(stereo_calib stereo_calib.cpp)
target_link_libraries(stereo_calib ${OpenCV_LIBS})

add_executable(stereo_match stereo_match.cpp)
target_link_libraries(stereo_match ${OpenCV_LIBS})
