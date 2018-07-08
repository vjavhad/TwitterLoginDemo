//
//  FriendsDataCell.swift
//  TwitterDemo
//
//  Created by ViJay Avhad on 08/07/18.
//  Copyright © 2018 ViJay Avhad. All rights reserved.
//

import UIKit

class FriendsDataCell: UITableViewCell {
    
    @IBOutlet weak var imgUser: UIImageView?
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblScreenName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class LoadDataCell: UITableViewCell {
    
   @IBOutlet weak var loader: UIActivityIndicatorView!
   @IBOutlet weak var btnLoadMore: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

