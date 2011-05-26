//
//  VolumeInfo.h
//  MapSelect
//
//  Created by Michael Klein on 2011-05-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface VolumeInfo : NSObject {
    NSString * volumePath;
    NSString * currentMap;
    NSArray * maps;

    NSString * prevMap;
}

- (id)initWithPath:(NSString*)p;
- (BOOL)findMaps;
- (void)activateMap:(NSString*)map;

+ (id)volumeInfoWithPath:(NSString*)p;

@property(copy) NSString * volumePath;
@property(copy) NSString * currentMap;
@property(copy) NSArray * maps;

@end
