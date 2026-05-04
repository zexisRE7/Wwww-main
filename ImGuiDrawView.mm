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
    
    // สร้างปุ่มลอย 
    [self createFlyButton];
    [self createTelekillButton];
    [self createAimkillButton];
    [self createNoRecoilButton];
    [self createMarkTPButton];
    [self createAutoTPButton];
    [self updateFloatButtonsVisibility];
}

// 
- (UIButton *)makeFloatButton:(NSString *)title centerX:(CGFloat)cx centerY:(CGFloat)cy {
    const CGFloat BW = 68.0f, BH = 58.0f;
    UIWindow *win = [UIApplication sharedApplication].keyWindow
                 ?: [UIApplication sharedApplication].windows.firstObject;
    UIButton *btn = [[UIButton alloc] initWithFrame:
        CGRectMake(cx - BW * 0.5f, cy - BH * 0.5f, BW, BH)];

    // สีพื้นหลัง
    btn.backgroundColor = [UIColor colorWithRed:0.07 green:0.22 blue:0.13 alpha:0.95];
    btn.layer.cornerRadius   = 12;
    btn.layer.borderWidth    = 1.5f;
    btn.layer.borderColor    = [UIColor colorWithRed:0.18 green:0.55 blue:0.32 alpha:1.0].CGColor;
    btn.layer.masksToBounds  = YES;

    // label บนสุด
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, BW, 18)];
    lbl.text          = title;
    lbl.textColor     = [UIColor whiteColor];
    lbl.font          = [UIFont boldSystemFontOfSize:10];
    lbl.textAlignment = NSTextAlignmentCenter;
    [btn addSubview:lbl];

    [btn addTarget:self action:@selector(buttonDragged:withEvent:)
        forControlEvents:UIControlEventTouchDragInside];
    [win addSubview:btn];
    [win bringSubviewToFront:btn];
    return btn;
}

- (UISwitch *)makeFloatSwitch:(UIButton *)btn {
    const CGFloat BW = 68.0f, BH = 58.0f;
    UISwitch *sw = [[UISwitch alloc] init];
    [sw sizeToFit];
    // ย่อ switch ให้พอดีปุ่ม
    sw.transform = CGAffineTransformMakeScale(0.78f, 0.78f);
    sw.center    = CGPointMake(BW * 0.5f, BH * 0.62f);
    // สีเขียว iOS เมื่อเปิด
    sw.onTintColor  = [UIColor colorWithRed:0.20 green:0.78 blue:0.35 alpha:1.0];
    sw.thumbTintColor = [UIColor whiteColor];
    [btn addSubview:sw];
    return sw;
}

// ── Screen center helper ───────────────────────────────────────────────────
- (CGPoint)screenCenter {
    CGSize s = UIScreen.mainScreen.bounds.size;
    return CGPointMake(s.width * 0.5f, s.height * 0.5f);
}

//  UIButtons  — ตำแหน่งเริ่มต้น: กลางจอ (ลากได้)
- (void)createFlyButton {
    CGPoint c = [self screenCenter];
    self.flyButton = [self makeFloatButton:@"FLY ALT"
                                   centerX:c.x - 76 centerY:c.y - 35];
    self.flySwitch = [self makeFloatSwitch:self.flyButton];
    self.flySwitch.on = ZX_FlyAlt;
    [self.flySwitch addTarget:self action:@selector(flySwitchChanged:)
        forControlEvents:UIControlEventValueChanged];
}

- (void)createTelekillButton {
    CGPoint c = [self screenCenter];
    self.telekillButton = [self makeFloatButton:@"TELE VIP"
                                        centerX:c.x centerY:c.y - 35];
    self.telekillSwitch = [self makeFloatSwitch:self.telekillButton];
    self.telekillSwitch.on = ZX_Telekill;
    [self.telekillSwitch addTarget:self action:@selector(telekillSwitchChanged:)
        forControlEvents:UIControlEventValueChanged];
}

- (void)createAimkillButton {
    CGPoint c = [self screenCenter];
    self.aimkillButton = [self makeFloatButton:@"AI KILL"
                                       centerX:c.x + 76 centerY:c.y - 35];
    self.aimkillSwitch = [self makeFloatSwitch:self.aimkillButton];
    self.aimkillSwitch.on = ZX_AimKill;
    [self.aimkillSwitch addTarget:self action:@selector(aimkillSwitchChanged:)
        forControlEvents:UIControlEventValueChanged];
}

- (void)createNoRecoilButton {
    CGPoint c = [self screenCenter];
    self.norecoilButton = [self makeFloatButton:@"KILL"
                                        centerX:c.x - 76 centerY:c.y + 35];
    self.norecoilSwitch = [self makeFloatSwitch:self.norecoilButton];
    self.norecoilSwitch.on = ZX_NoRecoil;
    [self.norecoilSwitch addTarget:self action:@selector(norecoilSwitchChanged:)
        forControlEvents:UIControlEventValueChanged];
}

- (void)createMarkTPButton {
    CGPoint c = [self screenCenter];
    self.markTPButton = [self makeFloatButton:@"NINJA"
                                      centerX:c.x centerY:c.y + 35];
    self.markTPSwitch = [self makeFloatSwitch:self.markTPButton];
    self.markTPSwitch.on = ZX_MarkTeleport;
    [self.markTPSwitch addTarget:self action:@selector(markTPSwitchChanged:)
        forControlEvents:UIControlEventValueChanged];
}

- (void)createAutoTPButton {
    CGPoint c = [self screenCenter];
    self.autoTPButton = [self makeFloatButton:@"GHOST"
                                      centerX:c.x + 76 centerY:c.y + 35];
    self.autoTPSwitch = [self makeFloatSwitch:self.autoTPButton];
    self.autoTPSwitch.on = ZX_AutoTeleport;
    [self.autoTPSwitch addTarget:self action:@selector(autoTPSwitchChanged:)
        forControlEvents:UIControlEventValueChanged];
}

