
class MainViewController: UITableViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        var navBar = navigationController.navigationBar
        navBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navBar.shadowImage = UIImage()
        navBar.barTintColor = UIColor.magentaColor()
        navBar.translucent = false
        navBar.alpha = 0.7
        navBar.barStyle = .Black
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

