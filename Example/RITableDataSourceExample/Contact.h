//
//  Contact.h
//  RITableDataSourceExample
//
//  Created by Ali Gadzhiev on 8/24/13.
//  Copyright (c) 2013 Ali Gadziev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * firstLetter;

@end