- (void)updateFloatButtonsVisibility {
    //  ปุ่มโผล่เมื่อเปิดฟังก์ชันนั้นจากเมนู — ผูกตรงกับ feature flag
    self.flyButton.hidden      = !ZX_FlyAlt;
    self.telekillButton.hidden = !ZX_Telekill;
    self.aimkillButton.hidden  = !ZX_AimKill;
    self.norecoilButton.hidden = !ZX_NoRecoil;
    self.markTPButton.hidden   = !ZX_MarkTeleport;
    self.autoTPButton.hidden   = !ZX_AutoTeleport;

    //  ซิงก์สถานะสวิตช์บนปุ่มให้ตรงกับ ZX_var
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

// ui — DS Gaming style (white iOS, top tabs)

// ui
static const ImU32 ZX_WIN_BG        = IM_COL32(  0,   0,   0, 255);   // pure black
static const ImU32 ZX_TITLE_BG      = IM_COL32(  0,   0,   0, 255);   // pure black
static const ImU32 ZX_PANEL_BG      = IM_COL32(  8,   8,   8, 255);   // sidebar bg
static const ImU32 ZX_PANEL_BORDER  = IM_COL32( 22,  22,  22, 255);
static const ImU32 ZX_SIDE_BTN_BG   = IM_COL32( 16,  16,  16, 255);   // sidebar btn
static const ImU32 ZX_SIDE_BTN_ACT  = IM_COL32( 24,  24,  24, 255);   // active btn bg
static const ImU32 ZX_SIDE_BORDER   = IM_COL32( 22,  22,  22, 255);
static const ImU32 ZX_SIDE_BORDER_A = IM_COL32( 28,  28,  28, 255);
static const ImU32 ZX_TAB_TEXT      = IM_COL32(255,  95,  30, 255);   // orange text
static const ImU32 ZX_TAB_TEXT_DIM  = IM_COL32(120, 120, 120, 200);   // dim gray
static const ImU32 ZX_TAB_UNDERLINE = IM_COL32(255,  95,  30, 120);
static const ImU32 ZX_TAB_DIV       = IM_COL32( 22,  22,  22, 255);
static const ImU32 ZX_SEP           = IM_COL32( 20,  20,  20, 255);   // separator
static const ImU32 ZX_SECTION       = IM_COL32(120, 120, 120, 255);   // section label
static const ImU32 ZX_SUB           = IM_COL32( 90,  90,  90, 255);
static const ImU32 ZX_TEXT          = IM_COL32(225, 225, 225, 255);   // white text
static const ImU32 ZX_TEXT_DIM      = IM_COL32(110, 110, 110, 255);   // gray dim
// checkmark circle toggle (replaces iOS toggle)
static const ImU32 ZX_TGL_ON        = IM_COL32(255,  95,  30, 255);   // orange ON
static const ImU32 ZX_TGL_OFF       = IM_COL32( 28,  28,  28, 255);   // near-black OFF
static const ImU32 ZX_TGL_KNOB      = IM_COL32(255, 255, 255, 255);
static const ImU32 ZX_HOVER         = IM_COL32(255, 255, 255,   8);
// checkmark
static const ImU32 ZX_CHK_BG        = IM_COL32( 28,  28,  28, 255);
static const ImU32 ZX_CHK_BG_ON     = IM_COL32(255,  95,  30, 255);
static const ImU32 ZX_CHK_BORDER    = IM_COL32( 38,  38,  38, 255);
static const ImU32 ZX_CHK_BORDER_ON = IM_COL32(255,  95,  30, 255);
static const ImU32 ZX_CORNER_YELLOW = IM_COL32(255,  95,  30, 100);
// slider
static const ImU32 ZX_SLIDER_BG     = IM_COL32( 28,  28,  28, 255);   // near-black track
static const ImU32 ZX_SLIDER_FILL   = IM_COL32(255,  95,  30, 255);   // orange fill
static const ImU32 ZX_KNOB_OUTLINE  = IM_COL32(255,  95,  30, 200);
// warning row
static const ImU32 ZX_WARN_BG       = IM_COL32(255,  95,  30,  30);   // orange tint
static const ImU32 ZX_WARN_BORDER   = IM_COL32(255,  95,  30, 110);
// item bg
static const ImU32 ZX_ITEM_BG       = IM_COL32( 14,  14,  14, 255);   // very dark item
static const ImU32 ZX_ITEM_BORDER   = IM_COL32( 22,  22,  22, 255);
static const ImU32 ZX_DROP_BORDER   = IM_COL32(255,  95,  30, 200);
// accents
static const ImU32 ZX_ORANGE        = IM_COL32(255,  95,  30, 255);
static const ImU32 ZX_CYAN          = IM_COL32(  0, 122, 255, 255);
static const ImU32 ZX_GREEN         = IM_COL32( 52, 199,  89, 255);
static const ImU32 ZX_RED           = IM_COL32(255,  59,  48, 255);
static const ImU32 ZX_PURPLE        = IM_COL32(175,  82, 222, 255);
static const ImU32 ZX_YELLOW        = IM_COL32(255, 204,   0, 255);

// ── Layout — Dark Gaming sidebar style 
static const float ZX_WIN_W      = 345.0f;
static const float ZX_WIN_H      = 480.0f;
static const float ZX_WIN_RAD    = 16.0f;
static const float ZX_SIDEBAR_W  = 54.0f;   // left sidebar width
static const float ZX_HEADER_H   = 54.0f;   // header area height
static const float ZX_ROW_H      = 46.0f;   // item row height
static const float ZX_ROW_RAD    = 10.0f;   // item border radius
static const float ZX_ROW_GAP    =  7.0f;   // gap between rows
static const float ZX_ROW_PAD    = 10.0f;   // left/right margin in content
static const float ZX_CHK_R      = 13.0f;   // checkmark circle radius
static const float ZX_PAD_LEFT   = 14.0f;
static const float ZX_FONT_SIZE  = 15.0f;
static const float ZX_SLIDER_H   =  6.0f;
static const float ZX_KNOB_R     = 10.0f;
// keep old names for compatibility with code outside RenderMenu()
static const float ZX_TITLE_H    = 50.0f;
static const float ZX_TOP_PAD    =  0.0f;
static const float ZX_TAB_H      = 44.0f;
static const float ZX_SIDE_W     =  0.0f;
static const float ZX_BOT_H      = 34.0f;
static const float ZX_SIDE_BTN   = 40.0f;
static const float ZX_SIDE_GAP   =  4.0f;
static const float ZX_DROP_H     = 22.0f;
static const float ZX_LABEL_H    = 24.0f;
static const float ZX_SUB_H      = 18.0f;
static const float ZX_PAD_TOP    =  5.0f;
static const float ZX_CHK_BOX    = 16.0f;
static const float ZX_CHK_RAD    =  4.0f;
static const float ZX_FRAME_RAD  =  5.0f;

// STATE
static int   ZX_Tab            = 0;   // 
static bool  ZX_Collapsed      = false;
static bool  ZX_StreamMode     = false;
static bool  ZX_Count          = false;
static bool  ZX_FlyAlt         = false;
static float ZX_FlySpeed       = 5.0f;
static bool  ZX_FastFire       = false;
static bool  ZX_LongRange      = false;
static bool  ZX_BulletThru     = false;
static bool  ZX_FastSwitch     = false;
static bool  ZX_FastSwitchAuto = false;   // สับปืนเร็วอัตโนมัติ (ทุกเฟรม)
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
static bool  ZX_DashForward    = false;   // กดปุ่ม → พุ่งไปข้างหน้า 100m ทันที
static float ZX_DashDistance   = 100.0f;  // ระยะ dash (เมตร)
static bool  ZX_HideModMenu    = false;
static bool  ZX_Esp2DCorner    = false;
static bool  ZX_Esp3DBox       = false;
static bool  ZX_CameraLeft     = false;
static float ZX_CameraHeight   = 5.0f;
static float ZX_CameraSide     = 0.0f;
static bool  ZX_FloatBtnEnabled = false;   //  master toggle — เปิดจากเมนูก่อนปุ่มลอยถึงจะโผล่
static bool  ZX_ShowFlyBtn      = false;
static bool  ZX_ShowTelekillBtn = false;
static bool  ZX_ShowAimkillBtn  = false;
static bool  ZX_ShowNorecoilBtn = false;
static bool  ZX_ShowMarkTPBtn   = false;
static bool  ZX_ShowAutoTPBtn   = false;
// 
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

// ── iOS-style toggle row: ชื่อซ้าย 
static bool ZX_SonicCheckCell(ImVec2 cellMin, ImVec2 cellMax, const char* label, bool* v) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    const ImGuiID id = window->GetID(label);
    ImRect bb(cellMin, cellMax);
    ImGui::ItemAdd(bb, id);
    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hovered, &held);
    if (pressed) *v = !*v;
    ImDrawList* dl = window->DrawList;
    if (hovered) dl->AddRectFilled(bb.Min, bb.Max, ZX_HOVER, 0.0f);

    // เส้นแบ่งบนและล่างแถว
    dl->AddLine(ImVec2(bb.Min.x, bb.Min.y), ImVec2(bb.Max.x, bb.Min.y), ZX_SEP, 1.0f);
    dl->AddLine(ImVec2(bb.Min.x, bb.Max.y - 1), ImVec2(bb.Max.x, bb.Max.y - 1), ZX_SEP, 1.0f);

    float cy     = (bb.Min.y + bb.Max.y) * 0.5f;
    float tglW   = 51.0f, tglH = 31.0f, tglR = tglH * 0.5f;
    float cW     = bb.Max.x - bb.Min.x;

    // ป้ายชื่อซ้าย
    dl->AddText(ImVec2(bb.Min.x + ZX_PAD_LEFT, cy - ImGui::GetFontSize() * 0.5f), ZX_TEXT, label);

    // iOS toggle ขวา
    float tglX = bb.Max.x - tglW - ZX_PAD_LEFT;
    float tglY = cy - tglH * 0.5f;
    ImU32 track = *v ? ZX_TGL_ON : ZX_TGL_OFF;
    dl->AddRectFilled(ImVec2(tglX, tglY), ImVec2(tglX + tglW, tglY + tglH), track, tglR);
    float knobX = *v ? (tglX + tglW - tglR) : (tglX + tglR);
    dl->AddCircleFilled(ImVec2(knobX, cy), tglR - 2.5f, ZX_TGL_KNOB);

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
    ZX_SonicCheckRow(l1, v1);
    ZX_SonicCheckRow(l2, v2);
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

