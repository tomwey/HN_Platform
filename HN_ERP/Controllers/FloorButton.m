//
//  Floor.m
//  HN_ERP
//
//  Created by tomwey on 25/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "FloorButton.h"
#import "Defines.h"

@interface FloorButton ()

@property (nonatomic, strong) UILabel *floorLabel;
@property (nonatomic, strong) UILabel *paySymbolLabel;

@end

@implementation FloorButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(tap)]];
    }
    return self;
}

- (void)tap
{
    if ( self.didSelectBlock ) {
        self.didSelectBlock(self);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.floorLabel.frame = self.bounds;
    
    self.paySymbolLabel.position = CGPointMake(self.width - self.paySymbolLabel.width - 3,
                                               3);
}

- (void)setFloor:(NSInteger)floor
{
    _floor = floor;
    
    self.floorLabel.text = [@(floor) description];
}

- (void)setNeedPay:(BOOL)needPay
{
    _needPay = needPay;
    
    [self addPaySymbolIfNeeded];
}

- (void)addPaySymbolIfNeeded
{
    self.paySymbolLabel.hidden = !self.needPay;
    
    if ( self.confirmType == FloorConfirmTypeUnconfirmed ) {
        self.paySymbolLabel.textColor = AWColorFromRGB(119, 168, 110);
    } else {
        self.paySymbolLabel.textColor = [UIColor whiteColor];
    }
}

//- (void)setConfirmed:(BOOL)confirmed
//{
//    _confirmed = confirmed;
//    
//    if ( confirmed ) {
//        self.backgroundColor = AWColorFromRGB(119, 168, 110);
//        self.floorLabel.textColor = [UIColor whiteColor];
//    } else {
//        self.backgroundColor = [UIColor whiteColor];
//        self.floorLabel.textColor = AWColorFromRGB(119, 168, 110);
//        
//        self.layer.borderWidth = 0.6;
//        self.layer.borderColor = AWColorFromRGB(119, 168, 110).CGColor;
//    }
//}
- (void)setConfirmType:(FloorConfirmType)confirmType
{
    _confirmType = confirmType;
    
    switch (confirmType) {
        case FloorConfirmTypeUnconfirmed:
        {
            self.backgroundColor = [UIColor whiteColor];
            self.floorLabel.textColor = AWColorFromRGB(119, 168, 110);
            self.layer.borderWidth = 0.6;
            self.layer.borderColor = AWColorFromRGB(119, 168, 110).CGColor;
        }
            break;
        
        case FloorConfirmTypeConfirmed:
        {
            self.backgroundColor = AWColorFromRGB(119, 168, 110);
            self.floorLabel.textColor = [UIColor whiteColor];
            
            self.layer.borderWidth = 0;
        }
            break;
            
        case FloorConfirmTypeShouldConfirming:
        {
            self.backgroundColor = AWColorFromHex(@"#E8A02A");
            self.floorLabel.textColor = [UIColor whiteColor];
            
            self.layer.borderWidth = 0;
        }
            break;
            
        default:
            break;
    }
    
    [self addPaySymbolIfNeeded];
}

- (UILabel *)floorLabel
{
    if ( !_floorLabel ) {
        _floorLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(15, NO),
                                    AWColorFromRGB(119, 168, 110));
        [self addSubview:_floorLabel];
    }
    return _floorLabel;
}

- (UILabel *)paySymbolLabel
{
    if ( !_paySymbolLabel ) {
        _paySymbolLabel = AWCreateLabel(CGRectMake(0, 0, 30, 30),
                                    @"¥",
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(10, NO),
                                    AWColorFromRGB(119, 168, 110));
        [self addSubview:_paySymbolLabel];
        
        [_paySymbolLabel sizeToFit];
    }
    return _paySymbolLabel;
}

@end
