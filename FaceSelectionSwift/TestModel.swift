//
//  TestModel.swift
//  SwiftTest
//
//  Created by Joseph Kubiak on 6/24/18.
//  Copyright © 2018 Joseph Kubiak. All rights reserved.
//

import Foundation

struct Blog: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
