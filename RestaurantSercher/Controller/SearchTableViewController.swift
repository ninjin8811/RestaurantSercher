import UIKit

class SearchTableViewController: UITableViewController {

    @IBOutlet private var restListTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        restListTableView.register(UINib(nibName: "SearchedRestaurantCell", bundle: nil), forCellReuseIdentifier: "restDataCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let restCell = tableView.dequeueReusableCell(withIdentifier: "restDataCell", for: indexPath) as? SearchedRestaurantCell else {
            preconditionFailure("dequeueReusableCellの登録に失敗しました")
        }

        return restCell
    }

}
