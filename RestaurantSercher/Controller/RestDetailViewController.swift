import Nuke
import UIKit

class RestDetailViewController: UIViewController {

    @IBOutlet weak private var restImageView1: UIImageView!
    @IBOutlet weak var restImageView2: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var prLabel: UILabel!
    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var opantimeLabel: UILabel!
    @IBOutlet weak var holidayLabel: UILabel!
    @IBOutlet weak var restNameLabel: UILabel!
    
    
    

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
            restNameLabel.text = restData.name

            guard let imageURL1 = URL(string: restData.imageUrl.shopImage1) else {
                preconditionFailure("StringからURLに変換できませんでした！")
            }
            let request = ImageRequest(url: imageURL1, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFill)
            Nuke.loadImage(with: request, into: restImageView1)

        }
    }
}
