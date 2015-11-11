ReviewMe
===================

ReviewMe is a simple class that takes care of asking users for a review in the App Store and gives you the option to reward the user by doing so 

#How to Use
Start by dragging `ReviewAlert.swift` into your project. 

Initialize everything in your AppDelegate. Use initialization to set up custom parameters.


####Simple Initialization
```
ReviewMe.shared().initialize(appStoreUrl: "https://itunes.apple.com/us/app/MyApp/id12345", title: "Enjoying Our App?", message: "Let us know in a review!", reward: nil)
```

####More Intense Initialization
```
ReviewMe.shared().initialize(appStoreUrl: "https://itunes.apple.com/us/app/MyApp/id12345", title: "Wanna Remove Ads??", message: "Of course you do! Review us in the App Store, and we'll remove those pesky ads", chance: 12, minIgnore: 4) { () -> Void in
            // the reward block is called when the user taps yes. it 
            // is called right before the user is directed to the app store
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "AdsRemoved")
        }
```

####Requesting a Review
At any point after initialization, you can call `tryForReview()`, which will prompt the user for a review when appropriate, based on `chance`. If the user asked not to see the alert again, the user already left a review, or the user has been asked once during the current launch this call will not do anything

```
ReviewMe.shared().tryForReview()
```

####Properties
After initialization, more properties can be set to further customize the alert. 

- `chance` This is the probability that the alert will show, given that the user hasn't already taken action. You can think of this as "there is a 1 in `x` chance the alert will show" where `x` is `chance` . The default is 10.
- `minIgnore` This is the amount of times to ignore presenting the alert. After this many tries, the alert will actually attempt to show. This is to prevent the alert from showing when the user first opens the apps
- `title` Alert title
- `message` Alert message
- `alertTextYes` Text for the yes button. Default "Yes"
- `alertTextNo` Text for the no button. Default "No"
- `alertTextStopIt` Text for not asking the user again. Default "Stop asking"


