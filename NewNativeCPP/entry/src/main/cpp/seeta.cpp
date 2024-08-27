#include <iostream>
#include "napi/native_api.h"
#include <dlfcn.h>
#include "Struct_cv.h"
#include "seeta/FaceDatabase.h"
#include "seeta/FaceDetector.h"
#include "seeta/FaceLandmarker.h"
#include "seeta/FaceRecognizer.h"
#include "seeta/FaceTracker.h"
#include "seeta/QualityAssessor.h"
#include <array>
#include <map>
#include "opencv2/imgcodecs.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"

#include "hilog_wrapper.h"

#define MIN_FACE_SIZE 80

#define HILOGI(fmt, args...) printf("[DEBUG][%s|%d]" fmt, __func__, __LINE__, ##args)
#define HILOGE(fmt, args...) printf("[ERROR][%s|%d]" fmt, __func__, __LINE__, ##args)
// #define LOGI(fmt, ...)                                                                                                 \
//     HILOG_INFO("[SeetaFaceApp][INFO ] [%{public}s, %{public}d]" fmt "\r\n", __func__, __LINE__, ##__VA_ARGS__)
// #define LOGE(fmt, ...)                                                                                                 \
//     HILOG_INFO("[SeetaFaceApp][ERROR] [%{public}s, %{public}d]" fmt "\r\n", __func__, __LINE__, ##__VA_ARGS__)

using namespace std;
using namespace cv;

// set the running platform
seeta::ModelSetting::Device device = seeta::ModelSetting::CPU;
int id = 0;

seeta::ModelSetting FD_model("../seeta_models/fd_2_00.dat", device, id);
seeta::ModelSetting PD_model("../seeta_models/pd_2_00_pts5.dat", device, id);
seeta::ModelSetting FR_model("../seeta_models/fr_2_10.dat", device, id);

seeta::v2::FaceDetector FD(FD_model);
seeta::v2::FaceLandmarker PD(PD_model);
seeta::v2::FaceDatabase FDB(FR_model);

/**
 * Use 'FaceDetector' to get the face data brief information
 * @param FD
 * @param image
 * @return vector of SeetaFaceInfo
 */
std::vector<SeetaFaceInfo> DetectFace(seeta::FaceDetector &FD, const SeetaImageData &image) {
    auto faces = FD.detect(image);

    return vector<SeetaFaceInfo>(faces.data, faces.data + faces.size);
}

std::vector<SeetaPointF> DetectPoints(seeta::FaceLandmarker &PD, const SeetaImageData &image, const SeetaRect &face) {
    vector<SeetaPointF> points(PD.number());
    PD.mark(image, face, points.data());

    return std::move(points);
}

/**
 * Native CPP Face Register Method
 * @param filePath
 * @param FD
 * @param PD
 * @param FDB
 * @return the id
 */
static int64_t RegisterFace(const cv::String& filePath, seeta::FaceDetector &FD, seeta::FaceLandmarker &PD,
                            seeta::FaceDatabase &FDB) {
    HILOGI("start Registering: \r\n");

    FD.set(seeta::FaceDetector::PROPERTY_MIN_FACE_SIZE, MIN_FACE_SIZE);
    seeta::cv::ImageData image = cv::imread(filePath);
    vector<SeetaFaceInfo> faces = DetectFace(FD, image);
    vector<SeetaPointF> points = DetectPoints(PD, image, faces[0].pos);
    auto id = FDB.Register(image, points.data());


    HILOGI("Register end !! \r\n");

    // deleteFile(filePath);
    return id;
}

/**
 * The recognize method
 * @param filePath
 * @param FD
 * @param PD
 * @param FDB
 * @return
 */
