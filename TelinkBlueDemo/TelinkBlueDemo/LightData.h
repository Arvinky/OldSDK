//
//  LightData.h
//  TelinkBlueDemo
//
//  Created by Green on 11/22/15.
//  Copyright (c) 2015 Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LightData : NSObject
{
    uint32_t macAdress;
    uint32_t devAress;//地址
    uint32_t devAressPer;//一个字节地址
    int lightStatus;//0-离线  1-灯灭  2-灯亮
    int comStartAdress;
    int bright;
    int colorTel;//色温
    UIColor *color;
    NSString *music;
    id devItem;
    BOOL isGetStatus;
    
@public
    int grpAdress[8];
}
@property (nonatomic, assign) uint32_t devAress;
@property (nonatomic, assign) int comStartAdress;
@property (nonatomic, assign) uint32_t devAressPer;
@property (nonatomic, assign) uint32_t macAdress;
@property (nonatomic, assign) int lightStatus;
@property (nonatomic, assign) int bright;
@property (nonatomic, assign) int colorTel;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *music;
@property (nonatomic, strong) id devItem;
@property (nonatomic, assign, getter=isGetStatus) BOOL isGetStatus;

#warning mark-add
@property(nonatomic,strong)NSString *addressName;


-(BOOL)addGrpAddressPro:(int)addAdr;
-(BOOL)removeGrpAddressPro:(int)addAdr;

@end
