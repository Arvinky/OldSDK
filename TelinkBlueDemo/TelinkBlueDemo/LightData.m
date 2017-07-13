//
//  LightData.m
//  TelinkBlueDemo
//
//  Created by Green on 11/22/15.
//  Copyright (c) 2015 Green. All rights reserved.
//

#import "LightData.h"

@implementation LightData
@synthesize lightStatus;
@synthesize bright;
@synthesize colorTel;
@synthesize color;
@synthesize music;
@synthesize devItem;
@synthesize macAdress;
@synthesize devAressPer;
@synthesize devAress;
@synthesize comStartAdress;
@synthesize isGetStatus;

-(id)init
{
    self=[super init];
    self.color=[UIColor whiteColor];
    self.devItem=nil;
    memset(grpAdress, 0xff, 8);
    return self;
}

-(BOOL)addGrpAddressPro:(int)addAdr
{
    BOOL result=NO;
    for (int i=0; i<8; i++)
    {
        if (grpAdress[i]==0xff)
        {
            grpAdress[i]=addAdr;
            result=YES;
            break;
        }
    }
    return result;
}

-(BOOL)removeGrpAddressPro:(int)addAdr
{
    BOOL result=NO;
    for (int i=0; i<8; i++)
    {
        if (grpAdress[i]==addAdr)
        {
            grpAdress[i]=0xff;
            result=YES;
        }
    }
    return result;
}
@end
