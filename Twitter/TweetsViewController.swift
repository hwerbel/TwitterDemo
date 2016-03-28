//
//  TweetsViewController.swift
//  Twitter
//
//  Created by user116136 on 2/12/16.
//  Copyright © 2016 Hannah Werbel. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var tweets: [Tweet]?
    var tweet: Tweet?
    var isLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        //Set up Navigation Bar
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 85/225.0, green: 172/225.0, blue: 238/225.0, alpha: 1.0)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        //Set up infinite Scroll
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        //Set up refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "didRefresh", forControlEvents: .ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        //Check if profile image tapped
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onProfileTap:", name: "profileTapNotification", object: nil)
        //Check if new tweet created
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTimeline:", name: "new_tweet", object: nil)
        //Check if new reply created
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onReply:", name: "replied", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        //Get tweets
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Logout button clicked
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tweets != nil {
            return tweets!.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        self.tweet = tweets![indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        
        cell.tweet = tweets![indexPath.row]
        //Customize Cell Style
        cell.selectionStyle = .None
        cell.accessoryType = .None 
        
        // Infinite Scroll
        if indexPath.row == self.tweets!.count - 3 && isLoading == false {
            isLoading = true
            
            //Progress Indicater
            let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
            loadingMoreView?.frame = frame
            loadingMoreView!.startAnimating()
            
            //Load more tweets
            let params = ["max_id": self.tweet!.id!] as NSDictionary
            TwitterClient.sharedInstance.homeTimelineWithParams(params, completion: { (tweets, error) -> () in
                
                if error != nil {
                    print("error loading more tweets")
                } else {
                    self.tweets = self.tweets! + tweets!
                }
                self.loadingMoreView!.stopAnimating()
                self.tableView.reloadData()
                self.isLoading = false
            })
        }
        
        return cell
    }
    
    //Profile image tapped
    func onProfileTap(notification: NSNotification) {
        //Segue to profile page
        performSegueWithIdentifier("profileSegue", sender: notification.userInfo!["user"])
    }
    
    //Profile button tapped
    @IBAction func onProfile(sender: AnyObject) {
        //Segue to profile page
        performSegueWithIdentifier("profileSegue", sender: User.currentUser!)
    }
    
    //Reply tapped
    func onReply(notification: NSNotification) {
        performSegueWithIdentifier("composeSegue", sender: notification.userInfo!["repliedToTweet"])
    }
    
    //Insert new tweet at top of home timeline
    func updateTimeline(notification: NSNotification) {
        let newTweet = notification.userInfo!["new_tweet"] as! Tweet
        tweets!.insert(newTweet, atIndex: 0)
        tableView.reloadData()
    }
    
    //Refresh Control
    func didRefresh() {
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (tweets, error) -> () in
            if error != nil {
                print("error refreshing")
            }else {
                self.tweets = tweets
                self.tableView.reloadData()
            }
        })
        refreshControl.endRefreshing()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //To profile page
        if segue.identifier == "profileSegue" {
            let user = sender as! User
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.user = user
        //To Single Tweet/Tweet Details
        } else if segue.identifier == "tweetDetailsSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets![indexPath!.row]
            let singleTweetViewController = segue.destinationViewController as! SingleTweetViewController
            singleTweetViewController.tweet = tweet
        //To Compose page
        } else if segue.identifier == "composeSegue" {
            if let tweet = sender as? Tweet {
                let composeViewController = segue.destinationViewController as! ComposeViewController
                composeViewController.replyTweet = tweet
            }
        }
    }


}
