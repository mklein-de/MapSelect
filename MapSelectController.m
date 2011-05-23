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

- (NSSortDescriptor*)mapSortDescriptor
{
    NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"mapName" ascending:YES];
    return [NSArray arrayWithObject:[sd autorelease]];
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
    NSArray * volumePaths = [[NSWorkspace sharedWorkspace] mountedRemovableMedia];
    NSMutableArray * volumes = [NSMutableArray array];
    NSEnumerator * e = [volumePaths objectEnumerator];
    NSObject * o;
    while ((o = [e nextObject]) != nil)
    {
        [volumes addObject:[NSDictionary dictionaryWithObject:o forKey:@"volumePath"]];
    }
    [volumesController setContent:volumes];
    [self updateMaps:nil];
}

- (IBAction)updateMaps:(id)sender
{
    NSInteger selection_index = [volumesController selectionIndex];
    NSMutableArray *dirs = [NSMutableArray array];

    if (selection_index == NSNotFound)
    {
        [mapsController setContent:dirs];
        return;
    }
    
    NSString * volume = [volumesController valueForKeyPath:@"selection.volumePath"];
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
                [dirs addObject:[NSDictionary dictionaryWithObject:o forKey:@"mapName"]];
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
    
    if (gmapsupp_found)
    {
        if (activeMap != nil)
        {
            [dirs addObject:[NSDictionary dictionaryWithObject:activeMap forKey:@"mapName"]];
        }
        else
        {
            NSLog(@"no empty directory for active map");
        }
    }
    else
    {
        [mapsController setSelectionIndex:-1];
        selected_index = NSNotFound;
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
    NSString * volume = [volumesController valueForKeyPath:@"selection.volumePath"];
    [[NSWorkspace sharedWorkspace] unmountAndEjectDeviceAtPath:volume];
}

- (IBAction)activateMap:(id)sender
{
    NSString * volume = [volumesController valueForKeyPath:@"selection.volumePath"];
    NSString * map = [mapsController valueForKeyPath:@"selection.mapName"];
    NSInteger selection_index = [mapsController selectionIndex];
    
    NSLog(@"activate %@ (%d)", map, selection_index);
    
    if (selection_index != NSNotFound && [map isEqualToString:activeMap])
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

    if (selection_index != NSNotFound)
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