// 
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

// ทำงานทุกเฟรม ไม่ต้องเปิดเมนูค้าง
static void ZX_ApplyAndRun() {
    Vars.AimbotEnable = Vars.Aimbot;
    Vars.isAimFov = (Vars.AimFov > 0);
    Vars.fovLineColor[0] = 0.90f;
    Vars.fovLineColor[1] = 0.22f;
    Vars.fovLineColor[2] = 0.24f;
    Vars.fovLineColor[3] = 1.00f;
    Vars.FastFire = ZX_FastFire;
    FireDelay = ZX_FastFire ? 0.0f : 0.001f;
    if (ZX_FastFire && Vars.Enable) {
        Vars.AutoFire = true;   // บังคับ AutoFire hook ทำงาน
        void* _ff_match = game_sdk->Curent_Match();
        if (_ff_match) {
            void* _ff_local = game_sdk->GetLocalPlayer(_ff_match);
            if (_ff_local) {
                void* _ff_wpn = GetWeaponOnHand1(_ff_local);
                if (_ff_wpn) Weapon_StartFiring(_ff_wpn);  // บังคับยิงทันที (0x4EA8A54)
            }
        }
    }
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
    if (ZX_DashForward) { RunDashForward(ZX_DashDistance); ZX_DashForward = false; }
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
    if (ZX_NoReload) {
        RunNoReload();
    }
    if (ZX_FastSwitchAuto) {
        RunFastSwitch();
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
    //  Camera Left – มุมสูงปรับได้ + ซ้าย/ขวา
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

// ── Dark Gaming: draw crosshair icon ─────────────────────────────────────────
static void ZX_DrawCrosshair(ImDrawList* dl, ImVec2 c, float s, ImU32 col) {
    float r = s * 0.38f, a = s * 0.55f;
    dl->AddCircle(c, r, col, 22, 1.6f);
    dl->AddLine(ImVec2(c.x-a, c.y), ImVec2(c.x-r*0.5f, c.y), col, 1.6f);
    dl->AddLine(ImVec2(c.x+r*0.5f, c.y), ImVec2(c.x+a, c.y), col, 1.6f);
    dl->AddLine(ImVec2(c.x, c.y-a), ImVec2(c.x, c.y-r*0.5f), col, 1.6f);
    dl->AddLine(ImVec2(c.x, c.y+r*0.5f), ImVec2(c.x, c.y+a), col, 1.6f);
}

// ── Dark Gaming: draw sword icon ─────────────────────────────────────────────
static void ZX_DrawSword(ImDrawList* dl, ImVec2 c, float s, ImU32 col) {
    float h = s * 0.70f;
    dl->AddLine(ImVec2(c.x, c.y - h), ImVec2(c.x, c.y + h * 0.4f), col, 2.0f);
    dl->AddLine(ImVec2(c.x - s*0.30f, c.y - h*0.15f), ImVec2(c.x + s*0.30f, c.y - h*0.15f), col, 1.6f);
    dl->AddLine(ImVec2(c.x, c.y + h*0.4f), ImVec2(c.x - s*0.14f, c.y + h*0.70f), col, 2.0f);
}

// ── Dark Gaming: draw warning triangle ───────────────────────────────────────
static void ZX_DrawWarning(ImDrawList* dl, ImVec2 c, float s, ImU32 col) {
    ImVec2 pts[3] = { ImVec2(c.x, c.y - s*0.55f), ImVec2(c.x - s*0.50f, c.y + s*0.40f), ImVec2(c.x + s*0.50f, c.y + s*0.40f) };
    dl->AddTriangle(pts[0], pts[1], pts[2], col, 1.8f);
    dl->AddLine(ImVec2(c.x, c.y - s*0.22f), ImVec2(c.x, c.y + s*0.10f), col, 2.0f);
    dl->AddCircleFilled(ImVec2(c.x, c.y + s*0.22f), s*0.07f, col, 8);
}

// ── Dark Gaming: draw moon/crescent icon ─────────────────────────────────────
static void ZX_DrawMoon(ImDrawList* dl, ImVec2 c, float s, ImU32 col) {
    dl->AddCircle(c, s*0.42f, col, 22, 1.6f);
    dl->AddCircleFilled(ImVec2(c.x + s*0.18f, c.y - s*0.10f), s*0.34f, ZX_PANEL_BG, 22);
}

// ── Dark Gaming: checkmark circle (ON=orange, OFF=gray) ──────────────────────
static void ZX_DrawCheckCircle(ImDrawList* dl, ImVec2 c, float r, bool on) {
    ImU32 bg = on ? ZX_TGL_ON : ZX_TGL_OFF;
    dl->AddCircleFilled(c, r, bg, 24);
    if (on) {
        float s = r * 0.48f;
        ImVec2 p0(c.x - s*0.80f, c.y);
        ImVec2 p1(c.x - s*0.15f, c.y + s*0.70f);
        ImVec2 p2(c.x + s*0.85f, c.y - s*0.65f);
        dl->AddLine(p0, p1, ZX_TGL_KNOB, 2.0f);
        dl->AddLine(p1, p2, ZX_TGL_KNOB, 2.0f);
    }
}

// ── Dark Gaming: item row (rounded dark rect + checkmark circle) ──────────────
static bool ZX_DarkItemRow(const char* label, bool* v) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;
    float aw  = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = window->DC.CursorPos;
    const ImGuiID id = window->GetID(label);
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + ZX_ROW_H));
    ImGui::ItemSize(ImVec2(aw, ZX_ROW_H + ZX_ROW_GAP), 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hovered, &held);
    if (pressed) *v = !*v;

    ImDrawList* dl = window->DrawList;
    ImU32 itemBg = hovered ? ZX_SIDE_BTN_ACT : ZX_ITEM_BG;
    dl->AddRectFilled(bb.Min, ImVec2(bb.Max.x, bb.Min.y + ZX_ROW_H), itemBg, ZX_ROW_RAD);

    float cy = bb.Min.y + ZX_ROW_H * 0.5f;
    dl->AddText(ImVec2(bb.Min.x + ZX_PAD_LEFT, cy - ImGui::GetFontSize() * 0.5f), ZX_TEXT, label);

    float cx = bb.Max.x - ZX_PAD_LEFT - ZX_CHK_R;
    ZX_DrawCheckCircle(dl, ImVec2(cx, cy), ZX_CHK_R, *v);

    return pressed;
}

