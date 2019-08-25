//
//  DogClient.swift
//  CatchIt
//
//  Created by Ahmed Afifi on 8/25/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit

class DogClient: NSObject {
    
    // GET RANDOM DOG PHOTO METHOD
    func getRandomDog(completionForGetRandomDog: @escaping (_ image: UIImage?, _ imageData: Data?,_ urlString: String?, _ error: String?) -> Void) {
        
        let randomDogURL = URL(string: Constants.APIUrls.randomDogAPIString)!
        var dogPhoto = UIImage()
        let request = URLRequest(url: randomDogURL)
        
        taskForGetMethod(urlRequest: request) { (randomDogData, error) in
            guard (error == nil) else {
                completionForGetRandomDog(nil, nil, nil, "error in taskForGet: \(error!)")
                return
            }
            
            guard let randomDogData = randomDogData else {
                completionForGetRandomDog(nil, nil, nil, "no dog data from taskForGet")
                return
            }
            
            let randomDogURLString = randomDogData.message
            
            if let randomDogURL = URL(string: randomDogURLString), let dogData = try? Data(contentsOf: randomDogURL) {
                if let dogImage = UIImage(data: dogData) {
                    dogPhoto = dogImage
                    completionForGetRandomDog(dogPhoto, dogData, randomDogURLString, nil)
                } else {
                    completionForGetRandomDog(nil, nil, nil, "no image present")
                }
                
            }
            
            }.resume()
        
    }
    
    // TASK FOR GET METHOD
    func taskForGetMethod(urlRequest: URLRequest, completionForGet: @escaping (_ result: Constants.RandomDog?, _ error: String?) -> Void) -> URLSessionDataTask{
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard (error == nil) else {
                completionForGet(nil, "there was an error: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completionForGet(nil, "no status code returned")
                return
            }
            
            if statusCode < 200 {
                completionForGet(nil, "Status code was not lower than 200: \(statusCode)")
                return
            }
            
            guard let data = data else {
                completionForGet(nil, "no data returned")
                return
            }
            
            self.convertToJSONFrom(randomDogData: data, completionForJSONConversion: completionForGet)
            
        }
        return task
    }
    
    
    // CONVERT TO JSON METHOD
    func convertToJSONFrom(randomDogData: Data, completionForJSONConversion: @escaping (_ result: Constants.RandomDog?, _ error: String?) -> Void) {
        var decodedResults: Constants.RandomDog!
        
        do {
            decodedResults = try JSONDecoder().decode(Constants.RandomDog.self, from: randomDogData)
            completionForJSONConversion(decodedResults, nil)
        } catch {
            print("error decoding randomDog JSON: \(error.localizedDescription)")
            completionForJSONConversion(nil, error.localizedDescription)
        }
    }
    
    
    // GET BREED & SUBBREED INFO FROM PHOTO URL
    func getBreedAndSubBreed(urlString: String) -> [String] {
        var stringArray = [String]()
        var breed: String!
        var subBreed: String!
        
        var fullBreed = urlString.replacingOccurrences(of: "https://images.dog.ceo/breeds/", with: "").capitalized
        if let slashIndex = fullBreed.firstIndex(of: "/") {
            fullBreed = String(fullBreed[..<slashIndex])
        }
        
        
        let splitDogBreed = fullBreed.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
        if splitDogBreed.count <= 1 {
            let breed = String(splitDogBreed[0])
            stringArray.append(breed)
        } else {
            breed = String(splitDogBreed[0])
            subBreed = String(splitDogBreed[1])
            stringArray.append(breed)
            stringArray.append(subBreed)
        }
        
        return stringArray
    } // GET BREED & SUBBREED
    
    // - MARK: SINGLETON
    static let sharedInstance = DogClient()
}

