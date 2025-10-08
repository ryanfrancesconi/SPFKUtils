import AppKit

extension NSOutlineView {
    public func collapseSelectedRows(collapseChildren: Bool = false) {
        for row in selectedRowIndexes.sorted().reversed() {
            collapseItem(item(atRow: row),
                         collapseChildren: collapseChildren)
        }
    }

    public func expandSelectedRows(expandChildren: Bool = false) {
        for row in selectedRowIndexes.sorted().reversed() {
            expandItem(item(atRow: row),
                       expandChildren: expandChildren)
        }
    }
}
