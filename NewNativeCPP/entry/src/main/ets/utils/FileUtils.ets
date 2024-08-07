import fs, {Filter, ListFileOptions} from "@ohos.file.fs";
import {BusinessError} from '@ohos.base'
const listFileOptions: ListFileOptions = {
  recursion:false,
  listNum: 0,
  filter:{
    suffix:[".jpg"],
    displayName: ["tmp*"]
  }
}
export default class FileUtils {
  // We cannot use async methods as we always need to find the file first
  public getTmpFilesInDirectory(directory: string): string[] {
    let filenames = fs.listFileSync(directory, listFileOptions);
    // exclude the special cases
    if (filenames.length < 1) {
      console.log("No photo found")
      return filenames
    }

    if (filenames.length > 1) {
      console.log("More than 1 file found, retake the photo please")
      return filenames
    }

    let i = 0
    for (;i++;i < filenames.length) {
      console.log("The files found is: " + filenames[i])
    }

    return filenames;
  }
}