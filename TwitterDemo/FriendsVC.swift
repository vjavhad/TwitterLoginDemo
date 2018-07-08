//
//  FriendsVC.swift
//  TwitterDemo
//
//  Created by ViJay Avhad on 08/07/18.
//  Copyright © 2018 ViJay Avhad. All rights reserved.
//

import UIKit
import TwitterKit
import TwitterCore


class FriendsVC: UIViewController {
    
    let TWAPI  = "https://api.twitter.com/1.1/"
    var screenName  = ""
    var getDataFor  = FriendDataType.follower
    var cursor = -1
    var loadingData = false
    var count = 10
    var followers = [TwitterUser]()

    @IBOutlet weak var headerImageView: UIImageView?
    @IBOutlet weak var tblFriendList: UITableView!
    @IBOutlet weak var lblFriendListName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblFriendList.delegate = self
        tblFriendList.dataSource = self
        cursor = -1
        getFriends()
        lblFriendListName.text = getDataFor == .follower ? "Following" : "Followers"
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        tblFriendList.tableFooterView = customView;
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerImageView?.image = UIImage(named: "header_bg")
        headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        headerImageView?.alpha = 1.0
        headerImageView?.blurImage10()
    }
    
    @IBAction func goBackToProfile(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)
    }
    
    func getFriends(){
        if self.cursor == 0 { return }

        var urlString = ""
        let client = TWTRAPIClient.withCurrentUser()
        if getDataFor == .follower{
            urlString = TWAPI+"followers/list.json?cursor=\(cursor)&screen_name=\(screenName)&skip_status=true&include_user_entities=false&count=10"
        }else{
            urlString = TWAPI+"friends/list.json?cursor=\(cursor)&screen_name=\(screenName)&skip_status=true&include_user_entities=false&count=10"
        }
        print(urlString)
        
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", url: urlString, parameters: nil, error: &clientError)
        loadingData = true;
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(connectionError!)")
                
                DispatchQueue.main.async{
                    self.showAlert("Unable to fetch your friends. \(connectionError?.localizedDescription ?? "")",title:"Error...")
                }
                return;
            }

            do {
                if let results: NSDictionary = try JSONSerialization .jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments  ) as? NSDictionary {
                    
                    if let next_cursor = results["next_cursor"] as? Int {
                        self.cursor =  next_cursor
                    }
                    
                    if let users = results["users"] as? [[String:Any]] {
                        for user in users {
                            print(user)
                            
                            let follower = TwitterUser(name: user["name"] as! String, email: "", screenName: user["name"] as! String, hdImgUrl: user["profile_image_url"] as! String, sdImgUrl: user["profile_image_url"] as! String)
                            
                            print(follower.name!)
                            self.followers.append(follower)
                        }
                        self.loadingData = false
                        self.tblFriendList.reloadSections(IndexSet(integersIn: 0...0), with: UITableViewRowAnimation.bottom)
                    } else {
                        print(results["errors"] ?? "")
                    }
                }
                
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(_ message: String="Default message",title:String = ""){
       
        let alertController = UIAlertController(title: title,  message: message, preferredStyle:.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { action -> Void in
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    func goToUserProfile(_ user : TwitterUser){
        
        let userProfile = TWUserProfileVC.instantiate(fromAppStoryboard: .Main)
        userProfile.TWUser = user
        userProfile.isViewFriendProfile = true;
        self.present(userProfile, animated: true, completion: nil)
    }
    
}

extension FriendsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if followers.isEmpty{ return 0 }
        return self.cursor == 0 ? followers.count : followers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Display last cell as loader for paging.
        if indexPath.row == followers.count && self.cursor != 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadDataCell", for: indexPath) as! LoadDataCell
            cell.btnLoadMore.isHidden = false
            cell.loader.isHidden = true

            cell.btnLoadMore.addTarget(self, action: #selector(loadMoreFriends(sender:)), for: UIControlEvents.touchUpInside)
            return cell
        }
        
        //Display User
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsDataCell", for: indexPath) as! FriendsDataCell
        if followers.isEmpty{ return cell }
        
        let follower = followers[indexPath.row]
        cell.lblUserName?.text = follower.name
        cell.lblScreenName?.text = "@"+follower.screenName!

        Download.downloadImageFrom(url: follower.profileURLsd!, imgView: cell.imgUser!)

        return cell
    }
    
    @objc func loadMoreFriends(sender : UIButton){
        
        if let cell = sender.superview?.superview as? LoadDataCell {
            cell.btnLoadMore.isHidden  = true
            cell.loader.isHidden = false
            cell.loader.startAnimating()
            self.getFriends()
        }
    }
    
}


extension FriendsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if indexPath.row != followers.count {
             goToUserProfile(followers[indexPath.row])
        }
    }
}
