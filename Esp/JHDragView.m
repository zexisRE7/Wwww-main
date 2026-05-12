#import "JHDragView.h"

@interface JHDragView ()
@end

@implementation JHDragView

- (instancetype)initWithFrame:(CGRect)frame {
    // กำหนดขนาดเริ่มต้น (ถ้า frame ไม่ถูกต้อง)
    if (CGRectGetWidth(frame) <= 0 || CGRectGetHeight(frame) <= 0) {
        frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 200, 130, 65, 65);
    }

    self = [super initWithFrame:frame];
    if (self) {
        // พื้นหลังโปร่งแสง (ดำจางๆ)
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
        self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
        self.clipsToBounds = YES;
        
        // Shadow (เงา) ให้ดูมีมิติ
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.4;
        self.layer.shadowRadius = 8;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.masksToBounds = NO;

        // Avatar image (รูปโปรไฟล์)
        UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
        avatar.layer.cornerRadius = 22.5;
        avatar.clipsToBounds = YES;
        avatar.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:avatar];

        // ดาวน์โหลดรูปจาก URL
        NSURL *url = [NSURL URLWithString:@"https://i.postimg.cc/fR2mymsn/IMG-0612.jpg"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    avatar.image = image;
                });
            }
        });
    }
    return self;
}

#pragma mark - Touch (ลากได้)

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

#pragma mark - Stay in Screen (ไม่ให้หลุดจอ)

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
