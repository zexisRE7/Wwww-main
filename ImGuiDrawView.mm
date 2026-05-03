//Require standard library
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include <iostream>
#include <UIKit/UIKit.h>
#include <vector>
#import <sys/sysctl.h>
#import "pthread.h"
#include <array>
#import <os/log.h>
#include <cmath>
#include <deque>
#include <fstream>
#include <algorithm>
#include <string>
#include <sstream>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <cstdint>
#include <cinttypes>
#include <cerrno>
#include <cctype>
//Imgui library
#import "Esp/CaptainHook.h"
#import "Esp/ImGuiDrawView.h"
#import "IMGUI/imgui.h"
#import "IMGUI/imgui_internal.h"
#import "IMGUI/imgui_impl_metal.h"
#import "IMGUI/zzz.h"
//#import "Hosts/NSObject+URL.h"
#include "oxorany/oxorany_include.h"
#import "Helper/Mem.h"
#include "font.h"
#import "Helper/Vector3.h"
#import "Helper/Vector2.h"
#import "Helper/Quaternion.h"
#import "Helper/Monostring.h"
#include "Helper/font.h"
#include "Helper/data.h"
ImFont* verdana_smol;
ImFont* pixel_big = {};
ImFont* pixel_smol = {};
#include "Helper/Obfuscate.h"
#import "Helper/Hooks.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <unistd.h>
#include <string.h>
#include "Other/dobby_defines.h"
#import "Other/H5hook.h"
#include "Other/Paste.h"

#define Hook(x, y, z) \
{ \
    NSString* result_##y = StaticInlineHookPatch(("Frameworks/UnityFramework.framework/UnityFramework"), x, nullptr); \
    if (result_##y) { \
        void* result = StaticInlineHookFunction(("Frameworks/UnityFramework.framework/UnityFramework"), x, (void *) y); \
        *(void **) (&z) = (void*) result; \
    } \
}

static float fixLoginTimeout = 60.0f;
static bool MenDeal = true;

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale  [UIScreen mainScreen].scale

BOOL isJailbroken() {
    NSArray *jailbreakPaths = @[
        @"/Applications/Cydia.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/bin/bash",
        @"/usr/sbin/sshd",
        @"/etc/apt",
        @"/private/var/lib/apt/"
    ];
    for (NSString *path in jailbreakPaths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    }
    NSError *error;
    NSString *testPath = @"/private/jb_test.txt";
    [@"test" writeToFile:testPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        [[NSFileManager defaultManager] removeItemAtPath:testPath error:nil];
        return YES;
    }
    return NO;
}

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, assign) CGRect menuBounds;
@property (nonatomic, strong) UIButton *ninjaRunButtonView;
@property (nonatomic, strong) UISwitch *ninjaRunSwitch;
@property (nonatomic, assign) BOOL ninjaRunButtonVisible;
@property (nonatomic, strong) UIView *menu;

// ✅ UIButtons ลอย
@property (nonatomic, strong) UIButton *flyButton;
@property (nonatomic, strong) UISwitch *flySwitch;
@property (nonatomic, strong) UIButton *telekillButton;
@property (nonatomic, strong) UISwitch *telekillSwitch;
@property (nonatomic, strong) UIButton *aimkillButton;
@property (nonatomic, strong) UISwitch *aimkillSwitch;
@property (nonatomic, strong) UIButton *norecoilButton;
@property (nonatomic, strong) UISwitch *norecoilSwitch;
@property (nonatomic, strong) UIButton *markTPButton;
@property (nonatomic, strong) UISwitch *markTPSwitch;
@property (nonatomic, strong) UIButton *autoTPButton;
@property (nonatomic, strong) UISwitch *autoTPSwitch;

@end

static __weak ImGuiDrawView *g_DrawView = nil;

@implementation ImGuiDrawView
ImFont *_espFont;
ImFont* verdanab;
ImFont* icons;
ImFont* interb;
ImFont* Urbanist;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    g_DrawView = self;
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    if (!self.device) abort();

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    ImGui::StyleColorsDark();

    auto& s = ImGui::GetStyle();
    s.WindowPadding     = ImVec2(0, 0);
    s.ItemSpacing       = ImVec2(0, 0);
    s.WindowRounding    = 8.0f;
    s.ChildRounding     = 0.0f;
    s.FrameRounding     = 4.0f;
    s.ScrollbarRounding = 4.0f;
    s.WindowBorderSize  = 0.0f;

    ImVec4* c = s.Colors;
    c[ImGuiCol_WindowBg]             = ImVec4(0.118f, 0.118f, 0.125f, 1.00f);
    c[ImGuiCol_ChildBg]              = ImVec4(0.000f, 0.000f, 0.000f, 0.00f);
    c[ImGuiCol_Border]               = ImVec4(0.000f, 0.000f, 0.000f, 0.00f);
    c[ImGuiCol_ScrollbarBg]          = ImVec4(0.000f, 0.000f, 0.000f, 0.00f);
    c[ImGuiCol_ScrollbarGrab]        = ImVec4(0.55f, 0.20f, 0.22f, 0.85f);
    c[ImGuiCol_ScrollbarGrabHovered] = ImVec4(0.75f, 0.28f, 0.30f, 1.00f);
    c[ImGuiCol_ScrollbarGrabActive]  = ImVec4(0.45f, 0.16f, 0.18f, 1.00f);

    ImFont* font = io.Fonts->AddFontFromMemoryTTF(sansbold, sizeof(sansbold), 18.0f, NULL, io.Fonts->GetGlyphRangesCyrillic());
    verdana_smol = io.Fonts->AddFontFromMemoryTTF(verdana, sizeof verdana, 40, NULL, io.Fonts->GetGlyphRangesCyrillic());
    pixel_big    = io.Fonts->AddFontFromMemoryTTF((void*)smallestpixel, sizeof smallestpixel, 128, NULL, io.Fonts->GetGlyphRangesCyrillic());
    pixel_smol   = io.Fonts->AddFontFromMemoryTTF((void*)smallestpixel, sizeof smallestpixel, 20,  NULL, io.Fonts->GetGlyphRangesCyrillic());
    ImGui_ImplMetal_Init(_device);
    return self;
}

+ (void)showChange:(BOOL)open { MenDeal = open; }
- (MTKView *)mtkView { return (MTKView *)self.view; }

- (void)loadView {
    CGFloat w = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
    CGFloat h = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
    Hook(0x4EB3E88, BLAGCMCGEJG1, old_BLAGCMCGEJG1);
    
    // ✅ สร้างปุ่มลอย (ซ่อนไว้ก่อน — ต้องเปิดจากเมนูถึงจะโผล่)
    [self createFlyButton];
    [self createTelekillButton];
    [self createAimkillButton];
    [self createNoRecoilButton];
    [self createMarkTPButton];
    [self createAutoTPButton];
    [self updateFloatButtonsVisibility];
}

//  UIButtons 
- (void)createFlyButton {
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    if (!mainWindow) mainWindow = [UIApplication sharedApplication].windows.firstObject;
    
    self.flyButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 58, 74)];
    self.flyButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.92];
    self.flyButton.layer.cornerRadius = 10;
    self.flyButton.layer.borderWidth = 1;
    self.flyButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.flyButton addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [mainWindow addSubview:self.flyButton];
    [mainWindow bringSubviewToFront:self.flyButton];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 58, 20)];
    label.text = @"FLY MOVE";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:11];
    label.textAlignment = NSTextAlignmentCenter;
    [self.flyButton addSubview:label];

    self.flySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(3, 28, 51, 31)];
    self.flySwitch.onTintColor = [UIColor blackColor];
    self.flySwitch.on = ZX_FlyAlt;
    [self.flySwitch addTarget:self action:@selector(flySwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.flyButton addSubview:self.flySwitch];
}

- (void)createTelekillButton {
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    if (!mainWindow) mainWindow = [UIApplication sharedApplication].windows.firstObject;
    
    self.telekillButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 184, 58, 74)];
    self.telekillButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.92];
    self.telekillButton.layer.cornerRadius = 10;
    self.telekillButton.layer.borderWidth = 1;
    self.telekillButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.telekillButton addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [mainWindow addSubview:self.telekillButton];
    [mainWindow bringSubviewToFront:self.telekillButton];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 58, 20)];
    label.text = @"TELEKILL";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:11];
    label.textAlignment = NSTextAlignmentCenter;
    [self.telekillButton addSubview:label];

    self.telekillSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(3, 28, 51, 31)];
    self.telekillSwitch.onTintColor = [UIColor blackColor];
    self.telekillSwitch.on = ZX_Telekill;
    [self.telekillSwitch addTarget:self action:@selector(telekillSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.telekillButton addSubview:self.telekillSwitch];
}

- (void)createAimkillButton {
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    if (!mainWindow) mainWindow = [UIApplication sharedApplication].windows.firstObject;
    
    self.aimkillButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 268, 58, 74)];
    self.aimkillButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.92];
    self.aimkillButton.layer.cornerRadius = 10;
    self.aimkillButton.layer.borderWidth = 1;
    self.aimkillButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.aimkillButton addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [mainWindow addSubview:self.aimkillButton];
    [mainWindow bringSubviewToFront:self.aimkillButton];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 58, 20)];
    label.text = @"AIMKILL V2";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:11];
    label.textAlignment = NSTextAlignmentCenter;
    [self.aimkillButton addSubview:label];

    self.aimkillSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(3, 28, 51, 31)];
    self.aimkillSwitch.onTintColor = [UIColor blackColor];
    self.aimkillSwitch.on = ZX_AimKill;
    [self.aimkillSwitch addTarget:self action:@selector(aimkillSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.aimkillButton addSubview:self.aimkillSwitch];
}

