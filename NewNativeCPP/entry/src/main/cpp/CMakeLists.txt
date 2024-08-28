# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(NewNativeCPP)


# 设置 C++ 标准为 C++11
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 指定使用 libc++
add_compile_options(-stdlib=libc++)
#add_link_options(-lc++ -lc++abi)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(SEETA_LIB_PATH ${NATIVERENDER_ROOT_PATH}/../../../libs/${OHOS_ARCH}/seeta2)
set(OPENCV_LIB_PATH ${NATIVERENDER_ROOT_PATH}/../../../libs/${OHOS_ARCH}/opencv/org)

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty/seetaface2/FaceDetector/include)
include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty/seetaface2/FaceLandmarker/include)
include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty/seetaface2/FaceDetector/include)
include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty/seetaface2/FaceRecognizer/include)
include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty/seetaface2/FaceTracker/include)
include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty/seetaface2/QualityAssessor/include)
include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty/seetaface2/SeetaNet/include)
include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty/opencv/include/opencv4)
include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty/hilog/include)
# include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty/opencv/include)


add_library(entry SHARED hello.cpp getString.cpp)
add_library(seeta SHARED seeta.cpp)
# add_library(seeta2 SHARED
#    ${RAW_THIRDPARTY_SOURCE_ROOT_PATH}/seetaface2/seeta.cpp
#   )
# add_subdirectory(${RAW_THIRDPARTY_SOURCE_ROOT_PATH}/seetaface2)

target_link_libraries(entry PUBLIC
    libace_napi.z.so
    libace_ndk.z.so
    libhilog_ndk.z.so
    )


# 指定库的查找路径
set(OpenCV_LIB_PATH ${NATIVERENDER_ROOT_PATH}/../../../libs/${OHOS_ARCH}/opencv/org)

# 查找 opencv_core 库
find_library(OPENCV_CORE_LIB NAMES opencv_core PATHS ${OpenCV_LIB_PATH})

# 查找 opencv_imgcodecs 库
find_library(OPENCV_IMGCODECS_LIB NAMES opencv_imgcodecs PATHS ${OpenCV_LIB_PATH})
find_library(OPENCV_CORE_LIB NAMES opencv_core PATHS ${OpenCV_LIB_PATH})
find_library(OPENCV_IMGPROC_LIB NAMES opencv_imgproc PATHS ${OpenCV_LIB_PATH})
find_library(OPENCV_OBJDETECT_LIB NAMES opencv_objdetect PATHS ${OpenCV_LIB_PATH})


target_link_libraries(seeta PUBLIC libace_napi.z.so
                                    libace_ndk.z.so
                                    libhilog_ndk.z.so
                                    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libc++_shared.so

                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_core.so.4.8.0
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_core.so.408
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_core.so

                                   #${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_objdetect.so.408
                                    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_features2d.so.4.8.0
                                    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_features2d.so.408
                                    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_features2d.so

                                    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_flann.so.4.8.0
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_flann.so.408
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_flann.so


                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_imgproc.so.4.8.0
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_imgproc.so.408
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_flann.so

                                    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_calib3d.so.4.8.0
                                    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_calib3d.so.408
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_flann.so

                                    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_imgcodecs.so.4.8.0
                                    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_imgcodecs.so.408
                                    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_imgcodecs.so


                                   ${SEETA_LIB_PATH}/libSeetaNet.z.so
                                   ${SEETA_LIB_PATH}/libseetafaceapi.z.so
                                   ${SEETA_LIB_PATH}/libFaceDetector.z.so
                                   ${SEETA_LIB_PATH}/libFaceLandMarker.z.so
                                   ${SEETA_LIB_PATH}/libFaceRecognizer.z.so
                                   ${SEETA_LIB_PATH}/libFaceTracker.z.so
                                   ${SEETA_LIB_PATH}/libQualityAssessor.z.so
                                   )
