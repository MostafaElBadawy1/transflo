/// Short media time labels: `0:05.3`, `12:00.0`, `1:02:03.5`.
enum TimeLabel {
    static func text(_ seconds: Double) -> String {
        let tenths = Int((max(seconds, 0) * 10).rounded())
        let fraction = tenths % 10
        let total = tenths / 10
        let (hours, minutes, secs) = (total / 3600, total / 60 % 60, total % 60)
        let clock = hours > 0
            ? "\(hours):\(pad(minutes)):\(pad(secs))"
            : "\(minutes):\(pad(secs))"
        return "\(clock).\(fraction)"
    }

    private static func pad(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }
}
