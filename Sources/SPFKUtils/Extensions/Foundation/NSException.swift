import Foundation

extension NSException {
    public var error: NSError {
        NSError(domain: "com.audiodesigndesk.exception",
                code: 1,
                userInfo: userInfo as? [String: Any])
    }
}
