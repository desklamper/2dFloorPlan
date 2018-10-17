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
@property (nonatomic,strong) NSMutableArray *xLines;
@property (nonatomic,strong) NSMutableArray *yLines;
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
    self.backgroundColor = [UIColor blackColor];
    
    self.wallArray = [[NSMutableArray alloc] init];
    self.xLines = [[NSMutableArray alloc] init];
    self.yLines = [[NSMutableArray alloc] init];
    self.currentWall = [[Wall alloc] init];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [panGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:panGestureRecognizer];
    
    self.mathUtil = [[MathUtil alloc] init];
}

-(void)addWall:(CGPoint)point{
    self.isAddingWall = NO;
    self.isFindingPoint = YES;
    self.startPoint = [self findPoint:point];
    [self setNeedsDisplay];
}

-(void)startPan{
    self.isAddingWall = YES;
    self.isFindingPoint = NO;
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
        CGRect a =  CGRectMake(self.startPoint.x-6, self.startPoint.y-6, 6*2, 6*2);
        CGContextFillEllipseInRect(context, a);
    }
}

#pragma mark - GestureRecognizer

- (void)panGestureDetected:(UIPanGestureRecognizer *)recognizer {
    if(!self.isAddingWall)
    {
        if((long)[recognizer state] == (long)UIGestureRecognizerStateBegan){
            CGPoint start = [recognizer locationInView:self];
            self.startPoint = start;
        }
        else if((long)[recognizer state] == (long)UIGestureRecognizerStateChanged)
        {
            CGPoint move = [recognizer locationInView:self];
            float offsetX = move.x - self.startPoint.x;
            float offsetY = move.y - self.startPoint.y;
            [self panCanvas:offsetX/100 offsetY:offsetY/100];
            [self setNeedsDisplay];
        }
        else if((long)[recognizer state] == (long)UIGestureRecognizerStateEnded){
            CGPoint end = [recognizer locationInView:self];
            float offsetX = end.x - self.startPoint.x;
            float offsetY = end.y - self.startPoint.y;
            [self panCanvas:offsetX/100 offsetY:offsetY/100];
            [self setNeedsDisplay];
        }
    }
    else
    {
        if((long)[recognizer state] == (long)UIGestureRecognizerStateBegan){
            CGPoint startPoint = self.startPoint;
            NSLog(@"start :  x:%f , y:%f",startPoint.x,startPoint.y);
            CGPoint start = [self findPoint:startPoint];
            Wall *wall = [[Wall alloc] init];
            wall.startPoint = start;
            wall.endPoint = start;
            self.currentWall = wall;
            [self.wallArray addObject:wall];
        }
        else if((long)[recognizer state] == (long)UIGestureRecognizerStateChanged){
            CGPoint changePoint = [recognizer locationInView:self];
            NSLog(@"change :  x:%f , y:%f",changePoint.x,changePoint.y);
            int xOy = [self.mathUtil isXorY:self.currentWall.startPoint anotherPoint:changePoint];
            int index = (int)self.wallArray.count-1;
            [self.wallArray removeObjectAtIndex:index];
            self.currentWall.endPoint = xOy == 0 ? CGPointMake(changePoint.x,self.currentWall.startPoint.y) : CGPointMake(self.currentWall.startPoint.x, changePoint.y);
            self.currentWall.endPoint = [self detectLines:self.currentWall.endPoint xORy:xOy];
            self.currentWall.wallType = xOy;
            Wall *wall = self.currentWall;
            [self.wallArray addObject:wall];
            [self setNeedsDisplay];
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
}

#pragma mark - helper

-(CGPoint)findPoint:(CGPoint) point{
    for(Wall *wall in self.wallArray){
        if(wall.wallType == Horizon){
            if(fabs(point.y - wall.endPoint.y) <= 30 && point.x >= wall.startPoint.x - 30 && point.x <= wall.endPoint.x + 30 ){
//                NSLog(@"here");
                if(point.x >= wall.startPoint.x - 30 && point.x < wall.startPoint.x)
                {
                    return CGPointMake(wall.startPoint.x, wall.startPoint.y);
                }
                else if(point.x > wall.endPoint.x && point.x <= wall.endPoint.x + 30)
                {
                    return CGPointMake(wall.endPoint.x, wall.endPoint.y);
                }
                else{
                    return CGPointMake(point.x, wall.startPoint.y);
                }
            }
        }
        else if(wall.wallType == Vertical){
            if(fabs(point.x - wall.endPoint.x) <= 30 && point.y >= wall.startPoint.y - 30 && point.y <= wall.endPoint.y + 30 ){
//                NSLog(@"there");
                if(point.y >= wall.startPoint.y - 30 && point.y < wall.startPoint.y)
                {
                    return CGPointMake(wall.startPoint.x, wall.startPoint.y);
                }
                else if(point.y > wall.endPoint.y && point.y <= wall.endPoint.y + 30)
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

-(CGPoint)detectLines:(CGPoint)point xORy:(int)xOy{
    //x
    if(xOy == 0){
        for(Wall *wall in self.wallArray){
            if(fabs(wall.startPoint.x - point.x) < 20)
            {
                return CGPointMake(wall.startPoint.x, point.y);
            }
            else if(fabs(wall.endPoint.x - point.x) < 20)
            {
                return CGPointMake(wall.endPoint.x, point.y);
            }
        }
    }
    else{
        for(Wall *wall in self.wallArray){
            if(fabs(wall.startPoint.y - point.y) < 20)
            {
                return CGPointMake(point.x, wall.startPoint.y);
            }
            else if(fabs(wall.endPoint.y - point.y) < 20)
            {
                return CGPointMake(point.x, wall.endPoint.y);
            }
        }
    }
    return point;
}

-(void)panCanvas:(float)offsetX offsetY:(float)offsetY{
    for(Wall *wall in self.wallArray)
    {
        wall.startPoint = CGPointMake(wall.startPoint.x+offsetX, wall.startPoint.y+offsetY);
        wall.endPoint = CGPointMake(wall.endPoint.x+offsetX, wall.endPoint.y+offsetY);
    }
}
@end
