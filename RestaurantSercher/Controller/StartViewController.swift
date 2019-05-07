import Alamofire
import CoreLocation
import SVProgressHUD
import SwiftyJSON
import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak private var pickerKeyboardButton: PickerViewKeyboard!
    @IBOutlet weak private var rangeLabel: UILabel!

    var locationManager = CLLocationManager()

    let gnaviURL = "https://api.gnavi.co.jp/RestSearchAPI/v3/"
    let accessKey = "bd585b21652351d6773c345c0266dcab"

    let pickerDataSource: [String] = ["300m", "500m", "1km", "2km", "3km"]
    var rangeIndex = 2
    var nowLatitude: Float = 0
    var nowLongitude: Float = 0
    var passDataToNextView: GnaviData?

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerKeyboardButton.delegate = self
        locationManager.delegate = self

        setupLocationManager()
    }

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.requestLocation()

            sendRequest({ isFetched in
                if isFetched == true {
                    self.performSegue(withIdentifier: "goToSearchView", sender: self)
                } else {
                    print("sendRequest失敗！")
                }
            })
        } else {
            print("位置情報の取得を許可されていません")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? SearchTableViewController else {
            preconditionFailure("遷移先のViewを取得できませんでした")
        }
        if let passData = passDataToNextView {
            destinationVC.hitCount = passData.totalHitCount
            destinationVC.restaurants = passData.rest
        }
    }

    // MARK: - Fetching restaurant data
    func sendRequest(_ after:@escaping (Bool) -> Void) {
        var isFetched = false
        let params: [String: Any] = [
            "keyid": accessKey,
            "range": rangeIndex,
            "latitude": nowLatitude,
            "longitude": nowLongitude,
            "hit_per_page": 15 //ここ変える！！
        ]

        SVProgressHUD.show()

        Alamofire.request(gnaviURL, method: .get, parameters: params).responseData(completionHandler: { (response) in
            if response.result.isSuccess == true {
                do {
                    guard let dataResponse = response.data else {
                        preconditionFailure("取得したデータが存在しませんでした")
                    }

                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedData = try decoder.decode(GnaviData.self, from: dataResponse)
                    self.passDataToNextView = decodedData

                    print(decodedData)

                    if decodedData.totalHitCount != 0 {
                        isFetched = true
                    }
                } catch {
                    print("トライエラー！")
                }
            } else {
                print("ぐるなびからデータを取得できませんでした： \(String(describing: response.result.error))")
            }
            after(isFetched)
            SVProgressHUD.dismiss()
        })
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
        rangeIndex = selectedRow + 1
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
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            nowLatitude = Float(location.coordinate.latitude)
            nowLongitude = Float(location.coordinate.longitude)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました")
    }
}
