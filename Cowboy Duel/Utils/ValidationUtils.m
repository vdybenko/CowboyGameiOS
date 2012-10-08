//
//  ValidationUtils.m
//  iFish
//
//  Created by Max Odnovolyk on 9/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ValidationUtils.h"


id ValidateObject(id obj, Class cls) {
	
	if (![obj isKindOfClass:cls])
		return [[cls alloc] init];
	
	return obj;
}