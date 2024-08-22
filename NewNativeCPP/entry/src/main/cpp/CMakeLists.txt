# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(NewNativeCPP)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(SEETA_LIB_PATH ${NATIVERENDER_ROOT_PATH}/../../../libs/${OHOS_ARCH})
set(RAW_THIRDPARTY_SOURCE_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty)
include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)
add_library(entry SHARED hello.cpp getString.cpp)
add_library(seeta SHARED seeta.cpp)
# add_library(seeta2 SHARED
#    ${RAW_THIRDPARTY_SOURCE_ROOT_PATH}/seetaface2/seeta.cpp
#   )
add_subdirectory(${RAW_THIRDPARTY_SOURCE_ROOT_PATH}/seetaface2)

target_link_libraries(entry PUBLIC
    libace_napi.z.so
    libace_ndk.z.so
    libhilog_ndk.z.so
    )

target_link_libraries(seeta PUBLIC libace_napi.z.so)
# target_link_libraries(seeta2 PUBLIC libace_napi.z.so)