
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
        user.refreshInBackgroundWithBlock(nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !(PFUser.currentUser().objectForKey("phone")) {
            addPhoneNumber()
        }
    }

    func addPhoneNumber(title: String = "Enter your phone number",
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
                    self.addPhoneNumber(title: "Please enter a valid phone",
                        message: "\rOnly people who know your phone number can add you on Taptone.")
                }
            }))              
        self.presentViewController(ac, animated: true, completion: nil)
    }

    @IBAction func showMenu(sender: AnyObject) {
        var ac = UIAlertController(title: "Ben Guo", message: "4435700053", preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Send invite", style: .Default,
            handler: { action in

            }))
        ac.addAction(UIAlertAction(title: "Edit name", style: .Default,
            handler: { action in

            }))              
        ac.addAction(UIAlertAction(title: "Edit phone", style: .Default,
            handler: { action in

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

    @IBAction func addFriend(sender: AnyObject) {
        var usernameTextField = UITextField()
        var ac = UIAlertController(title: "Add a friend by entering their phone number", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler({ textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = NSLocalizedString("phone number", comment: "")
            usernameTextField = textField
            })
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Add", style: .Default,
            handler: { action in

            }))
        self.presentViewController(ac, animated: true, completion: nil)
    }

// UITableViewDataSource

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel.text = "BENZGUO"
        cell.textLabel.textAlignment = .Center
        cell.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 30)
        cell.textLabel.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }

    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return tableView.frame.size.width / 5
    }

// UITableViewDelegate

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        performSegueWithIdentifier("showKeyboard", sender: self)
    }


}

