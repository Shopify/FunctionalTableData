import UIKit
import PlaygroundSupport
import FunctionalTableData

class ExampleViewController: UITableViewController {
	private let functionalData = FunctionalTableData()
	private var items: [CellConfigType] = [] {
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
		let item = LabelCell(
			key: "id-\(items.count)",
			state: LabelState(text: NSDate().description),
			cellUpdater: LabelState.updateView)
		
		items.append(item)
	}
	
	private func render() {
		functionalData.renderAndDiff([
			TableSection(key: "section", rows: items)
		])
	}
}

// Present the view controller in the Live View window
let liveController = UINavigationController(rootViewController: ExampleViewController())
liveController.preferredContentSize = CGSize(width: 320, height: 420)
PlaygroundPage.current.liveView = liveController
