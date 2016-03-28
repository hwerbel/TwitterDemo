//
//  TwitterClient.swift
//  Twitter
//
//  Created by user116136 on 2/8/16.
//  Copyright © 2016 Hannah Werbel. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterBaseURL = NSURL(string: "https://api.twitter.com")
let twitterConsumerKey = "8N1Dm6pJ0wYi17NtylY3pbxkp"
let twitterConsumerSecret = "4XjbD7CJERtx0mBw4LOciOS206wSdixkRIi1zVKeFWpD20yaif"

class TwitterClient: BDBOAuth1SessionManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }
    
    //Login Function
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        //Fetch Request Token and Redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestToekn: BDBOAuth1Credential!) -> Void in
            //If successful
            print("Got the request token")
            let oauthURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToekn.token)")
            UIApplication.sharedApplication().openURL(oauthURL!)
            //If error
            }) { (error: NSError!) -> Void in
                print("failed to get request token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    //Post New Tweet Function
    func newTweetWithParams(params: NSDictionary!, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/statuses/update.json", parameters: params, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            //If successful
            print("tweeted successfully")
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            //If Error
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("did not tweet")
                completion(tweet: nil, error: error)
        })
    }
    
    //Retweet Function
    func retweetWithParams(id: String, params: NSDictionary?, completion:(error: NSError?) -> ()) {
        POST("1.1/statuses/retweet/\(id).json", parameters: params, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            //If successful
            print("successfully retweeted")
            completion(error: nil)
        //If error
        }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error retweeting")
                completion(error: error)
        })
    }
    
    //UnRetweet Function
    func unretweetWithParams(id: String, tweet: Tweet?, params: NSDictionary?, completion:(error: NSError?) -> ()) {
        //Set up variables
        var originalTweetId = ""
        var retweetId = ""
        //Check to make sure tweet was retweeted
        if tweet!.retweeted == false {
           print("cannot untweet if have not retweeted")
        //If retweeted tweet was itself not a retweet
        } else if tweet!.retweeted_status == nil{
            originalTweetId = tweet!.id!
        //If retweeted tweet was itself a retweet
        } else {
            originalTweetId = tweet!.retweeted_status!["id_str"] as! String
        }
        //Get tweet and retweet ID
        GET("1.1/statuses/show/\(originalTweetId).json?include_my_retweet=1", parameters: params, success: { (operation: NSURLSessionDataTask!,response: AnyObject?) -> Void in
            //If successful
            let fullTweet = response as! NSDictionary
            let retweet = fullTweet["current_user_retweet"]!
            retweetId = retweet["id_str"] as! String
            print("got full tweet")
            //If error
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error getting full tweet")
        })
        //UnRetweet
        POST("1.1/statuses/unretweet/\(id).json", parameters: params, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            //If successful
            print("successfully unretweeted")
            completion(error: nil)
            //If error
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error unretweeting")
                completion(error: error)
        })
    }
    
    //Like Function
    func favoriteWithParams(id: String, params: NSDictionary?, completion:(error: NSError?) -> ()) {
        POST("1.1/favorites/create.json?id=\(id)", parameters: params, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            //If successful
            print("successfully favorited")
            completion(error: nil)
            //If error
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error favoriting")
                completion(error: error)
        })
    }
    
    //Unlike Function
    func unfavoriteWithParams(id: String, params: NSDictionary?, completion:(error: NSError?) -> ()) {
        POST("1.1/favorites/destroy.json?id=\(id)", parameters: params, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            //If successful
            print("successfully unfavorited")
            completion(error: nil)
        //If error
        }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
            print("error unfavoriting")
            completion(error: error)
        })
    }
    
    //Load tweets from home timeline function
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: NSURLSessionDataTask!,response: AnyObject?) -> Void in
            //If successful
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
        // If error
        }, failure: { (operation: NSURLSessionDataTask?, error:     NSError!) -> Void in
            print("eror getting home timeline")
            completion(tweets: nil, error: error)
        })
    }
    
    //Load tweets from selected user's timeline function
    func userTimelineWithParams(id: String, params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/user_timeline.json?id=\(id)", parameters: params, success: { (operation: NSURLSessionDataTask!,response: AnyObject?) -> Void in
            //If successful
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
        //If error
        }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
            print("eror getting user timeline")
            completion(tweets: nil, error: error)
        })
    }
    
    //ProcessRequest Token and obtain Current User
    func openUrl(url: NSURL) {
        //Fetch Access Token
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("got the access token")
            //Save Access Token
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            //Get Current User
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                    //Set current user
                    let user = User(dictionary: response as! NSDictionary)
                    User.currentUser = user
                    print("user: \(user.name)")
                    self.loginCompletion?(user: user, error: nil)
                //Error geetting current user
                }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                    print("eror getting current user")
                    self.loginCompletion?(user: nil, error: error)
            })
            //Error getting access token
            }) { (error: NSError!) -> Void in
                print("failed to receive access token")
                self.loginCompletion?(user: nil, error: error)
        }

    }
    
}
