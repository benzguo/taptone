class KeyButton: UIButton {

    init(frame: CGRect, color: KeyColor) {

        super.init(frame: frame)
        backgroundColor = (color == KeyColor.White) ? UIColor.whiteColor() : UIColor.blackColor()
    }

}