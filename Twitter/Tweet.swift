//
//  Tweet.swift
//  Twitter
//
//  Created by user116136 on 2/9/16.
//  Copyright © 2016 Hannah Werbel. All rights reserved.
//

import UIKit
import RelativeFormatter

class Tweet: NSObject {
    var user: User?
    var userName: String?
    var name: String?
    var profileImageUrl: String?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var timeAgo: String?
    var favoritesCount: Int?
    var retweetsCount: Int?
    var id: String?
    var retweeted: Bool?
    var favorited: Bool?
    var replyedId: String?
    var retweeted_status: NSDictionary?
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        //UserHandel/Screen Name
        userName = user!.screenName
        //UserName
        name = user!.name
        //Profile Image
        profileImageUrl = user!.profileImageUrl
        //Tweet Text
        text = dictionary["text"] as? String
        //Favorites Count
        favoritesCount = user!.favoritesCount
        //Retweets Count
        retweetsCount = dictionary["retweet_count"] as? Int
        //Tweet ID
        id = dictionary["id_str"] as? String
        //Retweeted
        retweeted = dictionary["retweeted"] as? Bool
        //Liked
        favorited = dictionary["favorited"] as? Bool
        //Reply ID
        replyedId = dictionary["in_reply_to_status_id_str"] as? String
        //Retweeted Status
        retweeted_status = dictionary["retweeted_status"] as? NSDictionary
        
        //Format Date
        createdAtString = dictionary["created_at"] as? String
        let formater = NSDateFormatter()
        formater.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formater.dateFromString(createdAtString!)
        timeAgo = createdAt!.relativeFormatted()
        
    }
    
    //Create an Array of Tweets
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
    
}
