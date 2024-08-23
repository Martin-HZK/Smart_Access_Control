// import fileio from '@ohos.fileio';
// import photoAccessHelper from '@ohos.file.photoAccessHelper';

import fs from '@ohos.file.fs';
import cryptoFramework from '@ohos.security.cryptoFramework';
import { BusinessError } from '@ohos.base';
import camera from '@ohos.multimedia.camera';
import common from '@ohos.app.ability.common';
import image from '@ohos.multimedia.image';

export default class Camera {
  private cameraManager?: camera.CameraManager
  private cameraInput?: camera.CameraInput
  public previewOutput?: camera.PreviewOutput
  public photoOutput?: camera.PhotoOutput
  private photoSession?: camera.PhotoSession
  private receiver: image.ImageReceiver | undefined = undefined;
  /**
   * This string is for holding the storage path that temporarily stored
   */
  private tmpPhotoPath:string = 'WrongPath'

  async initCamera(surfaceId: string): Promise<void> {
    console.log('ok get')

    // this.cameraManager = camera.getCameraManager(getContext(this) as common.UIAbilityContext);
    let baseContext:common.BaseContext = getContext(this)
    this.cameraManager = camera.getCameraManager(baseContext)
    let cameraArray: Array<camera.CameraDevice> = this.cameraManager.getSupportedCameras();
    console.log('Number of devices: '+ cameraArray.length)
    let cameraDevice = cameraArray[0]
    this.cameraInput = this.cameraManager.createCameraInput(cameraDevice);
    await this.cameraInput.open();
    console.log('session start')

    let cameraOutputCap: camera.CameraOutputCapability =
      this.cameraManager!.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_PHOTO);
    let previewProfilesArray: Array<camera.Profile> = cameraOutputCap.previewProfiles;
    let photoProfilesArray: Array<camera.Profile> = cameraOutputCap.photoProfiles;
    this.previewOutput = this.cameraManager!.createPreviewOutput(previewProfilesArray[0], surfaceId);
    let size: image.Size = {
      height: 2592, width: 1200
    };
    this.receiver = image.createImageReceiver(size, image.ImageFormat.JPEG, 8);
    this.photoOutput = this.cameraManager!.createPhotoOutput(photoProfilesArray[0]);
    this.photoOutput.on('photoAvailable', (errCode: BusinessError, photo: camera.Photo): void => {
      console.log("1 time");

      let imageObj = photo.main;
      imageObj.getComponent(image.ComponentType.JPEG, async (errCode: BusinessError, component: image.Component) => {
        if (errCode || component === undefined) {
          return;
        }
        let buffer: ArrayBuffer;
        buffer = component.byteBuffer;
        console.info(JSON.stringify(buffer));
        // console.log("We are ready for saving!")
        // this.tmpPhotoPath = await this.savePicture(buffer);
        await this.savePicture(buffer);
        console.log("The tmpImg path in photoOutput is: " + this.tmpPhotoPath)
      })
      imageObj.release();
    })
    this.photoSession = this.cameraManager!.createSession(camera.SceneMode.NORMAL_PHOTO);
    this.photoSession.beginConfig();
    this.photoSession.addInput(this.cameraInput);
    this.photoSession.addOutput(this.previewOutput);
    this.photoSession.addOutput(this.photoOutput);
    await this.photoSession.commitConfig();
    await this.photoSession.start();
    this.photoSession.on('error', (error: BusinessError) => {
      console.error(`Photo session error code: ${error.code}`);
    });
  }

  async takePicture():Promise<void> {
    console.log('takePicture');
    this.photoOutput!.capture();
  }

  // async takePicture():Promise<string> {
  //   console.log('takePicture');
  //   this.photoOutput!.capture();
  //   console.log("TakePicture the img path: " + this.tmpPhotoPath)
  //   return this.tmpPhotoPath
  // }

  getTmpImgPath(): string {
    return this.tmpPhotoPath
  }


  async savePicture(buffer: ArrayBuffer): Promise<string> {
    // let photoHelper: photoAccessHelper.PhotoAccessHelper =
    //   photoAccessHelper.getPhotoAccessHelper(getContext(this) as common.UIAbilityContext);
    // let options: photoAccessHelper.CreateOptions = {
    //   title: Date.now().toString()
    // };
    // let photoUri: string = await photoHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg', options);
    // // console.log('hi this is phone uri')
    // console.info('hi this is uri'+photoUri);
    //
    // //createAsset的调用需要ohos.permission.READ_IMAGEVIDEO和ohos.permission.WRITE_IMAGEVIDEO的权限
    // // let file: fileIo.File = fileIo.openSync(photoUri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    // // await fileIo.write(file.fd, buffer);
    // // fileIo.closeSync(file);
    // let file = fs.openSync(photoUri, fs.OpenMode.READ_WRITE|fs.OpenMode.CREATE)
    // await fs.write(file.fd, buffer)
    // fs.closeSync(file)
    try {
      let rdmPicId: number = this.doRandBySync()
      let rdmStoragePath = getContext(this).filesDir+"/tmp"+rdmPicId+".jpg"
      // this.tmpPhotoPath = rdmStoragePath
      // console.log("the tmp photo path is: "+ this.tmpPhotoPath)
      console.log('The random storage path is: '+ rdmStoragePath)
      let file = fs.openSync(rdmStoragePath,fs.OpenMode.READ_WRITE|fs.OpenMode.CREATE)
      console.log("OpenSync successfully, fd: ${file.fd}")
      await fs.writeSync(file.fd, buffer)
      console.log("Write successfully")
      fs.close(file.fd)
      return rdmStoragePath
    } catch(err) {
      console.error("Error here")
      return ''
    }

  }

  async releaseCamera(): Promise<void> {
    if (this.cameraInput) {
      await this.cameraInput.close();
    }
    if (this.previewOutput) {
      await this.previewOutput.release();
    }
    if (this.photoOutput) {
      await this.photoOutput.release()
    }
    if (this.photoSession) {
      await this.photoSession.release();
      this.photoSession = undefined;
    }
  }


  doRandBySync():number {
    let rand = cryptoFramework.createRandom();
    let len = 1; // Generate a 24-byte random number.
    try {
      let randData = rand.generateRandomSync(len);
      if (randData != null) {
        console.info("[Sync]: rand result: " + randData.data[0]);
        return randData.data[0]
      } else {
        console.error("[Sync]: get rand result fail!");
        return 0;
      }
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`do rand failed, ${e.code}, ${e.message}`);
      return 0;
    }
  }

}