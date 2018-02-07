//
//  SignCell.h
//  HN_ERP
//
//  Created by tomwey on 3/7/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SignData;
@interface SignCell : UITableViewCell

@property (nonatomic, strong) SignData *signData;

- (void)hideKeyboard;

@end

@interface SignData : NSObject

@property (nonatomic, copy)   NSString  *name;
@property (nonatomic, copy)   NSString  *ID;
@property (nonatomic, assign) NSInteger sort;
@property (nonatomic, assign) BOOL      checked;

- (instancetype)initWithName:(NSString *)name
                          ID:(NSString *)ID
                        sort:(NSInteger)sort;



@end
