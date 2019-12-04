//
//  ViewController.m
//  checkCarGraffiti
//
//  Created by 大豌豆 on 19/D/4.
//  Copyright © 2019 大碗豆. All rights reserved.
//

#import "ViewController.h"
#import "OriginalView.h"
#import "UIView+Extension.h"
#import "UIButton+ImageTitleSpacing.h"


#define SCREEN_WIDTH ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.width)
#define SCREENH_HEIGHT ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.height)
#define SCREEN_SIZE ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?CGSizeMake([UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale,[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale):[UIScreen mainScreen].bounds.size)

//判断是都为iPhoneX
#define iPhoneX [[UIScreen mainScreen] bounds].size.height == 896.0f || [[UIScreen mainScreen] bounds].size.height >= 812.0f
//导航栏+状态栏高度
#define STATUS_NAV_HEIGHT (iPhoneX ? 88.0 : 64.0)

@interface ViewController ()<UIGestureRecognizerDelegate>
//背景视图
@property (nonatomic, strong) UIScrollView *baseScorllView;
//顶部画布view
@property (nonatomic, strong) OriginalView *origview;

@property (nonatomic, strong) NSString *currentExmpleImgName;
//图片上已经画上的涂鸦数据
@property (nonatomic, strong) NSMutableArray *allScrArray;

/** 划痕程度数据  */
@property (nonatomic,strong) NSMutableArray *problemTypeArray;

/// 涂鸦照片展示
@property (nonatomic, strong) UIImageView *resultImag;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"验车";
    self.allScrArray = [[NSMutableArray alloc] init];
    
    self.problemTypeArray = [[NSMutableArray alloc]init];
    
    [self setUI];
}


