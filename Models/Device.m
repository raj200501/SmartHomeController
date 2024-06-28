#import "Device.h"

@implementation Device

- (instancetype)initWithName:(NSString *)name type:(NSString *)type {
    self = [super init];
    if (self) {
        _name = name;
        _type = type;
    }
    return self;
}

@end
