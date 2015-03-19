//
//  BLCAwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Paul Lozada on 2015-03-18.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCAwesomeFloatingToolbar;

@protocol BLCAwesomeFloatingToobarDelegate <NSObject>

@optional

-(void)floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;

@end

@interface BLCAwesomeFloatingToolbar : UIView

-(instancetype) initWithFourTitles:(NSArray *)titles;

-(void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@property (nonatomic,weak) id <BLCAwesomeFloatingToobarDelegate> delegate;





@end
