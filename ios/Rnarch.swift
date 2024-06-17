import Foundation
import SSZipArchive
import UIKit
import UnrarKit
import PLzmaSDK
import PDFKit

enum Errors: Error {
    case error
    case uncompress
    case srcNotFound
    case dstNotFound
    case dstAlreadyExists
    case notSupported
}

extension Errors: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .error:
                return NSLocalizedString("An error was occurred.", comment: "")
            case .uncompress:
                return NSLocalizedString("A problem occurred while uncompress the archive.", comment: "")
            case .srcNotFound:
                return NSLocalizedString("Source file not found.", comment: "")
            case .dstNotFound:
                return NSLocalizedString("Destination directory not found.", comment: "")
            case .dstAlreadyExists:
                return NSLocalizedString("Destination already exists.", comment: "")
            case .notSupported:
                return NSLocalizedString("Not supported.", comment: "")
        }
    }
}

@objc(RNArch)
class RNArch: NSObject {

  @objc
  func getName() -> String {
      return "RNArch"
  }

  @objc
    func isProtectedZip(
        _ srcPath: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let isProtected = try SSZipArchive.isFilePasswordProtected(atPath: encodedSrcPath)
            resolve(isProtected)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }
    
    @objc
    func uncompressZip(
        _ srcPath: String,
        dstPath: String,
        password: String? = nil,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let encodedDstPath = dstPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            var error: NSError?
            
            let success: Bool = SSZipArchive.unzipFile(
                atPath: encodedSrcPath,
                toDestination: encodedDstPath,
                preserveAttributes: true,
                overwrite: false,
                password: password,
                error: &error,
                delegate: nil
            )
            
            if let error = error {
                throw error
            }

            if !success {
                throw Errors.uncompress
            }
            
            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    @objc
    func isProtectedRar(
        _ srcPath: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let archive = try URKArchive(path: encodedSrcPath)
            let isProtected = archive.isPasswordProtected()
            resolve(isProtected)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    @objc
    func uncompressRar(
        _ srcPath: String,
        dstPath: String,
        password: String? = nil,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let encodedDstPath = dstPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let archive = try URKArchive(path: encodedSrcPath)
            
            if let password = password {
                archive.password = password
            }
            
            try archive.extractFiles(
                to: encodedDstPath,
                overwrite: false
            )

            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

     @objc
     func isProtectedSenvenZip(
         _ srcPath: String,
         resolve: RCTPromiseResolveBlock,
         reject: RCTPromiseRejectBlock
     ) {
        do {
            throw Errors.notSupported
        } catch {
            reject("error", error.localizedDescription, error)
        }
     }

    @objc
    func uncompressSevenZip(
        _ srcPath: String,
        dstPath: String,
        password: String? = nil,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let encodedDstPath = dstPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            // 1. Create a source input stream for reading archive file content.
            //  1.1. Create a source input stream with the path to an archive file.
            let archivePath = try Path(encodedSrcPath)
            let archivePathInStream = try InStream(path: archivePath)

            //  1.2. Create a source input stream with the file content.
            // let archiveData = Data(...)
            // let archiveData = try Data(contentsOf:URL(string: srcPath)!)
            // let archiveDataInStream = try InStream(dataNoCopy: archiveData) // also available Data(dataCopy: Data)

            // 2. Create decoder with source input stream, type of archive and optional delegate.
            let decoder = try Decoder(stream: archivePathInStream, fileType: .sevenZ, delegate: nil)
            
            //  2.1. Optionaly provide the password to open/list/test/extract encrypted archive items.
            if let password = password {
                try decoder.setPassword(password)
            }

            // let opened = try decoder.open()
            _ = try decoder.open()
            
            // 3. Select archive items for extracting or testing.
            //  3.1. Select all archive items.
            // let allArchiveItems = try decoder.items()
            // try decoder.items()
            
            //  3.2. Get the number of items, iterate items by index, filter and select items.
            // let numberOfArchiveItems = try decoder.count()
            // let selectedItemsDuringIteration = try ItemArray(capacity: numberOfArchiveItems)
            // let selectedItemsToStreams = try ItemOutStreamArray()
            // for itemIndex in 0..<numberOfArchiveItems {
            //     let item = try decoder.item(at: itemIndex)
            //     try selectedItemsDuringIteration.add(item: item)
            //     try selectedItemsToStreams.add(item: item, stream: OutStream()) // to memory stream
            // }
            
            // 4. Extract or test selected archive items. The extract process might be:
            //  4.1. Extract all items to a directory. In this case, you can skip the step #3.
            // let extracted = try decoder.extract(to: Path(dstPath))
            _ = try decoder.extract(to: Path(encodedDstPath))
            
            //  4.2. Extract selected items to a directory.
            // let extracted = try decoder.extract(items: selectedItemsDuringIteration, to: Path(destinationPath))
            
            //  4.3. Extract each item to a custom out-stream.
            //       The out-stream might be a file or memory. I.e. extract 'item #1' to a file stream, extract 'item #2' to a memory stream(then take extacted memory) and so on.
            // let extracted = try decoder.extract(itemsToStreams: selectedItemsToStreams)
            
            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    @available(iOS 11.0, *)
    @objc
    func isProtectedPdf(
        _ srcPath: String,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        do {
            let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let srcUrl = URL(string: "file://\(encodedSrcPath)")!
            let pdfDocument = PDFDocument(url: srcUrl)!

            var isProtected = false
            
            if pdfDocument.isEncrypted {
                isProtected = true
            }
            
            if pdfDocument.isLocked {
                isProtected = true
            }
            
            resolve(isProtected)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }

    @available(iOS 11.0, *)
    @objc
    func uncompressPdf(
        _ srcPath: String,
        dstPath: String,
        password: String? = nil,
        resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        func extractPage(
            page: PDFPage,
            dstUrl: URL,
            quality: Int
        ) throws -> Void {
            let pageBoundingRect = page.bounds(for: .mediaBox)
            let image = page.thumbnail(
                of: CGSize(width: pageBoundingRect.width, height: pageBoundingRect.height),
                for: .mediaBox
            )
            
            guard let data = image.jpegData(compressionQuality: CGFloat(quality) / 100) else {
                throw Errors.uncompress
            }
            
            try data.write(to: dstUrl)
        }
        
        do {
            let encodedSrcPath = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let encodedDstPath = dstPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let srcUrl = URL(string: "file://\(encodedSrcPath)")!
            let dstUrl = URL(string: encodedDstPath)!
            let pdfDocument = PDFDocument(url: srcUrl)!
            
            if let password = password {
                pdfDocument.unlock(withPassword: password)
            }
            
            // check dupe
            for page in 0..<pdfDocument.pageCount {
                let filePath = "\(dstUrl.absoluteString)/\(page).jpg"
                
                if FileManager.default.fileExists(atPath: filePath) {
                    throw Errors.dstAlreadyExists
                }
            }
            
            // uncompress
            for page in 0..<pdfDocument.pageCount {
                do {
                    let filePath = "file://\(dstUrl.absoluteString)/\(page).jpg"
                    let pdfPage = pdfDocument.page(at: page)!
                    let fileUrl = URL(string: filePath)!
                    try extractPage(page: pdfPage, dstUrl: fileUrl, quality: 100)
                } catch {
                    // pass
                }
            }
            
            resolve(nil)
        } catch {
            reject("error", error.localizedDescription, error)
        }
    }
}
