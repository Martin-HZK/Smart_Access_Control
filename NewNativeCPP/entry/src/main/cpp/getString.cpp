//
// Created on 2024/7/28.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".


//
// Created on 2024/7/26.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "napi/native_api.h"
#include <string>
using namespace std;

static napi_value getHelloString(napi_env env, napi_callback_info info) {
    napi_value result;
    std::string words = "Hello Napi";
    if (napi_create_string_utf8(env, words.c_str(), words.length(), &result) != napi_ok) {
        return nullptr;
    }
    return result;
}

static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"getHelloString", nullptr, getHelloString, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void *)0),
    .reserved = {0},
};
extern "C" __attribute__((constructor)) void RegisterHelloModule(void) { napi_module_register(&demoModule); }
