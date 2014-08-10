
import AVFoundation

class KeyButton: UIButton {

    let note: Note
    let audioPlayer: AVAudioPlayer
    let channels: [String]
    let shimmeringView: FBShimmeringView
    let originalBackgroundColor: UIColor

    required init(coder aDecoder: NSCoder!) {
        fatalError("NSCoding not supported")
    }

    init(frame: CGRect, note: Note, channels: [String]) {
        self.note = note
        self.channels = channels
        audioPlayer = AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource(note.toASCIIString(), withExtension: "caf"), error: nil)
        shimmeringView = FBShimmeringView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        shimmeringView.shimmering = true
        shimmeringView.shimmeringSpeed = note.keyColor == KeyColor.White ? 600 : 300
        shimmeringView.shimmeringPauseDuration = 0
        shimmeringView.shimmeringOpacity = 0.2
        var contentView = UIView(frame: shimmeringView.bounds)
        contentView.backgroundColor = UIColor.tt_whiteColor()
        shimmeringView.contentView = contentView
        shimmeringView.hidden = true
        originalBackgroundColor = note.keyColor == .White ? UIColor.tt_whiteColor() : UIColor.tt_grayColor()

        super.init(frame: frame)
        self.addSubview(shimmeringView)
        backgroundColor = originalBackgroundColor
        exclusiveTouch = true
    }

    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.audioPlayer.currentTime = 0
        self.audioPlayer.play()
        self.backgroundColor = UIColor.tt_orangeColor()
        self.shimmeringView.hidden = false
        Pusher.push(self.note.toASCIIString(), channels: self.channels, completionHandler: {success in
            UIView.animateWithDuration(0.3, animations: {
                self.shimmeringView.hidden = true
                self.backgroundColor = self.originalBackgroundColor

                }, completion: {finished in
                    if !success {
                        self.backgroundColor = UIColor.redColor()
                        UIView.animateWithDuration(0.3, animations: {
                            self.backgroundColor = self.originalBackgroundColor
                            })
                    }
                });
        })


        self.nextResponder().touchesBegan(touches, withEvent: event)
    }


}