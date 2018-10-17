//
//  MathUtil.h
//  2DFloorPlan
//
//  Created by 黄乘风 on 2018/10/17.
//  Copyright © 2018年 黄乘风. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MathUtil : NSObject

-(float)distanceBetweenPoints:(CGPoint)aPoint anotherPoint:(CGPoint)bPoint;
-(int)isXorY:(CGPoint)aPoint anotherPoint:(CGPoint)bPoint;
@end

NS_ASSUME_NONNULL_END
