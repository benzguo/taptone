
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
    }

    @IBAction func showMenu(sender: AnyObject) {
       var ac = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Log out", style: .Default,
            handler: { action in
                NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeyUsername)
                NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeyPassword)
                self.performSegueWithIdentifier("logout", sender: self)
            }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
    }

    @IBAction func addFriend(sender: AnyObject) {
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

