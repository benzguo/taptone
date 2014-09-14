class KeyboardView: UIView {

    var whiteKeys: [KeyButton] = []
    var blackKeys: [KeyButton] = []

    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    init(width: CGFloat, notes: [Note], channels: [String]) {
        let whiteNotes = notes.filter { $0.keyColor == KeyColor.White }
        let whiteKeyHeight: CGFloat = 65.5;
        let blackKeyHeight: CGFloat = whiteKeyHeight * 2/3
        let blackKeyWidth: CGFloat = width / 2;
        let viewHeight = whiteKeyHeight * CGFloat(whiteNotes.count) + 1

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
            let keyFrame = CGRectMake(0, y, keyWidth, noteHeight-1)
            let key = KeyButton(frame: keyFrame, note: n, channels: channels)

            if n.keyColor == .Black {
                blackKeys.append(key)
            }
            else {
                whiteKeys.append(key)
            }
            prevKeyColor = n.keyColor
        }

        let frame = CGRectMake(0, 0, width, viewHeight)
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