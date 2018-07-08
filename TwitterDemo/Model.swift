//  Models.swift
//  Created by ViJay Avhad on 08/07/18.
//  Copyright © 2018 ViJay Avhad. All rights reserved.
//

import Foundation
import UIKit

struct TwitterUser {
    
    var name: String?
    var email: String?
    var screenName: String?
    
    var profileURLsd: URL?
    var profileURLhd: URL?
    
    init (name: String, email:String, screenName: String, hdImgUrl: String, sdImgUrl: String) {
        
        self.name = name
        self.email = email
        self.screenName = screenName
        if let url1 = URL(string: hdImgUrl.replacingOccurrences(of: "_normal", with: "")){
            profileURLhd = url1
        }
        if let url2 = URL(string: sdImgUrl){
            profileURLsd = url2
        }
    }
}

enum FriendDataType : String {
    case follower
    case following
}

enum AppStoryboard : String {
    
    case Main
    
    var instance : UIStoryboard {
        
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T : UIViewController>(viewControllerClass : T.Type, function : String = #function, line : Int = #line, file : String = #file) -> T {
        
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {
    
    class var storyboardID : String {
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
}

let imageCache = NSCache<NSString, AnyObject>()

class Download {
    
    class func downloadImageFrom(url: URL,imgView :UIImageView) {
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            imgView.image = cachedImage
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }

                if let imageToCache = UIImage(data: data) {
                    imageCache.setObject(imageToCache, forKey: url.absoluteString as NSString)
                }

                DispatchQueue.main.async {
                    imgView.image = UIImage(data: data)
                    if(imgView.image == nil){
                        print(url.absoluteURL)
                        imgView.image = #imageLiteral(resourceName: "plchldr");
                    }
                }
                
            }.resume()
        }
    }
}
