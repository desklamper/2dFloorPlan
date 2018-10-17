//
//  CanvasView.h
//  2DFloorPlan
//
//  Created by 黄乘风 on 2018/10/16.
//  Copyright © 2018年 黄乘风. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CanvasView : UIView <UIGestureRecognizerDelegate>
-(void)initSource;
-(void)addWall:(CGPoint)point;
@end

NS_ASSUME_NONNULL_END
