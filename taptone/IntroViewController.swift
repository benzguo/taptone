
import AVFoundation

@objc(IntroViewController) class IntroViewController: UIViewController, UIAlertViewDelegate {

    let APlayer: AVAudioPlayer
    let GsPlayer: AVAudioPlayer
    let GPlayer: AVAudioPlayer

    @IBOutlet var signupButton: UIButton!
    @IBOutlet var blackKeyButton: UIButton!
    @IBOutlet var loginButton: UIButton!

    enum GenericError: String {
        case ConnectionError = "Connection error"
        case ObjectNotFound = "Object not found"
    }

    enum SignupError: String {
        case EmailTaken = "Email taken"
        case PhoneTaken = "Phone taken"
        case SignupFailed = "Signup failed"
    }

    enum LoginError: String {
        case UserNotFound = "User not found"
        case FailedToSendCode = "Failed to send code"
    }

    required init(coder aDecoder: NSCoder!) {
        APlayer = AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("A3", withExtension: "caf"), error: nil)
        GsPlayer = AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("G#3", withExtension: "caf"), error: nil)
        GPlayer = AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("G3", withExtension: "caf"), error: nil)
        super.init(coder: aDecoder)
    }

    @IBAction func unwindToIntroViewController(segue: UIStoryboardSegue) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        signupButton.setBackgroundImage(UIImage(color: UIColor.tt_orangeColor(), size: CGSizeMake(1, 1)),
            forState: .Highlighted)
        signupButton.setTitleColor(UIColor.tt_whiteColor(), forState: .Highlighted)
        signupButton.titleLabel.text = |"Sign up"

        loginButton.setBackgroundImage(UIImage(color: UIColor.tt_orangeColor(), size: CGSizeMake(1, 1)),
            forState: .Highlighted)
        loginButton.setTitleColor(UIColor.tt_whiteColor(), forState: .Highlighted)
        loginButton.titleLabel.text = |"Log in"

        blackKeyButton.setBackgroundImage(UIImage(color: UIColor.tt_orangeColor(), size: CGSizeMake(1, 1)),
            forState: .Highlighted)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if PFUser.currentUser() != nil {
            performSegueWithIdentifier("login", sender: self)
        }
    }

    func enterCode(email: String) {
        var codeTextField = UITextField()
        var ac = UIAlertController(title: |"Enter code",
            message: |"Check your email and enter the code to log in.",
            preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: |"Cancel", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: |"Log in", style: .Default, handler:
        { action in
            SVProgressHUD.show()
            let password = codeTextField.text
            PFUser.logInWithUsernameInBackground(email,
                password: password,
                block: { (user: PFUser?, error: NSError?) in
                    SVProgressHUD.dismiss()
                    if let e = error {
                         UIAlertController.presentStandardAlert(|"Log in failed",
                            message: |"Please try again",
                            fromViewController: self)                       
                    }
                    else {
                        let userChannel = "user_" + user!.objectId
                        PFInstallation.currentInstallation().setObject([userChannel], forKey:"channels")
                        PFInstallation.currentInstallation().saveEventually()

                        self.performSegueWithIdentifier("login", sender: self)
                    }
            })
        }))
        ac.addTextFieldWithConfigurationHandler {
            textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = NSLocalizedString("code", comment: "")
            textField.keyboardType = .PhonePad
            codeTextField = textField
        }
        self.presentViewController(ac, animated: true, completion: nil)
    }

    func handleLoginError(error: NSError) {
        let userInfo = error.userInfo
        if let u = userInfo as? [String: String]{
            let errorString = u["error"] as String!
            switch errorString {
            case LoginError.UserNotFound.toRaw():
                UIAlertController.presentStandardAlert(errorString,
                    message: |"Please enter the email you signed up with.",
                    fromViewController: self)
            case LoginError.FailedToSendCode.toRaw():
                UIAlertController.presentStandardAlert(errorString,
                    message: |"Please try again",
                    fromViewController: self)               
            default:
                UIAlertController.presentStandardAlert(error.localizedDescription,
                    message: "",
                    fromViewController: self)
            }
        }
    }

    @IBAction func logIn(sender: UIButton) {
        var emailTextField = UITextField()
        var ac = UIAlertController(title: "", message: nil, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: |"Cancel", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: |"Log in", style: .Default, handler:
        { action in
            SVProgressHUD.show()
            PFCloud.callFunctionInBackground("login",
                withParameters: ["email": emailTextField.text],
                block: {(result: AnyObject?, error: NSError?) in
                    SVProgressHUD.dismiss()
                    if let e = error {
                        self.handleLoginError(e)
                    }
                    else {
                        self.enterCode(emailTextField.text);
                    }
                })
        }))
        ac.addTextFieldWithConfigurationHandler {
            textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = NSLocalizedString("email", comment: "")
            textField.autocapitalizationType = .None
            textField.keyboardType = .EmailAddress
            emailTextField = textField
        }
        self.presentViewController(ac, animated: true, completion: nil)
    }

    func handleSignupError(error: NSError) {
        let userInfo = error.userInfo
        if let u = userInfo as? [String: String] {
            let errorString  = u["error"] as String!
            switch errorString {
            case SignupError.EmailTaken.toRaw():
                UIAlertController.presentStandardAlert(errorString,
                    message: |"This email is taken. Please log in or choose another email.",
                    fromViewController: self)
            case SignupError.PhoneTaken.toRaw():
                UIAlertController.presentStandardAlert(errorString,
                    message: |"This phone number is taken. Please log in or choose another phone number.",
                    fromViewController: self)
            default:
               SVProgressHUD.showErrorWithStatus(errorString)
            }
        }
    }


    @IBAction func signUp(sender: UIButton) {
        var nameTextField  = UITextField()
        var emailTextField = UITextField()
        var ac = UIAlertController(title: "", message: nil, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: |"Cancel", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: |"Sign up", style: .Default, handler:
        { action in
            SVProgressHUD.show()
            PFCloud.callFunctionInBackground("signup",
                withParameters: ["displayName": nameTextField.text,
                                 "email": emailTextField.text],
                block: {(result: AnyObject?, error: NSError?) in
                    SVProgressHUD.dismiss()
                    if let e = error {
                        self.handleSignupError(e)
                    }
                    else {
                        self.enterCode(emailTextField.text)
                    }
                })

        }))
        ac.addTextFieldWithConfigurationHandler {
            textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = |"name"
            nameTextField = textField
        }
        ac.addTextFieldWithConfigurationHandler {
            textField in
            textField.textAlignment = .Center
            textField.font = UIFont(name: "Helvetica-Neue", size: 25);
            textField.placeholder = |"email"
            textField.keyboardType = .EmailAddress
            emailTextField = textField
        }
        self.presentViewController(ac, animated: true, completion: nil)
    }

    @IBAction func signupTouchDown(sender: AnyObject) {
        APlayer.currentTime = 0
        APlayer.play()
    }
    @IBAction func blackKeyTouchDown(sender: AnyObject) {
        GsPlayer.currentTime = 0
        GsPlayer.play()
    }
    @IBAction func loginTouchDown(sender: AnyObject) {
        GPlayer.currentTime = 0
        GPlayer.play()
    }
}