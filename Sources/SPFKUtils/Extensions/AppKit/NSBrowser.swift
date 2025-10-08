import AppKit

extension NSBrowser {
    public func selectNextRow(byExtendingSelection: Bool = false) {
        var next = selectedRow(inColumn: selectedColumn) + 1
        if let maxRows = delegate?.browser?(self, numberOfRowsInColumn: selectedColumn) {
            next = min(maxRows, next)
        }

        selectRow(next, inColumn: selectedColumn)
    }

    public func selectPreviousRow(byExtendingSelection: Bool = false) {
        let next = selectedRow(inColumn: selectedColumn) - 1
        selectRow(max(0, next), inColumn: selectedColumn)
    }

    public func selectNone() {
        selectRowIndexes(.init(), inColumn: 0)
    }
}
