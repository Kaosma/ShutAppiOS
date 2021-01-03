//
//  ImageService.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-17.
//  Copyright © 2020 ShutApp. All rights reserved.
//

// MARK: Frameworks
import Foundation
import UIKit
import Firebase

// MARK: Class Declaration
class ImageService {
    
    // MARK: Constants and Variables
    static let cache = NSCache<NSString, UIImage>()
    static let storage = Storage.storage()
    static let db = Firestore.firestore()
    

    // MARK: ImageFunctions
    // Retrieve the user's profile image from Firebase Storage
    static func getProfileImage(imageView: UIImageView) {
        
        let currentUser = CurrentUser()
        
        if let url = URL(string: currentUser.profileImage) {
            URLSession.shared.dataTask(with: url) { data, responseURL, error in
                var downloadedImage:UIImage?
                
                if let data = data {
                    downloadedImage = UIImage(data: data)
                }
                if downloadedImage != nil {
                    DispatchQueue.main.async {
                        imageView.image = downloadedImage
                    }
                }
            }.resume()
        }
    }
    
    // Get the downloaded image
    static func cacheImage(imageView: UIImageView, urlString: String, completion: @escaping (String, UIImage?, Error?) -> Void) {
        
        var imageKey: String = ""
        
        if let url = URL(string: urlString) {
            
            imageKey = url.lastPathComponent
            
         
            if let image = cache.object(forKey: imageKey as NSString) {
                imageView.image = image
                print("image from cache")
                completion(imageKey, image, nil)
                return
            } else {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    
                    if let e = error {
                        completion(imageKey, nil, e)
                        
                    } else {
                        if let data = data, let image = UIImage(data: data) {
                            print("image stored")
                            cache.setObject(image, forKey: imageKey as NSString)
                            DispatchQueue.main.async {
                                completion(imageKey, image, nil)
                                imageView.image = image
                            }
                        }
                    }
                }.resume()
            }
        }
    }
    

    // Upload profile image to Firebase Storage
    static func uploadProfileImageToStorage(selectedImage image: UIImage, userId id: String) {
        
        let storageRef = storage.reference().child("profileImages/\(id)ProfileImage.jpg")
        
        if let uploadData = image.pngData(){
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error as Any)
                    return
                    
                } else {
                    storageRef.downloadURL(completion: { (url, error) in
                        
                        if let retrievedURL = url {
                            let forestRef = storage.reference().child("profileImages/\(id)ProfileImage.jpg")
                            
                            // Create file metadata to update
                            let newMetadata = StorageMetadata()
                            newMetadata.cacheControl = "public,max-age=300";
                            newMetadata.contentType = "image/jpeg";

                            // Update metadata properties
                            forestRef.updateMetadata(newMetadata) { metadata, error in
                                if let e = error {
                                    print(e)
                                } else {
                                    UserFunctions().changeProfileImage(newURL: retrievedURL)
                                }
                            }
                        }
                    })
                }
            })
        }
    }
}

