// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

public enum LoadStateEvent {
    case loading(string: String?, progress: ProgressValue1)
    case loaded
}
