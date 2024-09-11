# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(testcpp)


set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(LIB_ROOT_PATH ${NATIVERENDER_ROOT_PATH}/../../../libs/${OHOS_ARCH})
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
include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty)
include_directories(${NATIVERENDER_ROOT_PATH}/thirdparty/hilog/include)
include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(entry SHARED hello.cpp)

target_link_libraries(entry PUBLIC libace_napi.z.so
                        libhilog_ndk.z.so
                        #${OPENCV_LIB_PATH}/libopencv_core.so
                        #opencv_imgcodecs
                        ${LIB_ROOT_PATH}/libprintTest.so
                        )


target_link_libraries(entry PUBLIC
                        ${OPENCV_LIB_PATH}/3rdparty/libade.a
                        ${OPENCV_LIB_PATH}/3rdparty/liblibjpeg-turbo.a
                        ${OPENCV_LIB_PATH}/3rdparty/liblibpng.a
                        ${OPENCV_LIB_PATH}/3rdparty/liblibtiff.a
                        ${OPENCV_LIB_PATH}/3rdparty/liblibwebp.a
                        ${OPENCV_LIB_PATH}/3rdparty/libquirc.a
                        ${OPENCV_LIB_PATH}/3rdparty/liblibprotobuf.a
                        ${OPENCV_LIB_PATH}/3rdparty/liblibopenjp2.a
                        ${OPENCV_LIB_PATH}/3rdparty/libzlib.a


                        ${OPENCV_LIB_PATH}/libopencv_core.a
                        ${OPENCV_LIB_PATH}/libopencv_highgui.a
                        ${OPENCV_LIB_PATH}/libopencv_imgcodecs.a
                        ${OPENCV_LIB_PATH}/libopencv_imgproc.a

                    )

target_link_libraries(entry PUBLIC
                        ${SEETA_LIB_PATH}/libSeetaFaceDetector.a
                        ${SEETA_LIB_PATH}/libSeetaFaceLandmarker.a
                        ${SEETA_LIB_PATH}/libSeetaFaceRecognizer.a
                        ${SEETA_LIB_PATH}/libSeetaNet.a
                        ${SEETA_LIB_PATH}/libSeetaFaceTracker.a
                        ${SEETA_LIB_PATH}/libSeetaQualityAssessor.a

                    )