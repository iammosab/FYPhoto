//
//  PhotoProtocol.swift
//  FYPhoto
//
//  Created by xiaoyang on 2020/12/10.
//

import Foundation
import Photos
import UIKit

extension PHAsset {

    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

public protocol PhotoProtocol: URLPhotoProtocol, AssetPhotoProtocol, PhotoCaption {
    var image: UIImage? { get }
    var metaData: Data? { get }
    var isVideo: Bool { get }

    /// use this data to restore cropping photo scene
    var restoreData: CroppedRestoreData? { get set }

    func storeImage(_ image: UIImage?)
    func isEqualTo(_ photo: PhotoProtocol) -> Bool
}

public extension PhotoProtocol {
    var isVideo: Bool { return false }
    func storeImage(_ image: UIImage?) { }
}

public protocol PhotoCaption {
    var captionContent: String? { get }
    var captionSignature: String? { get }
}

public extension PhotoCaption {
    var captionContent: String? { return nil }
    var captionSignature: String? { return nil }
}

public protocol AssetPhotoProtocol {
    var asset: PHAsset? { get set }
    var targetSize: CGSize? { get set }
}

public protocol URLPhotoProtocol {
    var url: URL? { get set }

    func generateThumbnail(_ url: URL, size: CGSize, completion: @escaping ((Result<UIImage, Error>) -> Void))
    func clearThumbnail()
    func setCaptionContent(_ content: String)
    func setCaptionSignature(_ signature: String)
}

public extension URLPhotoProtocol {

    func generateThumbnail(_ url: URL, size: CGSize, completion: @escaping ((Result<UIImage, Error>) -> Void)) {}
    func clearThumbnail() {}
    func setCaptionContent(_ content: String) {}
    func setCaptionSignature(_ signature: String) {}
}
