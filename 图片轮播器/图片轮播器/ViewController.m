//
//  ViewController.m
//  图片轮播器
//
//  Created by 章芝源 on 16/1/13.
//  Copyright © 2016年 ZZY. All rights reserved.
//

///图片轮播器
#import "ViewController.h"
//define this constant if you want to use Masonry without the 'mas_' prefix
#define MAS_SHORTHAND

//define this constant if you want to enable auto-boxing for default syntax
#define MAS_SHORTHAND_GLOBALS

#import <Masonry.h>
#define ZYIMAGECOUNT 5
#define ZYSCROLLWIDTH 300
#define ZYSCROLLHEIGHT 130
@interface ViewController ()<UIScrollViewDelegate>
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)UIPageControl *pageControl;
//三张图片
@property(nonatomic, strong)UIImageView *leftImageView;
@property(nonatomic, strong)UIImageView *rightImageView;
@property(nonatomic, strong)UIImageView *centerImageView;
//当前索引
@property(assign, nonatomic)int currentImageIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  
    
    //设置UI
    [self setupUI];
}

#pragma mark - 设置UI部分

- (void)setupUI
{
    //添加图片到scrollView
    self.leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ZYSCROLLWIDTH, ZYSCROLLHEIGHT)];
    NSLog(@"%@", self.scrollView);
    self.leftImageView.image = [UIImage imageNamed:@"img_04"];
    [self.scrollView addSubview:self.leftImageView];
    
    self.centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(ZYSCROLLWIDTH, 0, ZYSCROLLWIDTH, ZYSCROLLHEIGHT)];
    self.centerImageView.image = [UIImage imageNamed:@"img_00"];
    [self.scrollView addSubview:self.centerImageView];
    
    self.rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(ZYSCROLLWIDTH * 2, 0, ZYSCROLLWIDTH, ZYSCROLLHEIGHT)];
    self.rightImageView.image = [UIImage imageNamed:@"img_01"];
    [self.scrollView addSubview:self.rightImageView];

    //默认选中第一张图片
    CGPoint pointOffset = CGPointMake(ZYSCROLLWIDTH, 0);
    [self.scrollView setContentOffset:pointOffset animated:NO];
    
    
    //pageControl
    UIPageControl *pageControl = [[UIPageControl alloc]init];
    pageControl.numberOfPages = 5;
    pageControl.currentPage = 0;
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
    [pageControl makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView).multipliedBy(0.5);
        make.width.equalTo(self.scrollView).multipliedBy(0.5);
        make.bottom.equalTo(self.scrollView.bottom).offset(20);
    }];
    
    //给self控制器添加定时器
    [self addTimer];

    
    //测试多线程:  创建textView
    UITextView *textView = [[UITextView alloc]init];
    [self.view addSubview:textView];
    textView.font = [UIFont systemFontOfSize:40];
    textView.text = @"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxx xxxxxxxxxxxxxxxx xxxxxxxx";
    [textView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.scrollView);
        make.height.equalTo(self.view).multipliedBy(0.3);
        make.right.equalTo(self.scrollView);
        make.topMargin.equalTo(self.scrollView.bottom).offset(30);
    }];
}

- (void)addTimer
{
     [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(offset) userInfo:nil repeats:YES];
}

//偏移
- (void)offset
{
    int page = (self.pageControl.currentPage + 1) % ZYIMAGECOUNT;
    self.pageControl.currentPage = page;
    [self.scrollView setContentOffset:CGPointMake(2 * ZYSCROLLWIDTH, 0) animated:YES];
}

#pragma mark scrollView代理
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
   
    [self setupPictureMove];
}

//当前偏移结束之后,  将三张图片替换调
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self setupPictureMove];
}

- (void)setupPictureMove
{
    //重新加载图片
    [self reloadImage];
    //移动到中间
    [self.scrollView setContentOffset:CGPointMake(ZYSCROLLWIDTH, 0) animated:NO];
    //    //设置分页点
    self.pageControl.currentPage = self.currentImageIndex;
}


#pragma mark 重新加载图片
-(void)reloadImage{
    int leftImageIndex, rightImageIndex;
    //当offset移动了到了最后一张图片的距离, 将图片换一个位置第一张图片, 放到图片列表最后
    CGPoint offsetOpint = self.scrollView.contentOffset;

    if (offsetOpint.x > ZYSCROLLWIDTH) {
        self.currentImageIndex = (self.currentImageIndex + 1) % ZYIMAGECOUNT;
        
    //到offset移动到了第一张图片的位置,  将最后一张图片放到图片列表最前面
    }else if (offsetOpint.x < ZYSCROLLWIDTH){
        //图片总数- 1 加 当前图片index  取余 图片总数
        self.currentImageIndex = (self.currentImageIndex + ZYIMAGECOUNT -1 ) % ZYIMAGECOUNT;
    }
    //左边的数, 等于中间的数 与 总数-1  的和  取 总数的余
    leftImageIndex = (self.currentImageIndex + ZYIMAGECOUNT - 1) % ZYIMAGECOUNT;
    //右边的数, 等于中间的数+1 取总数的余
    rightImageIndex = (self.currentImageIndex + 1) % ZYIMAGECOUNT;
    
    //设置图片
    self.centerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"img_0%d", self.currentImageIndex]];
    self.leftImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"img_0%d", leftImageIndex]];
    NSString *rightImage = [NSString stringWithFormat:@"img_0%d", rightImageIndex];
    self.rightImageView.image = [UIImage imageNamed:rightImage];
}

#pragma mark - 懒加载
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        CGFloat scrollViewH = 130;
        CGFloat scrollViewW = 300;
        CGFloat scrollViewX = ([UIScreen mainScreen].bounds.size.width - scrollViewW) / 2;
        _scrollView.frame = CGRectMake(scrollViewX, 50, scrollViewW, scrollViewH);
        [self.view addSubview:_scrollView];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        self.scrollView = _scrollView;
        self.scrollView.contentSize = CGSizeMake(3 * ZYSCROLLWIDTH, 0);
    }
    return _scrollView;
}

@end
