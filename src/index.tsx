import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'rnarch' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const RNArch = NativeModules.RNArch
  ? {
    /**
     * 
     * @param srcPath string
     * @param dstPath string
     * @param password string only supported in zip, rar, 7z
     * @returns 
     */
    exec: async function(srcPath: string, dstPath: string, password: string) {
      srcPath = Platform.select({
        android: decodeURIComponent(srcPath.replace(/^file:\/\//, "")),
        ios: decodeURIComponent(srcPath.replace(/^file:\/\//, "")),
        default: "",
      });
      
      dstPath = Platform.select({
        android: decodeURIComponent(dstPath.replace(/^file:\/\//, "")),
        ios: decodeURIComponent(dstPath.replace(/^file:\/\//, "")),
        default: "",
      });

      const ext = srcPath.split('.').pop();
      if (!ext) {
        throw new Error(`Source path must have an extension.`);
      }

      if (["zip", "zipx", "jar", "xpi", "odt", "ods", "docx", "xlsx", "epub", "cbz"].indexOf(ext) > -1) {
        return await NativeModules.RNArch.uncompressZip(srcPath, dstPath, password);
      } else if (["rar", "rev", "cbr"].indexOf(ext) > -1) {
        return await NativeModules.RNArch.uncompressRar(srcPath, dstPath, password);
      } else if (["7z", "cb7"].indexOf(ext) > -1) {
        return await NativeModules.RNArch.uncompressSevenZip(srcPath, dstPath, password);
      } else if (["pdf"].indexOf(ext) > -1) {
        return await NativeModules.RNArch.uncompressPdf(srcPath, dstPath, null);
      } else {
        throw new Error(`${ext} format has not been supported.`);
      }
    }
  } : new Proxy(
    {},
    {
      get() {
        throw new Error(LINKING_ERROR);
      },
    }
  );

export default RNArch;