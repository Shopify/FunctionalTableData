#
#  Be sure to run `pod spec lint FunctionalTableData.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "FunctionalTableData"
  s.version      = "1.0.0"
  s.summary      = "Declarative UITableViewDataSource implementation."
  s.description  = <<-DESC
                  Functional Table Data implements a functional renderer for UITableView. You pass it a complete description of your table state, and Functional Table Data compares it with the previous render call to insert, update, and remove the sections and cells that have changed. This massively simplifies state management of complex UI.

                  No longer do you have to manually track the number of sections, cells, and indices of your UI. Build one method that generates your table state structure from your data. The provided HostCell generic makes it easy to add FunctionalTableData support to UITableViewCells.
                  DESC

  s.homepage     = "https://github.com/Shopify/FunctionalTableData/"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license      = "MIT"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author             = { "Shopify" => "opensource@shopify.com" }
  s.social_media_url   = "http://twitter.com/Shopify"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.platform     = :ios

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source = { :git => "https://github.com/Shopify/FunctionalTableData.git", :tag => s.version.to_s }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = 'FunctionalTableData/*.swift'
end
