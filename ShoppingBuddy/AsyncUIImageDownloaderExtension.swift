//
//  AsyncUIImageDownloaderExtension.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 19.08.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit


extension ShoppingBuddyUser: URLSessionDownloadDelegate {
    public func userProfileImageFromURL(){
        if let index = ProfileImageCache.index(where: { $0.ProfileImageURL == self.profileImageURL }) {
            self.profileImage = ProfileImageCache[index].UserProfileImage!
            NSLog("UserProfileImage set from ImageCache!")
            return
        }
        if let imageURL = self.profileImageURL{
            if imageURL.isEmpty { return }
            NSLog(self.profileImageURL!)
            let url = URL(string: imageURL)!
            let uTask = self.uSession.downloadTask(with: url)
            uTask.resume()
        }
    }
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        if let image = try? UIImage(data: Data(contentsOf: location)),
            image != nil
        {
            let cachedImage = CacheUserProfileImage()
            cachedImage.ProfileImageURL = location.absoluteString
            cachedImage.UserProfileImage = image
            ProfileImageCache.append(cachedImage)
            NSLog("Added UserProfileImage to Cache")
            self.profileImage = image
            NSLog("UserProfileImage set from DownloadTask!")
        } else {
            //Set default image
        }
    }
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            NSLog(error!.localizedDescription)
            // let title = String.OnlineFetchRequestError
            // let message = error!.localizedDescription
            //self.ShowAlertMessage(title: title, message: message)
        }
    }
}

