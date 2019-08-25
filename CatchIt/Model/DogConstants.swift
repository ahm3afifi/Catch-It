//
//  DogConstants.swift
//  CatchIt
//
//  Created by Ahmed Afifi on 8/25/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

extension DogClient {
    struct Constants {
        struct RandomDog: Decodable {
            let status: String
            let message: String
        }
        
        struct AllDogBreeds: Decodable {
            let status: String
            let message: [String: [String]]
        }
        
        struct Breed: Decodable {
            let breed: String
        }
        
        struct SubBreed: Decodable {
            let subBreed: [String]
        }
        
        
        // RANDOM DOG JSON
        struct APIUrls {
            static let randomDogAPIString = "https://dog.ceo/api/breeds/image/random"
        }
        
    }
}
