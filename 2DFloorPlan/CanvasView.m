//
//  CanvasView.m
//  2DFloorPlan
//
//  Created by 黄乘风 on 2018/10/16.
//  Copyright © 2018年 黄乘风. All rights reserved.
//

#import "CanvasView.h"
#import "Wall.h"
#import "MathUtil.h"

@interface CanvasView()
@property (nonatomic,strong) NSMutableArray *wallArray;
@property (nonatomic,strong) Wall *currentWall;
@property (nonatomic,strong) MathUtil *mathUtil;
@property CGPoint startPoint;
@property BOOL isAddingWall;
@property BOOL isFindingPoint;
@end

@implementation CanvasView

typedef NS_ENUM(NSInteger, WallType){
    Horizon = 0,
    Vertical = 1
};
WallType walltype;

#pragma mark - init

-(void)initSource{
    self.wallArray = [[NSMutableArray alloc] init];
    self.currentWall = [[Wall alloc] init];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [panGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:panGestureRecognizer];
    
    self.mathUtil = [[MathUtil alloc] init];
}

-(void)addWall:(CGPoint)point{
    self.isAddingWall = YES;
    self.isFindingPoint = YES;
    self.startPoint = [self findPoint:point];
    [self setNeedsDisplay];
}

#pragma mark - drawRect

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0f);
    UIColor *wallcolor = [UIColor grayColor];
    [wallcolor set];

    for(Wall *wall in self.wallArray)
    {
        CGContextBeginPath(context);
        CGContextSetLineWidth(context, 10.0f);
        float x1 = wall.startPoint.x;
        float y1 = wall.startPoint.y;
        float x2 = wall.endPoint.x;
        float y2 = wall.endPoint.y;
        CGContextMoveToPoint(context, x1, y1);
        CGContextAddLineToPoint(context, x2, y2);
        CGContextStrokePath(context);
    }
    if(self.isFindingPoint)
    {
        [[UIColor whiteColor] set];
        float x = self.startPoint.x;
        float y = self.startPoint.y;
        CGRect rec = CGRectMake(x-6, y-6, 2*6, 2*6);
        CGContextFillEllipseInRect(context, rec);
    }
}

#pragma mark - GestureRecognizer

- (void)panGestureDetected:(UIPanGestureRecognizer *)recognizer {
    if(!self.isAddingWall)
    {
        return;
    }
    if((long)[recognizer state] == (long)UIGestureRecognizerStateBegan){
        CGPoint startPoint = [recognizer locationInView:self];
        NSLog(@"start :  x:%f , y:%f",startPoint.x,startPoint.y);
        CGPoint start = [self findPoint:startPoint];
        Wall *wall = [[Wall alloc] init];
        wall.startPoint = start;
        wall.endPoint = start;
        self.currentWall = wall;
        [self.wallArray addObject:wall];
    }
    else if((long)[recognizer state] == (long)UIGestureRecognizerStateChanged){
//        CGPoint changePoint = [recognizer locationInView:self];
//        NSLog(@"change :  x:%f , y:%f",changePoint.x,changePoint.y);
//        int index = (int)self.wallArray.count-1;
//        [self.wallArray removeObjectAtIndex:index];
//        self.currentWall.end = SCNVector3Make(changePoint.x, changePoint.y, 0);
//        Wall *wall = self.currentWall;
//        [self.wallArray addObject:wall];
//        [self setNeedsDisplay];
    }
    else if((long)[recognizer state] == (long)UIGestureRecognizerStateEnded){
        CGPoint endPoint = [recognizer locationInView:self];
        NSLog(@"end :  x:%f , y:%f",endPoint.x,endPoint.y);
        int xOy = [self.mathUtil isXorY:self.currentWall.startPoint anotherPoint:endPoint];
        int index = (int)self.wallArray.count-1;
        [self.wallArray removeObjectAtIndex:index];
        self.currentWall.endPoint = xOy == 0 ? CGPointMake(endPoint.x,self.currentWall.startPoint.y) : CGPointMake(self.currentWall.startPoint.x, endPoint.y);
        self.currentWall.wallType = xOy;
        [self.currentWall redefine];
        Wall *wall = self.currentWall;
        [self.wallArray addObject:wall];
        [self setNeedsDisplay];
        self.isAddingWall = NO;
    }
}

#pragma mark - helper

-(CGPoint)findPoint:(CGPoint) point{
    for(Wall *wall in self.wallArray){
        if(wall.wallType == Horizon){
            if(fabs(point.y - wall.endPoint.y) <= 10 && point.x >= wall.startPoint.x - 10 && point.x <= wall.endPoint.x + 10 ){
                if(point.x >= wall.startPoint.x - 10 && point.x < wall.endPoint.x)
                {
                    return CGPointMake(wall.startPoint.x, wall.startPoint.y);
                }
                else if(point.x > wall.endPoint.x && point.x <= wall.endPoint.x + 10)
                {
                    return CGPointMake(wall.endPoint.x, wall.endPoint.y);
                }
                else{
                    return CGPointMake(point.x, wall.startPoint.y);
                }
            }
        }
        else if(wall.wallType == Vertical){
            if(fabs(point.x - wall.endPoint.x) <= 10 && point.y >= wall.startPoint.y - 10 && point.y <= wall.endPoint.y + 10 ){
                if(point.y >= wall.startPoint.y - 10 && point.y < wall.endPoint.y)
                {
                    return CGPointMake(wall.startPoint.x, wall.startPoint.y);
                }
                else if(point.x > wall.endPoint.y && point.x <= wall.endPoint.y + 10)
                {
                    return CGPointMake(wall.endPoint.x, wall.endPoint.y);
                }
                else{
                    return CGPointMake(wall.startPoint.x, point.y);
                }
            }
        }
    }
    return point;
}

@end
