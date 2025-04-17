import Foundation

extension NSAttributedString {
    public convenience init?(htmlString: String) {
        guard let data = htmlString.data(using: .unicode) else {
            return nil
        }

        try? self.init(data: data,
                       options: [.documentType: NSAttributedString.DocumentType.html],
                       documentAttributes: nil)
    }
}
