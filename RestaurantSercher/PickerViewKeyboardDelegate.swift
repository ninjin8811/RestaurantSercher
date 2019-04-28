import Foundation

protocol PickerViewKeyboardDelegate: StartViewController {
    func titlesOfPickerViewKeyboard(sender: PickerViewKeyboard) -> [String]
    func initSelectedRow(sender: PickerViewKeyboard) -> Int
    func didCancel(sender: PickerViewKeyboard)
    func didDone(sender: PickerViewKeyboard, selectedData: String)
}