// ── Dark Gaming: warning row (orange tint + ⚠ icon + description text) ────────
static bool ZX_DarkWarningRow(const char* label, const char* desc, bool* v) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;
    float aw  = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = window->DC.CursorPos;
    float descH = desc ? 36.0f : 0.0f;
    float rowH  = ZX_ROW_H + descH;
    const ImGuiID id = window->GetID(label);
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + rowH));
    ImGui::ItemSize(ImVec2(aw, rowH + ZX_ROW_GAP), 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hovered, &held);
    if (pressed) *v = !*v;

    ImDrawList* dl = window->DrawList;
    dl->AddRectFilled(bb.Min, ImVec2(bb.Max.x, bb.Max.y), ZX_WARN_BG, ZX_ROW_RAD);
    dl->AddRect(bb.Min, ImVec2(bb.Max.x, bb.Max.y), ZX_WARN_BORDER, ZX_ROW_RAD, 0, 1.2f);

    float cy = bb.Min.y + ZX_ROW_H * 0.5f;
    ZX_DrawWarning(dl, ImVec2(bb.Min.x + ZX_PAD_LEFT + 9.0f, cy), 9.0f, ZX_ORANGE);
    dl->AddText(ImVec2(bb.Min.x + ZX_PAD_LEFT + 26.0f, cy - ImGui::GetFontSize() * 0.5f), ZX_TEXT, label);

    float cx = bb.Max.x - ZX_PAD_LEFT - ZX_CHK_R;
    ZX_DrawCheckCircle(dl, ImVec2(cx, cy), ZX_CHK_R, *v);

    if (desc) {
        ImFont* fnt = ImGui::GetFont();
        float   fsm = ImGui::GetFontSize() * 0.76f;
        dl->AddText(fnt, fsm, ImVec2(bb.Min.x + ZX_PAD_LEFT, bb.Min.y + ZX_ROW_H + 4.0f), ZX_TEXT_DIM, desc);
    }
    return pressed;
}

// ── Dark Gaming: orange slider row ───────────────────────────────────────────
static bool ZX_DarkSliderRow(const char* label, float* v, float vmin, float vmax) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;
    ImGuiContext& g = *GImGui;
    float aw   = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = window->DC.CursorPos;
    const float rowH = ZX_ROW_H + 16.0f;
    const ImGuiID id = window->GetID(label);
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + rowH));
    ImGui::ItemSize(ImVec2(aw, rowH + ZX_ROW_GAP), 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;

    ImDrawList* dl = window->DrawList;
    dl->AddRectFilled(bb.Min, ImVec2(bb.Max.x, bb.Max.y), ZX_ITEM_BG, ZX_ROW_RAD);

    float labelY = pos.y + 10.0f;
    dl->AddText(ImVec2(pos.x + ZX_PAD_LEFT, labelY), ZX_TEXT, label);
    char vbuf[32]; snprintf(vbuf, sizeof(vbuf), "%.1f", *v);
    ImVec2 vts = ImGui::CalcTextSize(vbuf);
    dl->AddText(ImVec2(pos.x + aw - ZX_PAD_LEFT - vts.x, labelY), ZX_TEXT_DIM, vbuf);

    const float tX0 = pos.x + ZX_PAD_LEFT;
    const float tX1 = pos.x + aw - ZX_PAD_LEFT;
    const float tY  = pos.y + rowH - 14.0f;
    float t = (*v - vmin) / (vmax - vmin);
    if (t < 0.0f) t = 0.0f; if (t > 1.0f) t = 1.0f;

    ImRect trackBB(ImVec2(tX0 - ZX_KNOB_R, tY - ZX_KNOB_R), ImVec2(tX1 + ZX_KNOB_R, tY + ZX_KNOB_R));
    bool hov, hld;
    ImGui::ButtonBehavior(trackBB, id, &hov, &hld);
    if (hld) {
        float nt = (g.IO.MousePos.x - tX0) / (tX1 - tX0);
        if (nt < 0.0f) nt = 0.0f; if (nt > 1.0f) nt = 1.0f;
        *v = vmin + nt * (vmax - vmin); t = nt;
        ImGui::MarkItemEdited(id);
    }
    dl->AddRectFilled(ImVec2(tX0, tY - ZX_SLIDER_H*0.5f), ImVec2(tX1, tY + ZX_SLIDER_H*0.5f), ZX_SLIDER_BG, ZX_SLIDER_H);
    dl->AddRectFilled(ImVec2(tX0, tY - ZX_SLIDER_H*0.5f), ImVec2(tX0 + (tX1-tX0)*t, tY + ZX_SLIDER_H*0.5f), ZX_SLIDER_FILL, ZX_SLIDER_H);
    float kX = tX0 + (tX1 - tX0) * t;
    dl->AddCircleFilled(ImVec2(kX, tY), ZX_KNOB_R + 1.0f, IM_COL32(0,0,0,30), 24);
    dl->AddCircleFilled(ImVec2(kX, tY), ZX_KNOB_R, ZX_TGL_KNOB, 24);
    dl->AddCircle(ImVec2(kX, tY), ZX_KNOB_R, ZX_ORANGE, 24, 1.2f);
    return hld;
}

