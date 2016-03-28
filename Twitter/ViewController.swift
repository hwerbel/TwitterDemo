//
//  ViewController.swift
//  Twitter
//
//  Created by user116136 on 2/8/16.
//  Copyright © 2016 Hannah Werbel. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class ViewController: UIViewController {
    
    @IBOutlet weak var blueView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Customize View
        self.loginButton.backgroundColor = UIColor(red: 213/225.0, green: 216/225.0, blue: 218/225.0, alpha: 1.0)
        self.loginButton.contentEdgeInsets = UIEdgeInsetsMake(8, 10, 8, 10)
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.clipsToBounds = true
        self.titleLabel.textColor = UIColor(red: 89/225.0, green: 92/225.0, blue: 92/225.0, alpha: 1.0)
        self.blueView.backgroundColor = UIColor(red: 85/225.0, green: 172/225.0, blue: 238/225.0, alpha: 1.0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Login Button Clicked
    @IBAction func onLogin(sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithCompletion(){
            (user: User?, eror: NSError?) in
            if user != nil {
                //perform segue
                self.performSegueWithIdentifier("loginSegue", sender: self)
            }else {
                print("error logging in")
            }
        }
    }
}

