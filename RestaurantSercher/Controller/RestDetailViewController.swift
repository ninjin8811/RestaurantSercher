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

        setContents()
    }

    func setContents() {
        if let restData = receivedData {
            if let imageURL1 = URL(string: restData.imageUrl.shopImage1) {
                let request1 = ImageRequest(url: imageURL1, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill)
                Nuke.loadImage(with: request1, into: restImageView1)
            } else {
                restImageView1.image = UIImage(named: "no-image")
            }
            if let imageURL2 = URL(string: restData.imageUrl.shopImage2) {
                let request2 = ImageRequest(url: imageURL2, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill)
                Nuke.loadImage(with: request2, into: restImageView2)
            } else {
                restImageView2.image = UIImage(named: "no-image")
            }

            restNameLabel.text = restData.name
            addressLabel.text = restData.address
            categoryLabel.text = restData.code.categoryNameL[0]
            budgetLabel.text = "￥ \(restData.budget)"
            accessLabel.text = "アクセス: \(accessSentense)"
            opentimeLabel.text = "営業時間: \(restData.opentime)"
            holidayLabel.text = "定休日: \(restData.holiday)"
            callButton.setTitle(restData.tel, for: .normal)
        }
    }

    @IBAction func callButtonPressed(_ sender: UIButton) { //info.plistの許可が必要かもしれない
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

    @IBAction func urlButtonPressed(_ sender: UIButton) { //info.plistに許可を書く
        if let url = receivedData?.url {
            guard let openUrl = URL(string: url) else {
                preconditionFailure("レストランページのURLを変換できませんでした")
            }
            UIApplication.shared.open(openUrl)
        }
    }
}