// ── Dark Gaming: section label ────────────────────────────────────────────────
static void ZX_DarkSection(const char* label) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return;
    float aw = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = window->DC.CursorPos;
    ImGui::ItemSize(ImVec2(aw, 22.0f), 0.0f);
    window->DrawList->AddText(ImVec2(pos.x + ZX_PAD_LEFT, pos.y + 4.0f), ZX_TEXT_DIM, label);
}

// ── DS Gaming: Section header row (gray bg, bold label) ──────────────────────
static void ZX_DSSection(ImDrawList* dl, ImVec2 pos, float w, const char* label) {
    const float H = ZX_LABEL_H + 10.0f;
    // gray background stripe
    dl->AddRectFilled(pos, ImVec2(pos.x + w, pos.y + H), ZX_PANEL_BG);
    // top + bottom separator lines
    dl->AddLine(pos, ImVec2(pos.x + w, pos.y), ZX_SEP, 1.0f);
    dl->AddLine(ImVec2(pos.x, pos.y + H), ImVec2(pos.x + w, pos.y + H), ZX_SEP, 1.0f);
    // label text
    dl->AddText(ImVec2(pos.x + ZX_PAD_LEFT, pos.y + (H - ImGui::GetFontSize()) * 0.5f),
                ZX_SECTION, label);
    ImGui::ItemSize(ImVec2(w, H), 0.0f);
}

// ── DS Gaming: iOS toggle row — label left, toggle right ─────────────────────
static bool ZX_DSToggleRow(const char* label, bool* v, bool last = false) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;
    ImVec2 pos  = window->DC.CursorPos;
    float  aw   = ImGui::GetContentRegionAvail().x;
    ImVec2 size(aw, ZX_ROW_H);
    const ImGuiID id = window->GetID(label);
    ImRect bb(pos, ImVec2(pos.x + size.x, pos.y + size.y));
    ImGui::ItemSize(size, 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hovered, &held);
    if (pressed) *v = !*v;

    ImDrawList* dl = window->DrawList;
    if (hovered) dl->AddRectFilled(bb.Min, bb.Max, ZX_HOVER, 0.0f);

    // white row bg
    dl->AddRectFilled(bb.Min, bb.Max, ZX_WIN_BG, 0.0f);
    if (hovered) dl->AddRectFilled(bb.Min, bb.Max, ZX_HOVER, 0.0f);

    // bottom separator (skip if last in group)
    if (!last)
        dl->AddLine(ImVec2(bb.Min.x + ZX_PAD_LEFT, bb.Max.y - 1.0f),
                    ImVec2(bb.Max.x, bb.Max.y - 1.0f), ZX_SEP, 1.0f);

    float cy = (bb.Min.y + bb.Max.y) * 0.5f;

    // label — black, left
    dl->AddText(ImVec2(bb.Min.x + ZX_PAD_LEFT,
                       cy - ImGui::GetFontSize() * 0.5f),
                ZX_TEXT, label);

    // iOS toggle — right side
    const float TW = 51.0f, TH = 31.0f, TR = TH * 0.5f;
    float tX = bb.Max.x - TW - ZX_PAD_LEFT;
    float tY = cy - TH * 0.5f;
    ImU32 track = *v ? ZX_TGL_ON : ZX_TGL_OFF;
    dl->AddRectFilled(ImVec2(tX, tY), ImVec2(tX + TW, tY + TH), track, TR);
    float kX = *v ? (tX + TW - TR) : (tX + TR);
    // knob shadow
    dl->AddCircleFilled(ImVec2(kX, cy), TR - 1.5f,
                        IM_COL32(0, 0, 0, 22), 28);
    dl->AddCircleFilled(ImVec2(kX, cy), TR - 2.5f, ZX_TGL_KNOB, 28);

    return pressed;
}

//
//   ใช้งาน: if (ZX_FlyAlt) { ZX_DSSubToggleRow("Free Fly", &ZX_FreeFly); }
static bool ZX_DSSubToggleRow(const char* label, bool* v, bool last = false) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;
    ImVec2 pos  = window->DC.CursorPos;
    float  aw   = ImGui::GetContentRegionAvail().x;
    ImVec2 size(aw, ZX_ROW_H);
    const ImGuiID id = window->GetID(label);
    ImRect bb(pos, ImVec2(pos.x + size.x, pos.y + size.y));
    ImGui::ItemSize(size, 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hovered, &held);
    if (pressed) *v = !*v;

    ImDrawList* dl = window->DrawList;
    // พื้นหลังฟ้าอ่อน — แยกออกจาก row ปกติ
    dl->AddRectFilled(bb.Min, bb.Max, IM_COL32(0, 122, 255, 14), 0.0f);
    if (hovered) dl->AddRectFilled(bb.Min, bb.Max, ZX_HOVER, 0.0f);

    // เส้นแบ่งซ้าย (indicator ว่าเป็น sub)
    dl->AddRectFilled(ImVec2(bb.Min.x + ZX_PAD_LEFT, bb.Min.y + 4.0f),
                      ImVec2(bb.Min.x + ZX_PAD_LEFT + 3.0f, bb.Max.y - 4.0f),
                      IM_COL32(0, 122, 255, 200), 2.0f);

    // bottom separator
    if (!last)
        dl->AddLine(ImVec2(bb.Min.x + ZX_PAD_LEFT + 10.0f, bb.Max.y - 1.0f),
                    ImVec2(bb.Max.x, bb.Max.y - 1.0f), ZX_SEP, 1.0f);

    float cy = (bb.Min.y + bb.Max.y) * 0.5f;

    // label — indent เพิ่ม 18px จาก pad ปกติ
    dl->AddText(ImVec2(bb.Min.x + ZX_PAD_LEFT + 18.0f,
                       cy - ImGui::GetFontSize() * 0.5f),
                ZX_TEXT, label);

    // iOS toggle — right side (เหมือน row ปกติ)
    const float TW = 51.0f, TH = 31.0f, TR = TH * 0.5f;
    float tX = bb.Max.x - TW - ZX_PAD_LEFT;
    float tY = cy - TH * 0.5f;
    ImU32 track = *v ? ZX_TGL_ON : ZX_TGL_OFF;
    dl->AddRectFilled(ImVec2(tX, tY), ImVec2(tX + TW, tY + TH), track, TR);
    float kX = *v ? (tX + TW - TR) : (tX + TR);
    dl->AddCircleFilled(ImVec2(kX, cy), TR - 1.5f, IM_COL32(0, 0, 0, 22), 28);
    dl->AddCircleFilled(ImVec2(kX, cy), TR - 2.5f, ZX_TGL_KNOB, 28);

    return pressed;
}

