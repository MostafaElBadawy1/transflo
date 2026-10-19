/// File tools offered on the Tools wheel (the reference's 26).
public enum ToolKind: String, Sendable, Hashable, CaseIterable {
    case compress
    case resize
    case crop
    case rotate
    case adjust
    case annotate
    case redact
    case removeBackground
    case addBackground
    case readCode
    case imagesToPDF
    case collage
    case trim
    case changeSpeed
    case split
    case merge
    case snapshot
    case mute
    case normalize
    case bleep
    case channels
    case reorganizePages
    case extractPages
    case editMetadata
    case removeMetadata
    case rename
}
