#import "MainViewController.h"
#import "DeviceController.h"
#import "NetworkManager.h"
#import "DeviceManager.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *lightsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [lightsButton setTitle:@"Control Lights" forState:UIControlStateNormal];
    lightsButton.frame = CGRectMake(50, 100, 200, 50);
    [lightsButton addTarget:self action:@selector(controlLights) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightsButton];
    
    UIButton *thermostatButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [thermostatButton setTitle:@"Control Thermostat" forState:UIControlStateNormal];
    thermostatButton.frame = CGRectMake(50, 200, 200, 50);
    [thermostatButton addTarget:self action:@selector(controlThermostat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:thermostatButton];
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cameraButton setTitle:@"View Security Camera" forState:UIControlStateNormal];
    cameraButton.frame = CGRectMake(50, 300, 200, 50);
    [cameraButton addTarget:self action:@selector(viewCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
}

- (void)controlLights {
    DeviceController *deviceController = [[DeviceController alloc] initWithDeviceType:@"Light"];
    [self.navigationController pushViewController:deviceController animated:YES];
}

- (void)controlThermostat {
    DeviceController *deviceController = [[DeviceController alloc] initWithDeviceType:@"Thermostat"];
    [self.navigationController pushViewController:deviceController animated:YES];
}

- (void)viewCamera {
    DeviceController *deviceController = [[DeviceController alloc] initWithDeviceType:@"SecurityCamera"];
    [self.navigationController pushViewController:deviceController animated:YES];
}

@end
