import Alamofire
import Nuke
import UIKit

struct AccessSentense {
    var accessText = ""
    init(line: String, station: String, stationExit: String, walk: String, note: String) {
        self.accessText = "\(line) \(station)\(stationExit) 徒歩\(walk)分 \(note)"
    }
}

class SearchTableViewController: UITableViewController {

    @IBOutlet private var restListTableView: UITableView!
    @IBOutlet weak private var hitCountLabel: UILabel!

    let delegate = UIApplication.shared.delegate as? AppDelegate
    let gnaviURL = "https://api.gnavi.co.jp/RestSearchAPI/v3/"
    let accessKey = "bd585b21652351d6773c345c0266dcab"

    var selectedIndex = 0
    var hitCount = 0
    var latitude: Float = 0
    var longitude: Float = 0
    var range: Int = 0
    var loadStatus = false
    var restaurants = [Restaurant]()
    var accessSentenses = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        //Settings to cache images
        // 1
        DataLoader.sharedUrlCache.diskCapacity = 0

        let pipeline = ImagePipeline {
            // 2
            do {
                let dataCache = try DataCache(name: "com.restaurantsearcher.datacache")
                // 3
                dataCache.sizeLimit = 200 * 1024 * 1024
                // 4
                $0.dataCache = dataCache
            } catch {
                print("トライエラー")
            }
        }

        // 5
        ImagePipeline.shared = pipeline

        let contentMode = ImageLoadingOptions.ContentModes(success: .scaleAspectFill, failure: .scaleAspectFit, placeholder: .scaleAspectFit)
        ImageLoadingOptions.shared.contentModes = contentMode
        ImageLoadingOptions.shared.placeholder = UIImage(named: "loading")
        ImageLoadingOptions.shared.failureImage = UIImage(named: "no-image")
        ImageLoadingOptions.shared.transition = .fadeIn(duration: 0.5)

        DataLoader.sharedUrlCache.diskCapacity = 0 //Disable the default disk cache

        //AppDelegateから再検索に使う値を取得
        if let appDelegate = delegate {
            latitude = appDelegate.latitude
            longitude = appDelegate.longitude
            range = appDelegate.rangeIndex
        } else {
            print("AppDelegateを取得できませんでした")
        }

        hitCountLabel.text = "\(hitCount)件見つかりました"
        restListTableView.register(UINib(nibName: "SearchedRestaurantCell", bundle: nil), forCellReuseIdentifier: "restDataCell")
        initAccessSentense(0)
    }

    //アクセスの文章を取得したデータを繋ぎ合わせて作成
    func initAccessSentense(_ biginNum: Int) {
        for i in biginNum ..< restaurants.count {
            let appendText = AccessSentense(line: restaurants[i].access.line, station: restaurants[i].access.station, stationExit: restaurants[i].access.stationExit, walk: restaurants[i].access.walk, note: restaurants[i].access.note).accessText
            accessSentenses.append(appendText)
        }
        restListTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? RestDetailViewController else {
            preconditionFailure("遷移先のViewControllerを取得できませんでした")
        }
        destinationVC.accessSentense = accessSentenses[selectedIndex]
        destinationVC.receivedData = restaurants[selectedIndex]
    }

    // MARK: - ぐるなびからデータを取ってくる処理
    func sendRequest(offsetPage: Int) {

        //リクエストパラメータ
        let params: [String: Any] = [
            "keyid": accessKey,
            "range": range,
            "latitude": latitude,
            "longitude": longitude,
            "hit_per_page": 20,
            "offset_page": offsetPage
        ]

        let initAccessNum = restaurants.count

        Alamofire.request(gnaviURL, method: .get, parameters: params).responseData(completionHandler: { (response) in
            if response.result.isSuccess == true {
                do {
                    guard let dataResponse = response.data else {
                        preconditionFailure("取得したデータが存在しませんでした")
                    }

                    //DecodeModelのデータにデコード
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedData = try decoder.decode(GnaviData.self, from: dataResponse)
                    self.restaurants.append(contentsOf: decodedData.rest)

                    print(decodedData)
                } catch {
                    print("トライエラー！")
                }
            } else {
                print("ぐるなびからデータを取得できませんでした： \(String(describing: response.result.error))")
            }
            self.loadStatus = false
            self.initAccessSentense(initAccessNum)
        })
    }

    // MARK: - TableViewのデータ取り扱い
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let restCell = tableView.dequeueReusableCell(withIdentifier: "restDataCell", for: indexPath) as? SearchedRestaurantCell else {
            preconditionFailure("dequeueReusableCellの登録に失敗しました")
        }

        //セルのアイテムにテキストを代入
        restCell.restNameLabel.text = restaurants[indexPath.row].name
        restCell.budgetLabel.text = "￥ \(restaurants[indexPath.row].budget)"
        restCell.prLabel.text = restaurants[indexPath.row].pr.prShort
        restCell.accessLabel.text = accessSentenses[indexPath.row]
        restCell.restCategoryLabel.text = restaurants[indexPath.row].code.categoryNameL[0]

        //NukeでImageをダウンロード
        guard let imageURL = URL(string: restaurants[indexPath.row].imageUrl.shopImage1) else {
            preconditionFailure("StringからURLに変換できませんでした！")
        }
        let request = ImageRequest(url: imageURL, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill)
        Nuke.loadImage(with: request, into: restCell.restImageView)

        return restCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row

        performSegue(withIdentifier: "goToRestDetail", sender: self)
    }

    //残りのスクロール可能範囲が500px以下になったら再読込み
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        if distanceToBottom < 500 && restaurants.count < 1000 && loadStatus == false {
            loadStatus = true
            sendRequest(offsetPage: restaurants.count / 20 + 1)
        }
    }
}

//extension UITableView {
//    // 与えられたindexPathの下部のセルの数を返す
//    func belowCellsCount(cellIndexPath: IndexPath) -> Int {
//        // 全てのセルの数
//        let allCellsCount = Array(0 ..< self.numberOfSections).reduce(0) { (sum, sectionIndex) -> Int in
//            return sum + numberOfRows(inSection: sectionIndex)
//        }
//        // `cellIndexPath`の上部のセクションのすべてのセルの数
//        let cellsInAboveSectionCount = Array(0 ..< cellIndexPath.section).reduce(0) { (sum, sectionIndex) -> Int in
//            return sum + self.numberOfRows(inSection: sectionIndex)
//        }
//        return allCellsCount - cellsInAboveSectionCount - cellIndexPath.row
//    }
//}
