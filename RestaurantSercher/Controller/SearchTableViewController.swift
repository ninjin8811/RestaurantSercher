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

    var selectedIndex = 0
    var hitCount = 0
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

        hitCountLabel.text = "\(hitCount)件見つかりました"
        restListTableView.register(UINib(nibName: "SearchedRestaurantCell", bundle: nil), forCellReuseIdentifier: "restDataCell")
        initAccessSentense()
    }

    func initAccessSentense() {
        for i in 0 ..< restaurants.count {
            let appendText = AccessSentense(line: restaurants[i].access.line, station: restaurants[i].access.station, stationExit: restaurants[i].access.stationExit, walk: restaurants[i].access.walk, note: restaurants[i].access.note).accessText
            accessSentenses.append(appendText)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? RestDetailViewController else {
            preconditionFailure("遷移先のViewControllerを取得できませんでした")
        }
        destinationVC.accessSentense = accessSentenses[selectedIndex]
        destinationVC.receivedData = restaurants[selectedIndex]
    }

    // MARK: - Table view data source

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

        restCell.restNameLabel.text = restaurants[indexPath.row].name
        restCell.budgetLabel.text = "￥ \(restaurants[indexPath.row].budget)"
        restCell.prLabel.text = restaurants[indexPath.row].pr.prShort
        restCell.accessLabel.text = accessSentenses[indexPath.row]
        restCell.restCategoryLabel.text = restaurants[indexPath.row].code.categoryNameL[0]

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
}
