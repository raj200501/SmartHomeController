#import "Device.h"

@interface Thermostat : Device

@property (nonatomic, assign) float temperature;

- (void)setTemperature:(float)temperature;

@end
