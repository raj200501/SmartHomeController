#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (instancetype)sharedManager;

- (void)sendRequest:(NSURLRequest *)request completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

@end
