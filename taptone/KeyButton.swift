class KeyButton: UIButton {

    let color: KeyColor

    init(frame: CGRect, color: KeyColor) {
        self.color = color
        super.init(frame: frame)
        if color == KeyColor.White {
            backgroundColor = UIColor.tt_whiteColor()
        }
        else {
            backgroundColor = UIColor.tt_grayColor()
        }
        exclusiveTouch = true
    }

    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
            self.backgroundColor = UIColor.tt_orangeColor()
            UIView.animateWithDuration(0.5, animations: {
                if self.color == KeyColor.White {
                    self.backgroundColor = UIColor.tt_whiteColor()
                }
                else {
                    self.backgroundColor = UIColor.tt_grayColor()
                }
            })

        self.nextResponder().touchesBegan(touches, withEvent: event)
    }


}