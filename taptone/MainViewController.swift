
class MainViewController: UITableViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        var navBar = navigationController.navigationBar
        navBar.barTintColor = UIColor.tt_orangeColor()
        navBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navBar.shadowImage = UIImage()
        tableView.backgroundColor = UIColor.tt_orangeColor()
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsZero
    }

// UITableViewDataSource

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.text = "bla"
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

