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
        //static var udacity = [PostSession.username: PostSession.password]()
        static var userKey = ""
        static var pswdKey = ""
        static var key = ""
        static var sessionId = ""
        
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
    
    class func getStudentLocations ( completion: @escaping ([Location], Error?) -> Void ) {
        let task = URLSession.shared.dataTask(with: Endpoints.getStudentLocations.url) { data, response, error in
            guard let data = data else {
                completion ([], error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(LocationResults.self, from: data)
                print(response.results)
                completion( response.results, nil)
            }catch {
                completion([], error)
            }
        }
        task.resume()
    }
    
    class func createSession (username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let udacityDict = Profile(username: username, password: password)
        let body = PostSession(udacity: udacityDict, username: username, password: password)
        
        var request = URLRequest(url: Endpoints.createOrDeleteSession.url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body) //
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
        guard let data = data else {
            completion(false, error)
           print("URL Session problem")
            return
             
        }
        let decoder = JSONDecoder()
        do {
            let range = 5..<data.count
            let dataSubset = data.subdata(in: range) //subset of data
            
            let response = try decoder.decode(SessionResponse.self, from: dataSubset)
            DispatchQueue.main.async {
                Auth.key = response.account?.key ?? "no account"
                Auth.sessionId = response.session?.id ?? "no sessionid"
                completion(true, nil)
            }
            print(response)
            print(Auth.key)
            print(Auth.sessionId)
            print("session set")
        }catch {
            print(error)
            completion(false, error)
        }
        }
        task.resume()
    }
    
    
    
    
}

