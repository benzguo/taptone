import Foundation

class Pusher {
    class func push(note: String, channels: [String]) {
        let push = PFPush()
        push.setChannels(channels)
        push.setData(["sound": "\(note).caf"])
        push.sendPushInBackgroundWithBlock({(success: Bool, error: NSError?) in
            if (!success || error) {
                print(error)
            }
            })
    }
}
