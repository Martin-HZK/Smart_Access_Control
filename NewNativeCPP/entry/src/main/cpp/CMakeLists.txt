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
set(OPENCV_LIB_PATH ${NATIVERENDER_ROOT_PATH}/../../../libs/${OHOS_ARCH}/opencv)

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



target_link_libraries(seeta PUBLIC libace_napi.z.so
                                    libace_ndk.z.so
                                    libhilog_ndk.z.so
                                    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_calib3d.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_core.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_dnn.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_features2d.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_flann.so
                                   #${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/libopencv_gapi.so.4.8.0
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_highgui.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_imgcodecs.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_imgproc.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_ml.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_objdetect.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_photo.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_stitching.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_video.so
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/opencv/org/libopencv_videoio.so
                                   ${SEETA_LIB_PATH}/libSeetaNet.z.so
                                   ${SEETA_LIB_PATH}/libseetafaceapi.z.so
                                   ${SEETA_LIB_PATH}/libFaceDetector.z.so
                                   ${SEETA_LIB_PATH}/libFaceLandMarker.z.so
                                   ${SEETA_LIB_PATH}/libFaceRecognizer.z.so
                                   ${SEETA_LIB_PATH}/libFaceTracker.z.so
                                   ${SEETA_LIB_PATH}/libQualityAssessor.z.so
                                   )
