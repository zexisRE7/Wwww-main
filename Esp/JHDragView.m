#import "JHDragView.h"

@interface JHDragView ()
@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, assign) CFTimeInterval lastTimestamp;
@end

@implementation JHDragView

- (instancetype)initWithFrame:(CGRect)frame {
    if (CGRectGetWidth(frame) <= 0 || CGRectGetHeight(frame) <= 0) {
        frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 200, 130, 65, 65);
    }

    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
        self.clipsToBounds = YES;

        // Avatar image
        UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
        avatar.layer.cornerRadius = 22.5;
        avatar.clipsToBounds = YES;
        avatar.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:avatar];

        NSURL *url = [NSURL URLWithString:@"https://files.manuscdn.com/user_upload_by_module/session_file/310519663282347718/jqJIxfyTTlsjRdyT.JPG"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    avatar.image = image;
                });
            }
        });

        // FPS Label
        self.fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 18, CGRectGetWidth(self.bounds), 15)];
        self.fpsLabel.font = [UIFont boldSystemFontOfSize:10];
        self.fpsLabel.textAlignment = NSTextAlignmentCenter;
        self.fpsLabel.textColor = [UIColor greenColor];
        self.fpsLabel.text = @"60 FPS";
        [self addSubview:self.fpsLabel];

        // Gradient Border
        [self setupGradientBorder];

        // FPS Monitor
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFPS:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)setupGradientBorder {
    CAShapeLayer *borderShape = [CAShapeLayer layer];
    borderShape.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
    borderShape.lineWidth = 3.0;
    borderShape.fillColor = [UIColor clearColor].CGColor;
    borderShape.strokeColor = [UIColor whiteColor].CGColor;

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(-self.bounds.size.width, 0, self.bounds.size.width * 3, self.bounds.size.height);
    gradient.colors = @[
        (__bridge id)[UIColor redColor].CGColor,
        (__bridge id)[UIColor orangeColor].CGColor,
        (__bridge id)[UIColor yellowColor].CGColor,
        (__bridge id)[UIColor greenColor].CGColor,
        (__bridge id)[UIColor blueColor].CGColor,
        (__bridge id)[UIColor purpleColor].CGColor,
        (__bridge id)[UIColor redColor].CGColor
    ];
    gradient.startPoint = CGPointMake(0, 0.5);
    gradient.endPoint = CGPointMake(1, 0.5);

    CALayer *container = [CALayer layer];
    container.frame = self.bounds;
    container.mask = borderShape;
    [container addSublayer:gradient];
    [self.layer addSublayer:container];

    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.x"];
    move.fromValue = @(-self.bounds.size.width);
    move.toValue = @(self.bounds.size.width * 2);
    move.duration = 4.0;
    move.repeatCount = HUGE_VALF;
    move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [gradient addAnimation:move forKey:@"move"];
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    self.center = point;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self shouldResetFrame];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self shouldResetFrame];
}

#pragma mark - FPS

- (void)updateFPS:(CADisplayLink *)link {
    static NSInteger count = 0;
    static CFTimeInterval last = 0;

    if (last == 0) {
        last = link.timestamp;
        return;
    }

    count++;
    CFTimeInterval delta = link.timestamp - last;
    if (delta >= 1.0) {
        NSInteger fps = (NSInteger)(count / delta);
        self.fpsLabel.text = [NSString stringWithFormat:@"%ld FPS", (long)fps];
        self.fpsLabel.textColor = fps >= 55 ? [UIColor greenColor] : [UIColor redColor];
        count = 0;
        last = link.timestamp;
    }
}

#pragma mark - Stay in Screen

- (void)shouldResetFrame {
    CGFloat maxX = CGRectGetWidth(self.superview.frame);
    CGFloat maxY = CGRectGetHeight(self.superview.frame);
    CGRect frame = self.frame;

    if (CGRectGetMinX(frame) < 0) frame.origin.x = 0;
    if (CGRectGetMaxX(frame) > maxX) frame.origin.x = maxX - CGRectGetWidth(frame);
    if (CGRectGetMinY(frame) < 0) frame.origin.y = 0;
    if (CGRectGetMaxY(frame) > maxY) frame.origin.y = maxY - CGRectGetHeight(frame);

    self.frame = frame;
}

@end

