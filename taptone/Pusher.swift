import Foundation

class Pusher {
    class func pushToUsers(users: String[], note: String) {
        var push = PFPush()
        var pushQuery = PFInstallation.query()
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
