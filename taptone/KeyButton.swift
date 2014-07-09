class KeyButton: UIButton {

    init(frame: CGRect, color: KeyColor) {

        super.init(frame: frame)
        if color == KeyColor.White {
            backgroundColor = UIColor.tt_whiteColor()
            setBackgroundImage(UIImage(color: UIColor.tt_orangeColor(), size: CGSizeMake(1, 1)), forState: .Highlighted)
        }
        else {
            backgroundColor = UIColor.tt_grayColor()
            setBackgroundImage(UIImage(color: UIColor.tt_orangeColor(), size: CGSizeMake(1, 1)), forState: .Highlighted)
        }
    }

}