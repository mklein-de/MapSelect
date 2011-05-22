//
//  MapArrayController.m
//  MapSelect
//
//  Created by Michael Klein on 2011-05-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapArrayController.h"


@implementation MapArrayController

- (void)setNilValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"selectionIndex"])
    {
        [self setSelectionIndex:NSNotFound];
    }
    else
    {
        [super setNilValueForKey:key];
    }
}

@end
