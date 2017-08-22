<img src="/Images/Banner.png" />

Functional Table Data takes a complete, idempotent description of your table state, compares it with the previous render call to compute which cells have changed, and updates the UITableView. Table state is declared in an idempotent and functional manner, simplifying state management of complex UI.

Instead of trying to build many different UITableViewCells and implement a UITableView(DataSource|Delegate) for each view that then needs to understand all possible state transformations, FunctionalTableData provides a system that lets you express this as a series of states describing the cells themselves.

|         | Noteworthy features       |
----------|---------------------
💯 | Functional approach for maintaining table state
👷‍ | Reusable views and states
✅ | Snapshot and Unit tests
🔀 | Automatic diff in your states
❤️ | Used across Shopify's iOS apps
🙅 | No more IndexPath bookkeeping

## Installation

### Manual

Simply drag and drop the `FunctionalTableData/FunctionalTableData` folder into your Xcode project.

### CocoaPods

Add the following to your `Podfile`:

```ruby
use_frameworks!
pod "FunctionalTableData"
```

### Carthage

Add the following to your `Cartfile`:

```ruby
github "Shopify/FunctionalTableData"
```

## Getting started

### Configure the UITableView

To use the Functional Table Data (FTD) you need an instance of UITableView, and an instance of FunctionalTableData. Once both are available, typically in a view controller's `viewDidLoad`, they are connected together using
`functionalTableData.tableView = myTableViewInstance`. After this, every time we want to display/update the data we simply call `functionalTableData.renderAndDiff(sections)`.

Here's a complete example:
```swift
class MyViewController : UITableViewController {
  let functionalTableData = new FunctionalTableData()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    functionalTableData.tableView = tableView
  }
}
```

### Build Table Cells

FunctionalTableData holds UITableView cells that conform to the CellConfigType protocol.  The CellConfigType protocol provides a bit of additional functionality to the cells:
- The cells are backed by a state object.  A cell's state must conform to Equatable so FunctionalTableData can update the cell  when the cell's state has changed.
- a method must exist that takes the cell's state, and updates the UI.

Included in FunctionalTableData is a generic helper called `HostCell`.  `HostCell` is a UITableViewCell that accepts a UIView, state object, and a field to determine if the HostCell should honor LayoutMargins or not.

```swift
/// The simplest possible version of a cell that displays a label. Useful to get started, but in most cases a more robust state should be used allowing more customization.
typealias LabelCell = HostCell<UILabel, String, LayoutMarginsTableItemLayout>
```

Developers can otherwise build their own UITableViewCells directly and conform to the `CellConfigType` protocol to use them directly with FunctionalTableData.

### Declare the Table State

Any time you want to update the data currently being displayed you generate the new table state and pass it off to your instance of the FunctionalTableData. FunctionalTableData will compute the differences between the previous table state and the new state, and updating itself as necessary.

The Table state is made up of many sections.  The sections need a unique `key`.  FunctionalTableData uses the key to detect when sections or rows are added, removed, or reordered within the table.  

Each section contains a series of rows where each row value must conform to the `CellConfigType` protocol.  Each row also needs a key that is unique within the row's section.

Each row is also given an instance of that Cell's state.  When a row's state changes between subsequent calls to `renderAndDiff`, FunctionalTableData will update the row.

Here is a declaration of a simple table:

```swift
let section = TableSection(
  key: "header-unique-key", 
  rows: [
	LabelCell(key: "company", state: "Shopify") { view, state in
		view.text = state
	},
	LabelCell(key: "location", state: "🇨🇦") { view, state in
		view.text = state
	}
  ])
```

## Render the Table

After building the table state, all that is needed to display the data in the table view is this method.

```swift
functionalTableData.renderAndDiff([section])
```

<img src="/Images/Example1.png" />

Check out the [example project](/Examples/) for more examples.

### Building new Cells
Knowing that a cell consists of a view and state let's start with a simple example, a cell that displays a label. By specifying the generic requirements of `HostCell`, the simplest possible example is one that takes an `UILabel` as its view, a `String` as its state and `LayoutMarginsTableItemLayout` as the layout (See `TableItemLayout` for more info).

```swift
typealias LabelCell = HostCell<UILabel, String, LayoutMarginsTableItemLayout>

// Usage
LabelCell(key: "company", state: "Shopify") { view, state in
	view.text = state
}
```

Although, the previous code is very useful to get started, in most cases a more robust state should be used allowing more customization. A better example would be something like this

```swift
typealias LabelCell = HostCell<UILabel, LabelState, LayoutMarginsTableItemLayout>

struct LabelState: Equatable {
	let text: String
	let alignment: NSTextAlignment
	let color: UIColor

	static func ==(lhs: LabelState, rhs: LabelState) -> Bool {
		return lhs.text == rhs.text && lhs.alignment == rhs.alignment && lhs.color == rhs.color
	}
}

// Usage
LabelCell(key: "company", state: LabelState(text: "Shopify",
                                            alignment: .center,
                                            color: .green)) { view, state in
	guard let state = state else {
		// If the state is `nil`, prepare this view to be reused
		view.text = ""
		view.textAlignment = .natural
		view.textColor = .black
		return
	}
	view.text = state.text
	view.textAlignment = state.alignment
	view.textColor = state.color
}
```

At the end of the day `HostCell` is just one of the possible implementations of `CellConfigType`, that's the underlying power of this framework.

## License
Functional Table Data is under the [MIT License](/LICENSE.txt)
