import UIKit

class SearchedRestaurantCell: UITableViewCell {

    @IBOutlet weak private var restImageView: UIImageView!
    @IBOutlet weak private var restNameLabel: UILabel!
    @IBOutlet weak private var restCategoryLabel: UILabel!
    @IBOutlet weak private var accessLabel: UILabel!
    @IBOutlet weak private var openingHoursLabel: UILabel!
    @IBOutlet weak private var budgetLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
