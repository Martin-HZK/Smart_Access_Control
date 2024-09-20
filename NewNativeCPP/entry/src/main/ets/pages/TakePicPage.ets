import grantPermission from '../utils/PermissionUtils'
import Camera from '../utils/Camera'
import { BusinessError } from '@ohos.base';
import router from '@ohos.router';
import FileUtils from '../utils/FileUtils';


@Entry
@Component
struct Index {
  private XComponentController: XComponentController = new XComponentController();
  private surfaceId: string = '';
  @State private camera: Camera = new Camera();
  @State private fileUtils : FileUtils = new FileUtils();

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
    await this.camera.initCamera(this.surfaceId);
  }







  build() {
    Column() {
      Row() {
        XComponent({ id: 'XComponentID1', type: 'surface', controller: this.XComponentController }).onLoad(async () => {
          await this.camera.releaseCamera()
          await this.XComponentInit()
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
          // router.pushUrl({"url": 'pages/FaceRecognize'})


        })
        .backgroundColor(Color.Black)
        .width(76)
        .height(76)
        .border({ color: Color.White, width: 1, radius: 37 })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Row() {
          // Row().backgroundColor(Color.Red).width(40).height(10).border({ radius: 15 })
          Button("Register")
            .type(ButtonType.Capsule)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Normal)
            .stateEffect(true)
            .onClick(()=>{

`              // let storagePaths : string[] = this.fileUtils.getTmpFilesInDirectory(getContext(this).filesDir)
`              //
              // if(storagePaths.length == 0) {
              //   // Afterwards
              //   console.log("NULL path")
              // } else {
              //   console.log("This is the storage path: "+storagePaths[0])
              // }

              router.pushUrl({
                url: 'pages/FaceRegisterPage',
              }).then(() =>{
                console.info('Jump success')
              }).catch((err:BusinessError)=>{
                console.log('Error code ${err.code}, Error message: ${err.message}')
              })
            })
          Button("Recognize")
            .type(ButtonType.Capsule)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Normal)
            .stateEffect(true)
            .onClick(()=>{

              router.pushUrl({
                url: 'pages/FaceRecognizePage',
              }).then(() =>{
                console.info('Jump success')
              }).catch((err:BusinessError)=>{
                console.log('Error code ${err.code}, Error message: ${err.message}')
              })
            })
        }
        .margin(10)
      }
      .width('100%')
      .flexShrink(0)
      .height(228)
      .backgroundColor(Color.Black)
      .alignItems(HorizontalAlign.Center)
    }.width('100%').height('100%').backgroundColor(Color.Black)
  }
}