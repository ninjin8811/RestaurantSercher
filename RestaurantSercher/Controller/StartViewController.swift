import Alamofire
import CoreLocation
import SVProgressHUD
import UIKit

class StartViewController: UIViewController {

    weak var appDelegate = UIApplication.shared.delegate as? AppDelegate

    @IBOutlet weak private var pickerKeyboardButton: PickerViewKeyboard!
    @IBOutlet weak private var rangeLabel: UILabel!

    var locationManager = CLLocationManager()
    let requestDataClass = RequestData()

    let gnaviURL = "https://api.gnavi.co.jp/RestSearchAPI/v3/"
    let accessKey = "bd585b21652351d6773c345c0266dcab"

    let pickerDataSource: [String] = ["300m", "500m", "1km", "2km", "3km"]

    override func viewDidLoad() {
        super.viewDidLoad()

        if appDelegate == nil {
            print("AppDelegateが存在しません")
        }
        pickerKeyboardButton.delegate = self
        locationManager.delegate = self

        setupLocationManager()
    }

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            SVProgressHUD.show()

            requestDataClass.restData.removeAll()
            requestDataClass.sendRequest { (isFetched) in
                if isFetched == true {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "goToSearchView", sender: self)
                } else {
                    SVProgressHUD.dismiss()

                    guard let errorData = self.requestDataClass.errorData else {
                        preconditionFailure("エラーデータが存在しませんでした")
                    }

                    //アラートの生成
                    let alert = UIAlertController(title: "エラー(\(errorData.code))", message: errorData.message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

                    alert.addAction(okAction)

                    self.present(alert, animated: true, completion: nil)

                    print("sendRequest失敗")
                }
            }
        } else {
            print("位置情報の取得を許可されていません")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? SearchTableViewController else {
            preconditionFailure("遷移先のViewControllerを取得できませんでした")
        }
        destinationVC.requestDataClass = requestDataClass
    }
}

// MARK: - PickerViewDelegate
extension StartViewController: PickerViewKeyboardDelegate {
    func titlesOfPickerViewKeyboard(sender: PickerViewKeyboard) -> [String] {
        return pickerDataSource
    }

    func initSelectedRow(sender: PickerViewKeyboard) -> Int {
        return 1
    }

    func didCancel(sender: PickerViewKeyboard) {
        print("キャンセル")
        sender.resignFirstResponder()
    }

    func didDone(sender: PickerViewKeyboard, selectedRow: Int) {
        rangeLabel.text = "半径 \(pickerDataSource[selectedRow]) 以内"
        requestDataClass.rangeIndex = selectedRow + 1
        sender.resignFirstResponder()
    }
}

// MARK: - LocationManagerDelegate
extension StartViewController: CLLocationManagerDelegate {
    func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()

        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 1000
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            requestDataClass.latitude = Float(location.coordinate.latitude)
            requestDataClass.longitude = Float(location.coordinate.longitude)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました")
    }
}
