//
//  CMPhotoAlbumViewController.swift
//  CMPhotoAlbum
//
//  Created by Moyun on 2017/7/1.
//

import UIKit
import Photos
import PhotosUI
import AssetsLibrary

@objc public protocol CMPhotoAlbumViewControllerDelegate : class {
    func dismissPhotoAlbum(image: UIImage,asset: PHAsset?)
    @objc optional func failedGetPhoto(error: NSError)
    @objc optional func photoAlbumDidCancel()
    @objc optional func needCustomCamera() -> Bool
    @objc optional func openCamera()
}

extension CMPhotoAlbumViewControllerDelegate {
    public func dismissPhotoAlbum(image: UIImage,asset: PHAsset?) {}
    public func failedGetPhoto(error: NSError) {}
    public func photoAlbumDidCancel() {}
    public func needCustomCamera() -> Bool { return false }
    public func openCamera() {}
}

public struct CMPhotoAlbumConfig {
    
    public var defaultCameraTitle = "Camera Roll"
    public var backIcon = CMBundle.bundleImage(named: "nav_back")
    public var videoIcon = CMBundle.bundleImage(named: "video")
    public var titleIcon = CMBundle.bundleImage(named: "pop_arrow")
    public var cameraIcon = CMBundle.bundleImage(named: "nav_camera")
    public var arrowIcon = CMBundle.bundleImage(named: "pop_arrow")
    
    public var numberOfColumn = 3
    public var animationDuring = 0.25
    
    public var mediaType: PHAssetMediaType? = nil
    
    public var needConvertToChinese = true
    var listBackgroundColor: UIColor = UIColor.gray.withAlphaComponent(0.6)
    
    public init () {}
}

open class CMPhotoAlbumViewController: UIViewController {
    public weak var delegate: CMPhotoAlbumViewControllerDelegate?
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var popUpView: CMPAPopView!
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var backItem: UIBarButtonItem!
    @IBOutlet weak var cameraItem: UIBarButtonItem!
    @IBOutlet weak var titleButton: UIButton!
    
    @IBAction func backAtion(_ sender: Any) {
        self.delegate?.photoAlbumDidCancel()
        self.closeCurrentVC()
    }
    
    @IBAction func cameraAction(_ sender: Any) {
        self.switchAlbum(needClose: true)
        if let delegate = self.delegate {
            if (delegate.needCustomCamera()) {
                self.delegate?.openCamera()
            } else {
                self.openCamera()
            }
        } else {
            self.openCamera()
        }
    }
    @IBAction func titleAction(_ sender: Any) {
        self.switchAlbum(needClose: false)
    }
    
    public var config = CMPhotoAlbumConfig() {
        didSet {
            
        }
    }
    var itemSize = CGSize.zero
    var photoLibrary = CMPhotoLibrary()
    var collections = [CMAssetsCollection]()
    var currentAlbumCollection: CMAssetsCollection? = nil{
        didSet {
            self.switchAlbum(needClose: false)
            self.updateNaviTitle()
            self.collectionView.reloadData()
        }
    }
    var isPresenting: Bool = false
    
