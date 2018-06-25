//
//  ViewController.swift
//  FaceSelectionSwift
//
//  Created by Joseph Kubiak on 6/24/18.
//  Copyright © 2018 Joseph Kubiak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let testImageURL = "https://s3-us-west-2.amazonaws.com/precious-interview/ios-face-selection/family.jpg"
        let testImageMetaDataURL = "https://s3-us-west-2.amazonaws.com/precious-interview/ios-face-selection/family_faces.json"
        
        AssetFetcher.fetch(URL: URL(string: testImageURL)!, OnFetched: onFetched, OnError: onAssetError)
        AssetFetcher.fetch(URL: URL(string: testImageMetaDataURL)!, OnFetched: onFetchedJson, OnError: onAssetError)
    }
    
    func onFetched(imageData: Data?) {
        let savePath = "testImage.jpg"
        let image = AssetFetcher.saveDataToImageFile(imageData: imageData!, path: savePath)
        
        DispatchQueue.main.async {
            let imageViewSize = image!.size
            let imageView = UIImageView(image: image!)
            
            imageView.frame = CGRect(x: 0, y: 0, width:imageViewSize.width, height: imageViewSize.height)
            self.view.addSubview(imageView)
        }
    }
    
    func onFetchedJson(imageMetaData: Data?) {
        //print("Meta Data: \(imageMetaData)")
        guard let detectResult = try? JSONDecoder().decode([DetectResultModel].self, from: imageMetaData!) else {
            let dataStr = String(data: imageMetaData!, encoding: String.Encoding.utf8)
            print("Error: Couldn't decode data into DetectResultModel\n \(dataStr!)")
            return
        }
        
        print("Face ID: \(detectResult[0].faceId)")
    }
    
    func onAssetError(fileName : String, errorMsg: String) {
        print("Save Error (\(fileName)): \(errorMsg)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

