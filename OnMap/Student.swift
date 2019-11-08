//
//  Student.swift
//  OnMap
//
//  Created by William Lewis on 11/7/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import Foundation

struct Student: Codable {
    let firstName: String
    let lastName: String
    let longitude: Float
    let latitude: Float
    let mapString: String
    let mediaURL: URL
    let uniqueKey: String?
    let objectId: String
    let createdAt: String
    let updatedAt: String
}
