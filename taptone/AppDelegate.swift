import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var notificationView: NotificationView?


    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool
    {
        application.statusBarHidden = true
        notificationView = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil)[0] as? NotificationView
        notificationView!.frame = CGRect(x: 0, y: 0,
            width: self.window!.frame.size.width, height: notificationView!.frame.size.height)

        // configure Parse + notifications
        Parse.setApplicationId("RUXkfe7Otj8ROooI0DQxH1AZULZonaz1EA3XFjnk",
            clientKey: "OIUU5084O4vsjvwUZHlRy0Pjf6h9Iog6OQLPMIwW")
        application.registerForRemoteNotifications()

        var settings = UIUserNotificationSettings(forTypes: .Badge | .Alert | .Sound,
            categories: nil)
        application.registerUserNotificationSettings(settings)
        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData?)
    {
        var currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
    }

    func application(application: UIApplication!, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]!, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)!)
    {
        let aps = userInfo["aps"] as NSDictionary?
        var sound = aps!["sound"] as String
        let userId = userInfo["userId"] as AnyObject? as String // WTF
        let name = userInfo["name"] as AnyObject? as String // WTF
        sound = sound.stringByReplacingOccurrencesOfString(".caf", withString: "") as NSString
        var soundURL = NSBundle.mainBundle().URLForResource(sound, withExtension:"caf") as CFURLRef
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL, &soundID)
        CFRelease(soundURL)
        AudioServicesPlaySystemSound(soundID)

        var query = PFUser.query()
        query.whereKey("objectId", equalTo:userId)
        query.getFirstObjectInBackgroundWithBlock({(user: PFObject?, error: NSError?) in
            if let u = user as? PFUser {
                var friendsRelation = PFUser.currentUser().relationForKey("friends")
                friendsRelation.addObject(user)
                PFUser.currentUser().saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
        //            self.reloadFriends()
                    completionHandler(.NewData)
                })
            }
            })

        notificationView!.nameLabel.text = name
        notificationView!.alpha = 0
        self.window!.addSubview(notificationView)
        UIView.animateWithDuration(0.3, animations: {
            self.notificationView!.alpha = 1
            }, completion: {finished in
                UIView.animateWithDuration(1, animations: {
                    self.notificationView!.alpha = 0;
                })
            })       
    }


    func application(application: UIApplication!,
        didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings!)
    {

    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: NSDictionary?)
    {
//        PFPush.handlePush(userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

