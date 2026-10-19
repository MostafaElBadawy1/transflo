/// File actions offered on the Actions wheel. They work on any file, folder or mixed selection.
public enum ActionKind: Sendable, Hashable, CaseIterable {
    case airDrop
    case float
    case copy
    case move
    case copyPath
    case terminal
}