- (void)createNoRecoilButton {
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    if (!mainWindow) mainWindow = [UIApplication sharedApplication].windows.firstObject;
    
    self.norecoilButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 352, 58, 74)];
    self.norecoilButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.92];
    self.norecoilButton.layer.cornerRadius = 10;
    self.norecoilButton.layer.borderWidth = 1;
    self.norecoilButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.norecoilButton addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [mainWindow addSubview:self.norecoilButton];
    [mainWindow bringSubviewToFront:self.norecoilButton];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 58, 20)];
    label.text = @"NORELOAD";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:11];
    label.textAlignment = NSTextAlignmentCenter;
    [self.norecoilButton addSubview:label];

    self.norecoilSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(3, 28, 51, 31)];
    self.norecoilSwitch.onTintColor = [UIColor blackColor];
    self.norecoilSwitch.on = ZX_NoRecoil;
    [self.norecoilSwitch addTarget:self action:@selector(norecoilSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.norecoilButton addSubview:self.norecoilSwitch];
}

- (void)createMarkTPButton {
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    if (!mainWindow) mainWindow = [UIApplication sharedApplication].windows.firstObject;

    self.markTPButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 436, 58, 74)];
    self.markTPButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.92];
    self.markTPButton.layer.cornerRadius = 10;
    self.markTPButton.layer.borderWidth = 1;
    self.markTPButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.markTPButton addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [mainWindow addSubview:self.markTPButton];
    [mainWindow bringSubviewToFront:self.markTPButton];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 58, 20)];
    label.text = @"TP MARK";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:11];
    label.textAlignment = NSTextAlignmentCenter;
    [self.markTPButton addSubview:label];

    self.markTPSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(3, 28, 51, 31)];
    self.markTPSwitch.onTintColor = [UIColor blackColor];
    self.markTPSwitch.on = ZX_MarkTeleport;
    [self.markTPSwitch addTarget:self action:@selector(markTPSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.markTPButton addSubview:self.markTPSwitch];
}

- (void)createAutoTPButton {
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    if (!mainWindow) mainWindow = [UIApplication sharedApplication].windows.firstObject;

    self.autoTPButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 520, 58, 74)];
    self.autoTPButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.92];
    self.autoTPButton.layer.cornerRadius = 10;
    self.autoTPButton.layer.borderWidth = 1;
    self.autoTPButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.autoTPButton addTarget:self action:@selector(buttonDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [mainWindow addSubview:self.autoTPButton];
    [mainWindow bringSubviewToFront:self.autoTPButton];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 58, 20)];
    label.text = @"AIMKILL";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:11];
    label.textAlignment = NSTextAlignmentCenter;
    [self.autoTPButton addSubview:label];

    self.autoTPSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(3, 28, 51, 31)];
    self.autoTPSwitch.onTintColor = [UIColor blackColor];
    self.autoTPSwitch.on = ZX_AutoTeleport;
    [self.autoTPSwitch addTarget:self action:@selector(autoTPSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.autoTPButton addSubview:self.autoTPSwitch];
}

- (void)updateFloatButtonsVisibility {
    self.flyButton.hidden      = !ZX_ShowFlyBtn;
    self.telekillButton.hidden = !ZX_ShowTelekillBtn;
    self.aimkillButton.hidden  = !ZX_ShowAimkillBtn;
    self.norecoilButton.hidden = !ZX_ShowNorecoilBtn;
    self.markTPButton.hidden   = !ZX_ShowMarkTPBtn;
    self.autoTPButton.hidden   = !ZX_ShowAutoTPBtn;
    
    // ✅ ซิงก์สถานะสวิตช์ให้ตรงกับ ZX_var (เผื่อกดเปิดจากเมนู)
    if (self.flySwitch.on      != ZX_FlyAlt)       self.flySwitch.on      = ZX_FlyAlt;
    if (self.telekillSwitch.on != ZX_Telekill)     self.telekillSwitch.on = ZX_Telekill;
    if (self.aimkillSwitch.on  != ZX_AimKill)      self.aimkillSwitch.on  = ZX_AimKill;
    if (self.norecoilSwitch.on != ZX_NoRecoil)     self.norecoilSwitch.on = ZX_NoRecoil;
    if (self.markTPSwitch.on   != ZX_MarkTeleport) self.markTPSwitch.on   = ZX_MarkTeleport;
    if (self.autoTPSwitch.on   != ZX_AutoTeleport) self.autoTPSwitch.on   = ZX_AutoTeleport;
}

- (void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:button] anyObject];
    CGPoint prev = [touch previousLocationInView:button.superview];
    CGPoint curr = [touch locationInView:button.superview];
    button.center = CGPointMake(button.center.x + (curr.x - prev.x), button.center.y + (curr.y - prev.y));
}

- (void)flySwitchChanged:(UISwitch *)sender {
    ZX_FlyAlt = sender.on;
    Vars.FlyUp = ZX_FlyAlt;
}

- (void)telekillSwitchChanged:(UISwitch *)sender {
    ZX_Telekill = sender.on;
    Vars.Telekill = ZX_Telekill;
}

- (void)aimkillSwitchChanged:(UISwitch *)sender {
    ZX_AimKill = sender.on;
    Vars.AimKill = ZX_AimKill;
}

- (void)norecoilSwitchChanged:(UISwitch *)sender {
    ZX_NoRecoil = sender.on;
    Vars.NoRecoil = ZX_NoRecoil;
}

- (void)markTPSwitchChanged:(UISwitch *)sender {
    ZX_MarkTeleport = sender.on;
    Vars.MarkTeleport = ZX_MarkTeleport;
}

- (void)autoTPSwitchChanged:(UISwitch *)sender {
    ZX_AutoTeleport = sender.on;
    Vars.AutoTeleport = ZX_AutoTeleport;
}

// ui

// 🟥 MODDER %7 THEME — ดำ + แดงเลือดหมู
static const ImU32 ZX_WIN_BG        = IM_COL32( 12,   8,  10, 252);
static const ImU32 ZX_TITLE_BG      = IM_COL32( 25,  10,  12, 255);
static const ImU32 ZX_PANEL_BG      = IM_COL32( 14,   8,  10, 255);
static const ImU32 ZX_PANEL_BORDER  = IM_COL32(120,  25,  30, 255);
static const ImU32 ZX_SIDE_BTN_BG   = IM_COL32( 30,  12,  14, 255);
static const ImU32 ZX_SIDE_BTN_ACT  = IM_COL32( 70,  18,  22, 255);
static const ImU32 ZX_SIDE_BORDER   = IM_COL32(100,  25,  30, 255);
static const ImU32 ZX_SIDE_BORDER_A = IM_COL32(220,  40,  50, 255);
static const ImU32 ZX_TAB_TEXT      = IM_COL32(245, 245, 250, 255);
static const ImU32 ZX_TAB_TEXT_DIM  = IM_COL32(180, 180, 190, 255);
static const ImU32 ZX_TAB_UNDERLINE = IM_COL32(220,  40,  50, 255);
static const ImU32 ZX_TAB_DIV       = IM_COL32( 90,  20,  25, 200);
static const ImU32 ZX_SEP           = IM_COL32( 70,  18,  22, 200);
static const ImU32 ZX_SECTION       = IM_COL32(230, 230, 235, 255);
static const ImU32 ZX_SUB           = IM_COL32(170, 170, 180, 255);
static const ImU32 ZX_TEXT          = IM_COL32(235, 235, 240, 255);
static const ImU32 ZX_TEXT_DIM      = IM_COL32(140, 140, 150, 255);
static const ImU32 ZX_CHK_BG        = IM_COL32( 28,  10,  12, 255);
static const ImU32 ZX_CHK_BG_ON     = IM_COL32(225,  35,  45, 255);   // 🔥 แดงสดขึ้น
static const ImU32 ZX_CHK_BORDER    = IM_COL32(170,  35,  40, 255);
static const ImU32 ZX_CHK_BORDER_ON = IM_COL32(255,  90, 100, 255);   // ขอบสว่างตอนเปิด
static const ImU32 ZX_HOVER         = IM_COL32(255,  60,  70,  20);
static const ImU32 ZX_CORNER_YELLOW = IM_COL32(220,  40,  50, 255);
static const ImU32 ZX_SLIDER_BG     = IM_COL32( 35,  12,  14, 255);
static const ImU32 ZX_SLIDER_FILL   = IM_COL32(220,  40,  50, 240);
static const ImU32 ZX_KNOB_OUTLINE  = IM_COL32(240,  60,  70, 255);

static const ImU32 ZX_CYAN          = IM_COL32(140, 200, 230, 255);
static const ImU32 ZX_GREEN         = IM_COL32(120, 200, 180, 255);
static const ImU32 ZX_RED           = IM_COL32(220,  40,  50, 255);
static const ImU32 ZX_PURPLE        = IM_COL32(160, 120, 200, 255);
static const ImU32 ZX_YELLOW        = IM_COL32(210, 170,  70, 255);