    public init() {
        super.init(nibName: "CMPhotoAlbumViewController", bundle: Bundle(for: CMPhotoAlbumViewController.self))
        
        self.view.bringSubview(toFront: self.naviBar)
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization({ [weak self] status in
                self?.initPhotoLibrary()
            })
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        commonInitUI()
        initPhotoLibrary()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.itemSize == CGSize.zero {
            commonInitSize()
        }
    }
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController?.topViewController == self {
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.navigationController?.topViewController == self {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
}

extension CMPhotoAlbumViewController {
    
    func initPhotoLibrary() {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.photoLibrary.delegate = self
            self.photoLibrary.getSourceData(mediaType: self.config.mediaType)
        }
    }
    
    func commonInitSize() {
        let count = CGFloat(self.config.numberOfColumn)
        let width = (self.collectionView.bounds.width - 5 * (count + 1))/count
        self.itemSize = CGSize(width: width, height: width)
        self.layout.itemSize = self.itemSize
    }
    
    func commonInitUI() {
        self.popUpView.transform = CGAffineTransform(translationX:0, y: -(self.view.bounds.height))
        self.backItem.image = self.config.backIcon
        self.cameraItem.image = self.config.cameraIcon
        self.popUpView.backgroundView.backgroundColor = self.config.listBackgroundColor
        self.updateNaviTitle()
        self.collectionView.register(UINib(nibName: "CMPACollectionViewCell", bundle: Bundle(for: CMPhotoAlbumViewController.self)), forCellWithReuseIdentifier: "CMPACollectionViewCell")
        self.popUpView.backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchAlbum)))
    }
    
    func openCamera()  {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func switchAlbum(needClose: Bool) {
        if needClose {
            self.popUpView.transform = CGAffineTransform(translationX:0, y: -(self.view.bounds.height))
            self.isPresenting = true
        } else {
            UIView.animate(withDuration: self.config.animationDuring, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
                self.popUpView.transform = self.isPresenting ? CGAffineTransform.identity : CGAffineTransform(translationX:0, y: -(self.view.bounds.height))
            }, completion: nil )
            self.isPresenting = !self.isPresenting
        }
    }
    
    func updateNaviTitle() {
        guard self.currentAlbumCollection != nil else {
            return
        }
        var title : String? = nil
        if let current = self.currentAlbumCollection {
            title = current.title
        } else {
            title = self.config.defaultCameraTitle
        }
        self.titleButton.set(image: self.config.arrowIcon, title: (self.config.needConvertToChinese ? self.photoLibrary.titleOfAlbumForChinese(title: title) : title)!, titlePosition: .left, additionalSpacing: 10.0, state: UIControlState.normal)
    }
    
    func updateConstrain(height: CGFloat) {
        self.popUpView.popupViewHeight.constant = height
    }
    
    func closeCurrentVC() {
        self.popUpView.removeFromSuperview()
        if self.navigationController?.topViewController == self {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension CMPhotoAlbumViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.delegate?.dismissPhotoAlbum(image: image, asset: nil)
        } else {
            self.delegate?.failedGetPhoto(error: NSError.init(domain: "CMPADomain", code: 10001, userInfo: ["info":"have no image"]))
        }
//        if let assertUrl = info[UIImagePickerControllerReferenceURL] as? URL {
//            let result = PHAsset.fetchAssets(withALAssetURLs: [assertUrl], options: nil)
//            if let asset = result.firstObject {
//                self.delegate?.dismissPhotoAlbum(withAsset: asset)
//            }
//        }
        picker.dismiss(animated: false) {
            self.closeCurrentVC()
        }
    }
}

extension CMPhotoAlbumViewController : CMPhotoLibraryDelegate {
    func loadCameraRollCollection(collection: CMAssetsCollection) {
        self.currentAlbumCollection = collection
        self.collections = [collection]
    }
    
    func loadCompleteAllCollection(collections: [CMAssetsCollection]) {
        self.collections = collections
        self.updateConstrain(height: CGFloat(min(self.collections.count*70, 5*70)))
        self.popUpView.tableView.reloadData()
    }
}

extension CMPhotoAlbumViewController : UICollectionViewDelegate,UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collection = self.currentAlbumCollection else { return }
        guard let asset = collection.getAsset(at: indexPath.row) else { return }
        if let image = self.photoLibrary.fetchOriginImage(asset: asset) {
            self.delegate?.dismissPhotoAlbum(image: image, asset: asset)
        } else {
            self.delegate?.failedGetPhoto(error: NSError.init(domain: "CMPADomain", code: 10001, userInfo: ["info":"have no image"]))
        }
        self.closeCurrentVC()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collection = self.currentAlbumCollection else {
            return 0
        }
        return collection.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CMPACollectionViewCell", for: indexPath) as! CMPACollectionViewCell
        guard let collection = self.currentAlbumCollection else { return cell }
        guard let asset = collection.getAsset(at: indexPath.row) else { return cell }
        _ = self.photoLibrary.imageAsset(asset: asset, size: cell.bounds.size, options: nil, completionBlock: { (image) in
            cell.imageView.image = image
        })
        if #available(iOS 9.1, *) {
            if asset.mediaSubtypes.contains(.photoLive) {
                cell.liveBadgeView.image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
            } else {
                cell.liveBadgeView.image = nil
            }
        }
        return cell
    }
}

extension CMPhotoAlbumViewController : UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.collections.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CMPAListViewCell") as! CMPAListViewCell
        let collection = self.collections[indexPath.row]
        if let asset = collection.getAsset(at: 0) {
            _ = self.photoLibrary.imageAsset(asset: asset, completionBlock: { (image) in
                cell.imgView.image = image
            })
        }
        cell.titleLabel.text = self.config.needConvertToChinese ? self.photoLibrary.titleOfAlbumForChinese(title: collection.title) : collection.title
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < self.collections.count else {
            return ;
        }
        self.currentAlbumCollection = self.collections[indexPath.row]
        
    }
}
