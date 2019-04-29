import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak private var pickerKeyboardButton: PickerViewKeyboard!
    @IBOutlet weak private var rangeLabel: UILabel!

    let pickerDataSource: [String] = ["100m", "300m", "500m", "800m", "1000m", "1500m", "2000m", "3000m"]

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerKeyboardButton.delegate = self
    }

    @IBAction func searchButtonPressed(_ sender: UIButton) {
    }
}

extension StartViewController: PickerViewKeyboardDelegate {
    func titlesOfPickerViewKeyboard(sender: PickerViewKeyboard) -> [String] {
        return pickerDataSource
    }

    func initSelectedRow(sender: PickerViewKeyboard) -> Int {
        return 3
    }

    func didCancel(sender: PickerViewKeyboard) {
        print("キャンセル")
        sender.resignFirstResponder()
    }

    func didDone(sender: PickerViewKeyboard, selectedData: String) {
        rangeLabel.text = "半径 \(selectedData) 以内"
        sender.resignFirstResponder()
    }
}
