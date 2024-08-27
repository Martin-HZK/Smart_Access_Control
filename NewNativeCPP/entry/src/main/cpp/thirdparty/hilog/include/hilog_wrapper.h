/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#ifndef HIDUMPER_UTILS_HILOG_WRAPPER_H
#define HIDUMPER_UTILS_HILOG_WRAPPER_H
#define CONFIG_HILOG
#ifdef CONFIG_HILOG
#include "./log.h"
namespace OHOS {
namespace HiviewDFX {
#ifdef DUMPER_HILOGF
#undef DUMPER_HILOGF
#endif
#ifdef DUMPER_HILOGE
#undef DUMPER_HILOGE
#endif
#ifdef DUMPER_HILOGW
#undef DUMPER_HILOGW
#endif
#ifdef DUMPER_HILOGI
#undef DUMPER_HILOGI
#endif
#ifdef DUMPER_HILOGD
#undef DUMPER_HILOGD
#endif

// 0xD002900: subsystem:DumperMgr module:DumperManager, 8 bits reserved.
#undef LOG_DOMAIN
#define LOG_DOMAIN 0xD002900
#undef LOG_TAG
#define LOG_TAG "DumperService"

#define DUMPER_HILOGF(module, fmt, ...) \
    HILOG_FATAL(LOG_CORE, "%{public}s# " fmt, __FUNCTION__, ##__VA_ARGS__)
#define DUMPER_HILOGE(module, fmt, ...) \
    HILOG_ERROR(LOG_CORE, "%{public}s# " fmt, __FUNCTION__, ##__VA_ARGS__)
#define DUMPER_HILOGW(module, fmt, ...) \
    HILOG_WARN(LOG_CORE, "%{public}s# " fmt, __FUNCTION__, ##__VA_ARGS__)
#define DUMPER_HILOGI(module, fmt, ...) \
    HILOG_INFO(LOG_CORE, "%{public}s# " fmt, __FUNCTION__, ##__VA_ARGS__)
#define DUMPER_HILOGD(module, fmt, ...) \
    HILOG_DEBUG(LOG_CORE, "%{public}s# " fmt, __FUNCTION__, ##__VA_ARGS__)
} // namespace HiviewDFX
} // namespace OHOS
#else
#define DUMPER_HILOGF(...)
#define DUMPER_HILOGE(...)
#define DUMPER_HILOGW(...)
#define DUMPER_HILOGI(...)
#define DUMPER_HILOGD(...)
#endif // CONFIG_HILOG
#endif // HIDUMPER_UTILS_HILOG_WRAPPER_H
