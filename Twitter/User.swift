//
//  User.swift
//  Twitter
//
//  Created by user116136 on 2/9/16.
//  Copyright © 2016 Hannah Werbel. All rights reserved.
//

import UIKit

var _currentUser: User?
var currentUserKey = "kCurrentUserKey"
var userDidLoginNotification = "userDidLoginNotification"
var userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var name: String?
    var screenName: String?
    var profileImageUrl: String?
    var tagline: String?
    var favoritesCount: Int?
    var headerImageUrl: String?
    var headerBackgroundColor: String?
    var followersCount: Int?
    var followingCount: Int?
    var tweetsCount: Int?
    var id: String?
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        //UserName
        name = dictionary["name"] as? String
        //UserHandle/Screen NAme
        screenName = dictionary["screen_name"] as? String
        //Profile Image
        profileImageUrl = dictionary["profile_image_url"] as? String
        //Tagline
        tagline = dictionary["description"] as? String
        //Favorites Count
        favoritesCount = dictionary["favourites_count"] as? Int
        //Header Image
        headerImageUrl = dictionary["profile_banner_url"] as? String
        //Heade Background Color
        headerBackgroundColor = dictionary["profile_background_color"] as? String
        //Followers Count
        followersCount = dictionary["followers_count"] as? Int
        //Following Count
        followingCount = dictionary["friends_count"] as? Int
        //Tweets Count
        tweetsCount = dictionary["statuses_count"] as? Int
        //User ID
        id = dictionary["id_str"] as? String
        
    }
    
    //Logout Function
    func logout() {
        //Clea Current User
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        //Send noification of logout
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    //Current User
    class var currentUser: User? {
        //Get Current User
        get {
            if _currentUser == nil {
                let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                //If current user available
                if data != nil {
                    do {
                        let dictionary = try NSJSONSerialization.JSONObjectWithData(data!,
                        options:NSJSONReadingOptions(rawValue:0)) as! NSDictionary
                        _currentUser = User(dictionary: dictionary)
                    } catch {
                        print("error reading JSON data")
                    }
                }
            }
            return _currentUser
        //Set user as current user
        } set(user) {
            _currentUser = user
            if _currentUser != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary,
                        options: NSJSONWritingOptions.PrettyPrinted)
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
            
                } catch {
                    print("error writing JSON data")
                }

            } else {
                 NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()

        }
    }
}