// Layout — MODDER %7 style: เล็ก + มุมโค้งทุกมุม ตามรูป
static const float ZX_WIN_W      = 340.0f;     // ✅ เล็กลงตามรูป
static const float ZX_WIN_H      = 300.0f;     // ✅ เล็กลงตามรูป
static const float ZX_TITLE_H    = 28.0f;
static const float ZX_TOP_PAD    = 0.0f;
static const float ZX_TAB_H      = 32.0f;     // ✅ แท็บแนวนอนด้านบน
static const float ZX_SIDE_W     = 0.0f;      // ✅ ไม่มี sidebar แล้ว
static const float ZX_SIDE_BTN   = 46.0f;
static const float ZX_SIDE_GAP   = 8.0f;
static const float ZX_ROW_H      = 26.0f;
static const float ZX_SLIDER_H   = 22.0f;
static const float ZX_DROP_H     = 24.0f;     // ✅ ดรอปดาวน์
static const float ZX_LABEL_H    = 22.0f;
static const float ZX_SUB_H      = 20.0f;
static const float ZX_PAD_LEFT   = 10.0f;
static const float ZX_PAD_TOP    = 6.0f;
static const float ZX_CHK_BOX    = 18.0f;     // 🔼 ใหญ่ขึ้น ตามรูป MODDER %7
static const float ZX_CHK_RAD    = 5.0f;      // ✅ มุมโค้งนิดๆ
static const float ZX_KNOB_R     = 6.0f;
static const float ZX_WIN_RAD    = 12.0f;     // ✅ มุมโค้งใหญ่
static const float ZX_FRAME_RAD  = 6.0f;      // ✅ มุมโค้งภายใน (แถบ/ปุ่ม/ดรอปดาวน์)
static const float ZX_FONT_SIZE  = 12.0f;

// STATE
static int   ZX_Tab            = 0;   // ✅ MODDER %7: เริ่มแท็บ AIM
static bool  ZX_Collapsed      = false;
static bool  ZX_StreamMode     = false;
static bool  ZX_Count          = false;
static bool  ZX_FlyAlt         = false;
static float ZX_FlySpeed       = 5.0f;
static bool  ZX_FastFire       = false;
static bool  ZX_LongRange      = false;
static bool  ZX_BulletThru     = false;
static bool  ZX_FastSwitch     = false;
static bool  ZX_ChainDamage    = false;
static float ZX_ChainDmgValue  = 1000.0f;
static bool  ZX_Telekill       = false;
static bool  ZX_FreeFly        = false;
static float ZX_FreeFlySpeed   = 8.0f;
static bool  ZX_AimKill        = false;
static bool  ZX_NoRecoil       = false;
static bool  ZX_NoReload       = false;
static bool  ZX_AIPlayerAim    = false;
static bool  ZX_FAKE           = false;
static bool  ZX_UNDER          = false;
static bool  ZX_RUN            = false;
static bool  ZX_FLYV2          = false;
static bool  ZX_GHOSTVIP       = false;
static bool  ZX_XMOVE          = false;
static bool  ZX_MarkTeleport   = false;
static bool  ZX_AutoTeleport   = false;
static bool  ZX_AmmoSpeedFast  = false;
static bool  ZX_BlueMap        = false;
static bool  ZX_SetMark        = false;
static bool  ZX_ResetAcc       = false;
static bool  ZX_HideModMenu    = false;
static bool  ZX_Esp2DCorner    = true;
static bool  ZX_Esp3DBox       = true;
static bool  ZX_CameraLeft     = false;
static float ZX_CameraHeight   = 5.0f;
static float ZX_CameraSide     = 0.0f;
static bool  ZX_FloatBtnEnabled = false;   // ✅ master toggle — เปิดจากเมนูก่อนปุ่มลอยถึงจะโผล่
static bool  ZX_ShowFlyBtn      = false;
static bool  ZX_ShowTelekillBtn = false;
static bool  ZX_ShowAimkillBtn  = false;
static bool  ZX_ShowNorecoilBtn = false;
static bool  ZX_ShowMarkTPBtn   = false;
static bool  ZX_ShowAutoTPBtn   = false;
// ✅ MODDER %7 — ตัวเลือกใหม่ในแท็บ AIM ตามรูป
static bool  ZX_AimRadius180   = false;
static bool  ZX_AimRadius360   = false;
static int   ZX_WhenShootIdx   = 0;        // 0=When Shoot and Scope
static int   ZX_HitboxIdx      = 0;        // 0=Head

static void ZX_DrawSidebarIcon(ImDrawList* dl, int idx, ImVec2 c, float s, ImU32 col) {
    switch (idx) {
        case 0: {
            dl->AddCircle(ImVec2(c.x, c.y - s*0.30f), s*0.28f, col, 18, 1.8f);
            dl->PathClear();
            dl->PathArcTo(ImVec2(c.x, c.y + s*0.65f), s*0.55f, IM_PI + 0.35f, 2.0f*IM_PI - 0.35f, 24);
            dl->PathStroke(col, 0, 1.8f);
            break;
        }
        case 1: {
            float w = s * 0.85f, h = s * 0.45f;
            dl->PathClear();
            for (int i = 0; i <= 20; ++i) {
                float t = (float)i / 20.0f;
                float x = c.x - w + 2.0f*w*t;
                float y = c.y - h * sinf(t * IM_PI);
                dl->PathLineTo(ImVec2(x, y));
            }
            for (int i = 20; i >= 0; --i) {
                float t = (float)i / 20.0f;
                float x = c.x - w + 2.0f*w*t;
                float y = c.y + h * sinf(t * IM_PI);
                dl->PathLineTo(ImVec2(x, y));
            }
            dl->PathStroke(col, 0, 1.8f);
            dl->AddCircleFilled(c, s * 0.22f, col, 16);
            break;
        }
        case 2: {
            float w = s * 0.30f, h = s * 0.65f;
            ImVec2 nose(c.x, c.y - h * 0.75f);
            ImVec2 tlc(c.x - w, c.y - h * 0.10f);
            ImVec2 trc(c.x + w, c.y - h * 0.10f);
            ImVec2 blc(c.x - w, c.y + h * 0.45f);
            ImVec2 brc(c.x + w, c.y + h * 0.45f);
            dl->AddLine(nose, tlc, col, 1.8f);
            dl->AddLine(nose, trc, col, 1.8f);
            dl->AddLine(tlc, blc, col, 1.8f);
            dl->AddLine(trc, brc, col, 1.8f);
            dl->AddLine(blc, brc, col, 1.8f);
            dl->AddCircle(ImVec2(c.x, c.y - h * 0.05f), s * 0.13f, col, 14, 1.6f);
            dl->AddTriangle(blc, ImVec2(blc.x - s*0.30f, c.y + h*0.55f), ImVec2(blc.x, c.y + h*0.20f), col, 1.6f);
            dl->AddTriangle(brc, ImVec2(brc.x + s*0.30f, c.y + h*0.55f), ImVec2(brc.x, c.y + h*0.20f), col, 1.6f);
            break;
        }
        case 3: {
            ImVec2 lc(c.x - s*0.18f, c.y - s*0.18f);
            float r = s * 0.42f;
            dl->AddCircle(lc, r, col, 22, 1.8f);
            float a = 0.7853981f;
            ImVec2 h0(lc.x + r * cosf(a), lc.y + r * sinf(a));
            ImVec2 h1(h0.x + s*0.40f, h0.y + s*0.40f);
            dl->AddLine(h0, h1, col, 2.2f);
            float pl = s * 0.18f;
            dl->AddLine(ImVec2(lc.x - pl, lc.y), ImVec2(lc.x + pl, lc.y), col, 1.8f);
            dl->AddLine(ImVec2(lc.x, lc.y - pl), ImVec2(lc.x, lc.y + pl), col, 1.8f);
            break;
        }
        case 4: {
            float ro = s * 0.55f;
            float ri = s * 0.40f;
            float cr = s * 0.20f;
            int teeth = 8;
            for (int t = 0; t < teeth; ++t) {
                float ang = (float)t / (float)teeth * 2.0f * IM_PI;
                float ca = cosf(ang), sa = sinf(ang);
                float ex = s * 0.10f;
                ImVec2 a1(c.x + ca * ri - sa * ex, c.y + sa * ri + ca * ex);
                ImVec2 a2(c.x + ca * ri + sa * ex, c.y + sa * ri - ca * ex);
                ImVec2 a3(c.x + ca * ro + sa * ex, c.y + sa * ro - ca * ex);
                ImVec2 a4(c.x + ca * ro - sa * ex, c.y + sa * ro + ca * ex);
                ImVec2 quad[4] = { a1, a2, a3, a4 };
                dl->AddConvexPolyFilled(quad, 4, col);
            }
            dl->AddCircleFilled(c, ri, col, 24);
            dl->AddCircleFilled(c, cr, ZX_SIDE_BTN_BG, 16);
            break;
        }
        case 5: {
            float w  = s * 0.78f;
            float dy = s * 0.30f;
            float dotR = s * 0.10f;
            float dotX = c.x - w * 0.55f;
            float lineX0 = dotX + s * 0.22f;
            float lineX1 = c.x + w * 0.48f;
            for (int i = -1; i <= 1; ++i) {
                float y = c.y + (float)i * dy;
                dl->AddCircleFilled(ImVec2(dotX, y), dotR, col, 10);
                dl->AddLine(ImVec2(lineX0, y), ImVec2(lineX1, y), col, 1.8f);
            }
            break;
        }
        default: break;
    }
}

static void ZX_DrawLightning(ImDrawList* dl, ImVec2 c, float s, ImU32 col) {
    ImVec2 pts[6] = {
        ImVec2(c.x + s * 0.10f, c.y - s * 0.55f),
        ImVec2(c.x - s * 0.40f, c.y + s * 0.05f),
        ImVec2(c.x - s * 0.05f, c.y + s * 0.05f),
        ImVec2(c.x - s * 0.18f, c.y + s * 0.55f),
        ImVec2(c.x + s * 0.40f, c.y - s * 0.10f),
        ImVec2(c.x + s * 0.05f, c.y - s * 0.10f),
    };
    dl->AddConvexPolyFilled(pts, 6, col);
}

