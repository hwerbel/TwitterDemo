//
//  TweetCell.swift
//  Twitter
//
//  Created by user116136 on 2/13/16.
//  Copyright © 2016 Hannah Werbel. All rights reserved.
//

import UIKit
import RelativeFormatter
import AFNetworking

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var retweetsLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    var tweetID: String?
    let profileTap = UITapGestureRecognizer()
    var tweet: Tweet! {
        didSet {
            //Set labels with tweet data
            timestampLabel.text = tweet.timeAgo
            tweetLabel.text = tweet.text
            userLabel.text = "@\(tweet.userName!)"
            userNameLabel.text = tweet.name
            likesLabel.text = "\(tweet.favoritesCount!)"
            retweetsLabel.text = "\(tweet.retweetsCount!)"
            retweetsLabel.text! == "0" ? (retweetsLabel.hidden = true) : (retweetsLabel.hidden = false)
            likesLabel.text! == "0" ? (likesLabel.hidden = true) : (likesLabel.hidden = false)
            let imageURL = NSURL(string: tweet.profileImageUrl!)
            profileImageView.setImageWithURL(imageURL!)
            //Check if liked to set like button status
            if tweet.favorited == true {
                likeButton.setImage(UIImage(named: "like-action-on-red.png"), forState: UIControlState.Normal)
            } else {
                likeButton.setImage(UIImage(named: "like-action-off.png"), forState: UIControlState.Normal)
            }
            //Check if retweeted to set retweet button status
            if tweet.retweeted == true {
                retweetButton.setImage(UIImage(named: "retweet-action-on-green.png"), forState: UIControlState.Normal)
            } else {
                retweetButton.setImage(UIImage(named: "retweet-action_default.png"), forState: UIControlState.Normal)
            }
            tweetID = tweet.id!
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Round corners of profile image
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        
        //Tap Gesture Recognizer
        profileTap.addTarget(self, action: Selector("onProfileImageTap:"))
        profileImageView.addGestureRecognizer(profileTap)
        profileImageView.userInteractionEnabled = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //Profile Image tapped
    func onProfileImageTap(recognizer: UITapGestureRecognizer) {
        print(tweet.user!)
        NSNotificationCenter.defaultCenter().postNotificationName("profileTapNotification", object: nil, userInfo: ["user" : tweet.user!])
    }
    
    //Reply Button Tapped
    @IBAction func onReply(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("replied", object: nil, userInfo: ["repliedToTweet": tweet])
    }
    
    //Like button tapped
    @IBAction func onLike(sender: AnyObject) {
        //If liked
        if tweet.favorited == false {
            TwitterClient.sharedInstance.favoriteWithParams(self.tweetID!, params: nil, completion: { (error) -> ()in
                //Change like button
                self.likeButton.setImage(UIImage(named: "like-action-on-pressed-red.png"), forState: UIControlState.Selected)
                self.likeButton.setImage(UIImage(named: "like-action-on-red.png"), forState: UIControlState.Normal)
                //Indicate was liked
                self.tweet.favorited = true
                if self.likesLabel.text! > "0" {
                    self.likesLabel.text = String(self.tweet!.favoritesCount! + 1)
                } else {
                    self.likesLabel.hidden = false
                    self.likesLabel.text = String(self.tweet!.favoritesCount! + 1)
                }
            })
        //If unlike
        } else {
            TwitterClient.sharedInstance.unfavoriteWithParams(self.tweetID!, params: nil, completion: { (error) -> () in
                //Change like button
                self.likeButton.setImage(UIImage(named: "like-action-on-pressed-red.png"), forState: UIControlState.Selected)
                self.likeButton.setImage(UIImage(named: "like-action-off.png"), forState: UIControlState.Normal)
                //Indicte was unliked
                self.tweet.favorited = false
                if self.likesLabel.text! > "0" {
                    self.likesLabel.text = String(self.tweet!.favoritesCount!)
                } else {
                    self.likesLabel.hidden = false
                    self.likesLabel.text = String(self.tweet!.favoritesCount!)
                }
            })
        }
    }
    
    //Retweet button tapped
    @IBAction func onRetweet(sender: AnyObject) {
        //If retweet
        if tweet.retweeted == false {
            TwitterClient.sharedInstance.retweetWithParams(self.tweetID!, params: nil, completion: { (error) -> ()in
                //Change retweet button
                self.retweetButton.setImage(UIImage(named: "retweet-action-on-pressed_green.png"), forState: UIControlState.Selected)
                self.retweetButton.setImage(UIImage(named: "retweet-action-on-green.png"), forState: UIControlState.Normal)
                //Indicate was retweeted
                self.tweet.retweeted = true
                if self.retweetsLabel.text! > "0" {
                    self.retweetsLabel.text = String(self.tweet!.retweetsCount! + 1)
                } else {
                    self.retweetsLabel.hidden = false
                    self.retweetsLabel.text = String(self.tweet!.retweetsCount! + 1)
                }
            })
        //If unretweeted
        } else {
            TwitterClient.sharedInstance.unretweetWithParams(self.tweetID!, tweet: tweet, params: nil, completion: { (error) -> () in
                //Change retweet button
                self.retweetButton.setImage(UIImage(named: "retweet-action-on-pressed_green.png"), forState: UIControlState.Selected)
                self.retweetButton.setImage(UIImage(named: "retweet-action_default.png"), forState: UIControlState.Normal)
                //Indicate was unretweeted
                self.tweet.retweeted = false
                if self.retweetsLabel.text! > "0" {
                    self.retweetsLabel.text = String(self.tweet!.retweetsCount!)
                } else {
                    self.retweetsLabel.hidden = false
                    self.retweetsLabel.text = String(self.tweet!.retweetsCount!)
                }
            })
        }
    }
}
