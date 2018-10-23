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
@property (nonatomic,strong) NSMutableArray *wallArrayOrigin;
@property (nonatomic,strong) NSMutableArray *xLines;
@property (nonatomic,strong) NSMutableArray *yLines;
@property (nonatomic,strong) Wall *currentWall;
@property (nonatomic,strong) MathUtil *mathUtil;
@property CGPoint startPoint;
@property BOOL isAddingWall;
@property BOOL isFindingPoint;
@end

@implementation CanvasView{
    CGFloat zoomScale;
    CGFloat zoomTemp;
    CGFloat originX,originY;
}



typedef NS_ENUM(NSInteger, WallType){
    Horizon = 0,
    Vertical = 1
};
WallType walltype;

#pragma mark - init

-(void)initSource{
    self.backgroundColor = [UIColor whiteColor];
    zoomScale = 1.0f;
    originX = self.frame.size.width / 2;
    originY = self.frame.size.height / 2;
    self.wallArray = [[NSMutableArray alloc] init];
    self.wallArrayOrigin = [[NSMutableArray alloc] init];
    self.xLines = [[NSMutableArray alloc] init];
    self.yLines = [[NSMutableArray alloc] init];
    self.currentWall = [[Wall alloc] init];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [panGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:panGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureDetected:)];
    [pinchGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:pinchGestureRecognizer];
    
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

-(void)popWallArray{
    if(self.wallArray.count > 0)
    {
        int index = self.wallArray.count - 1;
        [self.wallArray removeObjectAtIndex:index];
        [self setNeedsDisplay];
    }
}
#pragma mark - drawRect

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0f);
    UIColor *wallcolor = [UIColor grayColor];
    [wallcolor set];
    BOOL isOut = NO;
    float leftest = self.bounds.size.width;
    float rightest = 0;
    float lowest = self.bounds.size.height;
    float hightest = 0;
    for(Wall *wall in self.wallArray)
    {
        if(!isOut)
        {
            isOut = [self isWallOutScreen:wall];
        }
        leftest = wall.startPoint.x < leftest ? wall.startPoint.x : leftest;
        rightest = wall.endPoint.x > rightest ? wall.endPoint.x : rightest;
        lowest = wall.startPoint.y < lowest ? wall.startPoint.y : lowest;
        hightest = wall.endPoint.y > hightest ? wall.endPoint.y : hightest;
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
        [[UIColor blackColor] set];
        CGRect a =  CGRectMake(self.startPoint.x-6, self.startPoint.y-6, 6*2, 6*2);
        CGContextFillEllipseInRect(context, a);
    }
    if(!isOut){
        CGContextBeginPath(context);
        CGContextSetLineWidth(context, 2.0f);
        CGContextMoveToPoint(context, leftest, lowest-20);
        CGContextAddLineToPoint(context, rightest, lowest-20);
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context, leftest-20, lowest);
        CGContextAddLineToPoint(context, leftest-20, hightest);
        CGContextStrokePath(context);
        
        CGPoint drawx;
        CGPoint drawy;
        for(Wall *wall in self.wallArray)
        {
            if(wall.wallType == Horizon){
//                drawx = wall.startPoint;
//                CGContextMoveToPoint(context, drawx.x, lowest-30);
//                CGContextAddLineToPoint(context, drawx.x, lowest-10);
//                CGContextStrokePath(context);
//                drawx = wall.endPoint;
//                CGContextMoveToPoint(context, drawx.x, lowest-30);
//                CGContextAddLineToPoint(context, drawx.x, lowest-10);
//                CGContextStrokePath(context);
                drawy = wall.startPoint;
                CGContextMoveToPoint(context, leftest-30, drawy.y);
                CGContextAddLineToPoint(context, leftest-10, drawy.y);
                CGContextStrokePath(context);
            }
            else if(wall.wallType == Vertical)
            {
//                drawy = wall.startPoint;
//                CGContextMoveToPoint(context, leftest-30, drawy.y);
//                CGContextAddLineToPoint(context, leftest-10, drawy.y);
//                CGContextStrokePath(context);
//                drawy = wall.endPoint;
//                CGContextMoveToPoint(context, leftest-30, drawy.y);
//                CGContextAddLineToPoint(context, leftest-10, drawy.y);
//                CGContextStrokePath(context);
                drawx = wall.startPoint;
                CGContextMoveToPoint(context, drawx.x, lowest-30);
                CGContextAddLineToPoint(context, drawx.x, lowest-10);
                CGContextStrokePath(context);
            }
        }
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
            CGPoint translate = [recognizer translationInView:self];
            [recognizer setTranslation:CGPointMake(0, 0) inView:self];
            [self panCanvas:CGPointMake(translate.x, translate.y)];
            [self setNeedsDisplay];
        }
        else if((long)[recognizer state] == (long)UIGestureRecognizerStateEnded){
//            CGPoint end = [recognizer locationInView:self];
//            float offsetX = end.x - self.startPoint.x;
//            float offsetY = end.y - self.startPoint.y;
//            [self panCanvas:offsetX/100 offsetY:offsetY/100];
//            [self setNeedsDisplay];
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
//            CGPoint endPoint = [recognizer locationInView:self];
//            NSLog(@"end :  x:%f , y:%f",endPoint.x,endPoint.y);
//            int xOy = [self.mathUtil isXorY:self.currentWall.startPoint anotherPoint:endPoint];
            int index = (int)self.wallArray.count-1;
            [self.wallArray removeObjectAtIndex:index];
//            self.currentWall.endPoint = xOy == 0 ? CGPointMake(endPoint.x,self.currentWall.startPoint.y) : CGPointMake(self.currentWall.startPoint.x, endPoint.y);
//            self.currentWall.wallType = xOy;
            [self.currentWall redefine];
            if([self mixWall:self.currentWall])
            {

            }
            else
            {
                Wall *wall = self.currentWall;
                [self.wallArray addObject:wall];
            }
//            Wall *wall = self.currentWall;
//            [self.wallArray addObject:wall];
            [self setNeedsDisplay];
            self.isAddingWall = NO;
        }
    }
}

