//
//  TableViewController.m
//  RITableDataSourceExample
//
//  Created by Ali Gadzhiev on 8/24/13.
//  Copyright (c) 2013 Ali Gadziev. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "TableViewController.h"

#import "AppDelegate.h"

#import "RITableDataSource.h"

#import "Contact.h"

@interface TableViewController ()

@property (nonatomic, strong) ACAccount * twitterAccount;
@property (nonatomic, strong) ACAccountStore * accountStore;
@property (nonatomic, strong) RITableDataSource * dataSource;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TableViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext * context = [appDelegate managedObjectContext];
	
	NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
	// Configure the request's entity, and optionally its predicate.
	NSSortDescriptor * sortByFirstLetter = [[NSSortDescriptor alloc] initWithKey:@"firstLetter"
																	   ascending:YES
																		selector:@selector(localizedCaseInsensitiveCompare:)];
	NSSortDescriptor * sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[fetchRequest setSortDescriptors:@[sortByFirstLetter, sortByName]];
	
	NSFetchedResultsController * controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																				  managedObjectContext:context
																					sectionNameKeyPath:@"firstLetter"
																							 cacheName:nil];
	NSError * error;
	BOOL success = [controller performFetch:&error];
	if (!success)
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	RITableDataSource * dataSource = [RITableDataSource dataSourceWithFetchedResultsController:controller];
	[dataSource setReusableIdentifierBlock:^NSString *(NSIndexPath * indexPath) {
		return @"Cell";
	}];
	[dataSource setConfigureCellBlock:^(UITableViewCell * cell, NSIndexPath * indexPath, Contact * contact) {
		cell.textLabel.text = contact.name;
	}];
	self.dataSource = dataSource;
	self.dataSource.tableView = self.tableView;
	
	[self requestMyFollowers];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (ACAccountStore *)accountStore
{
	if (nil == _accountStore)
	{
		_accountStore = [[ACAccountStore alloc] init];
	}
	return _accountStore;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)userHasAccessToTwitter
{
	return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestAccessToTwitterAccount:(void(^)(NSError * error))completionBlock
{
	if (self.twitterAccount)
	{
		if (completionBlock)
		{
			completionBlock(nil);
		}
		return;
	}
	
	//  Step 1:  Obtain access to the user's Twitter accounts
	ACAccountType * twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	[self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
		if (granted)
		{
			//  Step 2:  Create a request
			NSArray * twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
			self.twitterAccount = [twitterAccounts lastObject];
		}
		
		if (completionBlock)
		{
			completionBlock(error);
		}
	}];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestMyFollowers
{
	//  Step 0: Check that the user has local Twitter accounts
	if (NO == [self userHasAccessToTwitter]) return;
	
	[self requestAccessToTwitterAccount:^(NSError *error) {
		if (nil == error)
		{
			NSURL * url = [NSURL URLWithString:@"https://api.twitter.com"
						   @"/1.1/friends/list.json"];
			NSDictionary * parameters = @{@"screen_name" : [self.twitterAccount username],
										  @"cursor" : @"-1",
										  @"skip_status" : @"1",
										  @"include_user_entities" : @"0"};
			SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeTwitter
													 requestMethod:SLRequestMethodGET
															   URL:url
														parameters:parameters];
			
			//  Attach an account to the request
			[request setAccount:self.twitterAccount];
			
			//  Step 3:  Execute the request
			[request performRequestWithHandler:^(NSData * responseData, NSHTTPURLResponse * urlResponse, NSError * error) {
				if (responseData)
				{
					if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300)
					{
						NSManagedObjectContext * defaultContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
						NSManagedObjectContext * context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
						[context setParentContext:defaultContext];
						[context performBlock:^{
							NSError * error;
							NSDictionary * responseInfo = [NSJSONSerialization JSONObjectWithData:responseData
																						  options:NSJSONReadingAllowFragments
																							error:&error];
							
							if (responseInfo)
							{
								NSArray * users = responseInfo[@"users"];
								[users enumerateObjectsUsingBlock:^(NSDictionary * userInfo, NSUInteger idx, BOOL *stop) {
									Contact * contact = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact"
																								 inManagedObjectContext:context];
									contact.name = userInfo[@"name"];
								}];
							}
							else
							{
								// Our JSON deserialization went awry
								NSLog(@"JSON Error: %@", [error localizedDescription]);
							}
							
							if ([context hasChanges])
							{
								if ([context save:nil])
								{
									[defaultContext performBlock:^{
										[defaultContext save:nil];
									}];
								}
							}
						}];
					}
					else
					{
						// The server did not respond successfully... were we rate-limited?
						NSLog(@"The response status code is %d", urlResponse.statusCode);
					}
				}
			}];
		}
	}];
}

@end
