#include "napi/native_api.h"
#include <hilog/log.h>
#include <cstdlib>
#include "include/helloTest.h"
#include <js_native_api.h>
#include <js_native_api_types.h>
#include "opencv2/opencv.hpp"
#include "seeta/FaceDatabase.h"
#include "seeta/FaceDetector.h"
#include "seeta/FaceLandmarker.h"
#include "seeta/QualityAssessor.h"
#include <rawfile/raw_file.h>
#include <vector>
#include <string>
#include "Struct_cv.h"
using namespace cv;
using namespace std;

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x0201
#define LOG_TAG "NAPI_TAG"
#define MIN_FACE_SIZE 80
// set the running platform
seeta::ModelSetting::Device device = seeta::ModelSetting::CPU;
int id = 0;


static std::unique_ptr<seeta::FaceDetector> FD;
static std::unique_ptr<seeta::FaceLandmarker> PD;
static std::unique_ptr<seeta::FaceDatabase> FDB;


static bool testStatus = false; // this is the argument used for testing the functionality of the async works

/**
 * This is the test method on the functionality of Native API
 * @param env
 * @param info
 * @return Add result
 */
static napi_value Add(napi_env env, napi_callback_info info) {
    size_t requireArgc = 2;
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);

    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    double value1;
    napi_get_value_double(env, args[1], &value1);

    napi_value sum;
    napi_create_double(env, value0 + value1, &sum);

    return sum;
}


/**
 * This load method fetch the db file from the disk and get it into the memory for further performance
 * @param env
 * @param info
 * @return the boolean value of whether the db is successfully loaded
 */
static napi_value LoadFDBMethod(napi_env env, napi_callback_info info) {
    

    napi_status status;

    // 获取函数调用的参数
    size_t argc = 1; // 期望一个参数
    napi_value args[1];
    status = napi_get_cb_info(env, info, &argc, args, NULL, NULL);
    if (status != napi_ok) return NULL;

    // 检查参数是否为字符串类型
    napi_valuetype valuetype;
    status = napi_typeof(env, args[0], &valuetype);
    if (status != napi_ok || valuetype != napi_string) {
        napi_throw_type_error(env, NULL, "Expected a string as argument");
        return NULL;
    }

    // 获取字符串的长度
    size_t str_len;
    status = napi_get_value_string_utf8(env, args[0], NULL, 0, &str_len);
    if (status != napi_ok) return NULL;

    // 分配内存以存储字符串
    char* str = (char*)malloc(str_len + 1);
    if (str == NULL) {
        napi_throw_error(env, NULL, "Memory allocation failed");
        return NULL;
    }

    // 将字符串值复制到缓冲区中
    status = napi_get_value_string_utf8(env, args[0], str, str_len + 1, &str_len);
    if (status != napi_ok) {
        free(str);
        return NULL;
    }

    OH_LOG_INFO(LOG_APP, "The FDB storage path is: %{public}s",str);
    bool myBool = FDB->Load(str);
    OH_LOG_INFO(LOG_APP, "The FDB load status is: %{public}d", myBool);
    free(str);
//    
     // 假设我们想返回true
//     bool myBool = true;

    // 创建一个napi_value来表示布尔值
    napi_value returnValue;
    status = napi_get_boolean(env, myBool, &returnValue);
    if (status != napi_ok) return NULL;

    // 返回布尔值
    return returnValue;
}

/**
 * This NAPI enables ArkTS to save the FDB data in the memory to the disk for permanent storage
 * @param env
 * @param info
 * @return boolean value of storage result
 */
static napi_value SaveFDBMethod(napi_env env, napi_callback_info info) {
    napi_status status;

    // 获取函数调用的参数
    size_t argc = 1; // 期望一个参数
    napi_value args[1];
    status = napi_get_cb_info(env, info, &argc, args, NULL, NULL);
    if (status != napi_ok)
        return NULL;

    // 检查参数是否为字符串类型
    napi_valuetype valuetype;
    status = napi_typeof(env, args[0], &valuetype);
    if (status != napi_ok || valuetype != napi_string) {
        napi_throw_type_error(env, NULL, "Expected a string as argument");
        return NULL;
    }

    // 获取字符串的长度
    size_t str_len;
    status = napi_get_value_string_utf8(env, args[0], NULL, 0, &str_len);
    if (status != napi_ok)
        return NULL;

    // 分配内存以存储字符串
    char *str = (char *)malloc(str_len + 1);
    if (str == NULL) {
        napi_throw_error(env, NULL, "Memory allocation failed");
        return NULL;
    }

    // 将字符串值复制到缓冲区中
    status = napi_get_value_string_utf8(env, args[0], str, str_len + 1, &str_len);
    if (status != napi_ok) {
        free(str);
        return NULL;
    }

    OH_LOG_INFO(LOG_APP, "The FDB storage path is: %{public}s", str);
    bool myBool = FDB->Save(str);
    OH_LOG_INFO(LOG_APP, "The FDB save status is: %{public}d", myBool);
    free(str);
    
    napi_value returnValue;
    status = napi_get_boolean(env, myBool, &returnValue);
    if (status != napi_ok)
        return NULL;

    // 返回布尔值
    return returnValue;
}

