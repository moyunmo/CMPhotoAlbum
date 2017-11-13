//
//  ViewController.swift
//  CMPhotoAlbum
//
//  Created by momo605654602@gmail.com on 07/01/2017.
//  Copyright (c) 2017 momo605654602@gmail.com. All rights reserved.
//

import UIKit
import CMPhotoAlbum
import Photos

class ViewController: UIViewController {

    @IBAction func pushAction(_ sender: Any) {
        let vc = CMPhotoAlbumViewController()
        vc.config = self.getConfig()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func popAction(_ sender: Any) {
        let vc = CMPhotoAlbumViewController()
        vc.config = self.getConfig()
        vc.delegate = self
        self.present(vc, animated: true) {
            
        }
    }
    @IBOutlet weak var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func getConfig() -> CMPhotoAlbumConfig {
        var config = CMPhotoAlbumConfig()
        config.numberOfColumn = 3;
        //        config.needConvertToChinese = false
        return config
    }

}

extension ViewController: CMPhotoAlbumViewControllerDelegate {
//    func dismissComplete() {
//        
//    }
//    
//    func dismissPhotoAlbum(withAsset: PHAsset) {
//        
//    }
    
    func dismissPhotoAlbum(image: UIImage, asset: PHAsset?) {
        self.imgView.image = image
    }
    
//    func photoAlbumDidCancel() {
//        
//    }
//    
//    
//    func needCustomCamera() -> Bool {
//        return true
//    }
//    
//    func openCamera() {
//        
//    }

}
