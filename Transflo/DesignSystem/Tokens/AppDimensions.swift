import CoreGraphics

/// Spacing, radii, icon sizes and window sizes.
enum AppDimensions {
    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 24
    }

    enum Radius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 10
        /// Glass panels: rounder, so the edge highlight reads as one continuous curve.
        static let large: CGFloat = 16
    }

    enum IconSize {
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
    }

    enum Stroke {
        static let hairline: CGFloat = 1
        /// Rings and frames marking a selection.
        static let selection: CGFloat = 2
        /// The keyboard focus ring (in the accent color) and its gap from the control.
        static let focus: CGFloat = 2.5
        static let focusGap: CGFloat = 2
    }

    enum Wheel {
        /// Ring size with up to `compactWedgeCount` wedges.
        static let compactOuterRadius: CGFloat = 140
        /// Ring size with `fullWedgeCount` wedges (one full page).
        static let fullOuterRadius: CGFloat = 200
        static let compactWedgeCount = 6
        static let fullWedgeCount = 12
        /// Leaves room in the hub for the hovered option's name on two lines.
        static let innerRadius: CGFloat = 60
        /// Space kept clear on each side of a wedge label.
        static let labelInset: CGFloat = 6
        /// Even space between neighboring petals, and between the petals and the hub well.
        static let petalGap: CGFloat = 8
        /// Space between the petals and the disc's rim.
        static let petalInset: CGFloat = 8
        static let petalCornerRadius: CGFloat = 20
        static let hubPillHeight: CGFloat = 32
        static let hubLabelTracking: CGFloat = 0.4
        /// Clear margin around the ring so the floating shadow is not clipped.
        static let margin: CGFloat = 16
        static let countBadgeDiameter: CGFloat = 22
        static let hubSummaryExtraWidth: CGFloat = 24
        static let hubDetailMinScale: CGFloat = 0.7
        static let hubGlyphSize: CGFloat = 22
    }

    /// Settings › Wheel checklist.
    enum Checkbox {
        static let size: CGFloat = 16
        static let radius: CGFloat = 4
        static let checkSize: CGFloat = 9
        /// Narrowest column in the checklist grid before it wraps to fewer columns.
        static let gridMinColumn: CGFloat = 128
    }

    /// The progress disc left at the wheel's center after a drop. Same size as the hub well.
    enum ResultDisc {
        static let diameter: CGFloat = 112
        static let ringStroke: CGFloat = 5
        /// Inset of the ring from the disc's edge.
        static let ringInset: CGFloat = 10
        static let glyphSize: CGFloat = 36
        static let glyphStroke: CGFloat = 6
        /// The disc starts this much larger, so the wheel appears to fold into it.
        static let enterScale: CGFloat = 1.5
        static let pulseScale: CGFloat = 1.08
        static let shakeDistance: CGFloat = 9
        static let captionWidth: CGFloat = 240
        static let captionHeight: CGFloat = 48
    }

    enum Shelf {
        static let width: CGFloat = 260
        static let headerHeight: CGFloat = 36
        static let rowHeight: CGFloat = 40
        static let maxVisibleRows = 6
        static let collapsedSize: CGFloat = 56
        static let iconSize: CGFloat = 28
    }

    enum Jobs {
        static let windowWidth: CGFloat = 480
        static let windowHeight: CGFloat = 440
        static let ringSize: CGFloat = 28
        static let emptyIconSize: CGFloat = 36
    }

    enum HUD {
        static let width: CGFloat = 280
        static let height: CGFloat = 64
        /// Gap between the drop point and the HUD.
        static let offset: CGFloat = 24
        static let ringSize: CGFloat = 28
        static let ringStroke: CGFloat = 3
    }

    enum Onboarding {
        static let width: CGFloat = 760
        static let illustrationWidth: CGFloat = 340
        static let contentHeight: CGFloat = 320
        static let padding: CGFloat = 32
        static let keycapWidth: CGFloat = 52
        static let keycapHeight: CGFloat = 36
        static let dotSize: CGFloat = 6
        static let selectedDotWidth: CGFloat = 20
        static let heroIconSize: CGFloat = 84
        /// Entrance motion: how far content rises, and where the icon and wheels start.
        static let entranceOffset: CGFloat = 16
        static let entranceScale: CGFloat = 0.96
        static let popScale: CGFloat = 0.5
        static let wheelStartScale: CGFloat = 0.82
        static let wheelStartTurn: Double = 28
        static let keycapPressedScale: CGFloat = 0.9
        static let keycapPressDepth: CGFloat = 2
    }

    enum Beautify {
        static let editorWidth: CGFloat = 860
        static let controlsWidth: CGFloat = 300
        static let presetWidth: CGFloat = 56
        static let presetHeight: CGFloat = 36
    }

    enum Editor {
        static let width: CGFloat = 560
        static let previewHeight: CGFloat = 300
        static let handleSize: CGFloat = 14
        static let trackHeight: CGFloat = 6
        static let fieldWidth: CGFloat = 80
        static let swatchSize: CGFloat = 24
        static let swatchRingGap: CGFloat = 4
        static let listHeight: CGFloat = 260
        static let pageThumbnailWidth: CGFloat = 76
        static let pageThumbnailHeight: CGFloat = 96
        static let rowThumbnailSize: CGFloat = 40
        static let unselectedOpacity: Double = 0.45
        static let renamePreviewHeight: CGFloat = 150
        static let assemblyPreviewHeight: CGFloat = 180
        static let assemblyThumbnailSize: CGFloat = 48
        static let menuPickerWidth: CGFloat = 220
        static let textEditorHeight: CGFloat = 90
    }

    enum Window {
        /// Stable native segmented-control width while the live preview changes.
        static let settingsControlWidth: CGFloat = 238
        static let settingsWidth: CGFloat = 700
        /// Settings sizes its height to the current tab's content, between these bounds.
        static let settingsMinContentHeight: CGFloat = 260
        static let settingsMaxHeight: CGFloat = 620
        /// The native tab bar's height above the content.
        static let settingsTabChrome: CGFloat = 30
        static let accentSwatchSize: CGFloat = 25
        static let aboutIconSize: CGFloat = 56
        static let welcomeWidth: CGFloat = 500
        static let welcomePadding: CGFloat = 32
    }

    /// Settings › Customization's live wheel preview.
    enum CustomizationPreview {
        static let viewport: CGFloat = 190
        static let scale: CGFloat = 0.48
    }

    /// The Welcome window's drawing of the menu bar with Transflo's icon highlighted.
    enum MenuBarIllustration {
        static let cornerRadius: CGFloat = 16
        static let iconCornerRadius: CGFloat = 10
        static let iconTile = CGSize(width: 46, height: 40)
        static let transfloIconSize: CGFloat = 24
        static let statusIconSize: CGFloat = 16
        static let batteryIconSize: CGFloat = 22
        static let arrowSize: CGFloat = 14
        static let captionWidth: CGFloat = 240
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 12
        static let hintIconSize: CGFloat = 20
    }
}
