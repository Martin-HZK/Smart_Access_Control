import grantPermission from '../utils/PermissionUtils'
import Camera from '../utils/Camera'
import { BusinessError } from '@ohos.base';
import hilog from '@ohos.hilog';
import testNapi from 'libentry.so';
import router from '@ohos.router'
// type MyParams = Record<string, string | number>;
type MyParams = Record<'src', string>;
// interface MyParams {
//   src:string
// }

@Entry
@Component
struct Index {
  @State message: string = 'FaceReg';
  // @State src: string = router.getParams()?.['src']
  // @State params:MyParams = router.getParams() as MyParams
  // @State imgPath:string = this.params.src as string

  onPageShow() {
    // console.log('The img path is: ' + this.imgPath)
  }

  onPageHide() {

  }

  build() {
    Column() {
      Text(this.message)
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          hilog.info(0x0000, 'testTag', 'Test NAPI 2 + 3 = %{public}d', testNapi.add(2, 3));
        })
    }.width('100%').height('100%').backgroundColor(Color.Black)
  }
}