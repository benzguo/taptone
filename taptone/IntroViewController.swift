
extension UIAlertController {
    class func presentStandardAlert(title: String, message: String, fromViewController viewController: UIViewController) {
        var ac = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
        viewController.presentViewController(ac, animated: true, completion: nil)
    }
}

class IntroViewController: UIViewController, UIAlertViewDelegate {

    enum GenericError: String {
        case ConnectionError = "Connection error"
        case ObjectNotFound = "Object not found"
    }

    enum SignupError: String {
        case UsernameTaken = "Username taken"
        case EmailTaken = "Email taken"
        case SignupFailed = "Signup failed"
    }

    enum LoginError: String {
        case UserNotFound = "User not found"
        case FailedToSendCode = "Failed to send code"
    }

    func handleSignupError(error: NSError) {
        let userInfo = error.userInfo
        if let u = userInfo {
            let errorString: NSString = u["error"] as NSString
            switch errorString {
            case SignupError.UsernameTaken.toRaw():
                UIAlertController.presentStandardAlert(errorString,
                    message: "This username is already in use. Please log in or choose another username.",
                    fromViewController: self)
            case SignupError.EmailTaken.toRaw():
                UIAlertController.presentStandardAlert(errorString,
                    message: "This email is already in use. Please log in or choose another email.",
                    fromViewController: self)
            default:
               SVProgressHUD.showErrorWithStatus(errorString)
            }
        }
    }

    func handleLoginError(error: NSError) {
        let userInfo = error.userInfo
        if let u = userInfo {
            let errorString: NSString = u["error"] as NSString
            switch errorString {
            case LoginError.UserNotFound.toRaw():
                UIAlertController.presentStandardAlert(errorString,
                    message: "Check your info or sign up to create an account.",
                    fromViewController: self)
             case LoginError.FailedToSendCode.toRaw():
                UIAlertController.presentStandardAlert(errorString,
                    message: "Please try again",
                    fromViewController: self)               
            default:
               SVProgressHUD.showErrorWithStatus(errorString)
            }
        }
    }

    func enterCode(username: String) {
        var codeTextField = UITextField()
        var ac = UIAlertController(title: "Enter code",
            message: "Check your email and enter the code the log in.",
            preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Log in", style: UIAlertActionStyle.Default, handler:
        { action in
            SVProgressHUD.show()
            PFUser.logInWithUsernameInBackground(username,
                password: codeTextField.text,
                block: { (user: PFUser?, error: NSError?) in
                    SVProgressHUD.dismiss()
                    if error {
                         UIAlertController.presentStandardAlert("Log in failed",
                            message: "Please try again",
                            fromViewController: self)                       
                    }
                    else {
                        self.performSegueWithIdentifier("login", sender: self)
                    }
            })
        }))
        ac.addTextFieldWithConfigurationHandler {
            textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = NSLocalizedString("code", comment: "")
            codeTextField = textField
        }
        self.presentViewController(ac, animated: true, completion: nil)
    }

    @IBAction func logIn(sender: UIButton) {
        var handleTextField = UITextField()
        var ac = UIAlertController(title: "Log in", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Log in", style: UIAlertActionStyle.Default, handler:
        { action in
            SVProgressHUD.show()
            PFCloud.callFunctionInBackground("login",
                withParameters: ["handle": handleTextField.text],
                block: {(result: AnyObject?, error: NSError?) in
                    SVProgressHUD.dismiss()
                    if let e = error {
                        self.handleLoginError(e)
                    }
                    else {
                        if let username = result as? String {
                            self.enterCode(username);
                        }
                    }
                })
        }))
        ac.addTextFieldWithConfigurationHandler {
            textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = NSLocalizedString("username or email", comment: "")
            handleTextField = textField
        }
        self.presentViewController(ac, animated: true, completion: nil)
    }

    @IBAction func signUp(sender: UIButton) {
        var usernameTextField  = UITextField()
        var emailTextField = UITextField()
        var ac = UIAlertController(title: "Sign up", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Sign up", style: UIAlertActionStyle.Default, handler:
        { action in
            SVProgressHUD.show()
            PFCloud.callFunctionInBackground("signup",
                withParameters: ["username": usernameTextField.text,
                                 "email": emailTextField.text],
                block: {(result: AnyObject?, error: NSError?) in
                    SVProgressHUD.dismiss()
                    if let e = error {
                        self.handleSignupError(e)
                    }
                    else {
                        self.enterCode(usernameTextField.text)
                    }
                })

        }))
        ac.addTextFieldWithConfigurationHandler {
            textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = "username"
            usernameTextField = textField
        }
        ac.addTextFieldWithConfigurationHandler {
            textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = "email"
            emailTextField = textField
        }
        self.presentViewController(ac, animated: true, completion: nil)
    }

}