import grantPermission from '../utils/PermissionUtils'
import Camera from '../utils/Camera'
import { BusinessError } from '@ohos.base';

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
    console.log('hi there')
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