- (void)setUI {
    
    UIScrollView *baseScorllView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, SCREEN_WIDTH, SCREENH_HEIGHT - STATUS_NAV_HEIGHT)];
    baseScorllView.showsVerticalScrollIndicator = NO;
    baseScorllView.showsHorizontalScrollIndicator = NO;
    baseScorllView.scrollEnabled = YES;
    baseScorllView.backgroundColor = [UIColor whiteColor];
    self.baseScorllView = baseScorllView;
    [self.view addSubview:baseScorllView];
    
    UILabel *topLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 20 * 2, 40)];
    topLab.textColor = [UIColor blackColor];
    topLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    topLab.backgroundColor = [UIColor whiteColor];
    topLab.text = @"外观检查";
    [baseScorllView addSubview:topLab];
    
    CGFloat scaleHeight = (200/375.0) * SCREEN_WIDTH;
    OriginalView *orview = [[OriginalView alloc] initWithFrame:CGRectMake(10, topLab.bottom + 5, SCREEN_WIDTH - 10 * 2, scaleHeight)];
    orview.backgroundColor = [UIColor whiteColor];
    UIImage *baseImg = [UIImage imageNamed:@"bg_checkCar"];
    orview.baseImage = baseImg;
    self.origview = orview;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(origviewGesture:)];
    tapGesture.numberOfTouchesRequired=1;
    tapGesture.numberOfTapsRequired=1;
    tapGesture.delegate = self;
    [orview addGestureRecognizer:tapGesture];
    [baseScorllView addSubview:orview];
    
    //说明
    UILabel *explainLab = [[UILabel alloc] initWithFrame:CGRectMake(20, orview.bottom + 10, baseScorllView.width - 40, 16)];
    explainLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    explainLab.textColor = [UIColor blackColor];
    explainLab.backgroundColor = [UIColor whiteColor];
    explainLab.text = @"说明：";
    [baseScorllView addSubview:explainLab];
    
    //图例
    UIView *legendView = [[UIView alloc] initWithFrame:CGRectMake(explainLab.x, explainLab.bottom + 10, explainLab.width, 20)];;
    legendView.backgroundColor = [UIColor whiteColor];
    [baseScorllView addSubview:legendView];
    
    NSArray *titleArray = @[@"划痕",@"缺少",@"裂痕",@"凹陷",@"脱落",@"其他"];
    for (NSInteger i = 0; i < titleArray.count;i ++) {
        CGFloat btnWidth = legendView.width/titleArray.count;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"checkCar_explain%ld", i]] forState:UIControlStateNormal];
        [button setTitle:titleArray[i] forState:(UIControlStateNormal)];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        button.frame = CGRectMake(i * btnWidth, 0, btnWidth, legendView.height);
        button.enabled = NO;
        [button layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:5];
        [legendView addSubview:button];
    }
    
    //指示标题
    UIView *selectStatuView = [[UIView alloc] initWithFrame:CGRectMake(legendView.x, legendView.bottom + 10, explainLab.width - 65, 30)];;
    selectStatuView.backgroundColor = [UIColor whiteColor];
    [baseScorllView addSubview:selectStatuView];
    NSArray *selectStatuArray = @[@"划",@"缺",@"裂",@"凹",@"脱",@"其"];
    
    for (NSInteger i = 0; i < selectStatuArray.count;i ++) {
        CGFloat btnWidth = 30;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:selectStatuArray[i] forState:(UIControlStateNormal)];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
        [button setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat margin = (selectStatuView.width - btnWidth * selectStatuArray.count) * 1.0/(selectStatuArray.count - 1);
        
        button.frame = CGRectMake(i * (btnWidth + margin), 0, btnWidth, btnWidth);
        button.layer.cornerRadius = btnWidth/2.0;
        button.layer.masksToBounds = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button addTarget:self action:@selector(selectStatuBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        button.tag = i;
        [selectStatuView addSubview:button];
    }
    //清除button
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn.frame = CGRectMake(selectStatuView.right + 5, selectStatuView.y, 60, selectStatuView.height);
    [clearBtn setTitle:@"擦除" forState:(UIControlStateNormal)];
    clearBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [clearBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    clearBtn.backgroundColor = [UIColor whiteColor];
    clearBtn.layer.cornerRadius = clearBtn.height * 1.0 /2;
    clearBtn.layer.masksToBounds = YES;
    clearBtn.layer.borderColor = [UIColor redColor].CGColor;
    clearBtn.layer.borderWidth = 0.5;
    [clearBtn addTarget:self action:@selector(clearBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [baseScorllView addSubview:clearBtn];
    
    UIButton *saveBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    saveBtn.frame = CGRectMake(20, clearBtn.bottom + 20, SCREEN_WIDTH - 20 * 2, 40);
    [saveBtn setTitle:@"保存" forState:(UIControlStateNormal)];
    saveBtn.backgroundColor = [UIColor orangeColor];
    [saveBtn addTarget:self action:@selector(saveBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
    [baseScorllView addSubview:saveBtn];
    
    UIImageView *resultImag = [[UIImageView alloc] initWithFrame:CGRectMake(10, saveBtn.bottom + 20, SCREEN_WIDTH - 10 * 2, scaleHeight)];
    self.resultImag = resultImag;
    [baseScorllView addSubview:resultImag];
    
    baseScorllView.contentSize = CGSizeMake(SCREEN_WIDTH, resultImag.bottom + 20);
}


//顶部图片手势
- (void)origviewGesture:(UITapGestureRecognizer *)Recognizer{
    if (self.currentExmpleImgName) {
        CGPoint point = [Recognizer locationInView:self.origview];
        CGRect rect = CGRectMake(point.x- 15* 0.5, point.y- 15* 0.5, 15, 15);
        NSLog(@"%@", NSStringFromCGPoint(point));
        
        for (NSDictionary *dic in self.allScrArray) {
            CGRect rectTmp = CGRectFromString(dic[@"rect"]);
            BOOL contains = CGRectContainsPoint(rectTmp, point);
            if (contains) {
                [self.allScrArray removeObject:dic];
                self.origview.imageArray = self.allScrArray;
                return;
            }
        }
        
        NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
        
        NSString *imgPoint = NSStringFromCGPoint(point);
        NSString *imgRect = NSStringFromCGRect(rect);
        
        [tmpDic setValue:imgRect forKey:@"rect"];
        [tmpDic setValue:imgPoint forKey:@"Point"];
        
        [tmpDic setValue:self.currentExmpleImgName forKey:@"imageName"];
        [self.allScrArray addObject:tmpDic];
        self.origview.imageArray = self.allScrArray;
    }else {
        return;
    }
}

//图例选择
- (void)selectStatuBtnAction:(UIButton *)btn {
    for (UIButton *tmpbtn in btn.superview.subviews) {
        tmpbtn.selected = NO;
        tmpbtn.backgroundColor = [UIColor whiteColor];
    }
    btn.selected = YES;
    btn.backgroundColor = [UIColor cyanColor];
    self.currentExmpleImgName = [NSString stringWithFormat:@"checkCar_explain%ld",btn.tag];
    [self.problemTypeArray addObject:@(btn.tag + 1)];
}

//清除
- (void)clearBtnAction:(UIButton *)clearBtn{
    
    if (self.allScrArray.count > 0) {
        [self.allScrArray removeLastObject];
        self.origview.imageArray = self.allScrArray;
    }
}
//保存
- (void)saveBtnAction{
    //画布图片存储
    UIGraphicsBeginImageContext(self.origview.frame.size);
    [self.origview.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = [[NSData alloc]init];
    imageData = UIImageJPEGRepresentation(viewImage, 0.5);
    self.resultImag.image = viewImage;
}
@end
