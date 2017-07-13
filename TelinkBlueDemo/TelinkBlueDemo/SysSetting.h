//
//  SysSetting.h
//  TelinkBlueDemo
//
//  Created by Green on 11/22/15.
//  Copyright (c) 2015 Green. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GroupInfo : NSObject
{
    NSString *grpName;
    int grpAdr;
    NSMutableArray *itemArrs;
}
@property (nonatomic, strong) NSString *grpName;
@property (nonatomic, assign) int grpAdr;
@property (nonatomic, strong) NSMutableArray *itemArrs;

-(BOOL)isAllRoom;

+(id)ItemWith:(NSString *)nStr Adr:(int)adr;
@end



@interface SysSetting : NSObject
{
    //新旧用户名密码
    NSString *nUserName;
    NSString *nUserPassword;
    
    NSString *oUserName;
    NSString *oUserPassword;
    
    NSString *memoryName;
    NSString *memoryPassword;
    
    NSMutableArray *grpArrs;
}
@property (nonatomic, strong) NSString *nUserName;
@property (nonatomic, strong) NSString *nUserPassword;
@property (nonatomic, strong) NSString *oUserName;
@property (nonatomic, strong) NSString *oUserPassword;
@property(nonatomic,strong)NSString *memoryName;
@property(nonatomic,strong)NSString *memoryPassword;
@property (nonatomic, strong) NSMutableArray *grpArrs;
-(void)updateMemoryInfo;
-(void)updateUserInfo;
+(SysSetting *)shareSetting;
+(void)saveSetting;
@end
