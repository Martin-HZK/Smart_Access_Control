import grantPermission from '../utils/PermissionUtils'
import Camera from '../utils/Camera'
import { BusinessError } from '@kit.BasicServicesKit';
import image from '@ohos.multimedia.image';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import {common, Want,Permissions, bundleManager, abilityAccessCtrl} from '@kit.AbilityKit'
import fs from '@ohos.file.fs';
import camera from '@ohos.multimedia.camera';
const context = getContext(this) as common.UIAbilityContext;
const baseContext = getContext(this) as common.BaseContext
@Entry
@Component
struct Index {
  private XComponentController: XComponentController = new XComponentController();
  private surfaceId: string = '';
  @State private camera: Camera = new Camera();

  async aboutToAppear() {
  await grantPermission().then(async () => {
    this.XComponentInit();
  }).catch((err: BusinessError) => {
    console.info(`grantPermission faild  ${JSON.stringify(err.code)}`);
  })
}

  onPageShow() {
    this.XComponentInit();
  }

  onPageHide() {
    this.camera.releaseCamera();
  }

  async aboutToDisappear() {
    await this.camera.releaseCamera();
  }

  async XComponentInit() {

    this.XComponentController.setXComponentSurfaceSize({ surfaceWidth: 240, surfaceHeight: 320 });
    this.surfaceId = this.XComponentController.getXComponentSurfaceId();

    // console.log('Initializing camera with surfaceId:', this.surfaceId);

    await this.camera.initCamera(this.surfaceId);
    console.log('Camera initialized!!!!')

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
    // let surfaceId:string = XComponentController.getXComponentSurfaceId();
    let previewOutput = cameraManager.createPreviewOutput(previewProfile, this.surfaceId);
    // 4、创建相机会话，在会话中添加摄像头输入流和预览输出流，然后启动会话，预览画面就会在XComponent组件上送显。
    let captureSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO);
    captureSession.beginConfig();
    captureSession.addInput(cameraInput);
    captureSession.addOutput(previewOutput);
    captureSession.commitConfig()
    captureSession.start();
  }



  build() {
    Column() {
      Row() {
        XComponent({ id: 'XComponentID1', type: 'surface', controller: this.XComponentController }).onLoad(async () => {
          await this.camera.releaseCamera()
          // await this.getCameraImage()
          await this.XComponentInit()
          console.log("XComponent init!")
        }).width('100%').height(500)
      }.width('100%').margin({ top: 30 }).flexGrow(1)

      Column() {
        Text('拍照').fontSize(14).fontColor(Color.White).margin({ top: 16 })
        Row()
          .backgroundColor('#0A59F7')
          .width(6)
          .height(6)
          .border({ radius: 3 })
          .margin({ top: 6, bottom: 20 })
        Row() {
          Row().backgroundColor(Color.White).width(60).height(60).border({ radius: 30 })
        }
        .onClick(async () => {
          console.log('click')
          await this.camera.takePicture()
        })
        .backgroundColor(Color.Black)
        .width(76)
        .height(76)
        .border({ color: Color.White, width: 1, radius: 37 })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .flexShrink(0)
      .height(228)
      .backgroundColor(Color.Black)
      .alignItems(HorizontalAlign.Center)
    }.width('100%').height('100%').backgroundColor(Color.Black)
  }
}