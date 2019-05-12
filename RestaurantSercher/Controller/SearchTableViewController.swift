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

    weak var appDelegate = UIApplication.shared.delegate as? AppDelegate
    let gnaviURL = "https://api.gnavi.co.jp/RestSearchAPI/v3/"
    let accessKey = "bd585b21652351d6773c345c0266dcab"
    let requestDataClass = RequestData()

    var selectedIndex = 0
    var loadStatus = false
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

        hitCountLabel.text = "\(appDelegate?.totalHit ?? 0)件見つかりました"
        restListTableView.register(UINib(nibName: "SearchedRestaurantCell", bundle: nil), forCellReuseIdentifier: "restDataCell")
        initAccessSentense(0)
    }

    //アクセスの文章を取得したデータを繋ぎ合わせて作成
    func initAccessSentense(_ biginNum: Int) {
        guard let delegate = appDelegate else {
            preconditionFailure("initAccessSentense: AppDelegateが存在しませんでした")
        }
        for i in biginNum ..< delegate.restData.count {
            let appendText = AccessSentense(line: delegate.restData[i].access.line, station: delegate.restData[i].access.station, stationExit: delegate.restData[i].access.stationExit, walk: delegate.restData[i].access.walk, note: delegate.restData[i].access.note).accessText
            accessSentenses.append(appendText)
        }
        restListTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? RestDetailViewController else {
            preconditionFailure("遷移先のViewControllerを取得できませんでした")
        }
        destinationVC.accessSentense = accessSentenses[selectedIndex]
        destinationVC.receivedData = appDelegate?.restData[selectedIndex]
    }

    // MARK: - TableViewのデータ取り扱い
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate?.restData.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let restCell = tableView.dequeueReusableCell(withIdentifier: "restDataCell", for: indexPath) as? SearchedRestaurantCell else {
            preconditionFailure("dequeueReusableCellの登録に失敗しました")
        }
        guard let delegate = appDelegate else {
            preconditionFailure("cellForRow: Appdelegateが存在しませんでした")
        }

        //セルのアイテムにテキストを代入
        restCell.restNameLabel.text = delegate.restData[indexPath.row].name
        restCell.budgetLabel.text = "￥ \(delegate.restData[indexPath.row].budget)"
        restCell.prLabel.text = delegate.restData[indexPath.row].pr.prShort
        restCell.accessLabel.text = accessSentenses[indexPath.row]
        restCell.restCategoryLabel.text = delegate.restData[indexPath.row].code.categoryNameL[0]

        //NukeでImageをダウンロード
        guard let imageURL = URL(string: delegate.restData[indexPath.row].imageUrl.shopImage1) else {
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

    //残りのスクロール可能範囲が400px以下になったら再読込み
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let delegate = appDelegate else {
            preconditionFailure("Scroll: AppDelegateが存在しませんでした")
        }

        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        let restDataCount = delegate.restData.count

        if distanceToBottom < 400 && restDataCount < 1000 && loadStatus == false {
            loadStatus = true

            requestDataClass.sendRequest { (isFetched) in
                if isFetched == true {
                    self.initAccessSentense(restDataCount)
                    self.loadStatus = false
                }
            }
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
