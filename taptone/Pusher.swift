import Foundation

class Pusher {
    class func push(note: String, channels: [String], completionHandler handler:((Bool)->(Void))!) {
        let name = PFUser.currentUser().objectForKey("name") as String
        let userId = PFUser.currentUser().objectId
        let push = PFPush()
        push.setChannels(channels)
        push.setData(["sound": "\(note).caf",
            "name": name,
            "userId": userId])
        push.sendPushInBackgroundWithBlock({(success: Bool, error: NSError?) in
            if (!success || error) {
                print(error)
            }
            handler(success)
            })
    }
}
