#import <Foundation/Foundation.h>

@interface DeviceManager : NSObject

+ (instancetype)sharedManager;

- (void)addDevice:(id)device;
- (void)removeDevice:(id)device;
- (NSArray *)allDevices;

@end