static void ZX_SonicSection(const char* text, bool withBolt) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return;
    ImVec2 pos = window->DC.CursorPos;
    ImVec2 size(ImGui::GetContentRegionAvail().x, ZX_LABEL_H);
    ImGui::ItemSize(size, 0.0f);
    float tx = pos.x + ZX_PAD_LEFT;
    float ty = pos.y + (ZX_LABEL_H - ImGui::GetFontSize()) * 0.5f;
    if (withBolt) {
        float iconSize = ImGui::GetFontSize();
        ZX_DrawLightning(window->DrawList, ImVec2(tx + iconSize * 0.5f, ty + iconSize * 0.5f), iconSize, ZX_SECTION);
        tx += iconSize + 6.0f;
    }
    window->DrawList->AddText(ImVec2(tx, ty), ZX_SECTION, text);
    float ly = pos.y + ZX_LABEL_H - 1.0f;
    window->DrawList->AddLine(ImVec2(pos.x + ZX_PAD_LEFT, ly), ImVec2(pos.x + size.x - ZX_PAD_LEFT, ly), ZX_SEP, 1.0f);
}

static bool ZX_SonicCheckCell(ImVec2 cellMin, ImVec2 cellMax, const char* label, bool* v) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    const ImGuiID id = window->GetID(label);
    ImRect bb(cellMin, cellMax);
    ImGui::ItemAdd(bb, id);
    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hovered, &held);
    if (pressed) *v = !*v;
    ImDrawList* dl = window->DrawList;
    if (hovered) dl->AddRectFilled(bb.Min, bb.Max, ZX_HOVER, ZX_FRAME_RAD);
    // 🟥 MODDER %7: เช็คบ็อกซ์เป็น "เหลี่ยมโค้งสีแดงเข้ม + ติ๊กขาว"
    // ✅ จัด [กล่อง + ป้าย] ให้อยู่กึ่งกลางในแต่ละ cell
    float cy = (bb.Min.y + bb.Max.y) * 0.5f;
    float labelW = ImGui::CalcTextSize(label).x;
    float gap    = 8.0f;
    float groupW = ZX_CHK_BOX + gap + labelW;
    float cellW  = bb.Max.x - bb.Min.x;
    float bx = bb.Min.x + (cellW - groupW) * 0.5f;
    if (bx < bb.Min.x + 4.0f) bx = bb.Min.x + 4.0f;   // กันชิดขอบ
    float by = cy - ZX_CHK_BOX * 0.5f;
    ImVec2 bMin(bx, by);
    ImVec2 bMax(bx + ZX_CHK_BOX, by + ZX_CHK_BOX);
    if (*v) {
        // 🔥 เปิด: พื้นแดงสด + ขอบแดงสว่าง + ติ๊กขาวหนา
        dl->AddRectFilled(bMin, bMax, ZX_CHK_BG_ON, ZX_CHK_RAD);
        dl->AddRect(bMin, bMax, ZX_CHK_BORDER_ON, ZX_CHK_RAD, 0, 1.2f);
        float pad = ZX_CHK_BOX * 0.22f;
        ImVec2 p1(bMin.x + pad,                   cy + ZX_CHK_BOX * 0.06f);
        ImVec2 p2(bMin.x + ZX_CHK_BOX * 0.42f,    cy + ZX_CHK_BOX * 0.28f);
        ImVec2 p3(bMax.x - pad,                   cy - ZX_CHK_BOX * 0.30f);
        dl->AddLine(p1, p2, IM_COL32(255,255,255,255), 2.6f);
        dl->AddLine(p2, p3, IM_COL32(255,255,255,255), 2.6f);
    } else {
        // ⚫️ ปิด: พื้นเข้ม + ขอบแดงเข้ม
        dl->AddRectFilled(bMin, bMax, ZX_CHK_BG, ZX_CHK_RAD);
        dl->AddRect(bMin, bMax, ZX_CHK_BORDER, ZX_CHK_RAD, 0, 1.2f);
    }
    ImVec2 tp(bMax.x + 8.0f, cy - ImGui::GetFontSize() * 0.5f);
    dl->AddText(tp, ZX_TEXT, label);
    return pressed;
}

static bool ZX_SonicCheckRow(const char* label, bool* v) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;
    ImVec2 pos = window->DC.CursorPos;
    ImVec2 size(ImGui::GetContentRegionAvail().x, ZX_ROW_H);
    ImGui::ItemSize(size, 0.0f);
    return ZX_SonicCheckCell(pos, ImVec2(pos.x + size.x, pos.y + size.y), label, v);
}

static void ZX_SonicCheckRow2(const char* l1, bool* v1, const char* l2, bool* v2) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return;
    ImVec2 pos = window->DC.CursorPos;
    ImVec2 size(ImGui::GetContentRegionAvail().x, ZX_ROW_H);
    ImGui::ItemSize(size, 0.0f);
    float midX = pos.x + size.x * 0.5f;   // ✅ แบ่ง 50/50 ให้สมดุล
    ZX_SonicCheckCell(pos, ImVec2(midX, pos.y + size.y), l1, v1);
    ZX_SonicCheckCell(ImVec2(midX, pos.y), ImVec2(pos.x + size.x, pos.y + size.y), l2, v2);
}

static bool ZX_Slider(const char* label, float* v, float vmin, float vmax) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;
    ImGuiContext& g = *GImGui;
    const ImGuiID id = window->GetID(label);
    ImVec2 pos = window->DC.CursorPos;
    float aw = ImGui::GetContentRegionAvail().x;
    ImVec2 size(aw, ZX_SLIDER_H);
    const ImRect bb(pos, ImVec2(pos.x + size.x, pos.y + size.y));
    ImGui::ItemSize(size, 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;
    const float labelW = 80.0f;
    const float trackH = 4.0f;
    float trackY = pos.y + ZX_SLIDER_H * 0.5f;
    float trackX0 = pos.x + ZX_PAD_LEFT;
    float trackX1 = pos.x + size.x - labelW - ZX_PAD_LEFT;
    ImRect inter(ImVec2(trackX0 - ZX_KNOB_R, pos.y), ImVec2(trackX1 + ZX_KNOB_R, pos.y + ZX_SLIDER_H));
    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(inter, id, &hovered, &held);
    float t = (*v - vmin) / (vmax - vmin);
    if (t < 0.0f) t = 0.0f;
    if (t > 1.0f) t = 1.0f;
    if (held) {
        float mx = g.IO.MousePos.x;
        float nt = (mx - trackX0) / (trackX1 - trackX0);
        if (nt < 0.0f) nt = 0.0f;
        if (nt > 1.0f) nt = 1.0f;
        *v = vmin + nt * (vmax - vmin);
        t = nt;
        ImGui::MarkItemEdited(id);
    }
    ImDrawList* dl = window->DrawList;
    dl->AddRectFilled(ImVec2(trackX0, trackY - trackH * 0.5f), ImVec2(trackX1, trackY + trackH * 0.5f), ZX_SLIDER_BG, 3.0f);
    dl->AddRectFilled(ImVec2(trackX0, trackY - trackH * 0.5f), ImVec2(trackX0 + (trackX1 - trackX0) * t, trackY + trackH * 0.5f), ZX_SLIDER_FILL, 3.0f);
    float kx = trackX0 + (trackX1 - trackX0) * t;
    dl->AddCircleFilled(ImVec2(kx, trackY), ZX_KNOB_R, ZX_WIN_BG, 28);
    dl->AddCircle(ImVec2(kx, trackY), ZX_KNOB_R, ZX_KNOB_OUTLINE, 28, 2.4f);
    char buf[64];
    snprintf(buf, sizeof(buf), "%s  %.0f", label, *v);
    ImVec2 lp(trackX1 + 14.0f, pos.y + (ZX_SLIDER_H - ImGui::GetFontSize()) * 0.5f);
    dl->AddText(lp, ZX_TEXT, buf);
    float ly = pos.y + ZX_SLIDER_H - 0.5f;
    dl->AddLine(ImVec2(pos.x + ZX_PAD_LEFT, ly), ImVec2(pos.x + size.x - ZX_PAD_LEFT, ly), ZX_SEP, 1.0f);
    return pressed;
}

