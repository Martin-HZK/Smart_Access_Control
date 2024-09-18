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
#include <rawfile/raw_file.h>
using namespace cv;
// using namespace std;

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x0201
#define LOG_TAG "NAPI_TAG"
// set the running platform
seeta::ModelSetting::Device device = seeta::ModelSetting::CPU;
int id = 0;


static std::unique_ptr<seeta::FaceDetector> FD;
static std::unique_ptr<seeta::FaceLandmarker> PD;
static std::unique_ptr<seeta::FaceDatabase> FDB;


static bool testStatus = false; // this is the argument used for testing the functionality of the async works

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


static napi_value seetaTestMethod(napi_env env, napi_callback_info info) {
    size_t requireArgc = 0;
    size_t argc = 0;


    napi_value result = nullptr;
    napi_status status;
    status = napi_create_int64(env, 10086, &result);

    return result;
}



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


static napi_value testNAPI(napi_env env, napi_callback_info info) {
    napi_value returnValue;
    napi_status status;
    status = napi_create_int32(env, (int32_t) test(), &returnValue);
//     char* aaa = "AAAA yes!";
//     int a = 5, b = 10;
//     OH_LOG_ERROR(LOG_APP, "Pure a: %{public}d b:%{private}d.", a, b);
//     OH_LOG_INFO(LOG_APP, "The test URL is: %{public}s", aaa);
    
    if (status != napi_ok) return NULL;

    return returnValue;
}



static napi_value LoadModelCallBackMethod(napi_env env, napi_callback_info info) {
    napi_value ret;

    try {
//         seeta::ModelSetting FD_model("/data/storage/el2/base/haps/entry/files/fd_2_00.dat", device, id);
//         seeta::ModelSetting PD_model("/data/storage/el2/base/haps/entry/files/pd_2_00_pts5.dat", device, id);
        seeta::ModelSetting FR_model("/data/storage/el2/base/haps/entry/files/fr_2_10.dat", device, id);
//         FD = std::make_unique<seeta::v2::FaceDetector>(FD_model);
//         PD = std::make_unique<seeta::v2::FaceLandmarker>(PD_model);
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
 * @return
 */
static napi_value SetStatusToDefaultMethod(napi_env env, napi_callback_info info) {
    testStatus = false;
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    //     std::abort();
//     try {
//
//         //             seeta::ModelSetting FD_model(
//         //                 "D:\\Nottingham\\OpenHarmony\\Projects\\FaceRegNew\\NewNativeCPP\\entry\\src\\main\\cpp\\seeta_models\\fd_2_00."
//         //                 "dat",
//         //                 device, id);
//         //             seeta::ModelSetting PD_model(
//         //                 "D:\\Nottingham\\OpenHarmony\\Projects\\FaceRegNew\\NewNativeCPP\\entry\\src\\main\\cpp\\seeta_models\\pd_2_00_"
//         //                 "pts5.dat",
//         //                 device, id);
//         //             seeta::ModelSetting FR_model(
//         //                 "D:\\Nottingham\\OpenHarmony\\Projects\\FaceRegNew\\NewNativeCPP\\entry\\src\\main\\cpp\\seeta_models\\fr_2_10."
//         //                 "dat",
//         //                 device, id);
//
//         //         seeta::ModelSetting FD_model("./seeta_models/fd_2_00.dat", device, id);
//         //         seeta::ModelSetting PD_model("./seeta_models/pd_2_00_pts5.dat", device, id);
//         //         seeta::ModelSetting FR_model("./seeta_models/fr_2_10.dat", device, id);
//         //         //             seeta::v2::FaceDetector FD(FD_model);
//         //         //             seeta::v2::FaceLandmarker PD(PD_model);
//         //         //             seeta::v2::FaceDatabase FDB(FR_model);
//
//
//         //                 seeta::ModelSetting FD_model("/data/storage/el2/base/haps/entry/files/fd_2_00.dat",
//         //                 device, id); seeta::ModelSetting
//         //                 PD_model("/data/storage/el2/base/haps/entry/files/pd_2_00_pts5.dat", device, id);
//         //                 seeta::ModelSetting FR_model("/data/storage/el2/base/haps/entry/files/fr_2_10.dat",
//         //                 device, id);
//         //         FD = std::make_unique<seeta::v2::FaceDetector>(FD_model);
//         //         PD = std::make_unique<seeta::v2::FaceLandmarker>(PD_model);
//         //         FDB = std::make_unique<seeta::v2::FaceDatabase>(FR_model);
//
//     } catch (const std::exception &e) {
//         OH_LOG_ERROR(LOG_APP, "Failed to initialize FaceDetector: %{public}s", e.what());
//         return nullptr;
//     }

    napi_property_descriptor desc[] = {
        {"add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"seetaTest", nullptr, seetaTestMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"LoadFDB", nullptr, LoadFDBMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"SaveFDB", nullptr, SaveFDBMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"TestNAPI", nullptr, testNAPI, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"TestOpenCV", nullptr, testOpenCV, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"LoadModelCallBack", nullptr, LoadModelCallBackMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"GetStatusTest", nullptr, GetStatusTestMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"SetStatusToDefault", nullptr, SetStatusToDefaultMethod, nullptr, nullptr, nullptr, napi_default, nullptr}

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
    //