//
//  Contact.m
//  RITableDataSourceExample
//
//  Created by Ali Gadzhiev on 8/24/13.
//  Copyright (c) 2013 Ali Gadziev. All rights reserved.
//

#import "Contact.h"


@implementation Contact

@dynamic name;
@dynamic firstLetter;

- (void)setName:(NSString *)name
{
	self.firstLetter = [name length] > 0 ? [[name substringToIndex:1] uppercaseString] : nil;
	[self willChangeValueForKey:@"name"];
	[self setPrimitiveValue:name forKey:@"name"];
	[self didChangeValueForKey:@"name"];
}

@end
