// #include <iostream>
// #include "napi/native_api.h"
// #include <dlfcn.h>
// #include "Struct_cv.h"
// #include "seeta/FaceDatabase.h"
// #include "seeta/FaceDetector.h"
// #include "seeta/FaceLandmarker.h"
// #include "seeta/FaceRecognizer.h"
// #include "seeta/FaceTracker.h"
// #include "seeta/QualityAssessor.h"
// #include <array>
// #include <map>
//
//
//
//
//
// EXTERN_C_START
// static napi_value InitSeeta(napi_env env, napi_value exports) {
// //     std::abort();
//     napi_property_descriptor desc[] = {
//         {"seetaTest", nullptr, seetaTestMethod, nullptr, nullptr, nullptr, napi_default, nullptr}
//    
//     };
//     napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
//     return exports;
// };
// EXTERN_C_END
//
//
// static napi_module registerModule = {
//     .nm_version = 1,
//     .nm_flags = 0,
//     .nm_filename = nullptr,
//     .nm_register_func = InitSeeta,
//     .nm_modname = "seeta",
//     .nm_priv = ((void *)0),
//     .reserved = {0},
// };
//
// extern "C" __attribute((constructor)) void RegisterSeetaModule(void) { napi_module_register(&registerModule); }
//
