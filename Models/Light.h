#import "Device.h"

@interface Light : Device

@property (nonatomic, assign) BOOL isOn;

- (void)toggle;

@end
