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
    
class func drawLineOnImage(image: UIImage, from: CGPoint, to: CGPoint) -> UIImage? {
    UIGraphicsBeginImageContext(image.size)
    let context = UIGraphicsGetCurrentContext()
    
    image.draw(at:CGPoint.zero)
    context!.setLineWidth(2.0)
    context!.setStrokeColor(UIColor.blue.cgColor)
    context!.move(to:from)
    context!.addLine(to:to)
    context!.strokePath()
    
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resultImage
}
}