static bool ZX_ButtonCard(ImVec2 cellMin, ImVec2 cellMax, const char* label, ImU32 labelColor, bool* v) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;
    ImVec2 cellSize(cellMax.x - cellMin.x, cellMax.y - cellMin.y);
    ImGui::SetCursorScreenPos(cellMin);
    char idbuf[96];
    snprintf(idbuf, sizeof(idbuf), "##bcard_%s", label);
    bool clicked = ImGui::InvisibleButton(idbuf, cellSize);
    const ImGuiID id = window->GetID(idbuf);
    ImGuiIO& zio = ImGui::GetIO();
    ImGuiStorage* st = window->DC.StateStorage;
    bool inBox = (zio.MousePos.x >= cellMin.x && zio.MousePos.x <= cellMax.x && zio.MousePos.y >= cellMin.y && zio.MousePos.y <= cellMax.y);
    bool isDown = zio.MouseDown[0];
    ImGuiID kDown = id ^ 0xC0DE0001u;
    ImGuiID kPin = id ^ 0xC0DE0002u;
    bool wasDown = st->GetInt(kDown, 0) != 0;
    bool pressIn = st->GetInt(kPin, 0) != 0;
    bool clickedManual = false;
    if (!wasDown && isDown && inBox) pressIn = true;
    if (wasDown && !isDown) { if (pressIn && inBox) clickedManual = true; pressIn = false; }
    if (!isDown) pressIn = false;
    st->SetInt(kDown, isDown ? 1 : 0);
    st->SetInt(kPin, pressIn ? 1 : 0);
    bool tapped = clicked || clickedManual;
    if (tapped) *v = !*v;
    ImDrawList* dl = window->DrawList;
    const ImU32 cardBg = IM_COL32(22, 30, 62, 255);
    const ImU32 cardBgDown = IM_COL32(30, 40, 78, 255);
    const ImU32 cardBorder = IM_COL32(40, 55, 105, 255);
    const float radius = 14.0f;
    bool pressedNow = (pressIn && isDown && inBox);
    dl->AddRectFilled(cellMin, cellMax, pressedNow ? cardBgDown : cardBg, radius);
    dl->AddRect(cellMin, cellMax, cardBorder, radius, 0, 1.2f);
    ImVec2 ts = ImGui::CalcTextSize(label);
    float cx = (cellMin.x + cellMax.x) * 0.5f;
    float labelY = cellMin.y + 14.0f;
    dl->AddText(ImVec2(cx - ts.x * 0.5f, labelY), labelColor, label);
    float pillW = 60.0f;
    float pillH = 28.0f;
    float pillX = cx - pillW * 0.5f;
    float pillY = cellMax.y - pillH - 14.0f;
    ImVec2 pMin(pillX, pillY);
    ImVec2 pMax(pillX + pillW, pillY + pillH);
    ImU32 pillBg = *v ? IM_COL32(95, 130, 255, 235) : IM_COL32(60, 80, 130, 220);
    dl->AddRectFilled(pMin, pMax, pillBg, pillH * 0.5f);
    float knobR = pillH * 0.5f - 3.0f;
    float knobX = *v ? (pMax.x - knobR - 3.0f) : (pMin.x + knobR + 3.0f);
    float knobY = (pMin.y + pMax.y) * 0.5f;
    dl->AddCircleFilled(ImVec2(knobX, knobY), knobR + 0.5f, IM_COL32(255,255,255,255), 28);
    return tapped;
}

static void ZX_ButtonGridRow(const char* lLabel, ImU32 lColor, bool* lv, const char* rLabel, ImU32 rColor, bool* rv) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return;
    ImVec2 pos = window->DC.CursorPos;
    float aw = ImGui::GetContentRegionAvail().x;
    const float gap = 14.0f;
    const float sideP = 10.0f;
    float cardW = (aw - sideP * 2.0f - gap) * 0.5f;
    const float cardH = 92.0f;
    ImGui::ItemSize(ImVec2(aw, cardH + 12.0f), 0.0f);
    ImVec2 lMin(pos.x + sideP, pos.y + 6.0f);
    ImVec2 lMax(lMin.x + cardW, lMin.y + cardH);
    ZX_ButtonCard(lMin, lMax, lLabel, lColor, lv);
    ImVec2 rMin(lMax.x + gap, pos.y + 6.0f);
    ImVec2 rMax(rMin.x + cardW, rMin.y + cardH);
    ZX_ButtonCard(rMin, rMax, rLabel, rColor, rv);
}

// ✅ MODDER %7 — Pill Slider: แสดง [ ค่า ] อยู่กลางแถบ + ป้ายอยู่ด้านขวานอกแถบ
static bool ZX_PillSlider(const char* label, float* v, float vmin, float vmax) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;
    ImGuiContext& g = *GImGui;
    const ImGuiID id = window->GetID(label);
    ImVec2 pos = window->DC.CursorPos;
    float aw = ImGui::GetContentRegionAvail().x;
    const float rowH = ZX_SLIDER_H + 10.0f;
    ImVec2 size(aw, rowH);
    const ImRect bb(pos, ImVec2(pos.x + size.x, pos.y + size.y));
    ImGui::ItemSize(size, 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;

    const float labelW = 64.0f;   // พื้นที่ป้ายขวานอกแถบ
    const float trackH = ZX_SLIDER_H;
    const float trackX0 = pos.x + ZX_PAD_LEFT;
    const float trackX1 = pos.x + size.x - labelW - ZX_PAD_LEFT;
    const float trackY0 = pos.y + (rowH - trackH) * 0.5f;
    const float trackY1 = trackY0 + trackH;

    ImRect track(ImVec2(trackX0, trackY0), ImVec2(trackX1, trackY1));
    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(track, id, &hovered, &held);
    float t = (*v - vmin) / (vmax - vmin);
    if (t < 0.0f) t = 0.0f;
    if (t > 1.0f) t = 1.0f;
    if (held) {
        float mx = g.IO.MousePos.x;
        float nt = (mx - trackX0) / (trackX1 - trackX0);
        if (nt < 0.0f) nt = 0.0f;
        if (nt > 1.0f) nt = 1.0f;
        *v = vmin + nt * (vmax - vmin);
        t = nt;
        ImGui::MarkItemEdited(id);
    }

    ImDrawList* dl = window->DrawList;
    // พื้นแถบสีแดงเข้ม + ขอบ
    dl->AddRectFilled(ImVec2(trackX0, trackY0), ImVec2(trackX1, trackY1), ZX_SLIDER_BG, ZX_FRAME_RAD);
    dl->AddRect(ImVec2(trackX0, trackY0), ImVec2(trackX1, trackY1), ZX_PANEL_BORDER, ZX_FRAME_RAD, 0, 1.0f);

    // ปุ่มเลื่อนสีแดงทรงพิลแนวตั้ง
    float pad   = 3.0f;
    float knobW = 9.0f;
    float knobH = trackH - pad * 2.0f;
    float maxX  = (trackX1 - pad) - (trackX0 + pad) - knobW;
    float knobX = trackX0 + pad + maxX * t;
    float knobY = trackY0 + pad;
    dl->AddRectFilled(ImVec2(knobX, knobY), ImVec2(knobX + knobW, knobY + knobH), ZX_SLIDER_FILL, knobW * 0.5f);

    // ค่า [ X.X ] กลางแถบ
    char buf[32];
    snprintf(buf, sizeof(buf), "[ %.1f ]", *v);
    ImVec2 ts = ImGui::CalcTextSize(buf);
    float tx = (trackX0 + trackX1) * 0.5f - ts.x * 0.5f;
    float ty = trackY0 + (trackH - ts.y) * 0.5f;
    dl->AddText(ImVec2(tx, ty), ZX_TEXT, buf);

    // ป้ายชื่อด้านขวานอกแถบ
    ImVec2 ls = ImGui::CalcTextSize(label);
    dl->AddText(ImVec2(trackX1 + 8.0f, pos.y + (rowH - ls.y) * 0.5f), ZX_TEXT, label);

    return pressed;
}

// ✅ MODDER %7 — Pill Dropdown: แถบโค้ง + ป้ายซ้าย + ▼ ขวา + ไอคอนเล็กนอกแถบ
//    iconType: 0 = crosshair (เป้า), 1 = plus (+), -1 = ไม่มีไอคอน
static bool ZX_PillDropdown(const char* label, int iconType) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;
    ImVec2 pos = window->DC.CursorPos;
    float aw = ImGui::GetContentRegionAvail().x;
    const float rowH = ZX_DROP_H + 8.0f;
    ImVec2 size(aw, rowH);
    ImGui::ItemSize(size, 0.0f);

    const float iconW   = (iconType >= 0) ? 22.0f : 0.0f;
    const float trackX0 = pos.x + ZX_PAD_LEFT;
    const float trackX1 = pos.x + size.x - ZX_PAD_LEFT - iconW;
    const float trackY0 = pos.y + (rowH - ZX_DROP_H) * 0.5f;
    const float trackY1 = trackY0 + ZX_DROP_H;

    char idbuf[80];
    snprintf(idbuf, sizeof(idbuf), "##drop_%s", label);
    ImGui::SetCursorScreenPos(ImVec2(trackX0, trackY0));
    bool clicked = ImGui::InvisibleButton(idbuf, ImVec2(trackX1 - trackX0, ZX_DROP_H));

    ImDrawList* dl = window->DrawList;
    // พื้นแถบ + ขอบ
    dl->AddRectFilled(ImVec2(trackX0, trackY0), ImVec2(trackX1, trackY1), ZX_SLIDER_BG, ZX_FRAME_RAD);
    dl->AddRect(ImVec2(trackX0, trackY0), ImVec2(trackX1, trackY1), ZX_PANEL_BORDER, ZX_FRAME_RAD, 0, 1.0f);

    // กล่องสามเหลี่ยม ▼ ที่มุมขวาในแถบ
    float boxW = 22.0f;
    ImVec2 boxMin(trackX1 - boxW, trackY0);
    ImVec2 boxMax(trackX1,        trackY1);
    dl->AddRectFilled(boxMin, boxMax, ZX_SIDE_BTN_ACT, ZX_FRAME_RAD, ImDrawFlags_RoundCornersRight);

    // ป้ายชื่อในแถบ
    ImVec2 ts = ImGui::CalcTextSize(label);
    dl->AddText(ImVec2(trackX0 + 10.0f, trackY0 + (ZX_DROP_H - ts.y) * 0.5f), ZX_TEXT, label);

    // สามเหลี่ยม ▼
    float ax = (boxMin.x + boxMax.x) * 0.5f;
    float ay = (boxMin.y + boxMax.y) * 0.5f - 1.0f;
    float aw2 = 4.0f, ah2 = 4.0f;
    dl->AddTriangleFilled(
        ImVec2(ax - aw2, ay - ah2 * 0.5f),
        ImVec2(ax + aw2, ay - ah2 * 0.5f),
        ImVec2(ax,       ay + ah2 * 0.7f),
        ZX_TAB_TEXT
    );

    // ไอคอนเล็กนอกแถบ (เป้า / +)
    if (iconType >= 0) {
        float iconCx = trackX1 + iconW * 0.5f;
        float iconCy = (trackY0 + trackY1) * 0.5f;
        float iconS  = 14.0f;
        if (iconType == 0) {
            float r = iconS * 0.42f;
            dl->AddCircle(ImVec2(iconCx, iconCy), r, ZX_TAB_TEXT, 18, 1.4f);
            float a = iconS * 0.55f;
            dl->AddLine(ImVec2(iconCx - a,             iconCy), ImVec2(iconCx - r * 0.55f, iconCy), ZX_TAB_TEXT, 1.4f);
            dl->AddLine(ImVec2(iconCx + r * 0.55f,     iconCy), ImVec2(iconCx + a,         iconCy), ZX_TAB_TEXT, 1.4f);
            dl->AddLine(ImVec2(iconCx, iconCy - a),             ImVec2(iconCx, iconCy - r * 0.55f), ZX_TAB_TEXT, 1.4f);
            dl->AddLine(ImVec2(iconCx, iconCy + r * 0.55f),     ImVec2(iconCx, iconCy + a),         ZX_TAB_TEXT, 1.4f);
            dl->AddCircleFilled(ImVec2(iconCx, iconCy), iconS * 0.08f, ZX_TAB_TEXT, 10);
        } else if (iconType == 1) {
            float a = iconS * 0.45f;
            dl->AddLine(ImVec2(iconCx - a, iconCy), ImVec2(iconCx + a, iconCy), ZX_TAB_TEXT, 2.0f);
            dl->AddLine(ImVec2(iconCx, iconCy - a), ImVec2(iconCx, iconCy + a), ZX_TAB_TEXT, 2.0f);
        }
    }
    return clicked;
}

