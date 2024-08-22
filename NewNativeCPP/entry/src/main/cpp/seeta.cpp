#include <iostream>
#include "napi/native_api.h"
//
// int seetaTest() {
//     return 10086;
// }



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
        {"seetaTest", nullptr, seetaTest, nullptr, nullptr, nullptr, napi_default, nullptr}
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

extern "C" __attribute((constructor)) void RegisterSeetaModule(void) {
    napi_module_register(&registerModule);
}
//
// static napi_value Init(napi_env env, napi_value exports) {
//     napi_status status;
//     // 缺少相应的头文件，写成最普通的形式
// //     napi_property_attributes desc[] = {
// //         DECLARE_NAPI_FUNCTION("seetaTest", seetaTest)
// //     }
//
// }
