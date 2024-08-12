import FileUtils from '../utils/FileUtils'
import faceUtils from '../utils/FaceUtils'
import promptAction from '@ohos.promptAction'
import { BusinessError } from '@ohos.base'
@Entry
@Component
struct FaceRegisterPage {
  @State message: string = 'Hello Reg';
  @State fileUtils: FileUtils = new FileUtils();
  @State faceUtils: faceUtils = new faceUtils();

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Button("Register")
          .type(ButtonType.Normal)
          .onClick(async()=>{
            let storagePaths : string[] = this.fileUtils.getTmpFilesInDirectory(getContext(this).filesDir)
            if(storagePaths.length == 0) {
                console.log("NULL path")
             } else {
              let imgPath:string = getContext(this).filesDir +"/" + storagePaths[0]
              console.log("This is the storage path: "+imgPath)

              // call face register function
              try {
                let retNum = await this.faceUtils.faceRegister(imgPath)
                console.log("The return number of face register is: " + retNum)
              } catch (err) {
                console.log("Error registering faces: " + err)
              }


              this.fileUtils.deleteTmpFile(imgPath)
              console.log("Register finished")
            }
            // try {
            //   promptAction.showToast({
            //     message: 'Register Successfully',
            //     duration: 2000
            //   });
            // } catch (error) {
            //   let message = (error as BusinessError).message
            //   let code = (error as BusinessError).code
            //   console.error(`showToast args error code is ${code}, message is ${message}`);
            // };
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}