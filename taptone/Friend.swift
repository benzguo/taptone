
class Friend: NSObject, NSCoding {
    let userId: String
    let name: String
    let phone: String

    init(userId u: String, name n: String, phone p: String) {
        userId = u
        name = n
        phone = p
    }

    required init(coder decoder: NSCoder!) {
        userId = decoder.decodeObjectForKey("userId") as String
        name = decoder.decodeObjectForKey("name") as String
        phone = decoder.decodeObjectForKey("phone") as String
        super.init()
    }

    func encodeWithCoder(coder: NSCoder!) {
        coder.encodeObject(userId, forKey:"userId")
        coder.encodeObject(name, forKey:"name")
        coder.encodeObject(phone, forKey:"phone")
    }

}