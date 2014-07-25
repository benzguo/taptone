
operator prefix | {}
@prefix func | (string: String) -> String {
    return NSLocalizedString(string, comment:"")
}

let localizedString = |"username"


