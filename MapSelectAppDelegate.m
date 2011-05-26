//
//  MapSelectAppDelegate.m
//  MapSelect
//
//  Created by Michael Klein on 2011-05-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapSelectAppDelegate.h"
#import "VolumeInfo.h"


@implementation MapSelectAppDelegate

- (void)volumeDidMount:(NSNotification*)notification
{
    NSString * path = [[notification userInfo] objectForKey:@"NSDevicePath"];
    VolumeInfo * volume = [VolumeInfo volumeInfoWithPath:path];
    if (volume != nil)
        [volumesController addObject:volume];
}

- (void)volumeDidUnmount:(NSNotification*)notification
{
    NSString * path = [[notification userInfo] objectForKey:@"NSDevicePath"];
    NSEnumerator * e = [[volumesController content] objectEnumerator];
    VolumeInfo * volume_info;
    
    while ((volume_info = [e nextObject]) != nil)
    {
        if ([[volume_info volumePath] isEqualToString:path])
        {
            [volumesController removeObject:volume_info];
            break;
        }
    }
}

- (NSSortDescriptor*)mapArraySortDescriptors
{
    NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"mapName" ascending:YES];
    return [NSArray arrayWithObject:sd];
}


- (void)ejectVolume:(NSString*)path
{
    [[NSWorkspace sharedWorkspace] unmountAndEjectDeviceAtPath:path];
}


- (void)awakeFromNib
{
    NSNotificationCenter * nc = [[NSWorkspace sharedWorkspace] notificationCenter];

    [nc addObserver:self 
           selector:@selector(volumeDidMount:)
               name:NSWorkspaceDidMountNotification
             object:nil];

    [nc addObserver:self 
           selector:@selector(volumeDidUnmount:)
               name:NSWorkspaceDidUnmountNotification
             object:nil];

    NSArray * volumePaths = [[NSWorkspace sharedWorkspace] mountedRemovableMedia];
    NSEnumerator * e = [volumePaths objectEnumerator];
    NSString * path;

    while ((path = [e nextObject]) != nil)
    {
        VolumeInfo * volume = [VolumeInfo volumeInfoWithPath:path];
        if (volume != nil)
            [volumesController addObject:volume];
    }

    [volumesController addObserver:self forKeyPath:@"selection.currentMap" options:0 context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    VolumeInfo * volume = [[object valueForKey:@"selectedObjects"] objectAtIndex:0];
    id map = [object valueForKeyPath:keyPath];
    NSString * map_name = [map isKindOfClass:[NSString class]] ? map : nil;
    [volume activateMap:map_name];
}

@end
