import Alamofire
import CoreLocation
import SVProgressHUD
import SwiftyJSON
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
    var rangeIndex = 2
    var nowLatitude: Float = 0
    var nowLongitude: Float = 0
    var passDataToNextView: GnaviData?

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

            requestDataClass.sendRequest { (isFetched) in
                if isFetched == true {
                    SVProgressHUD.dismiss()
                    //                    self.performSegue(withIdentifier: "goToSearchView", sender: self)
                } else {
                    SVProgressHUD.dismiss()
                    print("sendRequest失敗")
                }
            }
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

    // MARK: - ぐるなびからデータを取得する処理
    func sendRequest() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global(qos: .utility)
        var isFetched = false

        guard let delegate = appDelegate else {
            preconditionFailure("aaa")
        }
        let params: [String: Any] = [
            "keyid": accessKey,
            "range": rangeIndex,
            "latitude": delegate.latitude,
            "longitude": delegate.longitude,
            "hit_per_page": 15 //ここ変える！！
        ]

        //2回目以降のリクエストがうまくいかない
        Alamofire.request(gnaviURL, method: .get, parameters: params).responseData(queue: queue) { response in
            if response.result.isSuccess == true {
                do {
                    guard let dataResponse = response.data else {
                        preconditionFailure("取得したデータが存在しませんでした")
                    }
                    print(dataResponse)

                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedData = try decoder.decode(GnaviData.self, from: dataResponse)
                    self.passDataToNextView = decodedData

                    print(decodedData)

                    if decodedData.totalHitCount != 0 {
                        isFetched = true
                    }
                } catch {
                    print("トライエラー！!!!!")
                }
            } else {
                print("ぐるなびからデータを取得できませんでした： \(String(describing: response.result.error))")
            }
            semaphore.signal()
        }
        semaphore.wait()
        return isFetched
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
        appDelegate?.rangeIndex = selectedRow + 1
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
            // AppDelegateに値を保存
            nowLatitude = Float(location.coordinate.latitude)
            nowLongitude = Float(location.coordinate.longitude)
            appDelegate?.latitude = Float(location.coordinate.latitude)
            appDelegate?.longitude = Float(location.coordinate.longitude)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました")
    }
}
