import image from '@ohos.multimedia.image';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import {common, Want,Permissions, bundleManager, abilityAccessCtrl} from '@kit.AbilityKit'
import fs from '@ohos.file.fs';
import camera from '@ohos.multimedia.camera';
import {BusinessError} from '@ohos.base';
const context = getContext(this) as common.UIAbilityContext;
const baseContext = getContext(this) as common.BaseContext
@Entry
@Component

struct CameraPage {

  private xComponentController: XComponentController = new XComponentController();



  async savePicture(buffer:ArrayBuffer, img: image.Image): Promise<void> {
    // 相册管理模块，支持加入图片进入图库
    // let context = getContext(this) as common.UIAbilityContext

    let accessHelper: photoAccessHelper.PhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let options: photoAccessHelper.CreateOptions = {
      title: Date.now().toString()
    };
    let photoUri: string = await accessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg', options);
    //createAsset的调用需要ohos.permission.READ_IMAGEVIDEO和ohos.permission.WRITE_IMAGEVIDEO的权限
    // fs包含基本的文件操作能力
    let file: fs.File = fs.openSync(photoUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    await fs.write(file.fd, buffer);
    fs.closeSync(file);
    img.release();
  }

  setPhotoOutputCb(photoOutput:camera.PhotoOutput): void {
    //设置回调之后，调用photoOutput的capture方法，就会将拍照的buffer回传到回调中
    photoOutput.on('photoAvailable', (errCode:BusinessError, photo:camera.Photo):void=> {
      console.info('getPhoto start');
      console.info(`err: ${JSON.stringify(errCode)}`);
      if (errCode || photo === undefined) {
        console.error('getPhoto failed');
        return;
      }

      let imageObj = photo.main;
      imageObj.getComponent(image.ComponentType.JPEG, (errCode:BusinessError, component:image.Component):void=> {
        if (errCode || component === undefined) {
          console.error('getComponent failed');
          return;
        }
        let buffer: ArrayBuffer;
        if (component.byteBuffer) {
          buffer = component.byteBuffer;
        } else {
          console.error('byteBuffer is null');
          return;
        }
        this.savePicture(buffer, imageObj);
      })

    })
  }

  // 拍照事件
  async cameraShootingCase(baseContext:common.BaseContext,surfaceId:string): Promise<void> {
    //  创建camera对象
    let cameraManager:camera.CameraManager = camera.getCameraManager(baseContext);
    if(!cameraManager) {
      console.error("camera.getCameraManager error");
      return;
    }
    //监听相机状态变化
    cameraManager.on('cameraStatus', (err:BusinessError, cameraStatusInfo: camera.CameraStatusInfo)=> {
      console.info(`camera : ${cameraStatusInfo.camera.cameraId}`);
      console.info(`status: ${cameraStatusInfo.status}`);
    })

    // 获取相机列表
    let cameraArray: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
    if (cameraArray.length <= 0) {
      console.error("cameraManager.getSupportedCameras error");
      return;
    }

    for (let index = 0; index < cameraArray.length; index++) {
      console.info('cameraId : ' + cameraArray[index].cameraId);                          // 获取相机ID
      console.info('cameraPosition : ' + cameraArray[index].cameraPosition);              // 获取相机位置
      console.info('cameraType : ' + cameraArray[index].cameraType);                      // 获取相机类型
      console.info('connectionType : ' + cameraArray[index].connectionType);              // 获取相机连接类型
    }

    // 创建相机输入流
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      cameraInput = cameraManager.createCameraInput(cameraArray[0]);
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to createCameraInput errorCode = ' + err.code);
    }
    if (cameraInput === undefined) {
      return;
    }

    // 监听cameraInput错误信息
    let cameraDevice: camera.CameraDevice = cameraArray[0];
    cameraInput.on('error', cameraDevice, (error: BusinessError) => {
      console.error(`Camera input error code: ${error.code}`);
    })

    // 打开相机
    await cameraInput.open();

    // 获取支持的模式类型
    let sceneModes: Array<camera.SceneMode> = cameraManager.getSupportedSceneModes(cameraArray[0]);
    let isSupportPhotoMode: boolean = sceneModes.indexOf(camera.SceneMode.NORMAL_PHOTO) >= 0;
    if (!isSupportPhotoMode) {
      console.error('photo mode not support');
      return;
    }
    // 获取相机设备支持的输出流能力
    let cameraOutputCap: camera.CameraOutputCapability = cameraManager.getSupportedOutputCapability(cameraArray[0], camera.SceneMode.NORMAL_PHOTO);
    if (!cameraOutputCap) {
      console.error("cameraManager.getSupportedOutputCapability error");
      return;
    }
    console.info("outputCapability: " + JSON.stringify(cameraOutputCap));

    let previewProfilesArray: Array<camera.Profile> = cameraOutputCap.previewProfiles;
    if (!previewProfilesArray) {
      console.error("createOutput previewProfilesArray == null || undefined");
    }

    let photoProfilesArray: Array<camera.Profile> = cameraOutputCap.photoProfiles;
    if (!photoProfilesArray) {
      console.error("createOutput photoProfilesArray == null || undefined");
    }

    // 创建预览输出流,其中参数 surfaceId 参考上文 XComponent 组件，预览流为XComponent组件提供的surface
    let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      previewOutput = cameraManager.createPreviewOutput(previewProfilesArray[0], surfaceId);
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to create the PreviewOutput instance. error code: ${err.code}`);
    }
    if (previewOutput === undefined) {
      return;
    }
    // 监听预览输出错误信息
    previewOutput.on('error', (error: BusinessError) => {
      console.error(`Preview output error code: ${error.code}`);
    });

    // 创建拍照输出流
    let photoOutput: camera.PhotoOutput | undefined = undefined;
    try {
      photoOutput = cameraManager.createPhotoOutput(photoProfilesArray[0]);
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to createPhotoOutput errorCode = ' + err.code);
    }
    if (photoOutput === undefined) {
      return;
    }

    //调用上面的回调函数来保存图片
    this.setPhotoOutputCb(photoOutput);

    //创建会话
    let photoSession: camera.PhotoSession | undefined = undefined;
    try {
      photoSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to create the session instance. errorCode = ' + err.code);
    }
    if (photoSession === undefined) {
      return;
    }
    // 监听session错误信息
    photoSession.on('error', (error: BusinessError) => {
      console.error(`Capture session error code: ${error.code}`);
    });

    // 开始配置会话
    try {
      photoSession.beginConfig();
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to beginConfig. errorCode = ' + err.code);
    }

    // 向会话中添加相机输入流
    try {
      photoSession.addInput(cameraInput);
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to addInput. errorCode = ' + err.code);
    }

    // 向会话中添加预览输出流
    try {
      photoSession.addOutput(previewOutput);
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to addOutput(previewOutput). errorCode = ' + err.code);
    }

    // 向会话中添加拍照输出流
    try {
      photoSession.addOutput(photoOutput);
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to addOutput(photoOutput). errorCode = ' + err.code);
    }

    // 提交会话配置
    await photoSession.commitConfig();

    // 启动会话
    await photoSession.start().then(() => {
      console.info('Promise returned to indicate the session start success.');
    });
    // 判断设备是否支持闪光灯
    let flashStatus: boolean = false;
    try {
      flashStatus = photoSession.hasFlash();
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to hasFlash. errorCode = ' + err.code);
    }
    console.info('Returned with the flash light support status:' + flashStatus);

    if (flashStatus) {
      // 判断是否支持自动闪光灯模式
      let flashModeStatus: boolean = false;
      try {
        let status: boolean = photoSession.isFlashModeSupported(camera.FlashMode.FLASH_MODE_AUTO);
        flashModeStatus = status;
      } catch (error) {
        let err = error as BusinessError;
        console.error('Failed to check whether the flash mode is supported. errorCode = ' + err.code);
      }
      if (flashModeStatus) {
        // 设置自动闪光灯模式
        try {
          photoSession.setFlashMode(camera.FlashMode.FLASH_MODE_AUTO);
        } catch (error) {
          let err = error as BusinessError;
          console.error('Failed to set the flash mode. errorCode = ' + err.code);
        }
      }
    }

    // 判断是否支持连续自动变焦模式
    let focusModeStatus: boolean = false;
    try {
      let status: boolean = photoSession.isFocusModeSupported(camera.FocusMode.FOCUS_MODE_CONTINUOUS_AUTO);
      focusModeStatus = status;
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to check whether the focus mode is supported. errorCode = ' + err.code);
    }

    if (focusModeStatus) {
      // 设置连续自动变焦模式
      try {
        photoSession.setFocusMode(camera.FocusMode.FOCUS_MODE_CONTINUOUS_AUTO);
      } catch (error) {
        let err = error as BusinessError;
        console.error('Failed to set the focus mode. errorCode = ' + err.code);
      }
    }

    // 获取相机支持的可变焦距比范围
    let zoomRatioRange: Array<number> = [];
    try {
      zoomRatioRange = photoSession.getZoomRatioRange();
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to get the zoom ratio range. errorCode = ' + err.code);
    }
    if (zoomRatioRange.length <= 0) {
      return;
    }
    // 设置可变焦距比
    try {
      photoSession.setZoomRatio(zoomRatioRange[0]);
    } catch (error) {
      let err = error as BusinessError;
      console.error('Failed to set the zoom ratio value. errorCode = ' + err.code);
    }
    let photoCaptureSetting: camera.PhotoCaptureSetting = {
      quality: camera.QualityLevel.QUALITY_LEVEL_HIGH, // 设置图片质量高
      rotation: camera.ImageRotation.ROTATION_0 // 设置图片旋转角度0
    }
    // 使用当前拍照设置进行拍照
    photoOutput.capture(photoCaptureSetting, (err: BusinessError) => {
      if (err) {
        console.error(`Failed to capture the photo ${err.message}`);
        return;
      }
      console.info('Callback invoked to indicate the photo capture request success.');
    });
    // 停止当前会话
    photoSession.stop();

    // 释放相机输入流
    cameraInput.close();

    // 释放预览输出流
    previewOutput.release();

    // 释放拍照输出流
    photoOutput.release();

    // 释放会话
    photoSession.release();

    // 会话置空
    photoSession = undefined;

  }



  async getCameraImage() {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager()
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED
    let tokenId: number = 0
    try {
      let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    const permissions: Array<Permissions> = ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE', 'ohos.permission.WRITE_MEDIA', 'ohos.permission.READ_MEDIA', 'ohos.permission.MEDIA_LOCATION']


    for (const permission of permissions) {

        try {
          grantStatus = await atManager.checkAccessToken(tokenId, permission);
          console.log('This permission: ' + permission + ', status is'+ grantStatus)
        } catch (error) {
          const err: BusinessError = error as BusinessError;
          console.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
        }

    }

    // 1、使用系统相机框架camera模块获取物理摄像头信息。
    let cameraManager = camera.getCameraManager(context);
    let camerasInfo: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
    console.log('The number of cameradevice is '+camerasInfo.length)


    let cameraDevice: camera.CameraDevice = camerasInfo[0];
    console.log("Position is:"+cameraDevice.cameraPosition+", Type: " + cameraDevice.cameraType);
    console.log('Here!!')

    // 检测相机状态
    cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => {
      console.log(`camera : ${cameraStatusInfo.camera.cameraId}`);
      console.log(`status : : ${cameraStatusInfo.status}`);

    });

    // 2、创建并启动物理摄像头输入流通道
    // 设置为前置摄像头 camera.CameraPosition.CAMERA_POSITION_FRONT
  console.log("END")
    let cameraInput = cameraManager.createCameraInput(camera.CameraPosition.CAMERA_POSITION_FRONT, camera.CameraType.CAMERA_TYPE_WIDE_ANGLE);

    await cameraInput.open();

    // 3、拿到物理摄像头信息查询摄像头支持预览流支持的输出格式，结合XComponent提供的surfaceId创建预览输出通道
    let outputCapability = cameraManager.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_PHOTO);
    let previewProfile = outputCapability.previewProfiles[0];
    let surfaceId = this.xComponentController.getXComponentSurfaceId();
    let previewOutput = cameraManager.createPreviewOutput(previewProfile, surfaceId);
    // 4、创建相机会话，在会话中添加摄像头输入流和预览输出流，然后启动会话，预览画面就会在XComponent组件上送显。
    let captureSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO);
    captureSession.beginConfig();
    captureSession.addInput(cameraInput);
    captureSession.addOutput(previewOutput);
    captureSession.commitConfig()
    captureSession.start();
  }



  @State title: string = 'Camera'
  // xComponentContext: object | undefined = undefined;
  // xComponentAttrs: XComponentAttrs = {
  //   id: 'camera',
  //   type: XComponentType.SURFACE,
  //   libraryname: 'nativerender'
  // }

  build() {
    Row() {
      Column({ space: 20 }) {
        XComponent({ id: 'xComponentId1', type: 'surface', controller: this.xComponentController })
          .height(300)
        Row() {
          // Button('打开摄像头')
          //   .onClick(() => {
          //     // 在调用前确保已经获得相机权限
          //     this.getCameraImage();
          //   })

          Button('拍照')
            .onClick(() => this.cameraShootingCase(baseContext, this.xComponentController.getXComponentSurfaceId()))
        }

      }
      .width('100%')
    }
    .height('100%')
  }


}

interface XComponentAttrs {
  id: string,
  type: number,
  libraryname: string
}
