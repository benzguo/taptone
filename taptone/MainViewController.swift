import MessageUI

class MainViewController: UITableViewController, MFMessageComposeViewControllerDelegate {

    var friends: [PFUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar = navigationController.navigationBar
        navBar.barTintColor = UIColor.tt_orangeColor()
        navBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navBar.shadowImage = UIImage()
        tableView.backgroundColor = UIColor.tt_orangeColor()
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.separatorStyle = .None

        var user = PFUser.currentUser()
        user.refreshInBackgroundWithBlock({result in
            self.reloadFriends()
            })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !(PFUser.currentUser()["phone"]) {
            setPhone()
        }
    }

    func reloadFriends() {
        var friendsRelation = PFUser.currentUser().relationForKey("friends")
        friendsRelation.query().findObjectsInBackgroundWithBlock({(objects: [AnyObject]!, error: NSError?) in
            self.friends = objects as [PFUser]
            self.tableView.reloadData()
            })
    }

    func setPhone(title: String = |"Enter your phone number",
        message: String = |"\rYour friends can add you on Taptone using your phone number.") {
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
                if phoneTextField.text.utf16count < 7 {
                    self.setPhone(title: |"Please enter a valid phone",
                        message: |"\rOnly people who know your phone number can add you on Taptone.")
                }
                else {
                    PFUser.currentUser().setObject(phoneTextField.text, forKey: "phone");
                    PFUser.currentUser().saveInBackground()
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
        ac.addAction(UIAlertAction(title: |"Ok", style: .Default,
            handler: { action in
                if nameTextField.text.utf16count < 6 {
                    self.setName(title: |"Please enter a valid name",
                        message: |"\rYour name must be at least 6 characters long.")
                }
                else {
                    PFUser.currentUser().setObject(nameTextField.text, forKey: "name");
                    PFUser.currentUser().saveInBackground()
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
            UIAlertController.presentStandardAlert(|"Can't send texts", message: "\r😢", fromViewController: self)
        }
    }

    @IBAction func showMenu(sender: AnyObject) {
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
        ac.addAction(UIAlertAction(title: |"Edit phone", style: .Default,
            handler: { action in
                self.setPhone(title: |"Change your phone number", message: |"\rCurrent number: \(phone)")
            }))
        ac.addAction(UIAlertAction(title: |"Log out", style: .Default,
            handler: { action in
                NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeyEmail)
                NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeyPassword)
                self.performSegueWithIdentifier(|"logout", sender: self)
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
                            if u.username == PFUser.currentUser().username {
                                SVProgressHUD.dismiss()
                                UIAlertController.presentStandardAlert(|"You can't add yourself",
                                    message: |"\rPlease go make some friends.",
                                    fromViewController: self)
                            }
                            else {
                                var currentUser = PFUser.currentUser()
                                var friendsRelation = currentUser.relationForKey("friends")
                                let duplicateQuery = friendsRelation.query()
                                duplicateQuery.whereKey("username", equalTo:u["username"])
                                let duplicate = duplicateQuery.getFirstObject()
                                if let d = duplicate {
                                    SVProgressHUD.dismiss()
                                    let name = u["name"] as String!
                                    UIAlertController.presentStandardAlert(|"Already added \(name)",
                                        message: "",
                                        fromViewController: self)
                                }
                                else {
                                    friendsRelation.addObject(user)
                                    currentUser.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
                                        SVProgressHUD.dismiss()
                                        self.reloadFriends()
                                        })
                                }
                            }
                        }
                        else {
                            SVProgressHUD.dismiss()
                            var ac = UIAlertController(title: |"We couldn't find a user with that phone number. Invite them to join Taptone!",
                                message: "", preferredStyle: .Alert)
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

    @IBAction func addFriend(sender: AnyObject) {
        self.addFriendByPhone()
    }

// Segues

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "showKeyboard" {
            var keyboardVC = segue.destinationViewController as KeyboardViewController
            let user = sender as PFUser
            let userId = user.objectId
            keyboardVC.title = user["name"] as String
            keyboardVC.channels = ["user_" + userId]
            // TODO multiselect
        }
    }

// UITableViewDataSource

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel.textAlignment = .Center
        cell.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 30)
        cell.textLabel.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel.text = friends[indexPath.row]["name"] as String
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        performSegueWithIdentifier("showKeyboard", sender: friends[indexPath.row])
    }

    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!)  {
        if editingStyle == .Delete {
            let friend = self.friends[indexPath.row]
            var friendsRelation = PFUser.currentUser().relationForKey("friends")
            friendsRelation.removeObject(friend)
            SVProgressHUD.show()
            PFUser.currentUser().saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
                SVProgressHUD.dismiss()
                self.reloadFriends()
                })
        }
    }

// MFMessageComposeViewControllerDelegate

    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult)  {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

