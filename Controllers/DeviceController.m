#import "DeviceController.h"
#import "DeviceManager.h"

@interface DeviceController ()

@property (nonatomic, strong) NSString *deviceType;

@end

@implementation DeviceController

- (instancetype)initWithDeviceType:(NSString *)deviceType {
    self = [super init];
    if (self) {
        _deviceType = deviceType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 300, 50)];
    label.text = [NSString stringWithFormat:@"Control %@", self.deviceType];
    [self.view addSubview:label];
    
    if ([self.deviceType isEqualToString:@"Light"]) {
        [self setupLightControls];
    } else if ([self.deviceType isEqualToString:@"Thermostat"]) {
        [self setupThermostatControls];
    } else if ([self.deviceType isEqualToString:@"SecurityCamera"]) {
        [self setupCameraControls];
    }
}

- (void)setupLightControls {
    UISwitch *lightSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(50, 200, 100, 50)];
    [lightSwitch addTarget:self action:@selector(toggleLight:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:lightSwitch];
}

- (void)setupThermostatControls {
    UISlider *temperatureSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 200, 300, 50)];
    temperatureSlider.minimumValue = 60;
    temperatureSlider.maximumValue = 80;
    [temperatureSlider addTarget:self action:@selector(changeTemperature:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:temperatureSlider];
}

- (void)setupCameraControls {
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    refreshButton.frame = CGRectMake(50, 200, 100, 50);
    [refreshButton addTarget:self action:@selector(refreshCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refreshButton];
}

- (void)toggleLight:(UISwitch *)sender {
    // Logic to toggle light
}

- (void)changeTemperature:(UISlider *)sender {
    // Logic to change thermostat temperature
}

- (void)refreshCamera {
    // Logic to refresh security camera feed
}

@end
