import hilog from '@ohos.hilog';
import testNapi from 'libentry.so';
import router from '@ohos.router';
import {BusinessError} from '@ohos.base'
import camera from '@ohos.multimedia.camera';
import common from '@ohos.app.ability.common';
import exlib from 'libentry.so'
import TestSeeta from 'libseeta.so'

const context = getContext(this) as common.UIAbilityContext;
const baseContext = getContext(this) as common.BaseContext

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State exLine: string = exlib.getHelloString();
  @State testSeetaNum: number = TestSeeta.seetaTest();


  getSupportedCameras(cameraManager: camera.CameraManager): number {
    let cameras: Array<camera.CameraDevice> = [];
    try {
      cameras = cameraManager.getSupportedCameras();
    } catch (error) {
      let err = error as BusinessError;
      console.error(`The getSupportedCameras call failed. error code: ${err.code}`);
    }
    return cameras.length;
  }


  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            // hilog.info(0x0000, 'testTag', 'Test NAPI 2 + 3 = %{public}d', testNapi.add(2, 3));
            console.log("The number of Seeta test is: " + this.testSeetaNum)
          })

        // Text(this.exLine)
        //   .onAppear(()=>{
        //     let cameraManager: camera.CameraManager | undefined = undefined;
        //     try {
        //       cameraManager = camera.getCameraManager(context);
        //     } catch (error) {
        //       let err = error as BusinessError;
        //       console.error(`The getCameraManager call failed. error code: ${err.code}`);
        //     }
        //
        //     console.log('the number is: ' + this.getSupportedCameras(cameraManager))
        //   })
        Button() {
          Text('Register')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#777777');
        }
        .onClick(() => {
          console.info('Success in clicking')
          // router.pushUrl({url: 'pages/CameraPage'}).then(() => {
          router.pushUrl({url: 'pages/TakePicPage'}).then(() =>{
            console.info('Jump success')
          }).catch((err:BusinessError)=>{
            console.log('Error code ${err.code}, Error message: ${err.message}')
          })
        })
        .type(ButtonType.Capsule)
        .margin({ top: 20 })
        .backgroundColor('#0D9FFB')
        .width('40%')
        .height('5%')
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        }); // 确保按钮正确对齐并在容器中显示

        Button(){
          Text('Recognize')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#777777');
        }
        .onClick(() => {
          console.info('Success in clicking')
          // router.pushUrl({url: 'pages/CameraPage'}).then(() => {
          router.pushUrl({url: 'pages/FaceRecognize'}).then(() =>{
            console.info('Jump success')
          }).catch((err:BusinessError)=>{
            console.log('Error code ${err.code}, Error message: ${err.message}')
          })
        })
        .type(ButtonType.Capsule)
        .margin({ top: 20 })
        .backgroundColor('#0D9FFB')
        .width('40%')
        .height('5%')
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        }); // 确保按钮正确对齐并在容器中显示
      }
      .width('100%')
    }
    .height('100%')
  }
}
