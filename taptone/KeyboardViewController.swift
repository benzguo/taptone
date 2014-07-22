extension Range {
    func toArray() -> [T] {
        return [T](self)
    }
}

class KeyboardViewController: UIViewController {

    let noteNumbers: [Int]
    let notes: [Note]

    @IBOutlet var scrollView: UIScrollView

    init(coder aDecoder: NSCoder!) {
        noteNumbers = (48...72).toArray()
        notes = noteNumbers.map { Note(midiNumber: $0) }
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        let keyboardView = KeyboardView(width: scrollView.frame.size.width, notes: notes)
        scrollView.backgroundColor = UIColor.tt_orangeColor()
        scrollView.addSubview(keyboardView)
        scrollView.contentSize = keyboardView.frame.size
        scrollView.delaysContentTouches = false
        scrollView.multipleTouchEnabled = false

        for gestureRecognizer: UIGestureRecognizer in scrollView.gestureRecognizers as [UIGestureRecognizer] {
            if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer) {
                var panGestureRecognizer = gestureRecognizer as UIPanGestureRecognizer
                panGestureRecognizer.minimumNumberOfTouches = 2
            }
        }
    }

}