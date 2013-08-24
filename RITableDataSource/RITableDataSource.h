//
//  RITableDataSource.h
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

#import <Foundation/Foundation.h>
#import <CoreData/NSFetchedResultsController.h>

@interface RITableDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;

@property (nonatomic, copy) void(^configureCellBlock)(UITableViewCell * cell, NSIndexPath * indexPath, id object);
@property (nonatomic, copy) NSString * (^reusableIdentifierBlock)(NSIndexPath * indexPath);

+ (instancetype)dataSourceWithFetchedResultsController:(NSFetchedResultsController *)controller;
- (id)initWithFetchedResultsController:(NSFetchedResultsController *)controller;

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;
- (UITableViewCell *)cellForObject:(id)object;

- (NSInteger)totalObjectsCount;

@end
