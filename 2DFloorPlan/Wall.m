//
//  Wall.m
//  2DFloorPlan
//
//  Created by 黄乘风 on 2018/10/16.
//  Copyright © 2018年 黄乘风. All rights reserved.
//

#import "Wall.h"

@implementation Wall

-(instancetype)init{
    self = [super init];
    return self;
}

-(void)redefine{
    if(self.wallType == 0)
    {
        if(self.startPoint.x > self.endPoint.x)
        {
            CGPoint a = self.startPoint;
            self.startPoint = self.endPoint;
            self.endPoint = a;
        }
    }
    else if(self.wallType == 1)
    {
        if(self.startPoint.y > self.endPoint.y)
        {
            CGPoint a = self.startPoint;
            self.startPoint = self.endPoint;
            self.endPoint = a;
        }
    }
}

@end
