//
// Created on 2024/7/28.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef AAA_FACEINFO_H
#define AAA_FACEINFO_H
#include <string>
using namespace std;
struct FaceInfo {
    int FaceNumber;
    int FacePosition;
    int FaceConfidenceScore;
    string FaceImg;
};

struct FaceImg {
    
};

struct FacePoints {
    
};

// struct 


#endif //AAA_FACEINFO_H
