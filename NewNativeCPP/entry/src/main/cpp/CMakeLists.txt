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

target_link_libraries(seeta PUBLIC libace_napi.z.so
                                    libace_ndk.z.so
                                    libhilog_ndk.z.so

                                    ${OPENCV_LIB_PATH}/libopencv_core.so
                                    ${OPENCV_LIB_PATH}/libopencv_calib3d.so
                                    ${OPENCV_LIB_PATH}/libopencv_dnn.so
                                    ${OPENCV_LIB_PATH}/libopencv_features2d.so
                                    ${OPENCV_LIB_PATH}/libopencv_flann.so
                                    ${OPENCV_LIB_PATH}/libopencv_gapi.so
                                    ${OPENCV_LIB_PATH}/libopencv_highgui.so
                                    ${OPENCV_LIB_PATH}/libopencv_imgcodecs.so
                                    ${OPENCV_LIB_PATH}/libopencv_imgproc.so
                                    ${OPENCV_LIB_PATH}/libopencv_ml.so
                                    ${OPENCV_LIB_PATH}/libopencv_objdetect.so
                                    ${OPENCV_LIB_PATH}/libopencv_photo.so
                                    ${OPENCV_LIB_PATH}/libopencv_stitching.so
                                    ${OPENCV_LIB_PATH}/libopencv_video.so
                                    ${OPENCV_LIB_PATH}/libopencv_videoio.so
                                   ${SEETA_LIB_PATH}/libSeetaNet.z.so
                                   ${SEETA_LIB_PATH}/libseetafaceapi.z.so
                                   ${SEETA_LIB_PATH}/libFaceDetector.z.so
                                   ${SEETA_LIB_PATH}/libFaceLandMarker.z.so
                                   ${SEETA_LIB_PATH}/libFaceRecognizer.z.so
                                   ${SEETA_LIB_PATH}/libFaceTracker.z.so
                                   ${SEETA_LIB_PATH}/libQualityAssessor.z.so
                                   )
