import Alamofire
import SwiftyJSON
import UIKit

class RequestData {

    let gnaviURL = "https://api.gnavi.co.jp/RestSearchAPI/v3/"
    let accessKey = "bd585b21652351d6773c345c0266dcab"

    var latitude: Float = 0.0
    var longitude: Float = 0.0
    var rangeIndex = 2
    var offset = 1
    var totalHit = 0
    var restData = [Restaurant]()
    var errorData: ErrorMessage?

    //API通信した後、通信が成功したかどうかをBoolで返す
    func sendRequest(_ after:@escaping (Bool) -> Void) {

        var isFetched = false
        let params: [String: Any] = [
            "keyid": accessKey,
            "range": rangeIndex,
            "latitude": latitude,
            "longitude": longitude,
            "hit_per_page": 20,
            "offset": offset
        ]

        Alamofire.request(gnaviURL, method: .get, parameters: params).responseJSON(completionHandler: { (response) in
            if response.result.isSuccess == true {

                //レスポンスデータをJSON形式の配列に変換して、配列の要素数でエラーデータを判別するのに使う
                guard let responseValue = response.result.value else {
                    preconditionFailure("取得したデータが存在しませんでした")
                }
                let responseJSON = JSON(responseValue)

                //デコード設定
                guard let dataResponse = response.data else {
                    preconditionFailure("取得したデータが存在しませんでした")
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                //レストランデータの取得に成功した場合の処理
                if responseJSON.count > 2 {
                    do {
                        let decodedData = try decoder.decode(GnaviData.self, from: dataResponse)
                        self.totalHit = decodedData.totalHitCount
                        self.restData.append(contentsOf: decodedData.rest)

                        isFetched = true
                    } catch {
                        print("トライエラー！")
                    }
                } else { //エラーデータを受け取った場合の処理
                    do {
                        print(responseJSON)
                        let decodedData = try decoder.decode(ErrorCode.self, from: dataResponse)
                        self.errorData = decodedData.error[0]
                    } catch {
                        print("トライエラー！")
                    }
                }
            } else {
                print("ぐるなびと通信できませんでした。： \(String(describing: response.result.error))")
            }
            after(isFetched)
        })
    }
}
