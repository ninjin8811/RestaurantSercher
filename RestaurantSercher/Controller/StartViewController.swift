import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak private var pickerKeyboardButton: PickerViewKeyboard!
    @IBOutlet weak private var rangeLabel: UILabel!

    let pickerDataSource: [String] = ["100", "300", "500", "800", "1000", "1500", "2000", "3000"]

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerKeyboardButton.delegate = self
    }

    @IBAction func changeRangeButtonPressed(_ sender: UIButton) {
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
        rangeLabel.text = "何も選択されてないよ"
    }

    func didDone(sender: PickerViewKeyboard, selectedData: String) {
        print("キャンセル")
    }
}
