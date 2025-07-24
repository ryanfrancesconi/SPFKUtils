import AppKit

extension NSTableView {
    public func selectNextRow(byExtendingSelection: Bool = false) {
        var nextRow = min(numberOfRows - 1, selectedRow + 1)

        if hiddenRowIndexes.isNotEmpty, hiddenRowIndexes.contains(nextRow) {
            for i in nextRow ..< numberOfRows {
                if !hiddenRowIndexes.contains(i) {
                    nextRow = i
                    break
                }
            }
        }

        let selectRow = IndexSet(integer: nextRow)
        selectRowIndexes(selectRow, byExtendingSelection: byExtendingSelection)
        scrollRowToVisible(selectedRow)
    }

    public func selectPreviousRow(byExtendingSelection: Bool = false) {
        var nextRow = max(0, selectedRow - 1)

        if hiddenRowIndexes.isNotEmpty, hiddenRowIndexes.contains(nextRow) {
            var i = nextRow
            while i >= 0 {
                if !hiddenRowIndexes.contains(i) {
                    nextRow = i
                    break
                }
                i -= 1
            }
        }

        let selectRow = IndexSet(integer: nextRow)
        selectRowIndexes(selectRow, byExtendingSelection: byExtendingSelection)
        scrollRowToVisible(selectedRow)
    }
}
