//
//  ImageDrawing.swift
//  SwiftTest
//
//  Created by Joseph Kubiak on 6/24/18.
//  Copyright © 2018 Joseph Kubiak. All rights reserved.
//

import Foundation
import UIKit

class ImageDrawing {

    class func drawLineOnImage(image: UIImage, from: CGPoint, to: CGPoint, color: CGColor, lineWidth: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        image.draw(at:CGPoint.zero)
        context!.setLineWidth(lineWidth)
        context!.setStrokeColor(color)
        context!.move(to:from)
        context!.addLine(to:to)
        context!.strokePath()
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage
    }
    
    class func drawDotOnImage(image: UIImage, pt: CGPoint, color: CGColor, lineWidth: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        let halfWidth = lineWidth / 2.0

        image.draw(at:CGPoint.zero)
        context!.setLineWidth(lineWidth)
        context!.setFillColor(color)
        context!.fill(CGRect(x:pt.x - halfWidth, y:pt.y - halfWidth, width: lineWidth, height: lineWidth))
        context!.strokePath()
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage
    }
}
