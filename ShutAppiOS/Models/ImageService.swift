//
//  ImageService.swift
//  ShutAppiOS
//
//  Created by Erik Ugarte on 2020-12-17.
//  Copyright © 2020 ShutApp. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ImageService {
    
    static let cache = NSCache<NSString, UIImage>()
    static let storage = Storage.storage()
    
    //Downloading Image Whit URL
    static func downloadImage(withURL url:URL, completion: @escaping (_ image:UIImage?, _ url:URL)->()) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            var downloadedImage:UIImage?
            
            if let data = data {
                downloadedImage = UIImage(data: data)
            }
            if downloadedImage != nil {
                cache.setObject(downloadedImage!, forKey: url.absoluteString as NSString)
            }
            DispatchQueue.main.async {
                completion(downloadedImage, url)
            }
        }
        dataTask.resume()
    }
    
    //get Image after download it
    static func getImage(withURL url:URL?, completion: @escaping (_ image:UIImage?, _ url:URL)->()) {
        if let _url = url {
            if let image = cache.object(forKey: _url.absoluteString as NSString) {
                completion(image, _url)
            } else {
                downloadImage(withURL: _url, completion: completion)
            }
        }
    }
    
    //Set image to UIImageView
    static func setImage(imageView image: UIImageView, imageURL url: String) {
        getImage(withURL: URL(string: url)) { retrievedImage, error in
            image.image = retrievedImage
        }
    }
    
    /*static func saveImageToFirebase() {
        let storageRef = Storage.storage().reference().child()

        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"

        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {

                storageRef.downloadURL { url, error in
                    completion(url)
                    // success!
                    
                }
                } else {
                    // failed
                    completion(nil)
                }
            }
    }*/
}
