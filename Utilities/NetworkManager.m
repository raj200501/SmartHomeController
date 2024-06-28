#import "NetworkManager.h"

@implementation NetworkManager

+ (instancetype)sharedManager {
    static NetworkManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)sendRequest:(NSURLRequest *)request completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completion];
    [dataTask resume];
}

@end
