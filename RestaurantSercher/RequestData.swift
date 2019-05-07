import Alamofire
import SVProgressHUD
import UIKit

class RequestData {

    let delegate = UIApplication.shared.delegate as? AppDelegate

    let gnaviURL = "https://api.gnavi.co.jp/RestSearchAPI/v3/"
    let accessKey = "bd585b21652351d6773c345c0266dcab"

    // MARK: - Fetching restaurant data
    public func sendRequest(_ after:@escaping (Bool) -> Void) {

        guard let appDelegate = delegate else {
            preconditionFailure("AppDelegateを取得できませんでした")
        }

        var isFetched = false
        let params: [String: Any] = [
            "keyid": accessKey,
            "range": appDelegate.rangeIndex,
            "latitude": appDelegate.latitude,
            "longitude": appDelegate.longitude,
            "hit_per_page": 20,
            "offset": appDelegate.offset
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
                    appDelegate.restData.append(contentsOf: decodedData.rest)

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
