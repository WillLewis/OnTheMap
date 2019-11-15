//
//  UdacityClient.swift
//  OnMap
//
//  Created by William Lewis on 11/7/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import Foundation
import CoreLocation

class UdacityClient {
    
    struct Auth {
        static var sessionId = ""
        static var sessionKey = " "
        static var firstName = " "
        static var lastName = " "
        static var objectId = " "
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        static let limit100 = "limit=100"
        static let parameter = "?"
        static let reverseOrder = "order=-updatedAt"
        static let apiKey = "\(Auth.sessionKey)"
        
        case createOrDeleteSession
        case getStudentLocations
        case addStudentLocation
        case getUserData
        
        var stringValue: String {
            switch self {
            case .createOrDeleteSession: return Endpoints.base + "/session"
            case .getStudentLocations: return Endpoints.base + "/StudentLocation" + Endpoints.parameter + Endpoints.reverseOrder + Endpoints.parameter + Endpoints.limit100
            case .addStudentLocation: return Endpoints.base + "/StudentLocation"
            case .getUserData: return Endpoints.base + "/users" + Endpoints.apiKey
            }
        }
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    class func createSession (username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
           let udacityDict = Profile(username: username, password: password)
           let body = PostSession(udacity: udacityDict, username: username, password: password)
           
        var request = URLRequest(url: URL(string:"https://onthemap-api.udacity.com/v1/session")!)
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
                    Auth.sessionKey = response.account?.key ?? "3903878747"
                    Auth.sessionId = response.session?.id ?? "no sessionid"
                    completion(true, nil)
               }
               print(response.account?.key)
               print("key is \(Auth.sessionKey)")
               print("sessionId is \(Auth.sessionId)")
               print("session is all good")
           }catch {
               print(error)
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }}
           
           task.resume()
       }
    
    class func getStudentLocations ( completion: @escaping ([Location], Error?) -> Void ) {
        let task = URLSession.shared.dataTask(with: URL(string:"https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt?limit=100")!) { data, response, error in
            guard let data = data else {
                completion ([], error)
                print("problem with get StudentLocation URL")
                return
            }
            print("URL session for getStudentLocations worked")
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(LocationResults.self, from: data)
                print(String(data: data, encoding: .utf8))
                completion( response.results, nil)
            } catch let error as NSError { /* cast error to `NSError` */
               print(error.domain)
               print(error.code)
               print(error.userInfo)
            }catch {
                completion([], error)
                print(error)
            }
        }
        task.resume()
    }
   
    class func getUserData (completion: @escaping (Bool, Error?) -> Void ) {
        let task = URLSession.shared.dataTask(with: URL(string:"https://onthemap-api.udacity.com/v1/users/\(Auth.sessionKey)")!) { data, response, error in
            guard let data = data else {
                completion(false, error)
                print("problem with getUserData URL")
                return
            }
            print("URL session for getUserData worked")
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(UserDataResponse.self, from: data)
                DispatchQueue.main.async {
                    Auth.firstName = response.firstName ?? "no firstName"
                    Auth.lastName = response.lastName ?? "no lastName"
                    completion(true, nil)
                }
                completion(true, nil)
            } catch let error as NSError { /* cast error to `NSError` */
               print(error.domain)
               print(error.code)
               print(error.userInfo)
            }catch {
                completion(false, error)
                print(error)
            }
        }
        task.resume()
    }
    
    class func addStudentLocation (mapString: String?, mediaURL: String?, completion: @escaping (Bool, Error?) -> Void){
        let body = PostLocation(uniqueKey: Auth.sessionKey, firstName: Auth.firstName, lastName: Auth.lastName, mapString: mapString, mediaURL: mediaURL, latitude: Float(LocationDegrees.lat), longitude: Float(LocationDegrees.long))
        
        var request = URLRequest(url: URL(string:"https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        
       let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data else {
                completion(false, error)
               print("addStudentLocation URL Session problem")
                return
                 
            }
            let decoder = JSONDecoder()
            do {
                let range = 5..<data.count
                let dataSubset = data.subdata(in: range) //subset of data
                
                let response = try decoder.decode(PostLocationResponse.self, from: dataSubset)
                DispatchQueue.main.async {
                    Auth.objectId = response.objectId
                    completion(true, nil)
                }
                
                print("objectId is \(Auth.objectId)")
                print("addStudentLocation is all good")
            }catch {
                print(error)
                completion(false, error)
            }
            }
            task.resume()
    }
    
   
    
    class func getCoordinate( addressString: String, completion: @escaping (Bool, Error) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString, completionHandler: {
            (placemarks: [CLPlacemark]?, error: Error) in
            if let placemark = placemarks?[0] {
                LocationDegrees.lat = placemark.location!.coordinate.latitude
                LocationDegrees.long = placemark.location!.coordinate.longitude
                completion(true, error)
            } else {
                completion(false, error)
                
            }
            } as! CLGeocodeCompletionHandler)
    }
    
    
    
}

