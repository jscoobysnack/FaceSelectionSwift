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

struct HeadPose : Decodable {
    let pitch : Float
    let roll : Float
    let yaw : Float
}

struct FaceEmotion : Decodable {
    let anger : Float
    let contempt : Float
    let disgust : Float
    let fear : Float
    let happiness : Float
    let neutral : Float
    let sadness : Float
    let surprise : Float
}

struct FaceAttributes : Decodable {
    let gender : String
    let age : Float
    let emotion : FaceEmotion
    let headPose : HeadPose
}

struct DetectResultModel : Decodable {
    let faceId: String
    let faceRectangle: DetectRectangle
    let faceAttributes : FaceAttributes
    let faceLandmarks : [String: FaceLandmarkCoordinate]
}
