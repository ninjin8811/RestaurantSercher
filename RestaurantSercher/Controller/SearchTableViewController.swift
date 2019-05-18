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

    let gnaviURL = "https://api.gnavi.co.jp/RestSearchAPI/v3/"
    let accessKey = "bd585b21652351d6773c345c0266dcab"
    var requestDataClass = RequestData()

    var selectedIndex = 0
    var loadStatus = false
    var accessSentenses = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        hitCountLabel.text = "\(requestDataClass.totalHit)件見つかりました"
        restListTableView.register(UINib(nibName: "SearchedRestaurantCell", bundle: nil), forCellReuseIdentifier: "restDataCell")
        initAccessSentense(0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //詳細画面から戻ってきたときに参照していたセルを選択解除する
        restListTableView.indexPathsForSelectedRows?.forEach({ (indexPath) in
            restListTableView.deselectRow(at: indexPath, animated: true)
        })
    }

    //アクセスの文章を取得したデータを繋ぎ合わせて作成
    func initAccessSentense(_ biginNum: Int) {
        for i in biginNum ..< requestDataClass.restData.count {
            let appendText = AccessSentense(
                line: requestDataClass.restData[i].access.line,
                station: requestDataClass.restData[i].access.station,
                stationExit: requestDataClass.restData[i].access.stationExit,
                walk: requestDataClass.restData[i].access.walk,
                note: requestDataClass.restData[i].access.note).accessText
            accessSentenses.append(appendText)
        }
        restListTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? RestDetailViewController else {
            preconditionFailure("遷移先のViewControllerを取得できませんでした")
        }
        destinationVC.accessSentense = accessSentenses[selectedIndex]
        destinationVC.receivedData = requestDataClass.restData[selectedIndex]
    }

    // MARK: - TableViewのデータ取り扱い
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestDataClass.restData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let restCell = tableView.dequeueReusableCell(withIdentifier: "restDataCell", for: indexPath) as? SearchedRestaurantCell else {
            preconditionFailure("dequeueReusableCellの登録に失敗しました")
        }
        //セルのアイテムにテキストを代入
        restCell.restNameLabel.text = requestDataClass.restData[indexPath.row].name
        restCell.budgetLabel.text = "￥ \(requestDataClass.restData[indexPath.row].budget)"
        restCell.prLabel.text = requestDataClass.restData[indexPath.row].pr.prShort
        restCell.accessLabel.text = accessSentenses[indexPath.row]
        restCell.restCategoryLabel.text = requestDataClass.restData[indexPath.row].code.categoryNameL[0]

        //NukeでImageをダウンロード
        if let imageURL = URL(string: requestDataClass.restData[indexPath.row].imageUrl.shopImage1) {
            let request = ImageRequest(url: imageURL, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill)
            Nuke.loadImage(with: request, into: restCell.restImageView)
        } else {
            restCell.restImageView.image = UIImage(named: "no-image")
        }

        return restCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row

        performSegue(withIdentifier: "goToRestDetail", sender: self)
    }

    //一番下のセルまでスクロールしたら再読込み
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        let restDataCount = requestDataClass.restData.count

        if distanceToBottom <= 0 && restDataCount < 1000 && loadStatus == false {
            loadStatus = true

            //オフセットを設定して追加のデータを読み込み
            requestDataClass.offset = restDataCount + 1
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
