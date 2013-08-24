//
//  RITableViewDataSource.m
//
//  Copyright (c) 2013 Ali Gadzhiev
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RITableDataSource.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "RITableDataSource requires ARC support"
#endif

@interface RITableDataSource ()

@property (nonatomic, strong) NSMutableDictionary * registredCellClasses;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation RITableDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype)dataSourceWithFetchedResultsController:(NSFetchedResultsController *)fetchedResults
{
	return [[[self class] alloc] initWithFetchedResultsController:fetchedResults];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
	self.tableView.dataSource = nil;
	self.fetchedResultsController.delegate = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
	self = [super init];
	if (self)
	{
		self.registredCellClasses = [NSMutableDictionary dictionary];
	}
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResults
{
    self = [self init];
    if (self)
    {
        self.fetchedResults = fetchedResults;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFetchedResults:(NSFetchedResultsController *)fetchedResults
{
	if (fetchedResults == _fetchedResultsController) return;
    
	_fetchedResultsController.delegate = nil;
	_fetchedResultsController = fetchedResults;
	_fetchedResultsController.delegate = self;
	[self.tableView reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTableView:(UITableView *)tableView
{
	if (tableView == _tableView) return;
    
	_tableView.dataSource = nil;
	_tableView = tableView;
	_tableView.dataSource = self;
	[_tableView reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
	NSParameterAssert(cellClass);
	NSParameterAssert(identifier);
	[self.registredCellClasses setObject:cellClass forKey:identifier];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexPath *)indexPathForObject:(id)object
{
	return [self.fetchedResultsController indexPathForObject:object];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)cellForObject:(id)object
{
	return [self.tableView cellForRowAtIndexPath:[self indexPathForObject:object]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)totalObjectsCount
{
	return [[self.fetchedResultsController fetchedObjects] count];
}

#pragma mark - Table view data source

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray * sections = [self.fetchedResultsController sections];
	if ([sections count] == 0)
	{
		return 0;
	}
	
	id<NSFetchedResultsSectionInfo> sectionInfo = sections[section];
	return [sectionInfo numberOfObjects];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString * identifier = nil;
	if (self.reusableIdentifierBlock)
    {
		identifier = self.reusableIdentifierBlock(indexPath);
	}
	
	Class cellClass = [self.registredCellClasses objectForKey:identifier];
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell)
	{
		cell = [(UITableViewCell *)[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	
	if (self.configureCellBlock)
    {
		self.configureCellBlock(cell, indexPath, [self objectAtIndexPath:indexPath]);
	}
	return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSArray * sections = [self.fetchedResultsController sections];
	if ([sections count] == 0)
	{
		return 0;
	}
	
	id<NSFetchedResultsSectionInfo> sectionInfo = sections[section];
	return [sectionInfo name];
}

#pragma mark - Fetched results controller delegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView beginUpdates];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
	switch (type)
    {
		case NSFetchedResultsChangeInsert:
        {
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
			break;
		}
			
		case NSFetchedResultsChangeDelete:
        {
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
			break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	switch (type)
	{
		case NSFetchedResultsChangeInsert:
        {
			[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
			break;
		}
		case NSFetchedResultsChangeDelete:
        {
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
			break;
		}
		case NSFetchedResultsChangeMove:
        {
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
			[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
			break;
		}
		case NSFetchedResultsChangeUpdate:
        {
			[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
			break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView endUpdates];
}

@end
