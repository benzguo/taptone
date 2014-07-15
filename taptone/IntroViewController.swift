
class IntroViewController: UIViewController, UIAlertViewDelegate {
    @IBAction func logIn(sender: UIButton) {
        var alert = UIAlertController(title: "", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log in", style: UIAlertActionStyle.Default, handler:
        { action in

        }))
        alert.addTextFieldWithConfigurationHandler {
            textField in
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = "username or email"
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func signUp(sender: UIButton) {
        var usernameTextField  = UITextField()
        var emailTextField = UITextField()
        var ac = UIAlertController(title: "", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Sign up", style: UIAlertActionStyle.Default, handler:
        { action in
            PFCloud.callFunctionInBackground("signup",
                withParameters: ["username": usernameTextField.text,
                                 "email": emailTextField.text],
                target: self, selector: "signUpCallback:");
        }))
        ac.addTextFieldWithConfigurationHandler {
            textField in
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = "username"
            usernameTextField = textField
        }
        ac.addTextFieldWithConfigurationHandler {
            textField in
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = "email"
            emailTextField = textField
        }
        self.presentViewController(ac, animated: true, completion: nil)
    }

    func signUpCallback(result: NSString?, error: NSError?) {
        if (error) {
            SVProgressHUD.showErrorWithStatus(error?.localizedDescription)
        }
        print(result);
    }

}