// ✅ ทำงานทุกเฟรม ไม่ต้องเปิดเมนูค้าง
static void ZX_ApplyAndRun() {
    Vars.AimbotEnable = Vars.Aimbot;
    Vars.isAimFov = (Vars.AimFov > 0);
    Vars.fovLineColor[0] = 0.90f;
    Vars.fovLineColor[1] = 0.22f;
    Vars.fovLineColor[2] = 0.24f;
    Vars.fovLineColor[3] = 1.00f;
    Vars.FastFire = ZX_FastFire;
    FireDelay = ZX_FastFire ? 0.0f : 0.001f;
    Vars.LongRange = ZX_LongRange;
    Vars.BulletPenetration = ZX_BulletThru;
    Vars.ChainDamage = ZX_ChainDamage;
    Vars.ChainDamageValue = (int)ZX_ChainDmgValue;
    Vars.FastSwitch = ZX_FastSwitch;
    if (ZX_BulletThru) { SilentAim = true; CheckWall1 = false; }
    Vars.FlyUp = ZX_FlyAlt;
    Vars.FlySpeed = ZX_FlySpeed;
    Vars.Telekill = ZX_Telekill;
    Vars.FreeFly = ZX_FreeFly;
    Vars.FreeFlySpeed = ZX_FreeFlySpeed;
    Vars.AimKill = ZX_AimKill;
    Vars.NoRecoil = ZX_NoRecoil;
    Vars.NoReload = ZX_NoReload;
    Vars.AIPlayerAim = ZX_AIPlayerAim;
    Vars.CurrentTab = ZX_Tab;
    Vars.MarkTeleport = ZX_MarkTeleport;
    Vars.AutoTeleport = ZX_AutoTeleport;
    Vars.AmmoSpeedFast = ZX_AmmoSpeedFast;
    Vars.BlueMap = ZX_BlueMap;
    if (ZX_SetMark) { SetMarkAtCurrentPos(); ZX_SetMark = false; }
    if (ZX_ResetAcc) { DoResetAccount(); ZX_ResetAcc = false; }
    if (ZX_BlueMap && Vars.Enable) RunBlueMap();
    if (ZX_AmmoSpeedFast && Vars.Enable) RunAmmoSpeedFast();
    if (ZX_MarkTeleport && Vars.Enable) RunMarkTeleport();
    if (ZX_AutoTeleport && Vars.Enable) RunAutoTeleport();
    if (ZX_FlyAlt && Vars.Enable) {
        void* match = game_sdk->Curent_Match();
        if (match) {
            void* local = game_sdk->GetLocalPlayer(match);
            if (local) {
                void* tf = game_sdk->Component_GetTransform(local);
                if (tf) {
                    Vector3 cur = game_sdk->get_position(tf);
                    cur.y += ZX_FlySpeed * 0.1f;
                    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
                }
            }
        }
    }
    if ((ZX_AimKill || Vars.AutoFire) && Vars.Enable) {
        Vars.Aimbot = true;
        Vars.AimbotEnable = true;
        Vars.AimMode = 0;
        Vars.isAimFov = true;
        Vars.AimWhen = 0;
        Vars.AimHitbox = 0;
        Vars.AutoFire = true;
        Vars.FastFire = true;
        FireDelay = 0.0f;
        Vars.LongRange = true;
        Vars.BulletPenetration = true;
        Vars.ChainDamage = true;
        Vars.ChainDamageValue = 9999;
        Vars.VisibleCheck = false;
        Vars.IgnoreKnocked = true;
        Vars.UpPlayerOne = true;
        SilentAim = true;
        CheckWall1 = false;
        SetDamage = 1;
        if (Vars.AimFov < 500.0f) Vars.AimFov = 500.0f;
    }
    if (ZX_FreeFly && Vars.Enable) {
        void* match = game_sdk->Curent_Match();
        if (match) {
            void* local = game_sdk->GetLocalPlayer(match);
            void* cam = game_sdk->get_camera();
            if (local && cam) {
                void* tf = game_sdk->Component_GetTransform(local);
                void* camTF = game_sdk->Component_GetTransform(cam);
                if (tf && camTF) {
                    Vector3 cur = game_sdk->get_position(tf);
                    Vector3 fwd = game_sdk->GetForward(camTF);
                    float step = ZX_FreeFlySpeed * 0.1f;
                    cur.x += fwd.x * step;
                    cur.y += fwd.y * step;
                    cur.z += fwd.z * step;
                    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
                }
            }
        }
    }
    if (ZX_NoRecoil && Vars.Enable) {
        Vars.Aimbot = true;
        Vars.AimSpeed = (Vars.AimSpeed > 30.0f) ? Vars.AimSpeed : 50.0f;
        Vars.isAimFov = true;
        if (Vars.AimFov < 200.0f) Vars.AimFov = 200.0f;
    }
    if (ZX_NoReload && Vars.Enable) {
        Vars.FastFire = true;
        FireDelay = 0.0f;
    }
    if (ZX_AIPlayerAim && Vars.Enable) {
        Vars.Aimbot = true;
        Vars.AimMode = 0;
        Vars.isAimFov = true;
        Vars.AimSpeed = (Vars.AimSpeed > 20.0f) ? Vars.AimSpeed : 35.0f;
        Vars.AimManagerHitbox = 0;
        Vars.VisibleCheck = false;
        if (Vars.AimFov < 400.0f) Vars.AimFov = 400.0f;
        SilentAim = true;
    }
    if (ZX_Telekill && Vars.Enable) {
        void* match = game_sdk->Curent_Match();
        if (match) {
            void* local = game_sdk->GetLocalPlayer(match);
            void* enemy = GetClosestEnemy();
            if (local && enemy) {
                void* tf = game_sdk->Component_GetTransform(local);
                if (tf) {
                    Vector3 ePos = GetHeadPosition(enemy);
                    Transform_INTERNAL_SetPosition(tf, Vvector3(ePos.x + 1.5f, ePos.y - 1.0f, ePos.z + 1.5f));
                    SilentAim = true;
                    Vars.ChainDamage = true;
                }
            }
        }
    }
    // ✅ Camera Left – มุมสูงปรับได้ + ซ้าย/ขวา
    if (ZX_CameraLeft && Vars.Enable) {
        void* match = game_sdk->Curent_Match();
        if (match) {
            void* local = game_sdk->GetLocalPlayer(match);
            void* cam   = game_sdk->get_camera();
            if (local && cam) {
                void* pTF = game_sdk->Component_GetTransform(local);
                void* cTF = game_sdk->Component_GetTransform(cam);
                if (pTF && cTF) {
                    Vector3 p = game_sdk->get_position(pTF);
                    Transform_INTERNAL_SetPosition(cTF,
                        Vvector3(p.x + ZX_CameraSide, p.y + ZX_CameraHeight, p.z));
                }
            }
        }
    }
}

