//
//  HNImageHelper.m
//  HN_ERP
//
//  Created by tomwey on 2/21/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "HNImageHelper.h"
#import "Defines.h"

#define COLORS_COUNT 10
static NSString * colors[COLORS_COUNT] = {
    @"96,70,184",
    @"135,64,167",
    @"200,66,140",
    @"75,53,40",
    @"145,114,94",
    @"33,47,63",
    @"108,121,122",
    @"37,161,77",
    @"223,53,47",
    @"44,63,109"
};

@interface HNImageHelper ()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation HNImageHelper

+ (UIImage *)imageForName:(NSString *)name
                    manID:(NSInteger)manID
                     size:(CGSize)size
{
    
    HNImageHelper *imageHelper = [[HNImageHelper alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    if ( name.length >= 2 ) {
        imageHelper.nameLabel.text = [name substringFromIndex:name.length - 2];
    }
    
    NSInteger index = manID % COLORS_COUNT;
    
    NSArray *colorPartials = [colors[index] componentsSeparatedByString:@","];
    imageHelper.backgroundColor = AWColorFromRGB([colorPartials[0] intValue],
                                                 [colorPartials[1] intValue],
                                                 [colorPartials[2] intValue]);
    
    
    // 截图
    UIGraphicsBeginImageContextWithOptions(size,
                                           NO,
                                           [[UIScreen mainScreen] scale]);
    [imageHelper.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (void)imageForName:(NSString *)name
               manID:(NSInteger)manID
                size:(CGSize)size
     completionBlock:(void (^)(UIImage *anImage, NSError *error))completionBlock
{
    static dispatch_queue_t loadImageQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loadImageQueue = dispatch_queue_create("cn.heneng.create-icon-queue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    dispatch_async(loadImageQueue, ^{
        UIImage *newImage = [self imageForName:name manID:manID size:size];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                if ( newImage ) {
                    completionBlock(newImage, nil);
                } else {
                    completionBlock(nil, [NSError errorWithDomain:@"生成ICON图片失败" code:-1011 userInfo:nil]);
                }
            }
        });
    });
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(0, 0, self.width, 30);
    self.nameLabel.center = CGPointMake(self.width / 2, self.height / 2);
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   [UIFont systemFontOfSize:14],
                                   [UIColor whiteColor]);
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

@end
