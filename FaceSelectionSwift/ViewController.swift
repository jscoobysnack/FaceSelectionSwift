//
//  ViewController.swift
//  FaceSelectionSwift
//
//  Created by Joseph Kubiak on 6/24/18.
//  Copyright © 2018 Joseph Kubiak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var m_sourceImage : UIImage?
    var m_faceInfo : [DetectResultModel] = []
    var m_selectedFaceId : String?
    var m_imageView : UIImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(m_imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        
        m_imageView.addGestureRecognizer(tapGesture)
        m_imageView.isUserInteractionEnabled = true
        
        let testImageURL = "https://s3-us-west-2.amazonaws.com/precious-interview/ios-face-selection/family.jpg"
        let testImageMetaDataURL = "https://s3-us-west-2.amazonaws.com/precious-interview/ios-face-selection/family_faces.json"
        
        AssetFetcher.fetch(URL: URL(string: testImageURL)!, OnFetched: onFetched, OnError: onAssetError)
        AssetFetcher.fetch(URL: URL(string: testImageMetaDataURL)!, OnFetched: onFetchedJson, OnError: onAssetError)
    }
    
    func onFetched(imageData: Data?) {
        let savePath = "testImage.jpg"
        let image = AssetFetcher.saveDataToImageFile(imageData: imageData!, path: savePath)
        
        m_sourceImage = image
        
        DrawBoundingBoxes()
    }
    
    func onFetchedJson(imageMetaData: Data?) {
        //print("Meta Data: \(imageMetaData)")
        guard let detectResult = try? JSONDecoder().decode([DetectResultModel].self, from: imageMetaData!) else {
            let dataStr = String(data: imageMetaData!, encoding: String.Encoding.utf8)
            print("Error: Couldn't decode data into DetectResultModel\n \(dataStr!)")
            return
        }
        
        m_faceInfo = detectResult
        print("Face ID: \(detectResult[0].faceId)")
    }
    
    func ConvertScreenPointToImageSpace(pt: CGPoint, view : UIView, image: UIImage) -> CGPoint {
        let viewAspect = view.bounds.size.width / view.bounds.size.height
        let imageAspect = image.size.width / image.size.height
        
        var widthScale : CGFloat = 0.0
        var heightScale : CGFloat = 0.0
        
        if(viewAspect > imageAspect) {
            let newWidth = view.bounds.size.height * imageAspect
            let newHeight = view.bounds.size.height
            widthScale = image.size.width / newWidth
            heightScale = image.size.height / newHeight
        }
        else {
            let newWidth = view.bounds.size.width
            let newHeight = newWidth / imageAspect
            widthScale = image.size.width / newWidth
            heightScale = image.size.height / newHeight
        }
        
        return CGPoint(x: pt.x * widthScale, y: pt.y * heightScale)
    }
    
    func CalculateFrameRect(view : UIView, image: UIImage) -> CGRect {
        let viewAspect = view.bounds.size.width / view.bounds.size.height
        let imageAspect = image.size.width / image.size.height
        if(viewAspect > imageAspect) {
            let newWidth = view.bounds.size.height * imageAspect
            let newHeight = view.bounds.size.height
            return CGRect(x:0, y:0, width:newWidth, height:newHeight)
        }
        else {
            let newWidth = view.bounds.size.width
            let newHeight = newWidth / imageAspect
            return CGRect(x:0, y:0, width:newWidth, height:newHeight)
        }
    }
    
    func DrawBoundingBoxes() {
        if(m_faceInfo.count == 0 || m_sourceImage == nil)
        {
            print("Data not fetched yet.")
            return
        }
        
        DispatchQueue.main.async {
            var paintedImage = self.m_sourceImage
            
            for faceInfo in self.m_faceInfo {
                
                let pink = UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0).cgColor
                let tl = CGPoint(x:faceInfo.faceRectangle.left, y:faceInfo.faceRectangle.top)
                let bl = CGPoint(x:faceInfo.faceRectangle.left, y:faceInfo.faceRectangle.top + faceInfo.faceRectangle.height)
                let br = CGPoint(x:faceInfo.faceRectangle.left + faceInfo.faceRectangle.width, y:faceInfo.faceRectangle.top + faceInfo.faceRectangle.height)
                let tr = CGPoint(x:faceInfo.faceRectangle.left + faceInfo.faceRectangle.width, y:faceInfo.faceRectangle.top)
                let color = faceInfo.faceAttributes.gender == "male" ? UIColor.blue.cgColor : pink
                let lineWidth : CGFloat = self.m_selectedFaceId == faceInfo.faceId ? 5.0 : 2.0
                
                paintedImage = ImageDrawing.drawLineOnImage(image: paintedImage!, from: tl, to: bl, color: color, lineWidth: lineWidth)
                paintedImage = ImageDrawing.drawLineOnImage(image: paintedImage!, from: bl, to: br, color: color, lineWidth: lineWidth)
                paintedImage = ImageDrawing.drawLineOnImage(image: paintedImage!, from: br, to: tr, color: color, lineWidth: lineWidth)
                paintedImage = ImageDrawing.drawLineOnImage(image: paintedImage!, from: tr, to: tl, color: color, lineWidth: lineWidth)
            }
            
            self.m_imageView.image = paintedImage!
            
            let frameRect = self.CalculateFrameRect(view:self.view, image:paintedImage!)
            self.m_imageView.frame = frameRect
        }
    }
    
    func onAssetError(fileName : String, errorMsg: String) {
        print("Save Error (\(fileName)): \(errorMsg)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func imageTapped(gesture: UIGestureRecognizer) {
        let pt = gesture.location(ofTouch: 0, in: self.view)
        let scaledPt = self.ConvertScreenPointToImageSpace(pt: pt, view: self.view, image: m_sourceImage!)
        for faceInfo in self.m_faceInfo {
            let rect = CGRect(x: faceInfo.faceRectangle.left,
                              y: faceInfo.faceRectangle.top,
                              width: faceInfo.faceRectangle.width,
                              height: faceInfo.faceRectangle.height)
            
            if(rect.contains(scaledPt)) {
                m_selectedFaceId = faceInfo.faceId;
                DrawBoundingBoxes();
                break;
            }
        }
        
        print("Gesture: \(pt)" )
    }
}

