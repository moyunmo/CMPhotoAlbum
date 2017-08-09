//
//  CMBundle.swift
//  CMPhotoAlbum
//
//  Created by Moyun on 2017/7/1.
//

import Foundation

class CMBundle {
    
    class func bundleImage(named: String) -> UIImage? {
        let bundle = Bundle(for: CMBundle.self)
        if let url = bundle.url(forResource: "CMPhotoAlbum", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            return UIImage(named: named, in: bundle, compatibleWith: nil)!.withRenderingMode(.alwaysOriginal)
        }
        return nil
    }
}
