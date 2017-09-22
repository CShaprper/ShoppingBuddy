//
//  ImageCompressionExtension.swift
//  ShoppingBuddy
//
//  Created by Peter Sypek on 17.09.17.
//  Copyright © 2017 Peter Sypek. All rights reserved.
//

import UIKit
//Image Compression
extension UIImage
{
    var highestQualityJPEGNSData: NSData? { return UIImageJPEGRepresentation(self, 1.0)! as NSData }
    var highQualityJPEGNSData: NSData?    { return UIImageJPEGRepresentation(self, 0.75)! as NSData}
    var mediumQualityJPEGNSData: NSData?  { return UIImageJPEGRepresentation(self, 0.5)! as NSData }
    var lowQualityJPEGNSData: NSData?     { return UIImageJPEGRepresentation(self, 0.25)! as NSData}
    var lowestQualityJPEGNSData: NSData?  { return UIImageJPEGRepresentation(self, 0.0)! as NSData }
}
