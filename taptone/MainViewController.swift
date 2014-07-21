
class MainViewController: UITableViewController {
                            
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
            self.tableView.reloadData()
            })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !(PFUser.currentUser()["phone"]) {
            setPhone()
        }
    }

    func setPhone(title: String = "Enter your phone number",
        message: String = "\rYour friends can add you on Taptone using your phone number.") {
        var phoneTextField = UITextField()
        var ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler({ textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = NSLocalizedString("phone number", comment: "")
            phoneTextField = textField
            })
        ac.addAction(UIAlertAction(title: "Ok", style: .Default,
            handler: { action in
                if phoneTextField.text.utf16count < 7 {
                    self.setPhone(title: "Please enter a valid phone",
                        message: "\rOnly people who know your phone number can add you on Taptone.")
                }
                else {
                    PFUser.currentUser().setObject(phoneTextField.text, forKey: "phone");
                    PFUser.currentUser().saveInBackground()
                }
            }))              
        self.presentViewController(ac, animated: true, completion: nil)
    }

    func setName(message: String) {
        var nameTextField = UITextField()
        var ac = UIAlertController(title: "Change your name", message: message, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler({ textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = NSLocalizedString("name", comment: "")
            nameTextField = textField
            })
        ac.addAction(UIAlertAction(title: "Ok", style: .Default,
            handler: { action in
                if nameTextField.text.utf16count < 7 {
                    self.setPhone(title: "Please enter a valid phone",
                        message: "\rOnly people who know your phone number can add you on Taptone.")
                }
                else {
                    PFUser.currentUser().setObject(nameTextField.text, forKey: "phone");
                    PFUser.currentUser().saveInBackground()
                }
            }))              
        self.presentViewController(ac, animated: true, completion: nil)
    }   

    func inviteUser() {

    }

    @IBAction func showMenu(sender: AnyObject) {
        let name = PFUser.currentUser()["name"] as String?
        let phone = PFUser.currentUser()["phone"] as String?
        var ac = UIAlertController(title: name, message: phone, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Send invite", style: .Default,
            handler: { action in

            }))
        ac.addAction(UIAlertAction(title: "Edit name", style: .Default,
            handler: { action in

            }))              
        ac.addAction(UIAlertAction(title: "Edit phone", style: .Default,
            handler: { action in
                self.setPhone(title: "Change your phone number", message: "\rCurrent number: \(phone)")
            }))
        ac.addAction(UIAlertAction(title: "Log out", style: .Default,
            handler: { action in
                NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeyEmail)
                NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeyPassword)
                self.performSegueWithIdentifier("logout", sender: self)
            }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
    }

    func addFriendByPhone(title: String = "Add a friend by entering their phone number") {
        var phoneTextField = UITextField()
        var ac = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler({ textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = NSLocalizedString("phone number", comment: "")
            phoneTextField = textField
            })
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Add", style: .Default,
            handler: { action in
                let phone = phoneTextField.text
                if phone.utf16count < 7 {
                    self.addFriendByPhone(title: "Please enter a valid phone")
                }
                else {
                    var query = PFUser.query()
                    query.whereKey("phone", equalTo: phone)
                    let user = query.getFirstObject()
                    if let u = user as? PFUser {
                        if u.username == PFUser.currentUser().username {
                            UIAlertController.presentStandardAlert("You can't add yourself",
                                message: "\rPlease go make some friends.",
                                fromViewController: self)
                        }
                        else {
                            let newFriend: Dictionary<String, String> = ["username": u.username as String,
                                                                         "name": u["name"] as String]
                            var currentUser = PFUser.currentUser()
                            var friends = currentUser["friends"] as Array<Dictionary<String, String>>?
                            if let f = friends {
                                let duplicates = f.filter({e in e["username"] == newFriend["username"]})
                                if duplicates.count > 0 {
                                    let name = u["name"] as String!
                                    UIAlertController.presentStandardAlert("Already added \(name)",
                                        message: "",
                                        fromViewController: self)
                                }
                                else {
                                    var mf = f
                                    mf.insert(newFriend, atIndex:0)
                                    currentUser["friends"] = mf
                                }
                             }
                            else {
                                currentUser["friends"] = [newFriend]
                            }
                            currentUser.saveInBackgroundWithBlock({(succeeded: Bool, error: NSError?) in
                                self.tableView.reloadData()
                                })
                        }
                    }
                    else {
                        var ac = UIAlertController(title: "We couldn't find a user with that phone number. Invite them to join Taptone!",
                            message: "", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                        ac.addAction(UIAlertAction(title: "Invite", style: .Default,
                            handler: { action in
                                self.inviteUser()
                            }))
                        self.presentViewController(ac, animated: true, completion: nil)                       
                    }
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
            keyboardVC.title = sender as String
        }
    }

// UITableViewDataSource

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if let f = PFUser.currentUser()["friends"] as Array<Dictionary<String, String>>? {
            return f.count
        }
        return 0
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel.textAlignment = .Center
        cell.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 30)
        cell.textLabel.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        if let f = PFUser.currentUser()["friends"] as Array<Dictionary<String, String>>? {
            cell.textLabel.text = f[indexPath.row]["name"]
        }
        return cell
    }

    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return tableView.frame.size.width / 5
    }

// UITableViewDelegate

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        performSegueWithIdentifier("showKeyboard", sender: cell.textLabel.text)
    }


}

