//
//  TopPlayerCell.m
//  Cowboy Duel 1
//
//  Created by Taras on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreProductCell.h"
#import "Utils.h"
#import "UIView+Dinamic_BackGround.h"

@interface StoreProductCell()
{
}
@end

@implementation StoreProductCell

@synthesize backGround;
@synthesize icon;
@synthesize name;
@synthesize gold;
@synthesize coldTitle;
@synthesize effectTitle;
@synthesize effect;
@synthesize description;
@synthesize buyProduct;
@synthesize cellType;

UIColor * bronzeColor;
UIColor * brownColor;
UIColor * sandColor;

+(StoreProductCell*) cell {
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"StoreProductCell" owner:nil options:nil];
    NSLog(@"objects %@",objects);
    return [objects objectAtIndex:0];
}

+(NSString*) cellID { return @"StoreProductCell"; }

-(void) initMainControls {
    bronzeColor=[UIColor colorWithRed:0.596 green:0.525 blue:0.416 alpha:1];
    brownColor=[UIColor colorWithRed:0.38 green:0.267 blue:0.133 alpha:1];
    sandColor=[UIColor colorWithRed:1 green:0.917 blue:0.749 alpha:1];
    
    coldTitle.text=NSLocalizedString(@"Gold:", @"");
    
    [backGround setDinamicHeightBackground];
}

-(void)populateWithProduct:(CDDuelProduct *)product index:(NSIndexPath *)indexPath typeTable:(StoreDataSourceTypeTables)type;
{
    name.text = product.dName;
}
@end
