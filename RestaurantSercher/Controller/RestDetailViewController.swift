import Nuke
import UIKit

class RestDetailViewController: UIViewController {

    @IBOutlet weak private var categoryLabel: UILabel!
    @IBOutlet weak private var budgetLabel: UILabel!
    @IBOutlet weak private var restNameLabel: UILabel!
    @IBOutlet weak private var accessLabel: UILabel!
    @IBOutlet weak private var opentimeLabel: UILabel!
    @IBOutlet weak private var holidayLabel: UILabel!
    @IBOutlet weak private var urlButton: UIButton!
    @IBOutlet weak private var restImageView1: UIImageView!
    @IBOutlet weak private var restImageView2: UIImageView!
    @IBOutlet weak private var addressLabel: UILabel!
    @IBOutlet weak private var callButton: UIButton!

    var accessSentense = ""
    var receivedData: Restaurant?

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

        setContents()
    }

    func setContents() {
        if let restData = receivedData {
            guard let imageURL1 = URL(string: restData.imageUrl.shopImage1) else {
                preconditionFailure("StringからURLに変換できませんでした！")
            }
            guard let imageURL2 = URL(string: restData.imageUrl.shopImage2) else {
                preconditionFailure("StringからURLに変換できませんでした！")
            }
            let request1 = ImageRequest(url: imageURL1, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill)
            let request2 = ImageRequest(url: imageURL2, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill)
            Nuke.loadImage(with: request1, into: restImageView1)
            Nuke.loadImage(with: request2, into: restImageView2)

            restNameLabel.text = restData.name
            addressLabel.text = restData.address
            categoryLabel.text = restData.code.categoryNameL[0]
            budgetLabel.text = "￥ \(restData.budget)"
            accessLabel.text = accessSentense
            opentimeLabel.text = restData.opentime
            holidayLabel.text = restData.holiday
            callButton.titleLabel?.text = restData.tel
            urlButton.titleLabel?.text = restData.url
        }
    }

    @IBAction func callButtonPressed(_ sender: UIButton) { //info.plistに許可を書く

        if let url = receivedData?.url {
            guard let openUrl = URL(string: url) else {
                preconditionFailure("レストランページのURLを変換できませんでした")
            }
            UIApplication.shared.open(openUrl)
        }
    }

    @IBAction func urlButtonPressed(_ sender: UIButton) { //info.plistに許可が必要かもしれない

        if let num = receivedData?.tel {
            var connectedNum = ""
            let splitNum = num.components(separatedBy: "-")
            for item in splitNum {
                connectedNum += item
            }

            guard let callUrl = URL(string: "tel://\(connectedNum)") else {
                preconditionFailure("電話番号をURLに変換できませんでした")
            }
            UIApplication.shared.open(callUrl)
        }
    }
}
