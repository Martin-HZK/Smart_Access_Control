import router from '@ohos.router'
import {BusinessError} from '@ohos.base'
import testNapi from 'libentry.so'

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
@State testString: string = testNapi.getHelloString()
  build() {
    Row(){
      Column() {
        Text(this.testString)
          .fontSize(100)
          .fontWeight(FontWeight.Normal)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
        Text(this.message)
          .id('HelloWorld')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })

        Button() {
          Text('Next')
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
      }
      .height('100%')
      .width('100%')
    }
  }
}