//
//  AsyncUIImageDownloaderExtension.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 19.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit


extension ShoppingList: URLSessionDownloadDelegate {
    public func userProfileImageFromURL(){
        if let index = ProfileImageCache.index(where: { $0.ProfileImageURL == self.OwnerProfileImageURL }) {
            self.OwnerProfileImage = ProfileImageCache[index].UserProfileImage!
            NSLog("UserProfileImage set from ImageCache!")
            return
        }
        let url = URL(string: self.OwnerProfileImageURL!)!
        let uTask = self.uSession.downloadTask(with: url)
        uTask.resume()
    }
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        if let image = try? UIImage(data: Data(contentsOf: location)),
            image != nil
        {
            let cachedImage = CacheUserProfileImage()
            cachedImage.ProfileImageURL = location.absoluteString
            cachedImage.UserProfileImage = image
            ProfileImageCache.append(cachedImage)
            NSLog("Added UserProfileImage to Cache")
            self.OwnerProfileImage = image
            NSLog("UserProfileImage set from DownloadTask!")
            self.ShoppingBuddyImageReceived()
        } else {
            //Set default image
        }
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            NSLog(error!.localizedDescription)
            let title = String.OnlineFetchRequestError
            let message = error!.localizedDescription
            self.ShowAlertMessage(title: title, message: message)
        }
    }
}

