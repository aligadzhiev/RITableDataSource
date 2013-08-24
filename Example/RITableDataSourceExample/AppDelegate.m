//
//  AppDelegate.m
//  RITableDataSourceExample
//
//  Created by Ali Gadzhiev on 8/20/13.
//  Copyright (c) 2013 Ali Gadziev. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
	NSManagedObjectContext * _managedObjectContext;
	NSManagedObjectModel * _managedObjectModel;
	NSPersistentStoreCoordinator * _persistentStoreCoordinator;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

- (void)saveContext
{
    if (nil == self.managedObjectContext) return;

	NSError * error = nil;
	if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error])
	{
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}

#pragma mark - Core Data

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
	if (nil == _managedObjectContext)
	{
		NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
		if (coordinator)
		{
			_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
			[_managedObjectContext setPersistentStoreCoordinator:coordinator];
		}
	}

	return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (nil == _managedObjectModel)
	{
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (nil == _persistentStoreCoordinator)
	{
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
		
		NSError * error = nil;
		[_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
												  configuration:nil
															URL:nil
														options:nil
														  error:&error];
		
		if (error)
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
