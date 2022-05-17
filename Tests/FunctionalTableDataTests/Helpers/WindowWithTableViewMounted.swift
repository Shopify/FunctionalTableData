import UIKit



final class WindowWithTableViewMounted {
    
	private var rootWindow: UIWindow!
	let tableView = UITableView()
	private let tableViewController : TableViewControllerWithTableViewMounted

	init() {
		self.tableViewController = TableViewControllerWithTableViewMounted(tableView)
		setUpWindowWithTableView()
		presentWindow()
	}

	private func setUpWindowWithTableView() {
		rootWindow = UIWindow(frame: UIScreen.main.bounds)
		rootWindow.rootViewController = tableViewController
	}

	private func presentWindow() {
		rootWindow.isHidden = false
		tableViewController.viewWillAppear(false)
		tableViewController.viewDidAppear(false)
	}

	func tearDownWindow() {
		tableViewController.viewWillDisappear(false)
		tableViewController.viewDidDisappear(false)
		rootWindow.rootViewController = nil
		rootWindow.isHidden = true
		self.rootWindow = nil
	}
}


private final class TableViewControllerWithTableViewMounted: UIViewController {
	let tableView : UITableView
    
	init(_ tableView: UITableView) {
		self.tableView = tableView
		super.init(nibName: nil, bundle: nil)
	}
    
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
	override func loadView() {
		super.loadView()
		setupTableView()
	}
    
	func setupTableView() {
		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
	}
}
