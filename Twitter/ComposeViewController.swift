//
//  ComposeViewController.swift
//  Twitter
//
//  Created by user116136 on 2/21/16.
//  Copyright © 2016 Hannah Werbel. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var charCountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    var replyTweet: Tweet?
    let maxChars = 140
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Initialize Text View
        tweetTextView.delegate = self
        tweetTextView.becomeFirstResponder()
        
        //Customize Tweet Button
        tweetButton.backgroundColor = UIColor(red: 85/225.0, green: 172/225.0, blue: 238/225.0, alpha: 1.0)
        tweetButton.tintColor = UIColor.whiteColor()
        tweetButton.contentEdgeInsets = UIEdgeInsetsMake(8, 10, 8, 10)
        tweetButton.layer.cornerRadius = 5
        tweetButton.clipsToBounds = true
        
        //Check if keyboard is displayed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardIsShowing:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        //Check if tweet is a reply
        if replyTweet != nil {
            placeholderLabel.hidden = true
            tweetTextView.text = "@\(replyTweet!.user!.screenName!): "
            charCountLabel.text = "\(maxChars - tweetTextView.text.characters.count)"
        }
        
        //Set up profile image square
        let currentUser = User.currentUser!
        let imageUrl = NSURL(string: currentUser.profileImageUrl!)
        profileImageView.setImageWithURL(imageUrl!)
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //Make sure character count is less than 140
        return textView.text.characters.count + (text.characters.count - range.length) <= maxChars
    }
    
    func textViewDidChange(textView: UITextView) {
        let charCount = textView.text.characters.count
        //When start Typing
        if charCount > 0 {
            placeholderLabel.hidden = true
            charCountLabel.text = "\(maxChars - charCount)"
        //If no characters typed
        } else {
            placeholderLabel.hidden = false
            charCountLabel.text = "\(maxChars)"
        }
    }
    
    //Push tweet button and character count up when keyboard is showing
    func keyboardIsShowing(notification: NSNotification) {
        var keyboardInfo = notification.userInfo!
        let keyboardFrame: CGRect = (keyboardInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height + 5
        })
    }
    
    //Bring tweet and character count back down when keyboard hide
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = self.view.frame.minY
        })
    }
    
    //Tweet Button Clicked
    @IBAction func onTweet(sender: AnyObject) {
        var params = [String: AnyObject]()
        //Capture text of tweet
        params["status"] = tweetTextView.text
        //If tweet is a reply
        if replyTweet != nil {
            params["in_reply_to_status_id"] = replyTweet!.id!
        }
        //Tweet
        TwitterClient.sharedInstance.newTweetWithParams(params, completion: {(tweet, error) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("new_tweet", object: nil, userInfo: ["new_tweet": tweet!])
        })
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Cancel Button Clicked
    @IBAction func onCancel(sender: AnyObject) {
        print("canceled")
        self.dismissViewControllerAnimated(true, completion: nil)
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