// iOS blue slider row
static bool ZX_DSSliderRow(const char* label, float* v, float vmin, float vmax) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return false;
    ImGuiContext& g = *GImGui;
    const ImGuiID id = window->GetID(label);
    ImVec2 pos = window->DC.CursorPos;
    float  aw  = ImGui::GetContentRegionAvail().x;
    const float rowH = 58.0f;
    ImVec2 size(aw, rowH);
    const ImRect bb(pos, ImVec2(pos.x + size.x, pos.y + size.y));
    ImGui::ItemSize(size, 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;

    ImDrawList* dl = window->DrawList;
    dl->AddRectFilled(bb.Min, bb.Max, ZX_WIN_BG, 0.0f);

    // label row
    float labelY = pos.y + 10.0f;
    dl->AddText(ImVec2(pos.x + ZX_PAD_LEFT, labelY), ZX_TEXT, label);

    // value right
    char vbuf[32]; snprintf(vbuf, sizeof(vbuf), "%.1f", *v);
    ImVec2 vts = ImGui::CalcTextSize(vbuf);
    dl->AddText(ImVec2(pos.x + aw - ZX_PAD_LEFT - vts.x, labelY), ZX_TEXT_DIM, vbuf);

    // track geometry
    const float TH  = ZX_SLIDER_H;
    const float KR  = ZX_KNOB_R;
    const float tX0 = pos.x + ZX_PAD_LEFT;
    const float tX1 = pos.x + aw - ZX_PAD_LEFT;
    const float tY  = pos.y + rowH - 18.0f;

    float t = (*v - vmin) / (vmax - vmin);
    if (t < 0.0f) t = 0.0f;
    if (t > 1.0f) t = 1.0f;

    // dragging
    ImRect trackBB(ImVec2(tX0 - KR, tY - KR), ImVec2(tX1 + KR, tY + KR));
    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(trackBB, id, &hovered, &held);
    if (held) {
        float nt = (g.IO.MousePos.x - tX0) / (tX1 - tX0);
        if (nt < 0.0f) nt = 0.0f;
        if (nt > 1.0f) nt = 1.0f;
        *v = vmin + nt * (vmax - vmin);
        t  = nt;
        ImGui::MarkItemEdited(id);
    }

    // track
    dl->AddRectFilled(ImVec2(tX0, tY - TH * 0.5f),
                      ImVec2(tX1, tY + TH * 0.5f), ZX_SLIDER_BG, TH);
    dl->AddRectFilled(ImVec2(tX0, tY - TH * 0.5f),
                      ImVec2(tX0 + (tX1 - tX0) * t, tY + TH * 0.5f),
                      ZX_SLIDER_FILL, TH);
    // thumb
    float kX = tX0 + (tX1 - tX0) * t;
    dl->AddCircleFilled(ImVec2(kX, tY), KR + 1.0f,
                        IM_COL32(0, 0, 0, 25), 28);   // shadow
    dl->AddCircleFilled(ImVec2(kX, tY), KR, ZX_TGL_KNOB, 28);

    return pressed;
}

// ── Info display row (no toggle — แสดงค่าอย่างเดียว) ─────────────────────────
static void ZX_DarkInfoRow(const char* label, const char* value, ImU32 valueColor = 0) {
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems) return;
    ImVec2 pos = window->DC.CursorPos;
    float  aw  = ImGui::GetContentRegionAvail().x;
    ImVec2 size(aw, ZX_ROW_H);
    ImGui::ItemSize(size, 0.0f);

    ImDrawList* dl = window->DrawList;
    ImVec2 bMax(pos.x + aw, pos.y + ZX_ROW_H);
    dl->AddRectFilled(pos, bMax, ZX_ITEM_BG, ZX_ROW_RAD);
    dl->AddRect(pos, bMax, ZX_ITEM_BORDER, ZX_ROW_RAD, 0, 1.0f);

    float cy = pos.y + ZX_ROW_H * 0.5f;
    dl->AddText(ImVec2(pos.x + ZX_PAD_LEFT + 4.0f, cy - ImGui::GetFontSize() * 0.5f),
                ZX_TEXT, label);

    ImU32 vc = (valueColor != 0) ? valueColor : ZX_ORANGE;
    ImVec2 vts = ImGui::CalcTextSize(value);
    dl->AddText(ImVec2(bMax.x - ZX_PAD_LEFT - vts.x - 4.0f,
                       cy - ImGui::GetFontSize() * 0.5f), vc, value);

    ImGui::SetCursorScreenPos(ImVec2(pos.x, pos.y + ZX_ROW_H + ZX_ROW_GAP));
}

// ── Kill counter (static, increments each session) ────────────────────────────
static int  ZX_KillCount   = 0;
static bool ZX_BatMonInit  = false;

