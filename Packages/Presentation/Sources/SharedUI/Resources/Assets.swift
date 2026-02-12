import SwiftUI

public enum Assets: String {
    case checkmark = "checkmark"
    case chevronDown = "chevron.down"
    case runningFigure = "figure.run"
    case cyclingFigure = "figure.outdoor.cycle"
    case swimmingFigure = "figure.pool.swim"
    case hikingFigure = "figure.hiking"
    case dumbbellFilled = "dumbbell.fill"
    case trophyFilled = "trophy.fill"
    case clipboard = "pencil.and.list.clipboard"
    case gearshape = "gearshape"
    case plus = "plus"
    case filter = "slider.horizontal.3"
    case close = "xmark"
    case offline = "wifi.slash"
    case mobile = "iphone"
    case cloud = "cloud"
    case sun = "sun.max"
    case moon = "moon"
    case bin = "trash"
    case magnifyingglass = "magnifyingglass"
}

public extension Assets {
    var image: Image {
        Image(systemName: self.rawValue)
    }
}