// 🟥 MODDER %7 — ไอคอนแท็บแนวนอน 4 อัน
static void ZX_DrawTopTabIcon(ImDrawList* dl, int idx, ImVec2 c, float s, ImU32 col) {
    switch (idx) {
        case 0: { // AIM — crosshair
            float r = s * 0.42f;
            dl->AddCircle(c, r, col, 22, 1.6f);
            float a = s * 0.55f;
            dl->AddLine(ImVec2(c.x - a, c.y), ImVec2(c.x - r * 0.55f, c.y), col, 1.6f);
            dl->AddLine(ImVec2(c.x + r * 0.55f, c.y), ImVec2(c.x + a, c.y), col, 1.6f);
            dl->AddLine(ImVec2(c.x, c.y - a), ImVec2(c.x, c.y - r * 0.55f), col, 1.6f);
            dl->AddLine(ImVec2(c.x, c.y + r * 0.55f), ImVec2(c.x, c.y + a), col, 1.6f);
            dl->AddCircleFilled(c, s * 0.10f, col, 12);
            break;
        }
        case 1: { // ESP — eye
            float w = s * 0.65f, h = s * 0.40f;
            dl->PathClear();
            for (int i = 0; i <= 18; ++i) { float t=(float)i/18.0f; float x=c.x-w+2.0f*w*t; float y=c.y-h*sinf(t*IM_PI); dl->PathLineTo(ImVec2(x,y)); }
            for (int i = 18; i >= 0; --i) { float t=(float)i/18.0f; float x=c.x-w+2.0f*w*t; float y=c.y+h*sinf(t*IM_PI); dl->PathLineTo(ImVec2(x,y)); }
            dl->PathStroke(col, 0, 1.6f);
            dl->AddCircleFilled(c, s * 0.20f, col, 16);
            break;
        }
        case 2: { // MSL — gear
            float ro = s * 0.50f, ri = s * 0.36f, cr = s * 0.16f;
            int teeth = 8;
            for (int t = 0; t < teeth; ++t) {
                float ang = (float)t / (float)teeth * 2.0f * IM_PI;
                float ca = cosf(ang), sa = sinf(ang);
                float ex = s * 0.09f;
                ImVec2 a1(c.x + ca * ri - sa * ex, c.y + sa * ri + ca * ex);
                ImVec2 a2(c.x + ca * ri + sa * ex, c.y + sa * ri - ca * ex);
                ImVec2 a3(c.x + ca * ro + sa * ex, c.y + sa * ro - ca * ex);
                ImVec2 a4(c.x + ca * ro - sa * ex, c.y + sa * ro + ca * ex);
                ImVec2 quad[4] = { a1, a2, a3, a4 };
                dl->AddConvexPolyFilled(quad, 4, col);
            }
            dl->AddCircleFilled(c, ri, col, 24);
            dl->AddCircleFilled(c, cr, ZX_TITLE_BG, 16);
            break;
        }
        case 3: { // INFO — id card
            float w = s * 0.85f, h = s * 0.62f;
            ImVec2 a(c.x - w * 0.5f, c.y - h * 0.5f);
            ImVec2 b(c.x + w * 0.5f, c.y + h * 0.5f);
            dl->AddRect(a, b, col, 3.0f, 0, 1.6f);
            // โปรไฟล์ + บาร์
            float pcx = a.x + w * 0.25f;
            float pcy = c.y - h * 0.10f;
            dl->AddCircleFilled(ImVec2(pcx, pcy), s * 0.12f, col, 14);
            dl->AddRectFilled(ImVec2(pcx - s*0.18f, pcy + s*0.12f), ImVec2(pcx + s*0.18f, pcy + s*0.22f), col, 2.0f);
            // เส้นข้อมูล
            float lx0 = a.x + w * 0.55f;
            float lx1 = b.x - s * 0.10f;
            for (int i = 0; i < 3; ++i) {
                float yy = a.y + h * (0.30f + (float)i * 0.20f);
                dl->AddLine(ImVec2(lx0, yy), ImVec2(lx1, yy), col, 1.4f);
            }
            break;
        }
    }
}