static void RenderMenu() {
    if (!MenDeal) return;

    // ── Colors matching screenshots exactly ──────────────────────────────
    const ImU32 M_WIN_BG       = IM_COL32( 30,  30,  32, 255);   // near-black window
    const ImU32 M_TAB_INACTIVE = IM_COL32( 52,  52,  55, 255);   // inactive tab button
    const ImU32 M_TAB_ACTIVE   = IM_COL32( 47,  72,  87, 255);   // active tab: dark teal
    const ImU32 M_TGL_ON       = IM_COL32( 90, 200, 250, 255);   // iOS sky-blue toggle ON
    const ImU32 M_TGL_OFF      = IM_COL32( 62,  62,  66, 255);   // gray toggle OFF
    const ImU32 M_KNOB         = IM_COL32(255, 255, 255, 255);   // white knob
    const ImU32 M_TEXT         = IM_COL32(255, 255, 255, 255);   // white text
    const ImU32 M_BTN_BG       = IM_COL32( 62,  62,  66, 255);   // close/hide button bg
    const ImU32 M_SEP          = IM_COL32( 50,  50,  54, 255);   // row separator
    const ImU32 M_HOVER        = IM_COL32(255, 255, 255,  14);   // hover tint

    // ── Layout ──────────────────────────────────────────────────────────
    const float WIN_W     = ZX_WIN_W;    // 345
    const float WIN_H     = ZX_WIN_H;    // 480
    const float WIN_RAD   = 18.0f;
    const float SB_W      = 110.0f;      // sidebar width
    const float HDR_H     =  54.0f;      // header (title) height
    const float BOT_H     =  58.0f;      // bottom buttons bar height
    const float ROW_H     =  50.0f;      // toggle row height
    const float TAB_H     =  48.0f;      // each tab button height
    const float TAB_GAP   =   6.0f;      // gap between tab buttons
    const float TAB_PAD_X =   8.0f;      // horizontal padding inside sidebar
    const float PAD       =  14.0f;      // general horizontal pad

    ImGui::PushStyleColor(ImGuiCol_WindowBg,      ImVec4(30.0f/255,30.0f/255,32.0f/255,1.0f));
    ImGui::PushStyleColor(ImGuiCol_Border,        ImVec4(0,0,0,0));
    ImGui::PushStyleColor(ImGuiCol_ScrollbarBg,   ImVec4(0,0,0,0));
    ImGui::PushStyleColor(ImGuiCol_ScrollbarGrab, ImVec4(0.22f,0.22f,0.24f,1.0f));
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding,   WIN_RAD);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding,    ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing,      ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ScrollbarSize,    3.0f);

    ImGui::SetNextWindowSize(ImVec2(WIN_W, WIN_H), ImGuiCond_Always);
    ImGui::Begin("##IpaFF", nullptr,
        ImGuiWindowFlags_NoTitleBar  | ImGuiWindowFlags_NoResize |
        ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse |
        ImGuiWindowFlags_NoBringToFrontOnFocus);
    ImGui::SetWindowFontScale(ZX_FONT_SIZE / 18.0f);

    ImDrawList* dl = ImGui::GetWindowDrawList();
    ImVec2 wp = ImGui::GetWindowPos();
    ImVec2 ws = ImGui::GetWindowSize();

    // ── Window background (rounded) ──────────────────────────────────────
    dl->AddRectFilled(wp, ImVec2(wp.x + ws.x, wp.y + ws.y), M_WIN_BG, WIN_RAD);

    // ── HEADER: centered title ───────────────────────────────────────────
    {
        const char* title = "shopx2tl.site - IPA FF";
        float hCY = wp.y + HDR_H * 0.5f;
        ImVec2 tts = ImGui::CalcTextSize(title);
        dl->AddText(ImVec2(wp.x + (ws.x - tts.x) * 0.5f, hCY - tts.y * 0.5f),
                    M_TEXT, title);
        // thin separator below header
        dl->AddLine(ImVec2(wp.x, wp.y + HDR_H),
                    ImVec2(wp.x + ws.x, wp.y + HDR_H), M_SEP, 1.0f);
    }

    // ── Zone boundaries ──────────────────────────────────────────────────
    float zoneY0 = wp.y + HDR_H;          // top of sidebar+content zone
    float zoneY1 = wp.y + WIN_H - BOT_H;  // bottom of sidebar+content zone
    float zoneH  = zoneY1 - zoneY0;

    // thin separator above bottom buttons
    dl->AddLine(ImVec2(wp.x, zoneY1), ImVec2(wp.x + ws.x, zoneY1), M_SEP, 1.0f);

    // ── LEFT SIDEBAR: text tab buttons ───────────────────────────────────
    const char* kTabNames[] = { "ESP", "AIMBOT", "AIMKILL", "BUTTON" };
    const int   kTabCount   = 4;

    float totalTabH = (float)kTabCount * TAB_H + (float)(kTabCount - 1) * TAB_GAP;
    float tabsY0    = zoneY0 + (zoneH - totalTabH) * 0.5f;  // vertically centered

    for (int i = 0; i < kTabCount; ++i) {
        float bY0 = tabsY0 + (float)i * (TAB_H + TAB_GAP);
        float bY1 = bY0 + TAB_H;
        float bX0 = wp.x + TAB_PAD_X;
        float bX1 = wp.x + SB_W - TAB_PAD_X;

        bool active = (ZX_Tab == i);
        dl->AddRectFilled(ImVec2(bX0, bY0), ImVec2(bX1, bY1),
                          active ? M_TAB_ACTIVE : M_TAB_INACTIVE, 10.0f);

        ImVec2 lts = ImGui::CalcTextSize(kTabNames[i]);
        dl->AddText(ImVec2((bX0 + bX1) * 0.5f - lts.x * 0.5f,
                           (bY0 + bY1) * 0.5f - lts.y * 0.5f),
                    M_TEXT, kTabNames[i]);

        ImGui::SetCursorScreenPos(ImVec2(bX0, bY0));
        char bid[16]; snprintf(bid, sizeof(bid), "##tab%d", i);
        if (ImGui::InvisibleButton(bid, ImVec2(bX1 - bX0, TAB_H)))
            ZX_Tab = i;
    }

    // ── RIGHT CONTENT: scrollable toggle rows ────────────────────────────
    float rcX = wp.x + SB_W;
    float rcW = ws.x - SB_W;

    ImGui::SetCursorScreenPos(ImVec2(rcX, zoneY0));
    ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(30.0f/255,30.0f/255,32.0f/255,1.0f));
    ImGui::BeginChild("##ipa_content", ImVec2(rcW, zoneH),
                      false, ImGuiWindowFlags_AlwaysVerticalScrollbar);
    ImGui::SetWindowFontScale(ZX_FONT_SIZE / 18.0f);

    // ── Helper: draw one iOS-style toggle row ─────────────────────────────
    // We use a local struct to avoid lambda captures in ObjC++ static context
    struct RowHelper {
        static void Draw(const char* label, bool* v, bool lastRow,
                         ImU32 tglOn, ImU32 tglOff, ImU32 knob,
                         ImU32 text, ImU32 sep, ImU32 hover,
                         float rowH, float pad) {
            ImGuiWindow* cw = ImGui::GetCurrentWindow();
            if (cw->SkipItems) return;
            ImVec2 pos = cw->DC.CursorPos;
            float  aw  = ImGui::GetContentRegionAvail().x;
            const ImGuiID id = cw->GetID(label);
            ImRect bb(pos, ImVec2(pos.x + aw, pos.y + rowH));
            ImGui::ItemSize(ImVec2(aw, rowH), 0.0f);
            if (!ImGui::ItemAdd(bb, id)) return;
            bool hov, hld;
            bool pressed = ImGui::ButtonBehavior(bb, id, &hov, &hld);
            if (pressed) *v = !*v;
            ImDrawList* cdl = cw->DrawList;
            if (hov) cdl->AddRectFilled(bb.Min, bb.Max, hover, 0.0f);
            if (!lastRow)
                cdl->AddLine(ImVec2(bb.Min.x + pad, bb.Max.y - 1.0f),
                             ImVec2(bb.Max.x - pad, bb.Max.y - 1.0f), sep, 1.0f);
            float cy = (bb.Min.y + bb.Max.y) * 0.5f;
            // label
            cdl->AddText(ImVec2(bb.Min.x + pad, cy - ImGui::GetFontSize() * 0.5f),
                         text, label);
            // iOS toggle
            const float TW = 51.0f, TH = 31.0f, TR = TH * 0.5f;
            float tX = bb.Max.x - TW - pad;
            float tY = cy - TH * 0.5f;
            ImU32 track = *v ? tglOn : tglOff;
            cdl->AddRectFilled(ImVec2(tX, tY), ImVec2(tX + TW, tY + TH), track, TR);
            float kX = *v ? (tX + TW - TR) : (tX + TR);
            cdl->AddCircleFilled(ImVec2(kX, cy), TR - 1.5f, IM_COL32(0,0,0,20), 28);
            cdl->AddCircleFilled(ImVec2(kX, cy), TR - 2.5f, knob, 28);
        }
    };

