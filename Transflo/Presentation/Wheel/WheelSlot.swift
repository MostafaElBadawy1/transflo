import TransfloDomain

/// One visible wedge: an option, or the More wedge that pages through long lists.
enum WheelSlot: Equatable {
    case option(WheelOption)
    case more
}
