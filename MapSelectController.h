//
//  MapSelectController.h
//  MapSelect
//
//  Created by Michael Klein on 2011-05-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MapSelectController : NSObject {
    IBOutlet id volumesController;
    IBOutlet id mapsController;
    
    NSString * activeMap;
}

- (IBAction)updateVolumes:(id)sender;
- (IBAction)updateMaps:(id)sender;
- (IBAction)ejectVolume:(id)sender;
- (IBAction)activateMap:(id)sender;

@end
