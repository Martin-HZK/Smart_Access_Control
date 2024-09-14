import faceapi from 'libentry.so'
import fs from '@ohos.file.fs';
//
export default class FaceUtils {

  // test

  async openCVTest(facePath: string):Promise<boolean> {
    console.log("OPENCV Test")
    return faceapi.TestOpenCV(facePath);
  }


  // Encapsulate FaceRegister functionality
  // async faceRegister(facePath: string):Promise<number> {
  //   console.log("We are here")
  //   return seetafaceapi.FaceRegister(facePath);
  // }
  //
  //
  // // Encapsulate FaceRecognize functionality
  // async faceRecognize(filePath: string):Promise<number> {
  //   return seetafaceapi.FaceRecognize(filePath)
  // }
  //
  /**
   * Load the face database to the memory
   * The file is saved in the sandbox 'fileDir': data/storage/el2/base/haps/entry/files/
   */
  loadFaceDB(fileRootDir:string) {
    console.log("The root dir is: " + fileRootDir)

    let fdbDir = fileRootDir + '/Seeta.fdb'
    // only check if the file dir exists
    try {
      if (fs.accessSync(fdbDir)) {
        // Load
        console.log("Before load")
        let ret: boolean = faceapi.LoadFDB(fdbDir)
        console.log('This is the return value: ' + ret)

      } else {
        this.createDBFileHelper(fdbDir)
        // Load
        console.log("Before load")
        let ret: boolean = faceapi.LoadFDB(fdbDir)
        console.log('This is the return value: ' + ret)
      }
      console.log('File loaded into the runtime memory')
    } catch (err) {
      console.log("[ERR] Error loading the db file: " + err)
    }

  }
  //
  // /**
  //  * Load the face database to the memory
  //  * The file is saved in the sandbox 'fileDir': data/storage/el2/base/haps/entry/files/
  //  */
  // saveFaceDB(fileRootDir:string) {
  //   // let fileRootDir = getContext(this).filesDir
  //   let fdbDir = fileRootDir + '/Seeta.fdb'
  //   // only check if the file dir exists
  //
  //   if (fs.accessSync(fdbDir)) {
  //     // Load
  //     seetafaceapi.SaveFDB(fdbDir)
  //
  //   } else {
  //     this.createDBFileHelper(fdbDir)
  //     // Load
  //     seetafaceapi.SaveFDB(fdbDir)
  //   }
  // }
  //
  createDBFileHelper(path:string):void  {
    let newDBfile = fs.openSync(path, fs.OpenMode.CREATE)
    fs.closeSync(newDBfile)
  }



  // async loadFDBModel(): Promise<boolean> {
  //   return faceapi.LoadModelCallBack();
  // }

  // @Concurrent
  // function loadFDBModel():boolean {
  //   return faceapi.LoadModelCallBack();
  // }


  checkModelLoadStatus(): boolean {
    let ret:boolean = faceapi.GetStatusTest();
    console.log("The given load status is: " + ret)
    return ret
  }

  setFDBLoadStatusToDefault():void {
    faceapi.SetStatusToDefault();
  }

}