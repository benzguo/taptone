// Music.swift

enum NoteName: Character {
    case C = "C"
    case D = "D"
    case E = "E"
    case F = "F"
    case G = "G"
    case A = "A"
    case B = "B"
}

enum Accidental: Character {
    case DoubleSharp = "𝄪"
    case Sharp = "♯"
    case Natural = "♮"
    case Flat = "♭"
    case DoubleFlat = "𝄫"

    func toASCII() -> String {
        switch self {
        case DoubleSharp:
            return "x"
        case Sharp:
            return "#"
        case Natural:
            return ""
        case Flat:
            return "b"
        case DoubleFlat:
            return "bb"
        }
    }
}

class ProtoNote {
    var name: NoteName
    var accidental: Accidental?

    init(name n: NoteName, accidental a: Accidental?) {
        name = n
        accidental = a
    }
}

class Note: ProtoNote {
    var midiNumber: Int
    var octaveNumber: Int
    var protoNoteMap: Dictionary<Int, ProtoNote> = [
        0: ProtoNote(name: .C, accidental: nil),
        1: ProtoNote(name: .C, accidental: Accidental.Sharp),
        2: ProtoNote(name: .D, accidental: nil),
        3: ProtoNote(name: .D, accidental: Accidental.Sharp),
        4: ProtoNote(name: .E, accidental: nil),
        5: ProtoNote(name: .F, accidental: nil),
        6: ProtoNote(name: .F, accidental: Accidental.Sharp),
        7: ProtoNote(name: .G, accidental: nil),
        8: ProtoNote(name: .G, accidental: Accidental.Sharp),
        9: ProtoNote(name: .A, accidental: nil),
        10: ProtoNote(name: .A, accidental: Accidental.Sharp),
        11: ProtoNote(name: .B, accidental: nil)
    ]

    init(midiNumber number: Int) {
        midiNumber = number
        octaveNumber = Int(Float(number)/12.0)
        var protoNote: ProtoNote = protoNoteMap[number%12]!
        super.init(name: protoNote.name, accidental: protoNote.accidental)
    }

    func toString() -> String {
        return _toString(false)
    }

    func toASCIIString() -> String {
        return _toString(true)
    }

    func _toString(ASCII: Bool) -> String {
        var fullName: String = String(name.toRaw())
        if let _accidental = accidental {
            var accidentalString = ASCII ? String(_accidental.toRaw()) : _accidental.toASCII()
            fullName = fullName + accidentalString
        }
        return fullName + String(octaveNumber)
    }

}

