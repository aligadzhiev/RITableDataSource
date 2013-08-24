# RITableDataSource

UITableView data source based on NSFetchedResultsController.

```objective-c
NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
// Configure the request's entity, and optionally its predicate.
NSSortDescriptor * sortByFirstLetter = [[NSSortDescriptor alloc] initWithKey:@"firstLetter"
																   ascending:YES
																	selector:@selector(localizedCaseInsensitiveCompare:)];
NSSortDescriptor * sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
[fetchRequest setSortDescriptors:@[sortByFirstLetter, sortByName]];

NSFetchedResultsController * controller = <#Fetched results controller#>

RITableDataSource * dataSource = [RITableDataSource dataSourceWithFetchedResultsController:controller];
[dataSource setReusableIdentifierBlock:^NSString *(NSIndexPath * indexPath) {
	return <#Cell reusable identifier#>;
}];
[dataSource setConfigureCellBlock:^(UITableViewCell * cell, NSIndexPath * indexPath, id object) {
	// Configurate cell here
}];
dataSource.tableView = self.tableView;
```

## Requirements

RITableDataSource requires Xcode 4.4 with either the [iOS 5.0](http://developer.apple.com/library/ios/#releasenotes/General/WhatsNewIniPhoneOS/Articles/iOS5.html) SDK.

## Installation

[CocoaPods](http://cocoapods.org) is the recommended way to add RITableDataSource to your project.

Here's an example podfile that installs RITableDataSource. 

### Podfile

```ruby
platform :ios, '5.0'

pod 'RITableDataSource'
```

## License

RITableDataSource is available under the MIT license. See the LICENSE file for more info.

