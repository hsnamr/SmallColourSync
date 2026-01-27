//
//  ICCWriter.h
//  SmallICCer
//
//  Writes ICC profiles to disk
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;

@interface ICCWriter : NSObject

- (BOOL)writeProfile:(ICCProfile *)profile toPath:(NSString *)path error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
