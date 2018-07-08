//
//  TWUserProfileVC.swift
//  TwitterDemo
//
//  Created by ViJay Avhad on 08/07/18.
//  Copyright © 2018 ViJay Avhad. All rights reserved.
//

import UIKit
import TwitterKit


class TWUserProfileVC: UIViewController {
    
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var header:UIView!
    @IBOutlet var headerLabel:UILabel!
    
    var headerImageView:UIImageView!
    var headerBlurImageView:UIImageView!
    var blurredHeaderImageView:UIImageView?
    
    @IBOutlet var imgUser:UIImageView!
    
    @IBOutlet var lblUserName:UILabel!
    @IBOutlet var lblUserEmail:UILabel!
    @IBOutlet var lblUserScreenName:UILabel!
    
    @IBOutlet var btnFollower:UIButton!
    @IBOutlet var btnFollowing:UIButton!
    @IBOutlet var btnBack:UIButton!

    var TWUser : TwitterUser!
    var isViewFriendProfile = false; //FriendView flag
    
    let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
    let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
    let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        lblUserName.text = TWUser.name!
        lblUserEmail.text = TWUser.email!
        lblUserScreenName.text = "@"+TWUser.screenName!
        headerLabel.text = TWUser?.name!
        
        if isViewFriendProfile{
            btnBack.isHidden  = false
            btnFollower.isHidden = true
            btnFollowing.isHidden = true
        }else{
            btnBack.isHidden  = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Header - Image
        
        headerImageView = UIImageView(frame: header.bounds)
        headerImageView?.image = UIImage(named: "header_bg")
        headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        header.insertSubview(headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        
        headerBlurImageView = UIImageView(frame: header.bounds)
        headerBlurImageView?.image = UIImage(named: "header_bg")
        headerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerBlurImageView?.alpha = 0.0
        headerBlurImageView?.blurImage10()
        header.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        header.clipsToBounds = true
        Download.downloadImageFrom(url: TWUser.profileURLhd!, imgView: imgUser)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    
    @IBAction func goToFriendsList(_ sender: UIButton) {
        
        let friendListVC = FriendsVC.instantiate(fromAppStoryboard: .Main)
        friendListVC.screenName = TWUser.screenName!
        friendListVC.getDataFor = sender.tag == 0 ? FriendDataType.follower : FriendDataType.following
        self.present(friendListVC, animated: true, completion: nil)
        
    }
    
    @IBAction func goBackToFriendsList(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
}

extension TWUserProfileVC: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            header.layer.transform = headerTransform
        }else {
            
        
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerLabel.layer.transform = labelTransform
        
            headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / imgUser.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((imgUser.bounds.height * (1.0 + avatarScaleFactor)) - imgUser.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if imgUser.layer.zPosition < header.layer.zPosition{
                    header.layer.zPosition = 0
                }
                
            }else {
                if imgUser.layer.zPosition >= header.layer.zPosition{
                    header.layer.zPosition = 2
                }
            }
        }
        
        header.layer.transform = headerTransform
        imgUser.layer.transform = avatarTransform
    }
}

class AvatarImageView: UIImageView {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 10.0
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.white.cgColor
    }
}

class TWTButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 85.0/255.0, green: 172.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor
    }
}

extension UIImageView{
    
    func blurImage10(){
        
        var darkBlur:UIBlurEffect = UIBlurEffect()
        if #available(iOS 10.0, *) { //iOS 10.0 and above
            darkBlur = UIBlurEffect(style: UIBlurEffectStyle.light)//prominent,regular,extraLight, light, dark
        } else { //iOS 8.0 and above
            darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark) //extraLight, light, dark
        }
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.bounds //your view that have any objects
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurView)
    }
}

