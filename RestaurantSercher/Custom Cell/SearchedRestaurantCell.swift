import UIKit

class SearchedRestaurantCell: UITableViewCell {

    @IBOutlet weak var restImageView: UIImageView!
    @IBOutlet weak var restNameLabel: UILabel!
    @IBOutlet weak var restCategoryLabel: UILabel!
    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var prLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
