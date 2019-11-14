//
//  UserDataResponse.swift
//  OnMap
//
//  Created by William Lewis on 11/14/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import Foundation
struct UserDataResponse: Codable {
    let lastName: String?
    let firstName: String?
    
    enum CodingKeys: String, CodingKey {
        case lastName = "last_name"
        case firstName = "first_name"
    }
}
