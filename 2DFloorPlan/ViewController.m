//
//  ViewController.m
//  2DFloorPlan
//
//  Created by 黄乘风 on 2018/10/16.
//  Copyright © 2018年 黄乘风. All rights reserved.
//

#import "ViewController.h"
#import "Wall.h"
#import "CanvasView.h"

@interface ViewController ()
@property (nonatomic,strong) UIButton *addWall;
@property (nonatomic,strong) UIButton *undo;
@property (nonatomic,strong) CanvasView *canvas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)initUI{
    self.view.backgroundColor = [UIColor blackColor];
    
    CanvasView *canvas = [[CanvasView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [canvas initSource];
    self.canvas = canvas;
    [self.view addSubview:self.canvas];
    
    self.addWall = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 20 , 20)];
    self.addWall.backgroundColor = [UIColor blackColor];
//    [self.addWall setTitle:@"墙面" forState:UIControlStateNormal];
    [self.addWall setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addWall addTarget:self action:@selector(drag:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.addWall addTarget:self action:@selector(addWall:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addWall];
    
    self.undo = [[UIButton alloc] initWithFrame:CGRectMake(50, 90, 80, 30)];
    self.undo.backgroundColor = [UIColor blackColor];
    [self.undo setTitle:@"撤销墙体" forState:UIControlStateNormal];
    [self.undo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.undo addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.undo];
}

-(void)drag:(UIButton *)btn withEvent:ev
{
    CGPoint a = [[[ev allTouches] anyObject] locationInView:self.view];
    CGPoint b = CGPointMake(a.x + 30, a.y + 30);
    btn.center = a;
    [self.canvas addWall:a];
//    [self.canvas setNeedsDisplay];
}

-(void)addWall:(UIButton *)addWall withEvent:ev
{
    addWall.center = CGPointMake(20, 100);
    [self.canvas startPan];
}

-(void)undo:(UIButton *)undo{
    [self.canvas popWallArray];
}



@end
