import seetafaceapi from '@ohos.seetafaceapi';
import fs from '@ohos.file.fs';

export default class FaceUtils {

  // Encapsulate FaceRegister functionality
  async faceRegister(facePath: string):Promise<number> {
    console.log("We are here")
    return seetafaceapi.FaceRegister(facePath);
  }


  // Encapsulate FaceRecognize functionality
  async faceRecognize(filePath: string):Promise<number> {
    return seetafaceapi.FaceRecognize(filePath)
  }

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
        seetafaceapi.Load(fdbDir)

      } else {
        this.createDBFileHelper(fdbDir)
        // Load
        seetafaceapi.Load(fdbDir)
      }
      console.log('File loaded into the runtime memory')
    } catch (err) {
      console.log("[ERR] Error loading the db file")
    }

  }

  /**
   * Load the face database to the memory
   * The file is saved in the sandbox 'fileDir': data/storage/el2/base/haps/entry/files/
   */
  saveFaceDB(fileRootDir:string) {
    // let fileRootDir = getContext(this).filesDir
    let fdbDir = fileRootDir + '/Seeta.fdb'
    // only check if the file dir exists

    if (fs.accessSync(fdbDir)) {
      // Load
      seetafaceapi.Save(fdbDir)

    } else {
      this.createDBFileHelper(fdbDir)
      // Load
      seetafaceapi.Save(fdbDir)
    }
  }

  createDBFileHelper(path:string):void  {
    let newDBfile = fs.openSync(path, fs.OpenMode.CREATE)
    fs.closeSync(newDBfile)
  }

}