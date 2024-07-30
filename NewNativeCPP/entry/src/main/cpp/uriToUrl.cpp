//
// Created on 2024/7/30.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include <napi/native_api.h>
#include <string>

// 将 URI 转换为文件系统路径
std::string uriToPath(const std::string &uri) {
    const std::string fileScheme = "file://";
    if (uri.substr(0, fileScheme.size()) == fileScheme) {
        return uri.substr(fileScheme.size());
    }
    return uri;
}

// N-API 方法实现
napi_value UriToPath(napi_env env, napi_callback_info info) {
    napi_status status;

    // 获取函数参数
    size_t argc = 1;
    napi_value args[1];
    status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (status != napi_ok)
        return nullptr;

    // 确保参数数量正确
    if (argc < 1) {
        napi_throw_error(env, nullptr, "Expected one argument");
        return nullptr;
    }

    // 确保参数是一个字符串
    napi_valuetype valuetype;
    status = napi_typeof(env, args[0], &valuetype);
    if (status != napi_ok || valuetype != napi_string) {
        napi_throw_error(env, nullptr, "Expected a string as argument");
        return nullptr;
    }

    // 获取字符串的长度
    size_t str_length;
    status = napi_get_value_string_utf8(env, args[0], nullptr, 0, &str_length);
    if (status != napi_ok)
        return nullptr;

    // 分配内存以存储字符串
    char *str = (char *)malloc(str_length + 1);
    if (str == nullptr) {
        napi_throw_error(env, nullptr, "Failed to allocate memory");
        return nullptr;
    }

    // 获取字符串内容
    status = napi_get_value_string_utf8(env, args[0], str, str_length + 1, &str_length);
    if (status != napi_ok) {
        free(str);
        return nullptr;
    }

    // 调用 uriToPath 函数
    std::string resultPath = uriToPath(str);

    // 释放分配的内存
    free(str);

    // 创建一个新的 JavaScript 字符串作为返回值
    napi_value result;
    status = napi_create_string_utf8(env, resultPath.c_str(), NAPI_AUTO_LENGTH, &result);
    if (status != napi_ok)
        return nullptr;

    return result;
}

// napi_value Init(napi_env env, napi_value exports) {
//     napi_status status;
//     napi_value fn;
//
//     status = napi_create_function(env, nullptr, 0, UriToPath, nullptr, &fn);
//     if (status != napi_ok)
//         return nullptr;
//
//     status = napi_set_named_property(env, exports, "uriToPath", fn);
//     if (status != napi_ok)
//         return nullptr;
//
//     return exports;
// }

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {{"UriToPath", nullptr, UriToPath, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module urlModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterURLModule(void) { napi_module_register(&urlModule); }