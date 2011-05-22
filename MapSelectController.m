//
//  MapSelectController.m
//  MapSelect
//
//  Created by Michael Klein on 2011-05-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapSelectController.h"


@implementation MapSelectController

- (void)volumesDidChangeNotification:(NSNotification*)notification
{
    [self updateVolumes:nil];
}

- (void)awakeFromNib
{
    NSNotificationCenter * nc = [[NSWorkspace sharedWorkspace] notificationCenter];

    [nc addObserver:self 
           selector:@selector(volumesDidChangeNotification:)
               name:NSWorkspaceDidMountNotification
             object:nil];

    [nc addObserver:self 
           selector:@selector(volumesDidChangeNotification:)
               name:NSWorkspaceDidUnmountNotification
             object:nil];
    
    [self updateVolumes:nil];
}


- (IBAction)updateVolumes:(id)sender
{
    NSArray * volumes = [[NSWorkspace sharedWorkspace] mountedRemovableMedia];
    [volumesController setContent:volumes];
    [self updateMaps:self];
}

- (IBAction)updateMaps:(id)sender
{
    NSInteger selection_index = [volumesController selectionIndex];
    NSMutableArray *dirs = [NSMutableArray array];

    if (selection_index == INT_MAX)
    {
        [mapsController setContent:dirs];
        return;
    }
    
    NSString * volume = [volumesController valueForKeyPath:@"selection.self"];
    NSString * path = [volume stringByAppendingPathComponent:@"GARMIN"];
    NSFileManager * fm = [NSFileManager defaultManager];

    NSArray * dc = [fm directoryContentsAtPath:path];
    
    NSEnumerator * e = [dc objectEnumerator];
    NSString * o;
    BOOL gmapsupp_found = NO;
    
    activeMap = nil;
    
    while ((o = [e nextObject]) != nil)
    {
        BOOL isDir;
        NSString * dir = [path stringByAppendingPathComponent:o];
 
        if ([o caseInsensitiveCompare:@"gmapsupp.img"] == NSOrderedSame)
        {
            gmapsupp_found = YES;
        }
        else if ([fm fileExistsAtPath:dir isDirectory:&isDir] && isDir)
        {
            if ([fm fileExistsAtPath:[dir stringByAppendingPathComponent:@"gmapsupp.img"]])
            {
                [dirs addObject:o];
            }
            else
            {
                if (activeMap == nil)
                {
                    activeMap = [NSString stringWithString:o];
                }
                else
                {
                    NSLog(@"skipping directory: %@", o);
                }
            }
        }
    }
    
    NSInteger selected_index;
    
    [dirs sortUsingSelector:@selector(caseInsensitiveCompare:)];

    if (gmapsupp_found)
    {
        if (activeMap != nil)
        {
            [dirs addObject:activeMap];
            [dirs sortUsingSelector:@selector(caseInsensitiveCompare:)];
            
            selected_index = [dirs indexOfObject:activeMap];
        }
        else
        {
            NSLog(@"no empty directory for active map");
        }
    }
    else
    {
        [mapsController setSelectionIndex:-1];
        selected_index = INT_MAX;
        if (activeMap != nil)
        {
            NSLog(@"skipping directory: %@", activeMap);
            activeMap = nil;
        }
    }
    
    [mapsController setContent:dirs];
    [mapsController setSelectionIndex:selected_index];
}

- (IBAction)ejectVolume:(id)sender
{
    NSString * volume = [volumesController valueForKeyPath:@"selection.self"];
    [[NSWorkspace sharedWorkspace] unmountAndEjectDeviceAtPath:volume];
}

- (IBAction)activateMap:(id)sender
{
    NSString * volume = [volumesController valueForKeyPath:@"selection.self"];
    NSString * map = [mapsController valueForKeyPath:@"selection.self"];
    NSInteger selection_index = [mapsController selectionIndex];
    
    NSLog(@"activate %@ (%d)", map, selection_index);
    
    if (selection_index != INT_MAX && [map isEqualToString:activeMap])
    {
        return;
    }
    
    NSString * path = [volume stringByAppendingPathComponent:@"GARMIN"];
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error;
    
    if (activeMap != nil)
    {
        if (![fm moveItemAtPath:[path stringByAppendingPathComponent:@"gmapsupp.img"]
                         toPath:[[path stringByAppendingPathComponent:activeMap] stringByAppendingPathComponent:@"gmapsupp.img"]
                          error:&error])
        {
            [NSApp presentError:error];
            [self updateMaps:nil];
            return;
        }
    }

    if (selection_index != INT_MAX)
    {
        if (![fm moveItemAtPath:[[path stringByAppendingPathComponent:map] stringByAppendingPathComponent:@"gmapsupp.img"]
                         toPath:[path stringByAppendingPathComponent:@"gmapsupp.img"]
                          error:&error])
        {
            [NSApp presentError:error];
        }
    }

    [self updateMaps:nil];
}


@end
