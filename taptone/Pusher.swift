import Foundation

class Pusher {
    class func pushToUsers(users: [String], note: String) {
        let push = PFPush()
        let pushQuery = PFInstallation.query()
        pushQuery.whereKey("deviceType", equalTo: "ios")
        push.setQuery(pushQuery)
        push.setData(["sound": "\(note).caf"])
        push.sendPushInBackgroundWithBlock({(success: Bool, error: NSError?) in
            if (!success || error) {
                print(error)
            }
            })
    }
}
