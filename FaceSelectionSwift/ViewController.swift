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
    var m_textView : UITextView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(m_imageView)
        self.view.addSubview(m_textView)
        
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
        
        DrawImageInfo()
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
    
    func rotatePoint(target: CGPoint, aroundOrigin origin: CGPoint, byDegrees: CGFloat) -> CGPoint {
        let dx = target.x - origin.x
        let dy = target.y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx) // in radians
        let newAzimuth = azimuth + byDegrees * CGFloat(.pi / 180.0) // convert it to radians
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
    
    func DrawImageInfo() {
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
                
                let r = CGFloat(faceInfo.faceAttributes.headPose.roll)// * .pi / 180
                let halfWidth = CGFloat(faceInfo.faceRectangle.width) / 2.0
                let halfHeight = CGFloat(faceInfo.faceRectangle.height) / 2.0
                let centerX = CGFloat(tl.x) + halfWidth
                let centerY = CGFloat(tl.y) + halfHeight
                let centerPt = CGPoint(x: centerX, y: centerY)
                
                let rtl = self.rotatePoint(target:tl, aroundOrigin:centerPt, byDegrees:r)
                let rbl = self.rotatePoint(target:bl, aroundOrigin:centerPt, byDegrees:r)
                let rbr = self.rotatePoint(target:br, aroundOrigin:centerPt, byDegrees:r)
                let rtr = self.rotatePoint(target:tr, aroundOrigin:centerPt, byDegrees:r)
                
                let color = faceInfo.faceAttributes.gender == "male" ? UIColor.blue.cgColor : pink
                let lineWidth : CGFloat = self.m_selectedFaceId == faceInfo.faceId ? 5.0 : 2.0
                
                paintedImage = ImageDrawing.drawLineOnImage(image: paintedImage!, from: rtl, to: rbl, color: color, lineWidth: lineWidth)
                paintedImage = ImageDrawing.drawLineOnImage(image: paintedImage!, from: rbl, to: rbr, color: color, lineWidth: lineWidth)
                paintedImage = ImageDrawing.drawLineOnImage(image: paintedImage!, from: rbr, to: rtr, color: color, lineWidth: lineWidth)
                paintedImage = ImageDrawing.drawLineOnImage(image: paintedImage!, from: rtr, to: rtl, color: color, lineWidth: lineWidth)
                
                for landmark in faceInfo.faceLandmarks {
                    let pt = CGPoint(x:Int(landmark.value.x), y:Int(landmark.value.y))
                    let dotColor = UIColor.green.cgColor
                    paintedImage = ImageDrawing.drawDotOnImage(image: paintedImage!, pt: pt, color: dotColor, lineWidth: 2.0)
                }
            }
            
            self.m_imageView.image = paintedImage!
            
            let frameRect = self.CalculateFrameRect(view:self.view, image:paintedImage!)
            self.m_imageView.frame = frameRect
            
            let textTop = frameRect.origin.y + frameRect.height
            let textHeight = self.view.bounds.height - textTop
            self.m_textView.frame = CGRect(x: 0, y: textTop, width: self.view.bounds.width, height: textHeight)
        }
    }
    
    func onAssetError(fileName : String, errorMsg: String) {
        print("Save Error (\(fileName)): \(errorMsg)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getMainEmotion(faceInfo: DetectResultModel) -> String {
        var emotionStr = "Happiness";
        var emotionValue : Float = 0.0
        let emotion = faceInfo.faceAttributes.emotion
        
        if(emotion.anger > emotionValue) {
            emotionStr = "Anger"
            emotionValue = emotion.anger
        }
        if(emotion.contempt > emotionValue) {
            emotionStr = "Contempt"
            emotionValue = emotion.contempt
        }
        if(emotion.disgust > emotionValue) {
            emotionStr = "Disgust"
            emotionValue = emotion.disgust
        }
        if(emotion.fear > emotionValue) {
            emotionStr = "Fear"
            emotionValue = emotion.fear
        }
        if(emotion.happiness > emotionValue) {
            emotionStr = "Happiness"
            emotionValue = emotion.happiness
        }
        
        if(emotion.neutral > emotionValue) {
            emotionStr = "Neutral"
            emotionValue = emotion.neutral
        }
        
        if(emotion.sadness > emotionValue) {
            emotionStr = "Sadness"
            emotionValue = emotion.sadness
        }
        
        if(emotion.surprise > emotionValue) {
            emotionStr = "Surprise"
            emotionValue = emotion.surprise
        }
        
        return emotionStr;
    }
    
    func calculateFaceOccupation(image : UIImage, faceInfo : DetectResultModel) -> Float {
        let faceArea : Float = Float(faceInfo.faceRectangle.width * faceInfo.faceRectangle.height);
        let imageArea : Float = Float(image.size.width * image.size.height);
        return (faceArea / imageArea) * 100.0;
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
                let emotion = getMainEmotion(faceInfo: faceInfo)
                let occupationPct = calculateFaceOccupation(image: m_sourceImage!, faceInfo: faceInfo)
                var desc = "Gender: \(faceInfo.faceAttributes.gender)\n"
                desc += "Age: \(faceInfo.faceAttributes.age)\n"
                desc += "Emotion: \(emotion)\n"
                desc += "Face Occupation: \(occupationPct)%\n"
                m_textView.text = desc;
                DrawImageInfo();
                break;
            }
        }
        
        print("Gesture: \(pt)" )
    }
}

