
import AVFoundation

let KeychainServiceName = "taptone"
let UserDefaultsKeyEmail = "email"
let UserDefaultsKeyPassword = "password"


@objc(IntroViewController) class IntroViewController: UIViewController, UIAlertViewDelegate {

    let APlayer: AVAudioPlayer
    let GsPlayer: AVAudioPlayer
    let GPlayer: AVAudioPlayer

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

    init(coder aDecoder: NSCoder!) {
        APlayer = AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("A3", withExtension: "caf"), error: nil)
        GsPlayer = AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("G#3", withExtension: "caf"), error: nil)
        GPlayer = AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("G3", withExtension: "caf"), error: nil)
        super.init(coder: aDecoder)
    }

    @IBOutlet var signupButton: UIButton
    @IBOutlet var blackKeyButton: UIButton
    @IBOutlet var loginButton: UIButton

    @IBAction func unwindToIntroViewController(segue: UIStoryboardSegue) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.signupButton.setBackgroundImage(UIImage(color: UIColor.tt_orangeColor(), size: CGSizeMake(1, 1)),
            forState: .Highlighted)
        self.signupButton.setTitleColor(UIColor.tt_whiteColor(), forState: .Highlighted)
        self.signupButton.titleLabel.text = |"Sign up"

        self.loginButton.setBackgroundImage(UIImage(color: UIColor.tt_orangeColor(), size: CGSizeMake(1, 1)),
            forState: .Highlighted)
        self.loginButton.setTitleColor(UIColor.tt_whiteColor(), forState: .Highlighted)
        self.loginButton.titleLabel.text = |"Log in"

        self.blackKeyButton.setBackgroundImage(UIImage(color: UIColor.tt_orangeColor(), size: CGSizeMake(1, 1)),
            forState: .Highlighted)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let email: String? = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsKeyEmail) as String?
        let password: String? = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsKeyPassword) as String?
        if email != nil && password != nil {
            PFUser.logInWithUsernameInBackground(email,
                password: password,
                block: { (user: PFUser?, error: NSError?) in
                    SVProgressHUD.dismiss()
                    if error {
                        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeyEmail)
                        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeyPassword)
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    else {
                        self.performSegueWithIdentifier("login", sender: self)
                    }
            })
        }
    }

    func enterCode(email: String) {
        var codeTextField = UITextField()
        var ac = UIAlertController(title: |"Enter code",
            message: |"Check your email and enter the code the log in.",
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
                        let channelName = "user_" + user!.objectId
                        PFInstallation.currentInstallation().addUniqueObject(channelName, forKey:"channels")
                        PFInstallation.currentInstallation().saveEventually()

                        NSUserDefaults.standardUserDefaults().setObject(email, forKey: UserDefaultsKeyEmail)
                        NSUserDefaults.standardUserDefaults().setObject(password, forKey: UserDefaultsKeyPassword)
                        NSUserDefaults.standardUserDefaults().synchronize()
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
        if let u = userInfo {
            let errorString: NSString = u["error"] as NSString
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
        if let u = userInfo {
            let errorString: NSString = u["error"] as NSString
            switch errorString {
            case SignupError.EmailTaken.toRaw():
                UIAlertController.presentStandardAlert(errorString,
                    message: |"This email is already in use. Please log in or choose another email.",
                    fromViewController: self)
            case SignupError.PhoneTaken.toRaw():
                UIAlertController.presentStandardAlert(errorString,
                    message: |"This phone number is already in use. Please log in or choose another phone number.",
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