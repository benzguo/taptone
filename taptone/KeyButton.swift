
import AVFoundation

class KeyButton: UIButton {

    let note: Note
    let audioPlayer: AVAudioPlayer

    init(frame: CGRect, note: Note) {
        self.note = note
        self.audioPlayer = AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource(note.toASCIIString(), withExtension: "caf"), error: nil)
        super.init(frame: frame)
        if note.keyColor == KeyColor.White {
            backgroundColor = UIColor.tt_whiteColor()
        }
        else {
            backgroundColor = UIColor.tt_grayColor()
        }
        exclusiveTouch = true
    }

    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.audioPlayer.currentTime = 0
        self.audioPlayer.play()
        self.backgroundColor = UIColor.tt_orangeColor()
        UIView.animateWithDuration(0.3, animations: {
            if self.note.keyColor == KeyColor.White {
                self.backgroundColor = UIColor.tt_whiteColor()
            }
            else {
                self.backgroundColor = UIColor.tt_grayColor()
            }
        })

        self.nextResponder().touchesBegan(touches, withEvent: event)
    }


}