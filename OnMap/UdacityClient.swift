//
//  UdacityClient.swift
//  OnMap
//
//  Created by William Lewis on 11/7/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import Foundation

class UdacityClient {
    
    
    struct Auth {
        static let userKey = ""
        static let pswdKey = ""
    }
    //getting location "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt"
    //posting location "https://onthemap-api.udacity.com/v1/StudentLocation"
    //putting locatin "https://onthemap-api.udacity.com/v1/StudentLocation/8ZExGR5uX8"
    //deleting session "https://onthemap-api.udacity.com/v1/session"
    //posting session "https://onthemap-api.udacity.com/v1/session"
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        static let limit100 = "limit=100"
        static let parameter = "?"
        static let reverseOrder = "order=-updatedAt"
        
        case createOrDeleteSession
        case getStudentLocations
        case addStudentLocation
        case updateStudentLocation(String)
        
        var stringValue: String {
            switch self {
            case .createOrDeleteSession:
                return Endpoints.base + "/session"
            case .getStudentLocations:
                return Endpoints.base + "/StudentLocation" + Endpoints.parameter + Endpoints.reverseOrder
            case .addStudentLocation:
                return Endpoints.base + "/StudentLocation"
            case .updateStudentLocation(let studentKey):
                return Endpoints.base + "/StudentLocation\(studentKey)"
            }
        }
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    class func getStudentLocations ( completion: @escaping ([Student], Error?) -> Void ) {
        let task = URLSession.shared.dataTask(with: Endpoints.getStudentLocations.url) { data, response, error in
            guard let data = data else {
                completion ([], error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(StudentResults.self, from: data)
                completion( responseObject.results, nil)
            }catch {
                completion([], error)
            }
        }
        task.resume()
    }
    
    
}

