//
//  CanvasView.m
//  2DFloorPlan
//
//  Created by 黄乘风 on 2018/10/16.
//  Copyright © 2018年 黄乘风. All rights reserved.
//

#import "CanvasView.h"
#import "Wall.h"

@interface CanvasView()
@property (nonatomic,strong) NSMutableArray *wallArray;
@end

@implementation CanvasView

-(void)initArray{
    self.wallArray = [[NSMutableArray alloc] init];
}

-(void)addWall{
    Wall *wall = [[Wall alloc] init];
    wall.start = SCNVector3Make(-100, 100, 0);
    wall.end = SCNVector3Make(200, 100, 0);
    [self.wallArray addObject:wall];
    [self setNeedsDisplay];
}


-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0f);
    UIColor *wallcolor = [UIColor whiteColor];
    [wallcolor set];
    
    for(Wall *wall in self.wallArray)
    {
        float x1 = wall.start.x;
        float y1 = wall.start.y;
        float x2 = wall.end.x;
        float y2 = wall.end.y;
        CGContextMoveToPoint(context, x1, y1);
        CGContextAddLineToPoint(context, x2, y2);
        CGContextStrokePath(context);
    }
}

@end