static void RenderMenu() {
    if (!MenDeal) return;
    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImColor(ZX_WIN_BG).Value);
    ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0,0,0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, ZX_WIN_RAD);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ScrollbarSize, 4.0f);
    ImGui::SetNextWindowSize(ImVec2(ZX_WIN_W, ZX_WIN_H), ImGuiCond_Always);
    ImGui::Begin("##SonicMode", nullptr, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoBringToFrontOnFocus);
    ImGui::SetWindowFontScale(ZX_FONT_SIZE / 18.0f);
    ImDrawList* dl = ImGui::GetWindowDrawList();
    ImVec2 wp = ImGui::GetWindowPos();
    ImVec2 ws = ImGui::GetWindowSize();

    // 🟥 กรอบนอกแดง
    dl->AddRect(wp, ImVec2(wp.x + ws.x, wp.y + ws.y), ZX_PANEL_BORDER, ZX_WIN_RAD, 0, 1.8f);

    // ── Title bar ──
    ImVec2 tMin(wp.x, wp.y);
    ImVec2 tMax(wp.x + ws.x, wp.y + ZX_TITLE_H);
    dl->AddRectFilled(tMin, tMax, ZX_TITLE_BG, ZX_WIN_RAD, ImDrawFlags_RoundCornersTop);
    // ❌ ลบเส้นใต้ title แล้ว — ใช้แค่เส้นเดียวใต้ tab bar
    // ▼ ดรอปดาวน์ซ้าย
    {
        float ax = tMin.x + 16.0f;
        float ay = tMin.y + ZX_TITLE_H * 0.5f - 1.0f;
        float aw = 6.0f, ah = 5.0f;
        dl->AddTriangleFilled(ImVec2(ax - aw, ay - ah * 0.5f), ImVec2(ax + aw, ay - ah * 0.5f), ImVec2(ax, ay + ah * 0.7f), ZX_TAB_TEXT);
    }
    // 🔴 ชื่อ "MODDER %7" ตรงกลาง
    {
        const char* title = "MONA %9";
        ImVec2 ts = ImGui::CalcTextSize(title);
        dl->AddText(ImVec2(wp.x + (ws.x - ts.x) * 0.5f, tMin.y + (ZX_TITLE_H - ts.y) * 0.5f), ZX_TAB_TEXT, title);
    }
    // ✕ ปุ่มปิดขวา
    {
        const float cbW = 36.0f;
        float btnX0 = tMax.x - cbW;
        float btnY0 = tMin.y;
        float btnX1 = tMax.x;
        float btnY1 = tMax.y;
        ImGui::SetCursorScreenPos(ImVec2(btnX0, btnY0));
        bool clickedImGui = ImGui::InvisibleButton("##sm_close", ImVec2(cbW, ZX_TITLE_H));
        ImGuiIO& zio = ImGui::GetIO();
        bool inBox = (zio.MousePos.x >= btnX0 && zio.MousePos.x <= btnX1 && zio.MousePos.y >= btnY0 && zio.MousePos.y <= btnY1);
        bool isDown = zio.MouseDown[0];
        static bool s_wasDown = false;
        static bool s_pressedInBox = false;
        bool clickedManual = false;
        if (!s_wasDown && isDown && inBox) s_pressedInBox = true;
        if (s_wasDown && !isDown) { if (s_pressedInBox && inBox) clickedManual = true; s_pressedInBox = false; }
        if (!isDown) s_pressedInBox = false;
        s_wasDown = isDown;
        float cx = btnX0 + cbW * 0.5f;
        float cy = btnY0 + ZX_TITLE_H * 0.5f;
        float xs = 6.0f;
        dl->AddLine(ImVec2(cx - xs, cy - xs), ImVec2(cx + xs, cy + xs), ZX_TAB_TEXT, 1.8f);
        dl->AddLine(ImVec2(cx - xs, cy + xs), ImVec2(cx + xs, cy - xs), ZX_TAB_TEXT, 1.8f);
        if (clickedImGui || clickedManual) MenDeal = false;
    }

    // ── 🟥 TOP TAB BAR (4 แท็บ: AIM / ESP / MSL / INFO) ──
    float tabBarY0 = tMax.y;
    float tabBarY1 = tabBarY0 + ZX_TAB_H;
    dl->AddRectFilled(ImVec2(wp.x, tabBarY0), ImVec2(wp.x + ws.x, tabBarY1), ZX_TITLE_BG);
    // ✅ เส้นเล็กๆ บางเดียวใต้ tab bar (ไม่ชนขอบนอกซ้าย-ขวา)
    dl->AddLine(ImVec2(wp.x + 2.0f, tabBarY1), ImVec2(wp.x + ws.x - 2.0f, tabBarY1), ZX_SEP, 1.0f);

    const int kTabs = 4;
    const char* tabNames[kTabs] = { "AIM", "ESP", "MSL", "INFO" };
    float tabW = ws.x / (float)kTabs;
    for (int i = 0; i < kTabs; ++i) {
        ImVec2 tabMin(wp.x + (float)i * tabW, tabBarY0);
        ImVec2 tabMax(tabMin.x + tabW, tabBarY1);
        char idbuf[16];
        snprintf(idbuf, sizeof(idbuf), "##tab_%d", i);
        ImGui::SetCursorScreenPos(tabMin);
        bool clicked = ImGui::InvisibleButton(idbuf, ImVec2(tabW, ZX_TAB_H));
        if (clicked) ZX_Tab = i;
        bool active = (ZX_Tab == i);
        if (active) {
            // พื้นแดงเข้ม + เส้นขีดล่างแดงสด
            dl->AddRectFilled(tabMin, tabMax, ZX_SIDE_BTN_ACT);
            dl->AddRectFilled(ImVec2(tabMin.x, tabMax.y - 2.5f), tabMax, ZX_TAB_UNDERLINE);
        }
        // เส้นแบ่งระหว่างแท็บ
        if (i > 0) dl->AddLine(ImVec2(tabMin.x, tabMin.y + 6.0f), ImVec2(tabMin.x, tabMax.y - 6.0f), ZX_TAB_DIV, 1.0f);

        ImU32 col = active ? ZX_TAB_TEXT : ZX_TAB_TEXT_DIM;
        // ไอคอน + ข้อความเรียงแนวนอน
        ImVec2 ts = ImGui::CalcTextSize(tabNames[i]);
        float iconSize = ZX_TAB_H * 0.42f;
        float gap = 6.0f;
        float totalW = iconSize * 2.0f + gap + ts.x;
        float startX = tabMin.x + (tabW - totalW) * 0.5f;
        float midY = (tabMin.y + tabMax.y) * 0.5f;
        ZX_DrawTopTabIcon(dl, i, ImVec2(startX + iconSize, midY), iconSize, col);
        dl->AddText(ImVec2(startX + iconSize * 2.0f + gap, midY - ts.y * 0.5f), col, tabNames[i]);
    }

    // ── Content area ── (✅ ขยายให้ติดขอบนอก + มุมล่างโค้งให้พอดีกับขอบหน้าต่าง)
    float cX0 = wp.x + 2.0f;
    float cY0 = tabBarY1 + 2.0f;
    float cX1 = wp.x + ws.x - 2.0f;
    float cY1 = wp.y + ws.y - 2.0f;
    // มุมล่างโค้งเท่ากับขอบหน้าต่าง (ลบความหนา border 2 หน่วย) — ให้แนบเรียบเนียนกับมุมหน้าต่าง
    dl->AddRectFilled(ImVec2(cX0, cY0), ImVec2(cX1, cY1), ZX_PANEL_BG, ZX_WIN_RAD - 2.0f, ImDrawFlags_RoundCornersBottom);
    // ❌ ไม่มีขอบในของ content panel — ใช้แค่ขอบนอกหน้าต่างอันเดียว
    ImGui::SetCursorScreenPos(ImVec2(cX0 + 4.0f, cY0 + 6.0f));
    ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0,0,0,0));
    ImGui::BeginChild("##sm_content", ImVec2(cX1 - cX0 - 8.0f, cY1 - cY0 - 12.0f), false, ImGuiWindowFlags_AlwaysVerticalScrollbar);
    switch (ZX_Tab) {
        case 0: { // 🎯 AIM — MODDER %7 layout ตามรูป
            ZX_SonicCheckRow2("Enable Aimbot",        &Vars.Aimbot,      "Visible Check",        &Vars.VisibleCheck);
            ZX_SonicCheckRow2("AimSilent",            &SilentAim,        "AimKill(RiskBan)",     &ZX_AimKill);
            ZX_SonicCheckRow2("AimRadius 180\xc2\xb0", &ZX_AimRadius180, "AimRadius 360\xc2\xb0", &ZX_AimRadius360);
            ZX_PillDropdown("When Shoot and Scope", 0);   // ◎ crosshair
            ZX_PillDropdown("Head",                  1);   // + plus
            ZX_PillSlider("Fov Value", &Vars.AimFov, 0.0f, 500.0f);
            break;
        }
        case 1: { // 👁 ESP
            ZX_SonicCheckRow2("Enable ESP", &Vars.Enable, "Esp COUNT", &ZX_Count);
            ZX_SonicCheckRow2("Esp LINE", &Vars.lines, "Esp BOX", &Vars.Box);
            ZX_SonicCheckRow2("Esp2D CORNER", &ZX_Esp2DCorner, "Esp3D BOX", &ZX_Esp3DBox);
            ZX_SonicSection("Camera Left (High Angle)", false);
            ZX_SonicCheckRow("Camera Left", &ZX_CameraLeft);
            ZX_Slider("Cam Height", &ZX_CameraHeight, 1.0f, 25.0f);
            ZX_Slider("Cam Side  ", &ZX_CameraSide, -15.0f, 15.0f);
            break;
        }
        case 2: { // ⚙ MSL (Misc + OB53)
            ZX_SonicCheckRow2("Mark Teleport", &ZX_MarkTeleport, "Auto Teleport", &ZX_AutoTeleport);
            ZX_SonicCheckRow2("Ammo Speed Fast", &ZX_AmmoSpeedFast, "Blue Map", &ZX_BlueMap);
            ZX_SonicCheckRow2("Set Mark Pos", &ZX_SetMark, "Reset Account", &ZX_ResetAcc);
            ZX_SonicSection("Floating Buttons", false);
            ZX_SonicCheckRow2("Fly Move", &ZX_ShowFlyBtn, "Telekill", &ZX_ShowTelekillBtn);
            ZX_SonicCheckRow2("Aimkill", &ZX_ShowAimkillBtn, "No Recoil", &ZX_ShowNorecoilBtn);
            ZX_SonicCheckRow2("TP Mark", &ZX_ShowMarkTPBtn, "Auto TP", &ZX_ShowAutoTPBtn);
            ZX_SonicSection("Misc", false);
            ZX_SonicCheckRow2("Fast Fire", &ZX_FastFire, "Long Range", &ZX_LongRange);
            ZX_SonicCheckRow2("Bullet Thru Wall", &ZX_BulletThru, "Chain Damage", &ZX_ChainDamage);
            ZX_Slider("Damage", &ZX_ChainDmgValue, 100.0f, 9999.0f);
            ZX_SonicCheckRow("Fly Alt", &ZX_FlyAlt);
            ZX_Slider("Fly Spd", &ZX_FlySpeed, 1.0f, 20.0f);
            ZX_SonicCheckRow("Hide ModMenu", &ZX_HideModMenu);
            break;
        }
        case 3: { // ℹ INFO
            ZX_SonicSection("INFO", false);
            ImGuiWindow* w = ImGui::GetCurrentWindow();
            float lh = ImGui::GetFontSize() + 10.0f;
            const char* lines[] = {
                "Key    : ZexisRE",
                "Status : Available",
                "DEV    : MONALISA",
                "Build  : OB53 v6",
                "Theme  : MONA %9",
            };
            for (int i = 0; i < 5; ++i) {
                ImVec2 pos = w->DC.CursorPos;
                ImVec2 size(ImGui::GetContentRegionAvail().x, lh);
                ImGui::ItemSize(size, 0.0f);
                w->DrawList->AddText(ImVec2(pos.x + ZX_PAD_LEFT + 6.0f, pos.y + (lh - ImGui::GetFontSize()) * 0.5f), ZX_TEXT, lines[i]);
            }
            break;
        }
    }
    ImGui::EndChild();
    ImGui::PopStyleColor();

    // ❌ ลบสามเหลี่ยมแดงมุมล่างขวาแล้ว — ให้มุมโค้งเหมือนมุมอื่นๆ
    ImGui::End();
    ImGui::PopStyleVar(5);
    ImGui::PopStyleColor(2);
}

// Hooks / touch handlers (คงเดิม)
void SetNinjaRunSpeedPreset(int preset);
extern void old_AutoFire(void *_this, int32_t pFireStatus, int32_t pFireMode);
extern void (*_AutoFire)(void *_this, int32_t pFireStatus, int32_t pFireMode);
void initAutoFireHook(void);

void initAutoFireHook(void) {
    static bool hookInitialized = false;
    if (hookInitialized) return;
    hookInitialized = true;
    NSString *patchResult = StaticInlineHookPatch(("Frameworks/UnityFramework.framework/UnityFramework"), 0x56524D4, nullptr);
    NSLog(@"[AutoFire] patch result: %@", patchResult ?: @"<nil>");
    void *original = StaticInlineHookFunction(("Frameworks/UnityFramework.framework/UnityFramework"), 0x56524D4, (void *)old_AutoFire);
    if (original) { *(void **)(&_AutoFire) = original; }
}

- (void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);
    BOOL hasActive = NO;
    for (UITouch *touch in event.allTouches)
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
            { hasActive = YES; break; }
    io.MouseDown[0] = hasActive;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event   { [self updateIOWithTouchEvent:event]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint cur = [touch locationInView:self.view];
    CGPoint prv = [touch previousLocationInView:self.view];
    ImGui::GetIO().MouseWheel  = (prv.y - cur.y) / 8.0f;
    ImGui::GetIO().MouseWheelH = (cur.x - prv.x) / 8.0f;
    [self updateIOWithTouchEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event   { [self updateIOWithTouchEvent:event]; }

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView*)view {
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    CGFloat fbScale = view.window.screen.nativeScale ?: UIScreen.mainScreen.nativeScale;
    io.DisplayFramebufferScale = ImVec2(fbScale, fbScale);
    io.DeltaTime = 1.0f / float(view.preferredFramesPerSecond ?: 60);
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    [self.view setUserInteractionEnabled:MenDeal ? YES : NO];
    MTLRenderPassDescriptor* rpd = view.currentRenderPassDescriptor;
    if (rpd) {
        id<MTLRenderCommandEncoder> enc = [commandBuffer renderCommandEncoderWithDescriptor:rpd];
        [enc pushDebugGroup:@"ImGui"];
        ImGui_ImplMetal_NewFrame(rpd);
        ImGui::NewFrame();
        CGFloat screenW = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
        CGFloat screenH = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
        ImGui::SetNextWindowPos(ImVec2((screenW - ZX_WIN_W) * 0.5f, (screenH - ZX_WIN_H) * 0.5f), ImGuiCond_FirstUseEver);
        if (MenDeal) RenderMenu();
        ZX_ApplyAndRun();   // ✅ ทำงานทุกเฟรม ไม่ต้องเปิดเมนูค้าง
        [self updateFloatButtonsVisibility];   // ✅ โชว์/ซ่อน + ซิงก์ปุ่มลอย
        ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
        get_players();
        draw_watermark();
        aimbot();
        game_sdk->init();
        Vars.isAimFov = (Vars.AimFov > 0);
        ImGui::Render();
        ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, enc);
        [enc popDebugGroup];
        [enc endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size {}

@end
