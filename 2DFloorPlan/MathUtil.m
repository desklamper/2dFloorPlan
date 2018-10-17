//
//  MathUtil.m
//  2DFloorPlan
//
//  Created by 黄乘风 on 2018/10/17.
//  Copyright © 2018年 黄乘风. All rights reserved.
//

#import "MathUtil.h"

@implementation MathUtil


-(float)distanceBetweenPoints:(CGPoint)aPoint anotherPoint:(CGPoint)bPoint{
    float x12x2 = aPoint.x-bPoint.x;
    float y12y2 = aPoint.y-bPoint.y;
    float disSquare = powf(x12x2,2) + powf(y12y2, 2);
    return powf(disSquare,0.5);
}

-(int)isXorY:(CGPoint)aPoint anotherPoint:(CGPoint)bPoint{
    //0-->x方向  1-->y方向
    return   fabs(aPoint.x-bPoint.x) > fabs(aPoint.y-bPoint.y) ? 0 : 1;
}

@end