/**
 * This is the tester of the basic functionality, imread, of the OpenCV library
 * @param env
 * @param info
 * @return test status
 */
static napi_value testOpenCV(napi_env env, napi_callback_info info) {
        napi_status status;

    // 获取函数调用的参数
    size_t argc = 1; // 期望一个参数
    napi_value args[1];
    status = napi_get_cb_info(env, info, &argc, args, NULL, NULL);
    if (status != napi_ok) return NULL;

    // 检查参数是否为字符串类型
    napi_valuetype valuetype;
    status = napi_typeof(env, args[0], &valuetype);
    if (status != napi_ok || valuetype != napi_string) {
        napi_throw_type_error(env, NULL, "Expected a string as argument");
        return NULL;
    }

    // 获取字符串的长度
    size_t str_len;
    status = napi_get_value_string_utf8(env, args[0], NULL, 0, &str_len);
    if (status != napi_ok) return NULL;

    // 分配内存以存储字符串
    char* str = (char*)malloc(str_len + 1);
    if (str == NULL) {
        napi_throw_error(env, NULL, "Memory allocation failed");
        return NULL;
    }

    // 将字符串值复制到缓冲区中
    status = napi_get_value_string_utf8(env, args[0], str, str_len + 1, &str_len);
    if (status != napi_ok) {
        free(str);
        return NULL;
    }

    // 使用字符串（这里简单打印输出）
//     printf("Received string: %s\n", str);

    
    OH_LOG_INFO(LOG_APP, "The test URL is: %{public}s", str);
    
    cv::String filePath = str;
    Mat img = cv::imread(str);
    int ret = img.channels();
    
    OH_LOG_INFO(LOG_APP, "The image channels is: %{public}d", ret);

    // 假设我们想返回true
    bool myBool = true;

    // 创建一个napi_value来表示布尔值
    napi_value returnValue;
    status = napi_get_boolean(env, myBool, &returnValue);
    if (status != napi_ok) return NULL;
    

    // 使用完字符串后，释放内存
    free(str);

    return returnValue;

}

//
// static napi_value testNAPI(napi_env env, napi_callback_info info) {
//     napi_value returnValue;
//     napi_status status;
//     status = napi_create_int32(env, (int32_t) test(), &returnValue);
// //     char* aaa = "AAAA yes!";
// //     int a = 5, b = 10;
// //     OH_LOG_ERROR(LOG_APP, "Pure a: %{public}d b:%{private}d.", a, b);
// //     OH_LOG_INFO(LOG_APP, "The test URL is: %{public}s", aaa);
//    
//     if (status != napi_ok) return NULL;
//
//     return returnValue;
// }


/**
 * This is the method to load the Seetaface models and finish the initialization of facedatabase
 * @param env
 * @param info
 * @return boolean value of whether the models are successfully loaded
 */
static napi_value LoadModelCallBackMethod(napi_env env, napi_callback_info info) {
    napi_value ret;

    try {
        seeta::ModelSetting FD_model("/data/storage/el2/base/haps/entry/files/fd_2_00.dat", device, id);
        seeta::ModelSetting PD_model("/data/storage/el2/base/haps/entry/files/pd_2_00_pts5.dat", device, id);
        seeta::ModelSetting FR_model("/data/storage/el2/base/haps/entry/files/fr_2_10.dat", device, id);
        FD = std::make_unique<seeta::v2::FaceDetector>(FD_model);
        PD = std::make_unique<seeta::v2::FaceLandmarker>(PD_model);
        FDB = std::make_unique<seeta::v2::FaceDatabase>(FR_model);
        
    } catch (const std::exception &e) {
        OH_LOG_ERROR(LOG_APP, "Failed to initialize FaceDetector: %{public}s", e.what());
        napi_status ret_status = napi_get_boolean(env, false, &ret);
        
        return ret;
    }
    
    OH_LOG_INFO(LOG_APP, "[NAPI] Successfully initialize the FaceDetector");
    testStatus  = true;
    
    napi_get_boolean(env, true, &ret);
    
    return ret;
}

