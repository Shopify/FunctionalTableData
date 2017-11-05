import UIKit
import FunctionalTableData

public final class FunctionalCollectionViewController: UIViewController {
	public var layout: UICollectionViewLayout
	public let functionalData = FunctionalCollectionData()
	
	public required init(layout: UICollectionViewLayout) {
		self.layout = layout
		super.init(nibName: nil, bundle: nil)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .white
		
		functionalData.collectionView = collectionView
		view = collectionView
	}
}

public final class FunctionalTableViewController: UIViewController {
	public let functionalData = FunctionalTableData()
	
	public override func loadView() {
		let tableView = UITableView(frame: .zero, style: .plain)
		functionalData.tableView = tableView
		view = tableView
	}
}

