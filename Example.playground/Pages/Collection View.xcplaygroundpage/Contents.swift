import UIKit
import PlaygroundSupport
import FunctionalTableData

class ExampleViewController: UICollectionViewController {
	private let functionalData = FunctionalCollectionData()
	private var items: [String] = [] {
		didSet {
			render()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView?.backgroundColor = .white
		functionalData.collectionView = collectionView
		title = "Example"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didSelectAdd))
	}
	
	@objc private func didSelectAdd() {
		items.append("\(Int(arc4random_uniform(1500)+1))")
	}
	
	private func render() {
		let rows: [CellConfigType] = items.enumerated().map { index, item in
			return LabelCell(
				key: "id-\(index)",
				style: CellStyle(backgroundColor: .lightGray),
				state: LabelState(text: item),
				cellUpdater: LabelState.updateView)
		}
		
		functionalData.renderAndDiff([
			TableSection(key: "section", rows: rows)
			])
	}
}

// Create a layout, this is the key part when dealing with UICollectionView.
let layout = UICollectionViewFlowLayout()
layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize

// Present the view controller in the Live View window
let liveController = UINavigationController(rootViewController: ExampleViewController(collectionViewLayout: layout))
liveController.preferredContentSize = CGSize(width: 320, height: 420)
PlaygroundPage.current.liveView = liveController
