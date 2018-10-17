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
    [canvas initArray];
    self.canvas = canvas;
    [self.view addSubview:self.canvas];
    
    self.addWall = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 100 , 50)];
    self.addWall.backgroundColor = [UIColor whiteColor];
    [self.addWall setTitle:@"墙面" forState:UIControlStateNormal];
    [self.addWall setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addWall addTarget:self action:@selector(addWall:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addWall];
}

-(void)addWall:(UIButton *)addWall
{
    [self.canvas addWall];
}




@end
