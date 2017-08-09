//
//  CMPhotoLibrary.swift
//  CMPhotoAlbum
//
//  Created by Moyun on 2017/7/2.
//

import Foundation
import Photos

protocol CMPhotoLibraryDelegate: class {
    func loadCompleteAllCollection(collections: [CMAssetsCollection])
    func loadCameraRollCollection(collection: CMAssetsCollection)
}

struct CMAssetsCollection {
    
    var fetchResult: PHFetchResult<PHAsset>? = nil
    var title: String
    var localIdentifier: String
    
    var count: Int {
        guard let count = self.fetchResult?.count else {
            return 0
        }
        return count
    }
    
    init(collection: PHAssetCollection) {
        self.title = collection.localizedTitle ?? ""
        self.localIdentifier = collection.localIdentifier
    }
    
    func getAsset(at index: Int) -> PHAsset? {
        return self.fetchResult?.object(at: index)
    }
    
    static func !=(lhs: CMAssetsCollection, rhs: CMAssetsCollection) -> Bool {
        return lhs.localIdentifier != rhs.localIdentifier
    }
}


class CMPhotoLibrary {
    weak var delegate: CMPhotoLibraryDelegate? = nil
    lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    
    func titleOfAlbumForChinese(title: String?) -> String? {
        if title == "Slo-mo" {
            return "慢动作"
        } else if title == "Recently Added" {
            return "最近添加"
        } else if title == "Favorites" {
            return "个人收藏"
        } else if title == "Recently Deleted" {
            return "最近删除"
        } else if title == "Videos" {
            return "视频"
        } else if title == "All Photos" {
            return "所有照片"
        } else if title == "Selfies" {
            return "自拍"
        } else if title == "Screenshots" {
            return "屏幕快照"
        } else if title == "Camera Roll" {
            return "相机胶卷"
        } else if title == "Panoramas" {
            return "全景照片"
        }
        return title
    }
    
    func cancelPHImageRequest(requestId: PHImageRequestID) {
        self.imageManager.cancelImageRequest(requestId)
    }

    @available(iOS 9.1, *)
    func fetchLivePhotoAsset(asset: PHAsset, size: CGSize = CGSize(width:720, height: 1280), completionBlock:@escaping (PHLivePhoto) -> Void) -> PHImageRequestID {
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        let requestId = self.imageManager.requestLivePhoto(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (livePhoto, info) in
            if let livePhoto = livePhoto {
                completionBlock(livePhoto)
            }
        }
        return requestId
    }
    
    func imageAsset(asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), options: PHImageRequestOptions? = nil, completionBlock:@escaping (UIImage) -> Void) -> PHImageRequestID {
        var options = options
        if options == nil {
            options = PHImageRequestOptions()
            options?.deliveryMode = .highQualityFormat
            options?.isNetworkAccessAllowed = false
        }
        let requestId = self.imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (image, info) in
            if let image = image {
                completionBlock(image)
            }
        }
        return requestId
    }
    
    func fetchOriginImage(asset: PHAsset) -> UIImage? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .none
        options.isNetworkAccessAllowed = false
        options.version = .current
        var image: UIImage? = nil
        PHCachingImageManager().requestImageData(for: asset, options: options) { (data, dataString, orientation, info) in
            if let data = data {
                image = UIImage(data: data)
            }
        }
        return image
    }
    
}

extension CMPhotoLibrary {
    func getSourceData(mediaType: PHAssetMediaType? = nil) {
        let options = PHFetchOptions()
        let sortOrder = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortOrder]
        
        if let mediaType = mediaType {
            options.predicate = NSPredicate(format: "mediaType = %i", mediaType.rawValue)
        } else {
            options.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.image.rawValue)
        }
        
        func getSmartAlbum(subType: PHAssetCollectionSubtype, result: inout [CMAssetsCollection]) -> CMAssetsCollection? {
            let fetchCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subType, options: nil)
            if let collection = fetchCollection.firstObject, !result.contains(where: { $0.localIdentifier == collection.localIdentifier }) {
                var assetsCollection = CMAssetsCollection(collection: collection)
                assetsCollection.fetchResult = PHAsset.fetchAssets(in: collection, options: options)
                if assetsCollection.count > 0 {
                    result.append(assetsCollection)
                    return assetsCollection
                }
            }
            return nil
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            var assetCollections = [CMAssetsCollection]()
            let cameraCollection = getSmartAlbum(subType: .smartAlbumUserLibrary, result: &assetCollections)
            if let cameraCollection = cameraCollection {
                DispatchQueue.main.async {
                    self?.delegate?.loadCameraRollCollection(collection: cameraCollection)
                }
            }
            _ = getSmartAlbum(subType: .smartAlbumRecentlyAdded, result: &assetCollections)

            if #available(iOS 9.0, *) {
                _ = getSmartAlbum(subType: .smartAlbumSelfPortraits, result: &assetCollections)
                _ = getSmartAlbum(subType: .smartAlbumScreenshots, result: &assetCollections)
            }
            if #available(iOS 10.3, *) {
                _ = getSmartAlbum(subType: .smartAlbumLivePhotos, result: &assetCollections)
            }
            _ = getSmartAlbum(subType: .smartAlbumPanoramas, result: &assetCollections)
            _ = getSmartAlbum(subType: .smartAlbumFavorites, result: &assetCollections)
            let albumResult = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            albumResult.enumerateObjects({ (collection, index, stop) in
                guard let collection = collection as? PHAssetCollection else { return }
                var assetsCollection = CMAssetsCollection(collection: collection)
                assetsCollection.fetchResult = PHAsset.fetchAssets(in: collection, options: options)
                if assetsCollection.count > 0, !assetCollections.contains(where: { $0.localIdentifier == collection.localIdentifier }) {
                    assetCollections.append(assetsCollection)
                }
            })
            DispatchQueue.main.async {
                self?.delegate?.loadCompleteAllCollection(collections: assetCollections)
            }
        }
    }
}





