# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(NewNativeCPP)

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

target_link_libraries(seeta PUBLIC
    libace_napi.z.so
    libace_ndk.z.so
    libhilog_ndk.z.so
    ${SEETA_LIB_PATH}/libseetafaceapi.z.so
    ${SEETA_LIB_PATH}/libFaceLandMarker.z.so
    ${SEETA_LIB_PATH}/libFaceRecognizer.z.so
    ${SEETA_LIB_PATH}/libFaceTracker.z.so
    ${SEETA_LIB_PATH}/libQualityAssessor.z.so
    ${SEETA_LIB_PATH}/libSeetaNet.z.so
    ${OPENCV_LIB_PATH}/libopencv_avcodec.z.so
    ${OPENCV_LIB_PATH}/libopencv_avdevice.z.so
    ${OPENCV_LIB_PATH}/libopencv_avfilter.z.so
    ${OPENCV_LIB_PATH}/libopencv_avformat.z.so
    ${OPENCV_LIB_PATH}/libopencv_avutil.z.so
    ${OPENCV_LIB_PATH}/libopencv_calib3d.z.so
    ${OPENCV_LIB_PATH}/libopencv_core.z.so
    ${OPENCV_LIB_PATH}/libopencv_dnn.z.so
    ${OPENCV_LIB_PATH}/libopencv_features2d.z.so
    ${OPENCV_LIB_PATH}/libopencv_flann.z.so
    ${OPENCV_LIB_PATH}/libopencv_gapi.z.so
    ${OPENCV_LIB_PATH}/libopencv_highgui.z.so
    ${OPENCV_LIB_PATH}/libopencv_imgcodecs.z.so
    ${OPENCV_LIB_PATH}/libopencv_imgproc.z.so
    ${OPENCV_LIB_PATH}/libopencv_ml.z.so
    ${OPENCV_LIB_PATH}/libopencv_objdetect.z.so
    ${OPENCV_LIB_PATH}/libopencv_photo.z.so
    ${OPENCV_LIB_PATH}/libopencv_stitching.z.so
    ${OPENCV_LIB_PATH}/libopencv_swresample.z.so
    ${OPENCV_LIB_PATH}/libopencv_swscale.z.so
    ${OPENCV_LIB_PATH}/libopencv_ts.z.so
    ${OPENCV_LIB_PATH}/libopencv_video.z.so
    ${OPENCV_LIB_PATH}/libopencv_videoio.z.so
    )

# target_link_libraries(seeta2 PUBLIC libace_napi.z.so)