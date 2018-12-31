//
//  Extensions.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 07/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation
import CommonCrypto
import UIKit


extension String {
    
    ///Transforms the original String into a SHA-256 representation of that String.
    /// - returns: a SHA-256 hash, that represents the original String.
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    
    ///Helper method for the method sha256, actually executes the algorithm for the SHA-256 hashing of a String.
    /// - parameters:
    ///     - input: the bytes of the original String.
    /// - returns: bytes of the sha256 hash.
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    ///Receives the bytes of a sha256 hash, and converts it into a readable String.
    /// - parameters:
    ///     - input: the bytes of the sha256 hash.
    /// - returns: the String representation of a sha256 hash.
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    
}

extension UIView{
    
    ///blurs the screen and shows a loading icon.
    func showBlurLoader(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center

        
        self.addSubview(blurEffectView)
    }
    
    ///removes the loading blue from the screen and removes the loading icon.
    func removeBluerLoader(){
        self.subviews.compactMap {  $0 as? UIVisualEffectView }.forEach {
            $0.removeFromSuperview()
        }
    }
}

extension Encodable{
    ///converts the `Encodable` object to its JSON representation, as a `String`.
    func toJSON() -> String{
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(self)
        let json = String(data: jsonData, encoding: .utf8)!
        return json
    }
}

extension UIView{
    
    ///shakes the `UIView` left to right, in an error fashion.
    func shake(){
        UIView.animate(withDuration: 0.05, delay: 0, options: [.repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(3)
            self.transform = CGAffineTransform(translationX: 5, y: 0)
            
        }, completion:{ (_) in
            self.transform = CGAffineTransform.identity
        })
    }
}

extension UIScrollView {
    
    ///scrolls a `UIScrollView` to the top.
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}
