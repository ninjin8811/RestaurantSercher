import Alamofire
import UIKit

class RequestData {

    weak var delegate = UIApplication.shared.delegate as? AppDelegate

    let gnaviURL = "https://api.gnavi.co.jp/RestSearchAPI/v3/"
    let accessKey = "bd585b21652351d6773c345c0266dcab"

    //API通信した後、通信が成功したかどうかをBoolで返す
    func sendRequest(_ after:@escaping (Bool) -> Void) {

        guard let appDelegate = delegate else {
            preconditionFailure("RequestDataクラス: AppDelegateを取得できませんでした")
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

        print(params)

        Alamofire.request(gnaviURL, method: .get, parameters: params).responseData(completionHandler: { (response) in
            if response.result.isSuccess == true {
                do {
                    guard let dataResponse = response.data else {
                        preconditionFailure("取得したデータが存在しませんでした")
                    }
                    print(dataResponse)

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
        })
    }
}

//    // MARK: - ぐるなびからデータを取得する処理
//    func sendRequest() -> Bool {
//        let semaphore = DispatchSemaphore(value: 0)
//        let queue = DispatchQueue.global(qos: .utility)
//        var isFetched = false
//        let params: [String: Any] = [
//            "keyid": accessKey,
//            "range": rangeIndex,
//            "latitude": nowLatitude,
//            "longitude": nowLongitude,
//            "hit_per_page": 15 //ここ変える！！
//        ]
//
//        if let appDelegate = delegate {
//            appDelegate.latitude = nowLatitude
//            appDelegate.longitude = nowLongitude
//            appDelegate.rangeIndex = rangeIndex
//        }
//
//        //2回目以降のリクエストがうまくいかない
//        Alamofire.request(gnaviURL, method: .get, parameters: params).responseData(queue: queue) { response in
//            if response.result.isSuccess == true {
//                do {
//                    guard let dataResponse = response.data else {
//                        preconditionFailure("取得したデータが存在しませんでした")
//                    }
//
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    let decodedData = try decoder.decode(GnaviData.self, from: dataResponse)
//                    self.passDataToNextView = decodedData
//
//                    print(decodedData)
//
//                    if decodedData.totalHitCount != 0 {
//                        isFetched = true
//                    }
//                } catch {
//                    print("トライエラー！")
//                }
//            } else {
//                print("ぐるなびからデータを取得できませんでした： \(String(describing: response.result.error))")
//            }
//            semaphore.signal()
//        }
//        semaphore.wait()
//        DispatchQueue.main.async {
//            SVProgressHUD.dismiss()
//        }
//        return isFetched
//    }
