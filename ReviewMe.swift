//
//  ReviewMe.swift
//  Factorlator
//
//  Created by Chris M on 11/10/15.
//  Copyright © 2015 Chris Manahan. All rights reserved.
//

import Foundation

/// ReviewMe is a drop in class that takes care of asking the user for 
/// review in the AppStore and gives the option to give them some sort of
/// reward for reviewing.
class ReviewMe {
    
    // MARK: - Properties
    private var isInitialized: Bool
    private var attempts: Int
    private var didRequest: Bool
    
    var appStoreUrl: String
    var chance: Int
    var minIgnore: Int
    var title: String
    var message: String
    
    var alertTextYes: String?
    var alertTextNo: String?
    var alertTextStopIt: String?
    
    var rewardCompletion: (()->Void)?
    
    private static var sharedInstance: ReviewMe? = nil
    
    // MARK: - Init
    static func shared() -> ReviewMe {
        if sharedInstance == nil {
            sharedInstance = ReviewMe()
        }
        return sharedInstance!
    }
    
    init() {
        isInitialized = false
        didRequest = false
        appStoreUrl = ""
        chance = 10
        minIgnore = 3
        attempts = 0
        title = ""
        message = ""
    }
    
    /**
     Initializes ReviewMe
     
     - parameter url:       AppStore url where your app is location
     - parameter title:     Title to display on alert view
     - parameter message:   Message to display to the user
     - parameter chance:    The chance of showing the alert view. The higher this number, the less likely it will show. Think of it as "every 1 in x times"
     - parameter reward:    Closure to run when the user reviews your app
     - parameter minIgnore: Number of times to ignore tryForReview. Setting this will prevent the alert from showing the very first time you try to show the alert
     */
    func initialize(appStoreUrl url: String, title: String, message: String, chance: Int = 10,  minIgnore: Int = 3, reward: (()->Void)?) {
        self.appStoreUrl = url
        self.rewardCompletion = reward
        self.isInitialized = true
        self.minIgnore = minIgnore
        self.title = title
        self.message = message
    }
 
   // MARK: - Public
    /**
    Attempts to prompt the user for an app store review
    
    - returns: Bool indicating success
    */
    func tryForReview() -> Bool {
        
        // check if the user took action 
        let defs = NSUserDefaults.standardUserDefaults()
        guard !defs.boolForKey("ReviewMe.DidReview") && !defs.boolForKey("ReviewMe.StopAsking") && !self.didRequest else { return false }
        
        assert(isInitialized, "call initialize once before doing anything else")
        
        // abort if we haven't attempted enough times
        guard ++self.attempts > self.minIgnore else { return false }
        
        // compare a random number with our chance of a hit
        let rand = Int(arc4random()) % self.chance
        guard rand % self.chance == 0 else { return false }
        
        let alert = alertController()
        UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
        
        return true
    }
    
    /**
     Creates the alert view to prompt the user with
     
     - returns: An alert controller
     */
    private func alertController() -> UIAlertController {
        let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let yesAction = UIAlertAction(title: self.alertTextYes ?? "Yes", style: UIAlertActionStyle.Default) { action in
            // go to app store
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "ReviewMe.DidReview")
            if self.rewardCompletion != nil {
                self.rewardCompletion!()
            }
            
            let url = NSURL(string: self.appStoreUrl)!
            UIApplication.sharedApplication().openURL(url)
        }
        
        let noAction = UIAlertAction(title: self.alertTextNo ?? "No", style: UIAlertActionStyle.Cancel) { action in
            // cancel
            self.didRequest = true
        }
        
        let stopAction = UIAlertAction(title: self.alertTextStopIt ?? "Stop asking", style: UIAlertActionStyle.Default) { action in
            // set user default
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "ReviewMe.StopAsking")
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        alert.addAction(stopAction)
        
        return alert
    }
}