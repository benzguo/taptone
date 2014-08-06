import MessageUI

let cachedFriendsKey = "cachedFriends"

class MainViewController: UITableViewController, MFMessageComposeViewControllerDelegate {

    @IBOutlet var leftBarButtonItem: UIBarButtonItem
    @IBOutlet var rightBarButtonItem: UIBarButtonItem

    var friends: [Friend] = []
    var isMultiSelecting: Bool = false {
        didSet {
            if isMultiSelecting {
                self.leftBarButtonItem.image = UIImage(named: "cancel")
                self.rightBarButtonItem.image = UIImage(named: "next")
            }
            else {
                self.leftBarButtonItem.image = UIImage(named: "menu")
                self.rightBarButtonItem.image = UIImage(named: "plus")
                self.deselectAllRows()
            }
        }
    }

    func deselectAllRows() {
        let optIndexPaths: NSArray? = self.tableView.indexPathsForSelectedRows()
        if let indexPaths = optIndexPaths {
            for indexPath in indexPaths {
                self.tableView.deselectRowAtIndexPath(indexPath as NSIndexPath,
                    animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar = navigationController.navigationBar
        navBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navBar.shadowImage = UIImage()
        navBar.alpha = 1.0
        tableView.backgroundColor = navBar.backgroundColor
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.separatorStyle = .None
        tableView.allowsMultipleSelection = true

        var longPressGR = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGR.minimumPressDuration = 0.8
        tableView.addGestureRecognizer(longPressGR)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shouldReloadFriends:",
            name: NotificationNameShouldReloadFriends, object: nil)

        let maybeData: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(cachedFriendsKey)
        if let data = maybeData as? NSData {
            self.friends = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [Friend]
            self.reloadTableView()
        }
        var user = PFUser.currentUser()
        user.refreshInBackgroundWithBlock({result in
            self.reloadFriends()
            })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.reloadFriends()
        if !(PFUser.currentUser()["phone"]) {
            setPhone()
        }
        self.isMultiSelecting = false
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func reloadTableView() {
        self.friends.sort { $0.name < $1.name }
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }

    func reloadFriends() {
        var friendsRelation = PFUser.currentUser().relationForKey("friends")
        friendsRelation.query().findObjectsInBackgroundWithBlock({(objects: [AnyObject]?, error: NSError?) in
            if let os = objects as? [PFUser] {
                self.friends = os.map {
                    return Friend(userId: $0.objectId,
                        name: $0.objectForKey("name") as String,
                        phone: $0.objectForKey("phone") as String)
                }
                let cachedFriends = NSKeyedArchiver.archivedDataWithRootObject(self.friends)
                NSUserDefaults.standardUserDefaults().setObject(cachedFriends, forKey: cachedFriendsKey)
                NSUserDefaults.standardUserDefaults().synchronize()
                self.reloadTableView()
            }
            })
    }

    func shouldReloadFriends(notification: NSNotification?) {
        reloadFriends()
    }

    func setPhone(title: String = |"Enter your phone number",
        message: String = "\r" + |"Your friends can add you on Taptone using your phone number.") {
        var phoneTextField = UITextField()
        var ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler({ textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = |"phone number"
            textField.keyboardType = .PhonePad
            phoneTextField = textField
            })
        ac.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default,
            handler: { action in
                let phone = phoneTextField.text
                if phone.utf16count < 7 {
                    self.setPhone(title: |"Please enter a valid phone",
                        message: "\r" + |"Only people who know your phone number can add you on Taptone.")
                }
                else {
                    var query = PFUser.query()
                    query.whereKey("phone", equalTo: phone)
                    query.getFirstObjectInBackgroundWithBlock({(object: PFObject?, error: NSError?) in
                        if let user = object as? PFUser {
                            UIAlertController.presentStandardAlert(|"Phone number taken",
                                message: "\r" + |"Please choose a different number", fromViewController: self)
                        }
                        else {
                            let originalPhone = PFUser.currentUser().objectForKey("phone") as String
                            PFUser.currentUser().setObject(phone, forKey: "phone");
                            PFUser.currentUser().saveInBackgroundWithBlock({(success: Bool, error: NSError?) in
                                if let e = error {
                                    PFUser.currentUser().setObject(originalPhone, forKey: "phone");
                                    UIAlertController.presentStandardAlert(|"Save failed",
                                        message: e.localizedDescription, fromViewController: self)
                                }
                                })
                            }
                        })
                }
            }))              
        self.presentViewController(ac, animated: true, completion: nil)
    }

    func setName(title: String = |"Change your name", message: String = "") {
        var nameTextField = UITextField()
        var ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler({ textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = NSLocalizedString("name", comment: "")
            nameTextField = textField
            })
        ac.addAction(UIAlertAction(title: |"Cancel", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: |"Ok", style: .Default,
            handler: { action in
                if nameTextField.text.utf16count < 6 {
                    self.setName(title: |"Please enter a valid name",
                        message: "\r" + |"Your name must be at least 6 characters long.")
                }
                else {
                    let originalName = PFUser.currentUser().objectForKey("name") as String
                    PFUser.currentUser().setObject(nameTextField.text, forKey: "name");
                    PFUser.currentUser().saveInBackgroundWithBlock({(success: Bool, error: NSError?) in
                        if let e = error {
                            PFUser.currentUser().setObject(originalName, forKey: "name");
                            UIAlertController.presentStandardAlert(|"Save failed",
                                message: e.localizedDescription, fromViewController: self)
                        }
                        })
                }
            }))              
        self.presentViewController(ac, animated: true, completion: nil)
    }   

    func invitePhone(phone: String?) {
        if MFMessageComposeViewController.canSendText() {
            var messageVC = MFMessageComposeViewController()
            messageVC.messageComposeDelegate = self
            if let p = phone {
                messageVC.recipients = [p]
            }
            messageVC.body = |"Add me on Taptone! http://taptone.me/dl"
            self.presentViewController(messageVC, animated: true, completion: nil)
        }
        else {
            UIAlertController.presentStandardAlert(|"This device can't send texts", message: "", fromViewController: self)
        }
    }



    @IBAction func leftBarButtonItemAction(sender: AnyObject) {
        if self.isMultiSelecting {
            self.isMultiSelecting = false
        }
        else {
            self.showMenu()
        }
    }

    func showMenu() {
        let name = PFUser.currentUser()["name"] as String?
        let phone = PFUser.currentUser()["phone"] as String?
        var ac = UIAlertController(title: name, message: phone, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: |"Send invite", style: .Default,
            handler: { action in
                self.invitePhone(nil)
            }))

        ac.addAction(UIAlertAction(title: |"Edit name", style: .Default,
            handler: { action in
                self.setName()
            }))              

        ac.addAction(UIAlertAction(title: |"Log out", style: .Default,
            handler: { action in
                PFUser.logOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                var rootViewController = storyboard.instantiateViewControllerWithIdentifier("IntroViewController") as UIViewController
                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                appDelegate.window!.rootViewController = rootViewController
            }))
        ac.addAction(UIAlertAction(title: |"Cancel", style: .Cancel, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)       
    }

    func addFriendByPhone(title: String = |"Add a friend by entering their phone number") {
        var phoneTextField = UITextField()
        var ac = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler({ textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = NSLocalizedString("phone number", comment: "")
            textField.keyboardType = .PhonePad
            phoneTextField = textField
            })
        ac.addAction(UIAlertAction(title: |"Cancel", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: |"Add", style: .Default,
            handler: { action in
                let phone = phoneTextField.text
                if phone.utf16count < 7 {
                    self.addFriendByPhone(title: |"Please enter a valid phone")
                }
                else {
                    var query = PFUser.query()
                    query.whereKey("phone", equalTo: phone)
                    SVProgressHUD.show()
                    query.getFirstObjectInBackgroundWithBlock({(user: PFObject?, error: NSError?) in
                        if let u = user as? PFUser {
                            SVProgressHUD.dismiss()
                            if u.username == PFUser.currentUser().username {
                                UIAlertController.presentStandardAlert(|"You can't add yourself!",
                                    message: "\r" + |"Please go make some friends.",
                                    fromViewController: self)
                            }
                            else {
                                if self.friends.filter({ return $0.userId == u.objectId }).count != 0  {
                                    let name = u.objectForKey("name") as String
                                    UIAlertController.presentStandardAlert(|"Already added " + "\(name)",
                                        message: "\r",
                                        fromViewController: self)
                                    return
                                }
                                let friend = Friend(userId: u.objectId,
                                    name: u.objectForKey("name") as String,
                                    phone: u.objectForKey("phone") as String)
                                self.friends.append(friend)
                                self.reloadTableView()

                                var currentUser = PFUser.currentUser()
                                var friendsRelation = currentUser.relationForKey("friends")
                                friendsRelation.addObject(user)
                                currentUser.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
                                    if !succeeded || error != nil {
                                        self.reloadFriends()
                                    }
                                    })
                            }
                        }
                        else {
                            SVProgressHUD.dismiss()
                            var ac = UIAlertController(title: |"We couldn't find a user with that phone number",
                                message: "Invite them to join Taptone!", preferredStyle: .Alert)
                            ac.addAction(UIAlertAction(title: |"Cancel", style: .Cancel, handler: nil))
                            ac.addAction(UIAlertAction(title: |"Invite", style: .Default,
                                handler: { action in
                                    self.invitePhone(phone)
                                }))
                            self.presentViewController(ac, animated: true, completion: nil)                       
                        }
                        })
                }

            }))
        self.presentViewController(ac, animated: true, completion: nil)
    }

    @IBAction func rightBarButtonItemAction(sender: AnyObject) {
        if self.isMultiSelecting {
            performSegueWithIdentifier("showKeyboard", sender: nil)
        }
        else {
            self.addFriendByPhone()
        }
    }

