#import "DeviceManager.h"

@interface DeviceManager ()

@property (nonatomic, strong) NSMutableArray *devices;

@end

@implementation DeviceManager

+ (instancetype)sharedManager {
    static DeviceManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _devices = [NSMutableArray array];
    }
    return self;
}

- (void)addDevice:(id)device {
    [self.devices addObject:device];
}

- (void)removeDevice:(id)device {
    [self.devices removeObject:device];
}

- (NSArray *)allDevices {
    return [self.devices copy];
}

@end
