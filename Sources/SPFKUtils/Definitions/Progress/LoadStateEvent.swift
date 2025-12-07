// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

public enum LoadStateEvent {
    case loading(string: String?, progress: UnitInterval)
    case loaded
}
