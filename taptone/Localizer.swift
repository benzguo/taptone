
infix operator | {}
func | (lhs: String, rhs: String) -> String {
    return NSLocalizedString(lhs, comment: rhs)
}
postfix operator | {}
postfix func | (s: String) -> String {
    return NSLocalizedString(s, comment: "")
}


