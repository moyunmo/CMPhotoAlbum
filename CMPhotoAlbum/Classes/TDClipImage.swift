//
//  TDClipImage.swift
//  AFNetworking
//
//  Created by Moyun on 2017/11/13.
//

import Foundation
import UIKit

@objc open class TDClipImage : NSObject {
    class func clipImage(image: UIImage, mask: CGImage) -> UIImage {
        let width = image.size.width
        let height = image.size.height
        let maskData = UnsafeMutablePointer(mutating: CFDataGetBytePtr(mask.dataProvider!.data)!)
        for i in 0..<Int(width*height) {
            maskData[i] = 255 - maskData[i]
        }
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.translateBy(x: width, y: height)
        ctx.rotate(by: CGFloat.pi)
        ctx.translateBy(x: width, y: 0)
        ctx.scaleBy(x: -1, y: 1)
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        ctx.clip(to: rect, mask: mask)
        
        ctx.setBlendMode(.destinationAtop)
        ctx.draw(image.cgImage!, in: rect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result!
    }
    
    class func conver(imgRef: Unmanaged<CGImage>) -> CGImage {
        return imgRef.takeUnretainedValue()
    }
}

