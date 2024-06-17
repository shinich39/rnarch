# rnarch

Uncompress archive in react native.

Supported archive types: .zip, .epub, .cbz, .rar, .cbr, .7z, .cb7, .pdf

## Installation

```sh
npm install rnarch
```

## Usage

- RNArch.exec(archivePath, directoryPath)

```js
import RNArch from 'rnarch';

// recommended to use this library with document picker.
// https://docs.expo.dev/versions/latest/sdk/document-picker/

// with document picker
// const { assets, canceled } = await DocumentPicker.getDocumentAsync();
// archivePath = assets[0].uri;
// directoryPath = FileSystem.cacheDirectory + (/[\\\/]$/.test(FileSystem.cacheDirectory) ? "" : "/") + Date.now();

const archivePath = 'file://...PATH.../Library/Caches/ARCHIVE.zip';
const directoryPath = 'file://...PATH.../Library/Caches/DESTINATION';
await RNArch.exec(archivePath, directoryPath);

// read extracted files with expo.FileSystem
// https://docs.expo.dev/versions/latest/sdk/filesystem/
async function readDir(dirPath) {
  let result = [];
  for (const file of await FileSystem.readDirectoryAsync(dirPath)) {
    if ((await FileSystem.getInfoAsync(dirPath + "/" + file)).isDirectory) {
      result.push(...(await readDir(dirPath + "/" + file)))
    } else {
      result.push(dirPath + "/" + file);
    }
  }
  return result;
}

const files = await readDir(directoryPath);
// [...];
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
