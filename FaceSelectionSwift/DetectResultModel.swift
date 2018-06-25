//
//  DetectResultModel.swift
//  FaceSelectionSwift
//
//  Created by Joseph Kubiak on 6/24/18.
//  Copyright © 2018 Joseph Kubiak. All rights reserved.
//

import Foundation

struct DetectRectangle : Decodable {
    let top: Int
    let left: Int
    let width: Int
    let height: Int
}

struct FaceLandmarkCoordinate : Decodable {
    let x: Float
    let y: Float
}

struct FaceAttributes : Decodable {
    let gender : String
}

struct DetectResultModel : Decodable {
    let faceId: String
    let faceRectangle: DetectRectangle
    let faceAttributes : FaceAttributes
    let faceLandmarks : [String: FaceLandmarkCoordinate]
}
