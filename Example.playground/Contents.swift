import UIKit
import PlaygroundSupport
import FunctionalTableData

class ExampleViewController: UITableViewController {
	private let functionalData = FunctionalTableData()
	private var items: [String] = [] {
		didSet {
			render()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		functionalData.tableView = tableView
		title = "Example"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didSelectAdd))
	}
	
	@objc private func didSelectAdd() {
		items.append(NSDate().description)
	}
	
	private func render() {
		let rows: [CellConfigType] = items.enumerated().map { index, item in
			return LabelCell(
				key: "id-\(index)",
				state: LabelState(text: item),
				cellUpdater: LabelState.updateView)
		}
		
		functionalData.renderAndDiff([
			TableSection(key: "section", rows: rows)
		])
	}
}

// Present the view controller in the Live View window
let liveController = UINavigationController(rootViewController: ExampleViewController())
liveController.preferredContentSize = CGSize(width: 320, height: 420)
PlaygroundPage.current.liveView = liveController
