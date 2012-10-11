//
//  SwitchCell.m
//  CustomCell
//
//  Created by Aliksandr Andrashuk on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SwitchCell.h"

@implementation SwitchCell
@synthesize label=m_label, state=m_state;

+(SwitchCell*) cell {
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"SwitchCell" owner:nil options:nil];
    return [objects objectAtIndex:0];
}

+(NSString*) cellID { return @"switchCell"; }

- (void)dealloc {
    [m_state release];
    [m_label release];
    [super dealloc];
}

@end
