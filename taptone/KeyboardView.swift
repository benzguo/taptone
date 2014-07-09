class KeyboardView: UIView {

    var whiteKeys: KeyButton[] = []
    var blackKeys: KeyButton[] = []

    init(width: CGFloat, notes: Note[]) {
        var whiteNotes = notes.filter { $0.keyColor == KeyColor.White }
        var whiteKeyHeight = width / 5;
        var blackKeyHeight = whiteKeyHeight * 2/3
        var blackKeyWidth = width / 2;
        var viewHeight = whiteKeyHeight * CGFloat(whiteNotes.count) + 1

        var y = viewHeight
        var prevKeyColor = KeyColor.White
        for n in notes {
            var keyWidth: CGFloat
            var noteHeight: CGFloat
            if n.keyColor == .Black {
                noteHeight = blackKeyHeight
                y -= blackKeyHeight*1/2
                keyWidth = blackKeyWidth
            }
            else {
                noteHeight = whiteKeyHeight
                if prevKeyColor == .White {
                    y -= noteHeight
                }
                else {
                    y -= blackKeyHeight
                }
                keyWidth = width
            }
            var keyFrame = CGRectMake(0, y, keyWidth, noteHeight-1)
            var key = KeyButton(frame: keyFrame, color: n.keyColor)

            if n.keyColor == .Black {
                blackKeys.append(key)
            }
            else {
                whiteKeys.append(key)
            }
            prevKeyColor = n.keyColor
        }

        var frame = CGRectMake(0, 0, width, viewHeight)
        super.init(frame: frame)
        backgroundColor = UIColor.tt_orangeColor()
        for k in whiteKeys {
            addSubview(k)
        }
        for k in blackKeys {
            addSubview(k)
        }       
    }
}