-(void)pinchGestureDetected:(UIPinchGestureRecognizer *)recognizer{
    if((long)[recognizer state] == (long)UIGestureRecognizerStateBegan){
        if(zoomScale == 1.0f)
        {
            [self pinchStart];
        }
        zoomTemp = zoomScale;
    }else if((long)[recognizer state] == (long)UIGestureRecognizerStateChanged){
        CGFloat currentScale = recognizer.scale * zoomTemp;
        if(currentScale > 1){
            zoomScale = zoomTemp * recognizer.scale;
            [self pinchChanges:currentScale];
        }
        else{
            zoomScale = 1.0f;
            [self pinchReset];
        }
    }else if((long)[recognizer state] == (long)UIGestureRecognizerStateEnded){
        zoomScale = zoomTemp * recognizer.scale;
        if(zoomScale <= 1.0f){
            zoomScale = 1.0f;
            [self pinchReset];
        }
    }
}

#pragma mark - helper
//在墙面上找到点
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
//检测线
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
//拖动
-(void)panCanvas:(float)offsetX offsetY:(float)offsetY{
    for(Wall *wall in self.wallArray)
    {
        wall.startPoint = CGPointMake(wall.startPoint.x+offsetX, wall.startPoint.y+offsetY);
        wall.endPoint = CGPointMake(wall.endPoint.x+offsetX, wall.endPoint.y+offsetY);
    }
}
//拖动的正确方法
-(void)panCanvas:(CGPoint)point{
    for(Wall *wall in self.wallArray)
    {
        CGPoint start = CGPointMake(wall.startPoint.x+point.x, wall.startPoint.y+point.y);
        CGPoint end = CGPointMake(wall.endPoint.x+point.x, wall.endPoint.y+point.y);
        wall.startPoint = start;
        wall.endPoint = end;
        
        if(zoomScale > 1.0f){
//            Wall *wallOrigin = [self.wallArrayOrigin objectAtIndex:<#(NSUInteger)#>]
        }
    }
    for(int i = 0;i < self.wallArray.count;i++){
        
    }
}
//检测一面墙是否在屏幕外
-(BOOL)isWallOutScreen:(Wall *)wall{
    if([self isPointOutScreen:wall.startPoint] || [self isPointOutScreen:wall.endPoint]){
        return YES;
    }
    return NO;
}
//检测一个点是否在屏幕外
-(BOOL)isPointOutScreen:(CGPoint)point{
    float height = self.bounds.size.height;
    float width = self.bounds.size.width;
    if(point.x > 0 && point.x < width && point.y > 0 && point.y < height)
    {
        return NO;
    }
    return YES;
}
//墙体融合
-(BOOL)mixWall:(Wall *)wall{
    if(wall.wallType == Horizon){
        for(Wall *wall1 in self.wallArray)
        {
            if(wall1.wallType == Horizon && [self isWallsInLine:wall anotherWall:wall1])
            {
                if([self comparePoint:wall1.startPoint anotherPoint:wall.startPoint]){
                    wall1.startPoint = wall.startPoint;
                }
                if([self comparePoint:wall.endPoint anotherPoint:wall1.endPoint])
                {
                    wall1.endPoint = wall.endPoint;
                }
                return YES;
            }
        }
    }
    else
    {
        for(Wall *wall1 in self.wallArray)
        {
            if(wall1.wallType == Vertical && [self isWallsInLine:wall anotherWall:wall1])
            {
                if([self comparePoint:wall1.startPoint anotherPoint:wall.startPoint]){
                    wall1.startPoint = wall.startPoint;
                }
                if([self comparePoint:wall.endPoint anotherPoint:wall1.endPoint])
                {
                    wall1.endPoint = wall.endPoint;
                }
                return YES;
            }
        }
    }
    return NO;
}
//检测两个墙面是否在一条直线上并且可以融合
-(BOOL)isWallsInLine:(Wall *)wall1 anotherWall:(Wall *)wall2{
    CGPoint start1 = wall1.startPoint;
    CGPoint end1 = wall1.endPoint;
    CGPoint start2 = wall2.startPoint;
    CGPoint end2 = wall2.endPoint;
    if(wall1.wallType == Horizon && wall1.startPoint.y == wall2.startPoint.y)
    {
        if([self comparePoint:start1 anotherPoint:start2])
        {
            if([self comparePoint:start1 anotherPoint:end2])
                return false;
        }
        if([self comparePoint:start2 anotherPoint:start1])
        {
            if([self comparePoint:start2 anotherPoint:end1])
                return false;
        }
        return true;
    }
    else if(wall1.wallType == Vertical && wall1.startPoint.x == wall2.startPoint.x){
        if([self comparePoint:start1 anotherPoint:start2])
        {
            if([self comparePoint:start1 anotherPoint:end2])
                return false;
        }
        if([self comparePoint:start2 anotherPoint:start1])
        {
            if([self comparePoint:start2 anotherPoint:end1])
                return false;
        }
        return true;
    }
    return false;
}
//比较两个点的大小
-(BOOL)comparePoint:(CGPoint)point1 anotherPoint:(CGPoint)point2{
    if(point1.x == point2.x){
        if(point1.y > point2.y)
            return YES;//point1大
        else
            return NO;
    }
    else{
        if(point1.x > point2.x)
            return YES;
        else
            return NO;
    }
}
//开始缩放
-(void)pinchStart{
    [self.wallArrayOrigin removeAllObjects];
    for(int i = 0;i < self.wallArray.count;i++){
        Wall *wall = [self.wallArray objectAtIndex:i];
        Wall *wallOrigin = [[Wall alloc] initWithAnotherWall:wall];
        [self.wallArrayOrigin addObject:wallOrigin];
    }
}
//缩放变化
-(void)pinchChanges:(CGFloat)scale{
    for(int i = 0;i < self.wallArray.count;i++){
        Wall *wallOrigin = self.wallArrayOrigin[i];
        CGPoint startOrigin = wallOrigin.startPoint;
        CGPoint endOrigin = wallOrigin.endPoint;
        
        Wall *wall = self.wallArray[i];
        wall.startPoint = CGPointMake(originX + (startOrigin.x - originX) * scale, originY + (startOrigin.y - originY) * scale);
        wall.endPoint = CGPointMake(originX + (endOrigin.x - originX) * scale, originY + (endOrigin.y - originY) * scale);
    }
    [self setNeedsDisplay];
}
//重新回到1比例
-(void)pinchReset{
    [self.wallArray removeAllObjects];
    for(int i = 0;i < self.wallArrayOrigin.count;i++){
        Wall *wall = [[Wall alloc] initWithAnotherWall:self.wallArrayOrigin[i]];
        [self.wallArray addObject:wall];
    }
    [self setNeedsDisplay];
}
@end
