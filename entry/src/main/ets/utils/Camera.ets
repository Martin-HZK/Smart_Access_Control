import fileIo from '@ohos.file.fs';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import {BusinessError} from '@ohos.base'
import image from '@ohos.multimedia.image';
import common from '@ohos.app.ability.common';
import camera from '@ohos.multimedia.camera';


export default class Camera {
  private cameraManager?: camera.CameraManager
  private cameraInput?: camera.CameraInput
  public previewOutput?: camera.PreviewOutput
  public photoOutput?: camera.PhotoOutput
  private photoSession?: camera.PhotoSession
  private receiver: image.ImageReceiver | undefined = undefined;

  async initCamera(surfaceId: string): Promise<void> {
    this.cameraManager = camera.getCameraManager(getContext(this) as common.UIAbilityContext);
    let cameraArray: Array<camera.CameraDevice> = this.cameraManager.getSupportedCameras();
    let cameraDevice = cameraArray[0];
    this.cameraInput = this.cameraManager.createCameraInput(cameraDevice);

    await this.cameraInput.open();

    let cameraOutputCap: camera.CameraOutputCapability =
      this.cameraManager!.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_PHOTO);

    let previewProfilesArray: Array<camera.Profile> = cameraOutputCap.previewProfiles;
    let photoProfilesArray: Array<camera.Profile> = cameraOutputCap.photoProfiles;


    console.log('The length of preview profiles array is: ' + previewProfilesArray.length)
    console.log('The length of photo profiles array is: ' + photoProfilesArray.length)
    this.previewOutput = this.cameraManager!.createPreviewOutput(previewProfilesArray[0], surfaceId);

    let size: image.Size = {
      height: 2592, width: 1200
    };

    this.receiver = image.createImageReceiver(size, image.ImageFormat.JPEG, 8);
    this.photoOutput = this.cameraManager!.createPhotoOutput(photoProfilesArray[0]);
    this.photoOutput.on('photoAvailable', (errCode: BusinessError, photo: camera.Photo): void => {
      let imageObj = photo.main;
      imageObj.getComponent(image.ComponentType.JPEG, async (errCode: BusinessError, component: image.Component) => {
        if (errCode || component === undefined) {
          return;
        }
        let buffer: ArrayBuffer;
        buffer = component.byteBuffer;
        console.info(JSON.stringify(buffer));
        await this.savePicture(buffer);
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

  async takePicture() {
    console.log('takePicture');
    this.photoOutput!.capture();
  }

  async savePicture(buffer: ArrayBuffer): Promise<void> {
    let photoHelper: photoAccessHelper.PhotoAccessHelper =
      photoAccessHelper.getPhotoAccessHelper(getContext(this) as common.UIAbilityContext);
    let options: photoAccessHelper.CreateOptions = {
      title: Date.now().toString()
    };
    let photoUri: string = await photoHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg', options);
    console.info(photoUri);

    //createAsset的调用需要ohos.permission.READ_IMAGEVIDEO和ohos.permission.WRITE_IMAGEVIDEO的权限
    let file: fileIo.File = fileIo.openSync(photoUri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    await fileIo.write(file.fd, buffer);
    fileIo.closeSync(file);
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
}