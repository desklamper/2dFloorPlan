//
//  Wall.h
//  2DFloorPlan
//
//  Created by 黄乘风 on 2018/10/16.
//  Copyright © 2018年 黄乘风. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Wall : NSObject

@property (nonatomic) SCNVector3 start;
@property (nonatomic) SCNVector3 end;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) float length;
@property (nonatomic) int wallType;

-(void)redefine;
@end

NS_ASSUME_NONNULL_END