/**
 * This NAPI provide ArkTS with the current status of Model loading
 * @param env
 * @param info
 * @return boolean value of Model loading status 
 */
static napi_value GetStatusTestMethod(napi_env env, napi_callback_info info) {
    napi_value ret;
    napi_status retStatus;
    retStatus = napi_get_boolean(env, testStatus, &ret);

    if (retStatus != napi_ok)
        return NULL;

    return ret;
}

/**
 * After we finish the loading process, we need to set the status back to false
 * @param env
 * @return NULL
 */
static napi_value SetStatusToDefaultMethod(napi_env env, napi_callback_info info) {
    testStatus = false;
    return nullptr;
}

/**
 * The helper function for face detection
 * @param FD
 * @param image
 * @return
 */
static std::vector<SeetaFaceInfo> DetectFace(seeta::FaceDetector &FD, const SeetaImageData &image) {

    auto faces = FD.detect(image);


    return std::vector<SeetaFaceInfo>(faces.data, faces.data + faces.size);
}


static std::vector<SeetaPointF> DetectPoints(seeta::FaceLandmarker &PD, const SeetaImageData &image, const SeetaRect &face) {

    std::vector<SeetaPointF> points(PD.number());

    PD.mark(image, face, points.data());


    return std::move(points);
}

/**
 * Helper function for face register
 * @param filePath
 * @param FD
 * @param PD
 * @param FDB
 * @return
 */
static int64_t RegisterFace(const cv::String &filePath, seeta::FaceDetector &FD, seeta::FaceLandmarker &PD,

                            seeta::FaceDatabase &FDB) {

    std::cout << "Start Registering face..." << std::endl;

    FD.set(seeta::FaceDetector::PROPERTY_MIN_FACE_SIZE, MIN_FACE_SIZE);

    seeta::cv::ImageData image = cv::imread(filePath);

    vector<SeetaFaceInfo> faces = DetectFace(FD, image);

    vector<SeetaPointF> points = DetectPoints(PD, image, faces[0].pos);

    auto id = FDB.Register(image, points.data());


    cout << "The face register ends!" << endl;


    return id;
}


static int64_t RecognizeFace(const cv::String &filePath, seeta::FaceDetector &FD, seeta::FaceLandmarker &PD,

                             seeta::FaceDatabase &FDB) {

    seeta::QualityAssessor QA;

    float threshold = 0.7f; // 识别阈值

    cv::Mat frame = cv::imread(filePath);

    seeta::cv::ImageData image = frame;


    auto f = FD.detect(image);

    vector<SeetaFaceInfo> faces = vector<SeetaFaceInfo>(f.data, f.data + f.size);

    for (int i = 0; i < faces.size(); i++) {

        SeetaFaceInfo &face = faces[i];

        int64_t index = -1;

        float similarity = 0;

        vector<SeetaPointF> points(PD.number());

        PD.mark(image, face.pos, points.data()); // 获取人脸框信息

//         auto score = QA.evaluate(image, face.pos, points.data()); // 获取人脸质量评分
        auto score = 1; // we temporarily disable the quality checker
        char *name;

        if (score == 0) {

            // name = "ignored";

        } else {

            auto queried = FDB.QueryTop(image, points.data(), 1, &index, &similarity); // 从注册的人脸数据库中对比相似度

            if (queried < 1) {

                continue;
            }

            // if the result got return 0 instead!

            if (similarity > threshold) {

                return 1;
            }
        }
    }

    return 0;
}

/**
 * NAPI provided for ArkTS to register new come face data.
 * @param env
 * @param info
 * @return True if the successfully returned.
 */
