class KeyButton: UIButton {

    init(frame: CGRect, color: KeyColor) {

        super.init(frame: frame)
        if color == KeyColor.White {
            backgroundColor = UIColor.whiteColor()
            setBackgroundImage(UIImage(color: UIColor.lightGrayColor(), size: CGSizeMake(1, 1)), forState: .Highlighted)
        }
        else {
            backgroundColor = UIColor.blackColor()
            setBackgroundImage(UIImage(color: UIColor.grayColor(), size: CGSizeMake(1, 1)), forState: .Highlighted)
        }
    }

}