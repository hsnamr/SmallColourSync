//
//  ICCTag.h
//  SmallICCer
//
//  Base class for all ICC tag types
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ICCTag : NSObject {
    NSString *signature;
    NSData *rawData;
}

@property (nonatomic, retain) NSString *signature;
@property (nonatomic, retain) NSData *rawData;

- (id)initWithData:(void *)data signature:(NSString *)sig;
- (NSData *)serialize;

@end

NS_ASSUME_NONNULL_END
