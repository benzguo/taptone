extension Range {
    func toArray() -> T[] {
        return T[](self)
    }
}

class KeyboardViewController: UIViewController {

    var noteNumbers: Int[]
    var notes: Note[]

    @IBOutlet var scrollView: UIScrollView

    init(coder aDecoder: NSCoder!) {
        noteNumbers = (48...72).toArray()
        notes = noteNumbers.map { Note(midiNumber: $0) }
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var keyboardView: UIView =
            NSBundle.mainBundle().loadNibNamed("KeyboardView", owner: self, options: nil)[0] as UIView
        scrollView.addSubview(keyboardView)
        scrollView.contentSize = keyboardView.frame.size
    }

}