extension Range {
    func toArray() -> [T] {
        return [T](self)
    }
}

class KeyboardViewController: UIViewController {

    // public
    var channels: [String] = []

    // private
    let noteNumbers: [Int]
    let notes: [Note]
    var maxOffset: Double = 0
    var minOffset: Double = 0

    @IBOutlet var scrollPad: UIView
    @IBOutlet var scrollView: UIScrollView

    init(coder aDecoder: NSCoder!) {
        noteNumbers = (48...72).toArray()
        notes = noteNumbers.map { Note(midiNumber: $0) }
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        var shimmeringView = FBShimmeringView(frame: scrollPad.bounds)
        shimmeringView.shimmering = true
        shimmeringView.shimmeringSpeed = 100
        shimmeringView.shimmeringPauseDuration = 1
        shimmeringView.shimmeringOpacity = 0.8
        var contentView = UIView(frame: shimmeringView.bounds)
        contentView.layer.cornerRadius = scrollPad.frame.size.height / 2
        contentView.backgroundColor = UIColor.tt_whiteColor()
        shimmeringView.contentView = contentView
        scrollPad.addSubview(shimmeringView)

        let keyboardView = KeyboardView(width: scrollView.frame.size.width, notes: notes, channels: self.channels)
        maxOffset = keyboardView.frame.size.height - self.view.frame.size.height
        minOffset = -self.navigationController.navigationBar.frame.size.height
        scrollPad.hidden = (maxOffset < 5)

        scrollView.backgroundColor = UIColor.tt_orangeColor()
        scrollView.addSubview(keyboardView)
        scrollView.contentSize = keyboardView.frame.size
        scrollView.delaysContentTouches = false
        scrollView.multipleTouchEnabled = false
    }

    @IBAction func handlePan(sender: UIPanGestureRecognizer?) {
        var translation = sender!.translationInView(sender!.view)
        var y = self.scrollView.contentOffset.y + (translation.x/8)
        y = max(min(y, maxOffset), minOffset)
        self.scrollView.contentOffset = CGPoint(x: 0, y: y)

    }

    @IBAction func menuButtonAction(sender: AnyObject) {

    }
}