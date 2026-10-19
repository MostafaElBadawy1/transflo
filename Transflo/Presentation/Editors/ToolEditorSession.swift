/// The model behind one open editor, typed per tool.
enum ToolEditorSession {
    case resize(ResizeEditorViewModel)
    case crop(CropEditorViewModel)
    case adjust(AdjustEditorViewModel)
    case trim(TrimEditorViewModel)
    case speed(SpeedEditorViewModel)
    case split(SplitEditorViewModel)
    case snapshot(SnapshotEditorViewModel)
    case annotate(AnnotateEditorViewModel)
    case redact(RedactEditorViewModel)
    case background(AddBackgroundEditorViewModel)
    case collage(CollageEditorViewModel)
    case bleep(BleepEditorViewModel)
    case reorganize(ReorganizePagesEditorViewModel)
    case extract(ExtractPagesEditorViewModel)
    case metadata(MetadataEditorViewModel)
    case rename(RenameEditorViewModel)

    var model: any ToolEditorModel {
        switch self {
        case .resize(let model): model
        case .crop(let model): model
        case .adjust(let model): model
        case .trim(let model): model
        case .speed(let model): model
        case .split(let model): model
        case .snapshot(let model): model
        case .annotate(let model): model
        case .redact(let model): model
        case .background(let model): model
        case .collage(let model): model
        case .bleep(let model): model
        case .reorganize(let model): model
        case .extract(let model): model
        case .metadata(let model): model
        case .rename(let model): model
        }
    }
}
