//
//  PostLocation.swift
//  OnMap
//
//  Created by William Lewis on 11/12/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import Foundation

struct PostLocation: Codable {
    let uniqueKey: String
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaURL: String?
    let latitude: Float
    let longitude: Float
}
