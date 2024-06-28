#import "Device.h"

@interface SecurityCamera : Device

@property (nonatomic, strong) NSString *feedURL;

- (void)refreshFeed;

@end
