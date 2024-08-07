import SeetafaceApi from '@ohos.SeetafaceApi';

export default class FaceUtils {

  // Encapsulate FaceRegister functionality
  async faceRegister(facePath: string):Promise<number> {
    return SeetafaceApi.FaceRegister(facePath);
  }


  // Encapsulate FaceRecognize functionality
  async faceRecognize(filePath: string):Promise<number> {
    return SeetafaceApi.FaceRecognize(filePath)
  }
}