// Segues

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "showKeyboard" {
            var keyboardVC = segue.destinationViewController as KeyboardViewController
            if let friend = sender as? Friend {
                keyboardVC.channels = ["user_" + friend.userId]
                keyboardVC.phones = [friend.phone as String]
            }
            else {
                var selectedFriends: [Friend] = []
                let maybeIndexPaths: NSArray? = self.tableView.indexPathsForSelectedRows()
                if let indexPaths = maybeIndexPaths {
                    for indexPath in indexPaths {
                        selectedFriends += self.friends[indexPath.row]
                    }
                    keyboardVC.channels = selectedFriends.map {(friend: Friend) in
                        return "user_" + friend.userId
                    }
                    keyboardVC.phones = selectedFriends.map {(friend: Friend) in
                        return friend.phone
                    }
                    self.deselectAllRows()
                }
            }
        }
    }

// UITableViewDataSource

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel.textAlignment = .Center
        cell.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 30)
        cell.textLabel.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel.text = friends[indexPath.row].name as String
        return cell
    }

    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return tableView.frame.size.width / 5
    }

    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

// UITableViewDelegate

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if !self.isMultiSelecting {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            performSegueWithIdentifier("showKeyboard", sender: friends[indexPath.row])
        }
    }

    override func tableView(tableView: UITableView!, didDeselectRowAtIndexPath indexPath: NSIndexPath!) {
        let indexPaths: NSArray? = tableView.indexPathsForSelectedRows()
        if indexPaths == nil {
            self.isMultiSelecting = false
        }
    }

    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!)  {
        if editingStyle == .Delete {
            let friend = self.friends[indexPath.row]
            self.friends.removeAtIndex(indexPath.row)
            self.reloadTableView()

            var friendsRelation = PFUser.currentUser().relationForKey("friends")
            let friendQuery = friendsRelation.query()
            friendQuery.whereKey("objectId", equalTo:friend.userId)
            friendQuery.getFirstObjectInBackgroundWithBlock({(friend: PFObject?, error: NSError?) in
                if let f = friend {
                    friendsRelation.removeObject(friend)
                    PFUser.currentUser().saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
                        if !succeeded || error != nil {
                            self.reloadFriends()
                        }
                        })
                }
                else {
                    self.reloadFriends()
                }
                })
        }
    }

// UIGestureRecognizer

    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer?) {
        let p = gestureRecognizer!.locationInView(self.tableView)
        if let indexPath = self.tableView.indexPathForRowAtPoint(p) {
            self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            self.isMultiSelecting = true
        }
    }

// MFMessageComposeViewControllerDelegate

    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult)  {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