static int64_t RecognizeFace(const cv::String& filePath, seeta::FaceDetector &FD, seeta::FaceLandmarker &PD,
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
        PD.mark(image, face.pos, points.data());                  // 获取人脸框信息
        auto score = QA.evaluate(image, face.pos, points.data()); // 获取人脸质量评分
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


static napi_value FaceRegisterMethod(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_status status;
    napi_value result = nullptr;

    status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (status != napi_ok)
        return result;
    if (argc != 1) {
        // napi_throw_error(env, NULL, "Expected one argument");
//         LOGE("get napi params number failed! this napi must have one param! \n");
        cout << "get napi params number failed! this napi must have one param! \n" << endl;
        return result;
    }

    // 获取字符串的长度
    size_t str_length;
    status = napi_get_value_string_utf8(env, args[0], NULL, 0, &str_length);
    if (status != napi_ok)
        return result;

    // 分配内存以存储字符串
    char *str = (char *)malloc(str_length + 1);
    if (str == NULL) {
//         LOGE("cannot create string \n");
        cout << "cannot create string \n" << endl;
        return result;
    }

    // 获取字符串内容
    status = napi_get_value_string_utf8(env, args[0], str, str_length + 1, &str_length);
    if (status != napi_ok) {
        free(str);
        return result;
    }

    cv::String cvStr(str);
//     int64_t regResult = RegisterFace(str, FD, PD, FDB);
    int64_t regResult = RegisterFace(cvStr, FD, PD, FDB);
    status = napi_create_int64(env, regResult, &result);
    if (status != napi_ok) {
//         LOGE("Create 64 fail \n");
        cout << "Create 64 fail \n" << endl;
        return result;
    }

    free(str);

    return result;
}


static napi_value FaceRecognizeMethod(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_status status;
    napi_value result = nullptr;


    status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (status != napi_ok)
        return result;
    if (argc != 1) {
        // napi_throw_error(env, NULL, "Expected one argument");
//         LOGE("get napi params number failed! this napi must have one param! \n");
        cout << "Wrong number of params" << endl;
        return result;
    }

    size_t str_length;
    status = napi_get_value_string_utf8(env, args[0], NULL, 0, &str_length);
    if (status != napi_ok)
        return result;

    char *str = (char *)malloc(str_length + 1);
    if (str == NULL) {
        // napi_throw_error(env, NULL, "Failed to allocate memory");
//         LOGE("cannot create string \n");
        cout << "Cannot create string \n" << endl;
        return result;
    }

    // 获取字符串内容
    status = napi_get_value_string_utf8(env, args[0], str, str_length + 1, &str_length);
    if (status != napi_ok) {
        free(str);
        return result;
    }
    cv::String cvStr(str);
    int64_t regResult = RecognizeFace(cvStr, FD, PD, FDB);
    //     int64_t regResult = RecognizeFace(str, FD, PD, FDB);

    status = napi_create_int64(env, regResult, &result);
    if (status != napi_ok) {
//         LOGE("Create 64 fail \n");
        cout << "Create 64 fail \n" << endl;
        return nullptr;
    }


    free(str);

    return result;
}


/**
 * Input: path string
 */
static napi_value LoadFDBMethod(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_status status;
    napi_value result = nullptr;


    status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (status != napi_ok)
        return result;
    if (argc != 1) {
        // napi_throw_error(env, NULL, "Expected one argument");
//         LOGE("get napi params number failed! this napi must have one param! \n");
        cout << "Fail to get the params number" << endl;
        return result;
    }

    size_t str_length;
    status = napi_get_value_string_utf8(env, args[0], NULL, 0, &str_length);
    if (status != napi_ok)
        return result;

    char *str = (char *)malloc(str_length + 1);
    if (str == NULL) {
        // napi_throw_error(env, NULL, "Failed to allocate memory");
//         LOGE("cannot create string \n");
        cout << "Cannot create string \n" << endl;
        return result;
    }

    // 获取字符串内容
    status = napi_get_value_string_utf8(env, args[0], str, str_length + 1, &str_length);
    if (status != napi_ok) {
        free(str);
        return result;
    }

    // Load the file
    bool loadResult = FDB.Load(str);
    status = napi_get_boolean(env, loadResult, &result);
    if (status != napi_ok) {
        free(str);
        return result;
    }

    free(str);

    return result;
}

/**
 * Input: path string
 */
static napi_value SaveFDBMethod(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_status status;
    napi_value result = nullptr;


    status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (status != napi_ok)
        return result;
    if (argc != 1) {
        // napi_throw_error(env, NULL, "Expected one argument");
//         LOGE("get napi params number failed! this napi must have one param! \n");
        cout << "get napi params number failed! this napi must have one param! \n" << endl;
        return result;
    }

    size_t str_length;
    status = napi_get_value_string_utf8(env, args[0], NULL, 0, &str_length);
    if (status != napi_ok)
        return result;

    char *str = (char *)malloc(str_length + 1);
    if (str == NULL) {
        // napi_throw_error(env, NULL, "Failed to allocate memory");
//         LOGE("cannot create string \n");
        cout << "cannot create string \n" << endl;
        return result;
    }

    //     // 获取字符串内容
    status = napi_get_value_string_utf8(env, args[0], str, str_length + 1, &str_length);
    if (status != napi_ok) {
        free(str);
        return result;
    }

    //     // Load the file
    bool saveResult = FDB.Save(str);
    status = napi_get_boolean(env, saveResult, &result);
    if (status != napi_ok) {
        free(str);
        return result;
    }

    free(str);

    return result;
}


static napi_value seetaTest(napi_env env, napi_callback_info info) {
    size_t requireArgc = 0;
    size_t argc = 0;


    napi_value result = nullptr;
    napi_status status;
    status = napi_create_int64(env, 10086, &result);

    return result;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"seetaTest", nullptr, seetaTest, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"FaceRegister", nullptr, FaceRegisterMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"FaceRecognize", nullptr, FaceRecognizeMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"LoadFDB", nullptr, LoadFDBMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"SaveFDB", nullptr, SaveFDBMethod, nullptr, nullptr, nullptr, napi_default, nullptr}
    
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
};
EXTERN_C_END


static napi_module registerModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "seeta",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute((constructor)) void RegisterSeetaModule(void) { napi_module_register(&registerModule); }

