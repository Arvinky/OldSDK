//
//  SysSetting.m
//  TelinkBlueDemo
//
//  Created by Green on 11/22/15.
//  Copyright (c) 2015 Green. All rights reserved.
//

#import "SysSetting.h"

#define SaveSysSettingTag @"SysSettingTag"

@implementation GroupInfo
@synthesize grpName;
@synthesize grpAdr;
@synthesize itemArrs;

-(id)init
{
    self=[super init];
    self.itemArrs=[[NSMutableArray alloc] init];
    return self;
}

+(id)ItemWith:(NSString *)nStr Adr:(int)adr
{
    GroupInfo *tempItem=[[GroupInfo alloc] init];
    tempItem.grpName=nStr;
    tempItem.grpAdr=adr;
    return tempItem;
}


-(BOOL)isAllRoom
{
    return self.grpAdr==0xe000;
}
//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.grpName forKey:@"grpName"];
    [encoder encodeInt:self.grpAdr forKey:@"grpAdr"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.grpName = [decoder decodeObjectForKey:@"grpName"];
        self.grpAdr = [decoder decodeIntForKey:@"grpAdr"];
    }
    return self;
}

@end





static SysSetting *shareSysSetting=nil;

@implementation SysSetting
@synthesize nUserName;
@synthesize nUserPassword;
@synthesize oUserName;
@synthesize oUserPassword;
@synthesize memoryName;
@synthesize memoryPassword;
@synthesize grpArrs;

-(void)initData
{
    if (!self.grpArrs || self.grpArrs.count<1)
    {
//        新建组加入数组
        self.grpArrs=[[NSMutableArray alloc] init];
        [grpArrs addObject:[GroupInfo ItemWith:@"All Room" Adr:0xffff]];
        [grpArrs addObject:[GroupInfo ItemWith:@"Living Room" Adr:0x8001]];
        [grpArrs addObject:[GroupInfo ItemWith:@"Family Room" Adr:0x8002]];
        [grpArrs addObject:[GroupInfo ItemWith:@"Kitchen" Adr:0x8003]];
        [grpArrs addObject:[GroupInfo ItemWith:@"Bedroom" Adr:0x8004]];
    }
    
    if (!oUserName || [oUserName length]<1)
        oUserName=@"telink_mesh1";
    
    if (!oUserPassword || [oUserPassword length]<1)
        oUserPassword=@"123";
}

//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.nUserName forKey:@"nUserName"];
    [encoder encodeObject:self.nUserPassword forKey:@"nUserPassword"];
    [encoder encodeObject:self.oUserName forKey:@"oUserName"];
    [encoder encodeObject:self.oUserPassword forKey:@"oUserPassword"];
    [encoder encodeObject:self.memoryName forKey:@"memoryName"];
    [encoder encodeObject:self.memoryPassword forKey:@"memoryPassword"];
    
    [encoder encodeObject:self.grpArrs forKey:@"grpArrs"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.nUserName = [decoder decodeObjectForKey:@"nUserName"];
        self.nUserPassword = [decoder decodeObjectForKey:@"nUserPassword"];
        self.oUserName = [decoder decodeObjectForKey:@"oUserName"];
        self.oUserPassword = [decoder decodeObjectForKey:@"oUserPassword"];
        self.memoryName = [decoder decodeObjectForKey:@"memoryName"];
        self.memoryPassword = [decoder decodeObjectForKey:@"memoryPassword"];
        self.grpArrs = [decoder decodeObjectForKey:@"grpArrs"];
    }
    return self;
}

-(void)updateMemoryInfo{
    self.memoryName = self.oUserName;
    self.memoryPassword = self.oUserPassword;
}

-(void)updateUserInfo
{
    self.oUserName=self.nUserName;
    self.oUserPassword=self.nUserPassword;
    [SysSetting saveSetting];
}

+(SysSetting *)shareSetting
{
    static dispatch_once_t disOnce;
    dispatch_once(&disOnce, ^{
        shareSysSetting=[SysSetting readSetting];
        [shareSysSetting initData];
    });
    return shareSysSetting;
}

+(SysSetting *)readSetting
{
    NSData *tempData = [[NSUserDefaults standardUserDefaults] objectForKey:SaveSysSettingTag];
    
    SysSetting *tempSelSetting=nil;
    
    @try {
        if (tempData)
            tempSelSetting=[NSKeyedUnarchiver unarchiveObjectWithData: tempData];
        if (![tempSelSetting isKindOfClass:[SysSetting class]])
            tempSelSetting=[[SysSetting alloc] init];
    }
    @catch (NSException *exception) {
        
        tempSelSetting=[[SysSetting alloc] init];
    }
    @finally {
        
    }
    if (!tempSelSetting)
        tempSelSetting=[[SysSetting alloc] init];
    
    return tempSelSetting;
}

+(void)saveSetting
{
    SysSetting *tempSelSetting=[SysSetting shareSetting];
    
    NSData *tempData = [NSKeyedArchiver archivedDataWithRootObject:tempSelSetting];
    if (tempData)
    {
        [[NSUserDefaults standardUserDefaults] setObject:tempData forKey:SaveSysSettingTag];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
