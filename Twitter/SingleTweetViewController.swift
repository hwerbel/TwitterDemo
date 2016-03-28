//
//  SingleTweetViewController.swift
//  Twitter
//
//  Created by user116136 on 2/16/16.
//  Copyright © 2016 Hannah Werbel. All rights reserved.
//

import UIKit


class SingleTweetViewController: UIViewController {

    @IBOutlet weak var retweetsLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userHandleLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
         var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set labels with Tweet data
        let imageURL = NSURL(string: tweet.profileImageUrl!)
        profileImageView.setImageWithURL(imageURL!)
        userNameLabel.text = tweet.name
        userHandleLabel.text = "@\(tweet.userName!)"
        tweetLabel.text = tweet.text
        timestampLabel.text = tweet.timeAgo
        likesLabel.text = "\(tweet.favoritesCount!)"
        retweetsLabel.text = "\(tweet.retweetsCount!)"
        //Check whether user favorited tweet to set like button status
        if tweet.favorited == true {
            likeButton.setImage(UIImage(named: "like-action-on-red.png"), forState: UIControlState.Normal)
            likesLabel.text = String(tweet!.favoritesCount! + 1)
        } else {
            likeButton.setImage(UIImage(named: "like-action-off.png"), forState: UIControlState.Normal)
        }
        //Check whether user retweeted tweet to set retweet button status
        if tweet.retweeted == true {
            retweetButton.setImage(UIImage(named: "retweet-action-on-green.png"), forState: UIControlState.Normal)
            retweetsLabel.text = String(tweet!.retweetsCount! + 1)
        } else {
            retweetButton.setImage(UIImage(named: "retweet-action_default.png"), forState: UIControlState.Normal)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Retweet button clicked
    @IBAction func onRetweet(sender: AnyObject) {
        //If retweeting
        if tweet.retweeted == false {
            TwitterClient.sharedInstance.retweetWithParams(tweet.id!, params: nil, completion: { (error) -> ()in
                //Change retweet button to
                self.retweetButton.setImage(UIImage(named: "retweet-action-on-pressed_green.png"), forState: UIControlState.Selected)
                self.retweetButton.setImage(UIImage(named: "retweet-action-on-green.png"), forState: UIControlState.Normal)
                //Indicate was retweeted
                self.tweet.retweeted = true
                self.retweetsLabel.text = String(self.tweet!.retweetsCount! + 1)
            })
        //If unretweeting
        } else {
            TwitterClient.sharedInstance.unretweetWithParams(tweet.id!, tweet: tweet, params: nil, completion: { (error) -> () in
                //Change Retweet Button
                self.retweetButton.setImage(UIImage(named: "retweet-action-on-pressed_green.png"), forState: UIControlState.Selected)
                self.retweetButton.setImage(UIImage(named: "retweet-action_default.png"), forState: UIControlState.Normal)
                //Indicate was unretweeted
                self.tweet.retweeted = false
                self.retweetsLabel.text = String(self.tweet!.retweetsCount!)
            })
        }

    }
    
    @IBAction func onLike(sender: AnyObject) {
        //If like
        if tweet.favorited == false {
            TwitterClient.sharedInstance.favoriteWithParams(tweet.id!, params: nil, completion: { (error) -> ()in
                //Change like button
                self.likeButton.setImage(UIImage(named: "like-action-on-pressed-red.png"), forState: UIControlState.Selected)
                self.likeButton.setImage(UIImage(named: "like-action-on-red.png"), forState: UIControlState.Normal)
                //Indicate was liked
                self.tweet.favorited = true
                self.likesLabel.text = String(self.tweet!.favoritesCount! + 1)
            })
        //If unlike
        } else {
            TwitterClient.sharedInstance.unfavoriteWithParams(tweet.id!, params: nil, completion: { (error) -> () in
                // Change like button
                self.likeButton.setImage(UIImage(named: "like-action-on-pressed-red.png"), forState: UIControlState.Selected)
                self.likeButton.setImage(UIImage(named: "like-action-off.png"), forState: UIControlState.Normal)
                //Indicate was unliked
                self.tweet.favorited = false
                self.likesLabel.text = String(self.tweet!.favoritesCount!)
            })
        }

    }

    //Reply button clicked
    @IBAction func onReply(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("replied", object: nil, userInfo: ["repliedToTweet": tweet])
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
