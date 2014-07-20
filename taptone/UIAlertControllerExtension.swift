extension UIAlertController {
    class func presentStandardAlert(title: String, message: String, fromViewController viewController: UIViewController) {
        var ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        viewController.presentViewController(ac, animated: true, completion: nil)
    }
}