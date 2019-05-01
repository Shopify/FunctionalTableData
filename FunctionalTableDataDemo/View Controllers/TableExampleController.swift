//
//  TableExampleController.swift
//  FunctionalTableDataDemo
//
//  Created by Kevin Barnes on 2018-04-20.
//  Copyright © 2018 Shopify. All rights reserved.
//

import UIKit
import FunctionalTableData

class TableExampleController: UITableViewController {
	private let functionalData = FunctionalTableData()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		functionalData.tableView = tableView
		title = "Example View"
		view.backgroundColor = .groupTableViewBackground
		render()
	}
	
	private func render() {
		functionalData.renderAndDiff([
			userTableSection(key: "user.section"),
			spacerSection(key: "spacer.user"),
			networkSection(key: "network.section"),
			spacerSection(key: "spacer.network"),
			resetSection(key: "reset.section"),
		])
	}
	
	private func userTableSection(key: String) -> TableSection {
		typealias ImageSubtitleCell = HostCell<CombinedView<UIImageView, SubtitleView>, CombinedState<ImageState, SubtitleState>, LayoutMarginsTableItemLayout>
		
		let title = ControlText.attributed(NSAttributedString(string: "Shopify Inc.", attributes: [
			NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .medium)
		]))
		let subtitle = ControlText.attributed(NSAttributedString(string: "Build your business. You’ve got the will. We’ve got the way.", attributes: [
			NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular),
			NSAttributedString.Key.foregroundColor: UIColor.darkGray
		]))
		
		let imageState = ImageState(image: UIImage(named: "logo")!, width: 58, height: 58)
		let subtitleState = SubtitleState(title: title, subtitle: subtitle)

		let rows: [CellConfigType] = [
			ImageSubtitleCell(key: "user.row", style: CellStyle(accessoryType: .disclosureIndicator), state: CombinedState(state1: imageState, state2: subtitleState), cellUpdater: { view, state in
				view.stackView.spacing = 16
				
				ImageState.updateView(view.view1, state: state?.state1)
				SubtitleState.updateView(view.view2, state: state?.state2)
			})
		]
		return TableSection(key: key, rows: rows, style: SectionStyle(separators: .topAndBottom))
	}
	
	private func spacerSection(key: String) -> TableSection {
		return TableSection(key: key, rows: [
			SpacerCell(key: "spacer", style: CellStyle(backgroundColor: .clear), state: SpacerState(height: CGFloat(22.0)), cellUpdater: SpacerState.updateView)
		])
	}
	
	private func networkSection(key: String) -> TableSection {
		let airplaneLabelState = LabelState(text: .plain("Airplane mode"))
		let airplaneSwitchState = SwitchState(isOn: false) { _ in }
		
		typealias SubtitleSwitchCell = HostCell<CombinedView<SubtitleView, UISwitch>, CombinedState<SubtitleState, SwitchState>, LayoutMarginsTableItemLayout>
		
		let title = ControlText.attributed(NSAttributedString(string: "Safari App", attributes: [
			NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)
			]))
		let subtitle = ControlText.attributed(NSAttributedString(string: "365 MB.", attributes: [
			NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular),
			NSAttributedString.Key.foregroundColor: UIColor.darkGray
		]))
		
		let exampleAppSubtitleState = SubtitleState(title: title, subtitle: subtitle)
		let exampleAppSwitchState = SwitchState(isOn: true) { _ in }
		
		let rows: [CellConfigType] = [
			SwitchCell(key: "airplane.mode", state: CombinedState(state1: airplaneLabelState, state2: airplaneSwitchState), cellUpdater: { (view, state) in
				LabelState.updateView(view.view1, state: state?.state1)
				SwitchState.updateView(view.view2, state: state?.state2)
			}),
			SubtitleSwitchCell(key: "example.app", state: CombinedState(state1: exampleAppSubtitleState, state2: exampleAppSwitchState), cellUpdater: { (view, state) in
				SubtitleState.updateView(view.view1, state: state?.state1)
				SwitchState.updateView(view.view2, state: state?.state2)
			})
		]
		return TableSection(key: key, rows: rows, style: SectionStyle(separators: .default))
	}
	
	private func resetSection(key: String) -> TableSection {
		let rows: [CellConfigType] = [
			ButtonCell(key: "all.settings", state: ButtonState(title: "Reset All Settings", alignment: .left, action: { _ in }), cellUpdater: ButtonState.updateView),
			ButtonCell(key: "all.content.settings", state: ButtonState(title: "Reset All Content and Settings", alignment: .left, action: { _ in }), cellUpdater: ButtonState.updateView),
		]
		return TableSection(key: key, rows: rows, style: SectionStyle(separators: .default))
	}
}

