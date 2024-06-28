#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;

- (instancetype)initWithName:(NSString *)name type:(NSString *)type;

@end