static napi_value FaceRegisterMethod(napi_env env, napi_callback_info info) {
    napi_status status;


    // 获取函数调用的参数
    size_t argc = 1; // 期望一个参数
    napi_value args[1];
    status = napi_get_cb_info(env, info, &argc, args, NULL, NULL);
    if (status != napi_ok)
        return NULL;

    // 检查参数是否为字符串类型
    napi_valuetype valuetype;
    status = napi_typeof(env, args[0], &valuetype);
    if (status != napi_ok || valuetype != napi_string) {
        napi_throw_type_error(env, NULL, "Expected a string as argument");
        return NULL;
    }

    // 获取字符串的长度
    size_t str_len;
    status = napi_get_value_string_utf8(env, args[0], NULL, 0, &str_len);
    if (status != napi_ok)
        return NULL;

    // 分配内存以存储字符串
    char *str = (char *)malloc(str_len + 1);
    if (str == NULL) {
        napi_throw_error(env, NULL, "Memory allocation failed");
        return NULL;
    }

    // 将字符串值复制到缓冲区中
    status = napi_get_value_string_utf8(env, args[0], str, str_len + 1, &str_len);
    if (status != napi_ok) {
        free(str);
        return NULL;
    }
    
    std::string filePath(str);
    napi_value ret;
    int64_t id = -1;
    try {
        OH_LOG_INFO(LOG_APP, "Start registering faces...");

        id = RegisterFace(filePath, *FD, *PD, *FDB);
        OH_LOG_INFO(LOG_APP, "Successfully registered!The face id is: %{public}d.", id);
    } catch (const std::exception &e) {
        OH_LOG_ERROR(LOG_APP, "Failed to initialize FaceDetector: %{public}s", e.what());
        napi_status ret_status = napi_get_boolean(env, false, &ret);

        return ret;
    }

    if(id == -1) {
        napi_get_boolean(env, false, &ret);
    } else {
        napi_get_boolean(env, true, &ret);
    }
    
    
    return ret;
}

static napi_value FaceRecognizerMethod(napi_env env, napi_callback_info info) {
    napi_status status;


    // 获取函数调用的参数
    size_t argc = 1; // 期望一个参数
    napi_value args[1];
    status = napi_get_cb_info(env, info, &argc, args, NULL, NULL);
    if (status != napi_ok)
        return NULL;

    // 检查参数是否为字符串类型
    napi_valuetype valuetype;
    status = napi_typeof(env, args[0], &valuetype);
    if (status != napi_ok || valuetype != napi_string) {
        napi_throw_type_error(env, NULL, "Expected a string as argument");
        return NULL;
    }

    // 获取字符串的长度
    size_t str_len;
    status = napi_get_value_string_utf8(env, args[0], NULL, 0, &str_len);
    if (status != napi_ok)
        return NULL;

    // 分配内存以存储字符串
    char *str = (char *)malloc(str_len + 1);
    if (str == NULL) {
        napi_throw_error(env, NULL, "Memory allocation failed");
        return NULL;
    }

    // 将字符串值复制到缓冲区中
    status = napi_get_value_string_utf8(env, args[0], str, str_len + 1, &str_len);
    if (status != napi_ok) {
        free(str);
        return NULL;
    }

    std::string filePath(str);
    napi_value ret;
    OH_LOG_INFO(LOG_APP, "Start recognizing faces...");
    int64_t isSuccess = RecognizeFace(filePath, *FD, *PD, *FDB);


    //     napi_create_int64(env, isSuccess, &ret);

    if (isSuccess == 0) {
        napi_get_boolean(env, false, &ret);
        OH_LOG_INFO(LOG_APP, "Face lost!!!");

    } else {
        napi_get_boolean(env, true, &ret);
        OH_LOG_INFO(LOG_APP, "Face found!!!");
    }

    return ret;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    //     std::abort();


    napi_property_descriptor desc[] = {
        {"add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"LoadFDB", nullptr, LoadFDBMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"SaveFDB", nullptr, SaveFDBMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        //         {"TestNAPI", nullptr, testNAPI, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"TestOpenCV", nullptr, testOpenCV, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"LoadModelCallBack", nullptr, LoadModelCallBackMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"GetStatusTest", nullptr, GetStatusTestMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"SetStatusToDefault", nullptr, SetStatusToDefaultMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"FaceRegister", nullptr, FaceRegisterMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"FaceRecognize", nullptr, FaceRecognizerMethod, nullptr, nullptr, nullptr, napi_default, nullptr},

    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
    }
    EXTERN_C_END

    static napi_module demoModule = {
        .nm_version = 1,
        .nm_flags = 0,
        .nm_filename = nullptr,
        .nm_register_func = Init,
        .nm_modname = "entry",
        .nm_priv = ((void *)0),
        .reserved = {0},
    };

    extern "C" __attribute__((constructor)) void RegisterEntryModule(void) {
        //     abort();
        napi_module_register(&demoModule);
    }