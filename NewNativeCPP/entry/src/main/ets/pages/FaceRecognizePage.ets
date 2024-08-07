import FileUtils from '../utils/FileUtils'
@Entry
@Component
struct FaceRecognizePage {
  @State message: string = 'Hello Reg';
  @State fileUtils: FileUtils = new FileUtils();
  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Button("Register")
          .type(ButtonType.Normal)
          .onClick(()=>{
            let storagePaths : string[] = this.fileUtils.getTmpFilesInDirectory(getContext(this).filesDir)
            if(storagePaths.length == 0) {
                console.log("NULL path")
             } else {
              let imgPath:string = getContext(this).filesDir +"/" + storagePaths[0]
              console.log("This is the storage path: "+imgPath)
              this.fileUtils.deleteTmpFile(imgPath)
            }
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}