//
//  AssetFetcher.swift
//  SwiftTest
//
//  Created by Joseph Kubiak on 6/24/18.
//  Copyright © 2018 Joseph Kubiak. All rights reserved.
//

import Foundation
import UIKit

class AssetFetcher {
    class func fetch(
        URL: URL,
        OnFetched: @escaping(Data?) -> Void,
        OnError: @escaping(String, String) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request, completionHandler: { (data: Data!, response: URLResponse!, error: Error!) -> Void in
            if (error == nil) {
                OnFetched(data)
            }
            else {
                OnError(URL.absoluteString, error.localizedDescription)
            }
        })
        task.resume()
    }
    
    class func saveDataToImageFile(imageData: Data, path: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(path)
        let image = UIImage(data:imageData)
        if let data = UIImageJPEGRepresentation(image!, 1.0),
            !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
            } catch {
                print("error saving file:", error)
            }
        }
        
        return image
    }
}