// Convenience macro so call sites stay readable
#define TOGGLE_ROW(lbl, ptr, last) \
    RowHelper::Draw(lbl, ptr, last, M_TGL_ON, M_TGL_OFF, M_KNOB, M_TEXT, M_SEP, M_HOVER, ROW_H, PAD)

    switch (ZX_Tab) {
        // ── ESP ──────────────────────────────────────────────────────────
        case 0: {
            TOGGLE_ROW("Enable ESP",  &Vars.Enable,  false);
            TOGGLE_ROW("Line ESP",    &Vars.lines,   false);
            TOGGLE_ROW("Box ESP",     &Vars.Box,     false);
            TOGGLE_ROW("3D Box ESP",  &ZX_Esp3DBox,  true);
            break;
        }
        // ── AIMBOT ───────────────────────────────────────────────────────
        case 1: {
            TOGGLE_ROW("Enable Aimbot",   &Vars.Enable,        false);
            TOGGLE_ROW("Aimbot",          &Vars.Aimbot,        false);
            TOGGLE_ROW("Silent Aim",      &SilentAim,          false);
            TOGGLE_ROW("Auto Fire",       &Vars.AutoFire,      false);
            TOGGLE_ROW("Aim Kill",        &ZX_AimKill,         false);
            TOGGLE_ROW("Visible Check",   &Vars.VisibleCheck,  false);
            TOGGLE_ROW("Ignore Knocked",  &Vars.IgnoreKnocked, true);
            break;
        }
        // ── AIMKILL ──────────────────────────────────────────────────────
        case 2: {
            TOGGLE_ROW("Enable",            &Vars.Enable,           false);
            TOGGLE_ROW("Fly Alt",           &ZX_FlyAlt,             false);
            TOGGLE_ROW("Telekill",          &ZX_Telekill,           false);
            TOGGLE_ROW("Fast Fire",         &ZX_FastFire,           false);
            TOGGLE_ROW("No Reload",         &ZX_NoReload,           false);
            TOGGLE_ROW("Chain Damage",      &ZX_ChainDamage,        false);
            TOGGLE_ROW("Long Range",        &Vars.LongRange,        true);
            break;
        }
        // ── BUTTON ───────────────────────────────────────────────────────
        case 3: {
            TOGGLE_ROW("RevealEnemy",    &ZX_FAKE,     false);
            TOGGLE_ROW("Under Hack",     &ZX_UNDER,    false);
            TOGGLE_ROW("Ninja Run",      &ZX_RUN,      false);
            TOGGLE_ROW("Speed NinjaRun", &ZX_GHOSTVIP, true);
            break;
        }
    }

#undef TOGGLE_ROW

    ImGui::EndChild();
    ImGui::PopStyleColor();  // ChildBg

    // ── BOTTOM BUTTONS: Close  |  HIDE ───────────────────────────────────
    {
        float bbCY = zoneY1 + BOT_H * 0.5f;
        const float BH  = 40.0f;  // button height
        const float GAP = 12.0f;
        float bW  = (ws.x - PAD * 2.0f - GAP) * 0.5f;
        float bY0 = bbCY - BH * 0.5f;
        float bY1 = bbCY + BH * 0.5f;

        // ── Close
        float cX0 = wp.x + PAD;
        float cX1 = cX0 + bW;
        dl->AddRectFilled(ImVec2(cX0, bY0), ImVec2(cX1, bY1), M_BTN_BG, 12.0f);
        ImVec2 cts = ImGui::CalcTextSize("Close");
        dl->AddText(ImVec2((cX0 + cX1) * 0.5f - cts.x * 0.5f, bbCY - cts.y * 0.5f),
                    M_TEXT, "Close");
        ImGui::SetCursorScreenPos(ImVec2(cX0, bY0));
        if (ImGui::InvisibleButton("##close", ImVec2(bW, BH)))
            MenDeal = false;

        // ── HIDE
        float hX0 = cX1 + GAP;
        float hX1 = hX0 + bW;
        dl->AddRectFilled(ImVec2(hX0, bY0), ImVec2(hX1, bY1), M_BTN_BG, 12.0f);
        ImVec2 hts = ImGui::CalcTextSize("HIDE");
        dl->AddText(ImVec2((hX0 + hX1) * 0.5f - hts.x * 0.5f, bbCY - hts.y * 0.5f),
                    M_TEXT, "HIDE");
        ImGui::SetCursorScreenPos(ImVec2(hX0, bY0));
        if (ImGui::InvisibleButton("##hide", ImVec2(bW, BH)))
            ZX_HideModMenu = !ZX_HideModMenu;
    }

    ImGui::End();
    ImGui::PopStyleVar(5);
    ImGui::PopStyleColor(4);
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
        if (MenDeal) { RenderMenu(); }

        // ── Floating KILL Button — ลอยบนหน้าจอตลอด (กด = kill, ค้าง+ลาก = ย้าย) ──
        if (Vars.Enable) {
            static ImVec2 killBtnPos(screenW - 90.0f, screenH * 0.5f);
            static bool   killDragging   = false;
            static ImVec2 killDragOffset(0.0f, 0.0f);

            const float BW = 70.0f, BH = 36.0f, BR = 18.0f;
            ImVec2 bMin = killBtnPos;
            ImVec2 bMax = ImVec2(bMin.x + BW, bMin.y + BH);

            ImGuiIO& io   = ImGui::GetIO();
            bool hovered  = io.MousePos.x >= bMin.x && io.MousePos.x <= bMax.x &&
                            io.MousePos.y >= bMin.y && io.MousePos.y <= bMax.y;

            if (hovered && ImGui::IsMouseClicked(0))
                killDragOffset = ImVec2(io.MousePos.x - bMin.x, io.MousePos.y - bMin.y);
            if (ImGui::IsMouseDown(0) && hovered && io.MouseDownDuration[0] > 0.3f)
                killDragging = true;
            if (killDragging)
                killBtnPos = ImVec2(io.MousePos.x - killDragOffset.x,
                                    io.MousePos.y - killDragOffset.y);
            if (!ImGui::IsMouseDown(0)) killDragging = false;

            ImDrawList* fdl   = ImGui::GetForegroundDrawList();
            ImU32 btnColor    = (hovered && !killDragging)
                              ? IM_COL32(200,  0,  0, 255)
                              : IM_COL32(255, 59, 48, 220);
            fdl->AddRectFilled(bMin, bMax, btnColor, BR);
            fdl->AddRect(bMin, bMax, IM_COL32(255,255,255,60), BR, 0, 1.5f);

            const char* txt = "KILL";
            ImVec2 ts = ImGui::CalcTextSize(txt);
            fdl->AddText(ImVec2(bMin.x + (BW - ts.x) * 0.5f,
                                bMin.y + (BH - ts.y) * 0.5f),
                         IM_COL32(255,255,255,255), txt);

            if (hovered && ImGui::IsMouseReleased(0) && !killDragging) {
                // ใส่ kill function
                // ZX_AimKill = true;
                // KillNearestEnemy();
            }
        }

        ZX_ApplyAndRun();   //  ทำงานทุกเฟรม ไม่ต้องเปิดเมนูค้าง
        [self updateFloatButtonsVisibility];   //โชว์/ซ่อน + ซิงก์ปุ่มลอย
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
