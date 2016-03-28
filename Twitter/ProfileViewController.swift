//
//  ProfileViewController.swift
//  Twitter
//
//  Created by user116136 on 2/20/16.
//  Copyright © 2016 Hannah Werbel. All rights reserved.
//

import UIKit

let offset_HeaderStop:CGFloat = 40.0
let offset_B_LabelHeader:CGFloat = 95.0
let distance_W_LabelHeader:CGFloat = 35.0

class ProfileViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    var user: User!
    var tweets: [Tweet]!
    @IBOutlet weak var headerImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Transparencies
        scrollContentView.backgroundColor = UIColor.clearColor()
        headerView.backgroundColor = UIColor.clearColor()
        
        //Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        //Get user tweets
        let id = user!.id
        TwitterClient.sharedInstance.userTimelineWithParams(id!, params: nil, completion: { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
        })
        
        //User Info
        let imageURL = NSURL(string: user!.profileImageUrl!)
        profileImageView.setImageWithURL(imageURL!)
        nameLabel.text = user!.name
        screenNameLabel.text = "@\(user!.screenName!)"
        followersLabel.text = "\(user!.followersCount!)"
        followingLabel.text = "\(user!.followingCount!)"
        tweetsLabel.text = "\(user!.tweetsCount!)"
        //If user has header image
        if user!.headerImageUrl != nil {
            headerImageView.setImageWithURL(NSURL(string: user!.headerImageUrl!)!)
        //If user does not have header image
        } else {
            let headerColor = UIColorFromRGB("0xFF\(user!.headerBackgroundColor!)")
            headerImageView.backgroundColor = headerColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Obtain UIColor from RGB values
    func UIColorFromRGB(colorCode: String, alpha: Float = 1.0) -> UIColor {
        let scanner = NSScanner(string:colorCode)
        var color:UInt32 = 0;
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tweets != nil {
            return tweets!.count
        } else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTweetCell", forIndexPath: indexPath) as! UserTweetCell
        
        cell.tweet = tweets![indexPath.row]
        cell.selectionStyle = .None
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
