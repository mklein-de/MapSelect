//
//  VolumeInfo.m
//  MapSelect
//
//  Created by Michael Klein on 2011-05-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VolumeInfo.h"


@implementation VolumeInfo

@synthesize volumePath;
@synthesize currentMap;
@synthesize maps;

+ (id)volumeInfoWithPath:(NSString*)p
{
    return [[[VolumeInfo alloc] initWithPath:p] autorelease];
}

- (id)initWithPath:(NSString*)p
{
    if ((self = [super init]) != nil)
    {
        [self setVolumePath:p];
        if (![self findMaps])
        {
            [self release];
            return nil;
        }
    }
    
    return self;
}

- (BOOL)findMaps
{
    NSFileManager * fm = [NSFileManager defaultManager];

    NSMutableArray *dirs = [NSMutableArray array];
    NSString * path = [volumePath stringByAppendingPathComponent:@"GARMIN"];
    NSArray * dc = [fm directoryContentsAtPath:path];

    BOOL isDir;

    if (!([fm fileExistsAtPath:path isDirectory:&isDir] && isDir))
    {
        return NO;
    }
    
    NSEnumerator * e = [dc objectEnumerator];
    NSString * o;
    BOOL gmapsupp_found = NO;
    
    NSString * current_map = nil;

    while ((o = [e nextObject]) != nil)
    {
        NSString * dir = [path stringByAppendingPathComponent:o];
 
        if ([o caseInsensitiveCompare:@"gmapsupp.img"] == NSOrderedSame)
        {
            gmapsupp_found = YES;
        }
        else if ([fm fileExistsAtPath:dir isDirectory:&isDir] && isDir)
        {
            if ([fm fileExistsAtPath:[dir stringByAppendingPathComponent:@"gmapsupp.img"]])
            {
                [dirs addObject:[NSDictionary dictionaryWithObjectsAndKeys:o, @"mapName", nil]];
            }
            else
            {
                if (current_map == nil)
                {
                    current_map = [NSString stringWithString:o];
                }
                else
                {
                    NSLog(@"skipping directory: %@", o);
                }
            }
        }
    }

    prevMap = current_map;
    
    if (gmapsupp_found)
    {
        if (current_map != nil)
        {
            [dirs addObject:[NSDictionary dictionaryWithObjectsAndKeys:current_map, @"mapName", nil]];
            [self setCurrentMap:current_map];
        }
        else
        {
            NSLog(@"no empty directory for active map");
        }
    }
    else
    {
        [self setCurrentMap:nil];
    }

    [self setMaps:dirs];
    return YES;
}

- (void)activateMap:(NSString*)map
{
    NSString * path = [volumePath stringByAppendingPathComponent:@"GARMIN"];
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error;
    
    if (prevMap != nil)
    {
        if (![fm moveItemAtPath:[path stringByAppendingPathComponent:@"gmapsupp.img"]
                         toPath:[[path stringByAppendingPathComponent:prevMap] stringByAppendingPathComponent:@"gmapsupp.img"]
                          error:&error])
        {
            [NSApp presentError:error];
            return;
        }
    }

    prevMap = map;

    if (map != nil)
    {
        if (![fm moveItemAtPath:[[path stringByAppendingPathComponent:map] stringByAppendingPathComponent:@"gmapsupp.img"]
                         toPath:[path stringByAppendingPathComponent:@"gmapsupp.img"]
                          error:&error])
        {
            [NSApp presentError:error];
        }
        else
        {
            prevMap = map;
            currentMap = map;
            return;
        }
    }

    // FIXME
    currentMap = nil;
}

@end
