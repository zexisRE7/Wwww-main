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

// ── Helper: สร้างปุ่มลอยสไตล์เขียวเข้มตามรูป ──────────────────────────────
- (UIButton *)makeFloatButton:(NSString *)title centerX:(CGFloat)cx centerY:(CGFloat)cy {
    const CGFloat BW = 68.0f, BH = 58.0f;
    UIWindow *win = [UIApplication sharedApplication].keyWindow
                 ?: [UIApplication sharedApplication].windows.firstObject;
    UIButton *btn = [[UIButton alloc] initWithFrame:
        CGRectMake(cx - BW * 0.5f, cy - BH * 0.5f, BW, BH)];

    // สีพื้นหลัง: เขียวเข้มตามรูป
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
    // ✅ ปุ่มโผล่เมื่อเปิดฟังก์ชันนั้นจากเมนู — ผูกตรงกับ feature flag
    self.flyButton.hidden      = !ZX_FlyAlt;
    self.telekillButton.hidden = !ZX_Telekill;
    self.aimkillButton.hidden  = !ZX_AimKill;
    self.norecoilButton.hidden = !ZX_NoRecoil;
    self.markTPButton.hidden   = !ZX_MarkTeleport;
    self.autoTPButton.hidden   = !ZX_AutoTeleport;

    // ✅ ซิงก์สถานะสวิตช์บนปุ่มให้ตรงกับ ZX_var
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

// ui — CheatiOSVip style (left sidebar + iOS toggles)

// ── Colors — pure black + white text ─────────────────────────────────────────
static const ImU32 ZX_WIN_BG        = IM_COL32(  0,   0,   0, 252);   // pure black
static const ImU32 ZX_TITLE_BG      = IM_COL32(  8,   8,   8, 255);
static const ImU32 ZX_PANEL_BG      = IM_COL32(  0,   0,   0, 255);
static const ImU32 ZX_PANEL_BORDER  = IM_COL32( 50,  50,  50, 255);
static const ImU32 ZX_SIDE_BTN_BG   = IM_COL32( 38,  38,  38, 255);   // ปุ่ม tab เทาเข้ม
static const ImU32 ZX_SIDE_BTN_ACT  = IM_COL32( 60,  60,  60, 255);   // tab ที่เลือก
static const ImU32 ZX_SIDE_BORDER   = IM_COL32( 45,  45,  45, 255);
static const ImU32 ZX_SIDE_BORDER_A = IM_COL32( 70,  70,  70, 255);
static const ImU32 ZX_TAB_TEXT      = IM_COL32(255, 255, 255, 255);   // ขาวสด
static const ImU32 ZX_TAB_TEXT_DIM  = IM_COL32(160, 160, 160, 255);   // เทาอ่อน
static const ImU32 ZX_TAB_UNDERLINE = IM_COL32(255, 255, 255, 180);
static const ImU32 ZX_TAB_DIV       = IM_COL32( 60,  60,  60, 255);
static const ImU32 ZX_SEP           = IM_COL32( 60,  60,  60, 255);   // เส้นชัดขึ้น
static const ImU32 ZX_SECTION       = IM_COL32(255, 255, 255, 255);
static const ImU32 ZX_SUB           = IM_COL32(160, 160, 160, 255);
static const ImU32 ZX_TEXT          = IM_COL32(255, 255, 255, 255);   // ขาวสด
static const ImU32 ZX_TEXT_DIM      = IM_COL32(130, 130, 130, 255);
// iOS toggle
static const ImU32 ZX_TGL_ON        = IM_COL32( 52, 199,  89, 255);   // iOS green
static const ImU32 ZX_TGL_OFF       = IM_COL32( 80,  80,  80, 255);   // เทาเข้ม
static const ImU32 ZX_TGL_KNOB      = IM_COL32(255, 255, 255, 255);
static const ImU32 ZX_HOVER         = IM_COL32(255, 255, 255,  10);
// slider / checkbox
static const ImU32 ZX_CHK_BG        = IM_COL32( 38,  38,  38, 255);
static const ImU32 ZX_CHK_BG_ON     = IM_COL32( 52, 199,  89, 255);
static const ImU32 ZX_CHK_BORDER    = IM_COL32( 70,  70,  70, 255);
static const ImU32 ZX_CHK_BORDER_ON = IM_COL32( 52, 199,  89, 255);
static const ImU32 ZX_CORNER_YELLOW = IM_COL32(255, 255, 255, 200);
static const ImU32 ZX_SLIDER_BG     = IM_COL32( 38,  38,  38, 255);
static const ImU32 ZX_SLIDER_FILL   = IM_COL32( 52, 199,  89, 240);
static const ImU32 ZX_KNOB_OUTLINE  = IM_COL32(255, 255, 255, 200);
static const ImU32 ZX_CYAN          = IM_COL32(140, 200, 230, 255);
static const ImU32 ZX_GREEN         = IM_COL32( 52, 199,  89, 255);
static const ImU32 ZX_RED           = IM_COL32(220,  40,  50, 255);
static const ImU32 ZX_PURPLE        = IM_COL32(160, 120, 200, 255);
static const ImU32 ZX_YELLOW        = IM_COL32(210, 170,  70, 255);

// ── Layout — compact ─────────────────────────────────────────────────────────
static const float ZX_WIN_W      = 300.0f;   // ลดกว้างให้ตรงรูป
static const float ZX_WIN_H      = 360.0f;
static const float ZX_TITLE_H    = 38.0f;
static const float ZX_TOP_PAD    = 0.0f;
static const float ZX_TAB_H      = 0.0f;
static const float ZX_SIDE_W     = 82.0f;    // sidebar แคบลงตามสัดส่วน
static const float ZX_BOT_H      = 46.0f;    // ลดลงจาก 54
static const float ZX_SIDE_BTN   = 40.0f;
static const float ZX_SIDE_GAP   = 6.0f;
static const float ZX_ROW_H      = 40.0f;    // ลดลงจาก 50 — compact rows
static const float ZX_SLIDER_H   = 20.0f;
static const float ZX_DROP_H     = 22.0f;
static const float ZX_LABEL_H    = 20.0f;
static const float ZX_SUB_H      = 18.0f;
static const float ZX_PAD_LEFT   = 14.0f;
static const float ZX_PAD_TOP    = 5.0f;
static const float ZX_CHK_BOX    = 16.0f;
static const float ZX_CHK_RAD    = 4.0f;
static const float ZX_KNOB_R     = 5.0f;
static const float ZX_WIN_RAD    = 10.0f;
static const float ZX_FRAME_RAD  = 5.0f;
static const float ZX_FONT_SIZE  = 13.0f;

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

// ── iOS-style toggle row: ชื่อซ้าย | toggle ขวา ─────────────────────────────
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
        RunNoReload();   // set_AmmoInClip(999) + set_OnceAmmo(999) ทุกเฟรม
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
    ImGui::PushStyleColor(ImGuiCol_Border,   ImVec4(0,0,0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding,  ZX_WIN_RAD);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding,   ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing,     ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ScrollbarSize,   4.0f);
    ImGui::SetNextWindowSize(ImVec2(ZX_WIN_W, ZX_WIN_H), ImGuiCond_Always);
    ImGui::Begin("##CheatiOS", nullptr,
        ImGuiWindowFlags_NoTitleBar  | ImGuiWindowFlags_NoResize |
        ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse |
        ImGuiWindowFlags_NoBringToFrontOnFocus);
    ImGui::SetWindowFontScale(ZX_FONT_SIZE / 18.0f);

    ImDrawList* dl = ImGui::GetWindowDrawList();
    ImVec2 wp = ImGui::GetWindowPos();
    ImVec2 ws = ImGui::GetWindowSize();

    // ── Title bar ──────────────────────────────────────────────────────────
    ImVec2 tMin(wp.x, wp.y);
    ImVec2 tMax(wp.x + ws.x, wp.y + ZX_TITLE_H);
    dl->AddRectFilled(tMin, tMax, ZX_TITLE_BG, ZX_WIN_RAD, ImDrawFlags_RoundCornersTop);
    dl->AddLine(ImVec2(tMin.x, tMax.y), ImVec2(tMax.x, tMax.y), ZX_SEP, 1.0f);

    // ชื่อ "CheatiOSVip.Com" กลาง
    {
        const char* title = "CheatiOSVip.Com";
        ImVec2 ts = ImGui::CalcTextSize(title);
        dl->AddText(ImVec2(wp.x + (ws.x - ts.x) * 0.5f,
                           tMin.y + (ZX_TITLE_H - ts.y) * 0.5f),
                    ZX_TAB_TEXT, title);
    }

    // ── Body: sidebar (left) + content (right) ──────────────────────────────
    float bodyY0 = tMax.y;
    float bodyH  = ws.y - ZX_TITLE_H - ZX_BOT_H;
    float bodyY1 = bodyY0 + bodyH;

    // เส้นแบ่ง sidebar
    dl->AddLine(ImVec2(wp.x + ZX_SIDE_W, bodyY0),
                ImVec2(wp.x + ZX_SIDE_W, bodyY1), ZX_SEP, 1.0f);

    // ── Left sidebar tabs: AIMBOT / AIMKILL / BUTTON / OTHER ───────────────
    const int   kTabs    = 4;
    const char* tabNames[kTabs] = { "AIMBOT", "AIMKILL", "BUTTON", "OTHER" };
    float tabH = bodyH / (float)kTabs;

    for (int i = 0; i < kTabs; ++i) {
        float ty0 = bodyY0 + (float)i * tabH;
        float ty1 = ty0 + tabH;
        bool  active = (ZX_Tab == i);

        // พื้นปุ่ม
        ImU32 btnCol = active ? ZX_SIDE_BTN_ACT : ZX_SIDE_BTN_BG;
        dl->AddRectFilled(ImVec2(wp.x + 5, ty0 + 5),
                          ImVec2(wp.x + ZX_SIDE_W - 5, ty1 - 5),
                          btnCol, 8.0f);

        // ชื่อ tab กลาง — ฟอนต์เล็กลง (scale 0.72 × 0.78 ≈ เล็กลง 22%)
        ImFont* font = ImGui::GetFont();
        float   smallSz = ImGui::GetFontSize() * 0.78f;
        ImVec2  ts = font->CalcTextSizeA(smallSz, FLT_MAX, 0.0f, tabNames[i]);
        ImU32   tc = active ? ZX_TAB_TEXT : ZX_TAB_TEXT_DIM;
        dl->AddText(font, smallSz,
                    ImVec2(wp.x + (ZX_SIDE_W - ts.x) * 0.5f,
                           ty0 + (tabH - ts.y) * 0.5f),
                    tc, tabNames[i]);

        // invisible button
        ImGui::SetCursorScreenPos(ImVec2(wp.x + 5, ty0 + 5));
        char uid[16]; snprintf(uid, sizeof uid, "##stab%d", i);
        if (ImGui::InvisibleButton(uid, ImVec2(ZX_SIDE_W - 10, tabH - 10)))
            ZX_Tab = i;

        // เส้นแบ่งระหว่าง tab
        if (i < kTabs - 1)
            dl->AddLine(ImVec2(wp.x, ty1), ImVec2(wp.x + ZX_SIDE_W, ty1),
                        ZX_SEP, 0.5f);
    }

    // ── Content area ────────────────────────────────────────────────────────
    float cX0 = wp.x + ZX_SIDE_W + 1.0f;
    float cX1 = wp.x + ws.x;

    ImGui::SetCursorScreenPos(ImVec2(cX0, bodyY0));
    ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0,0,0,0));
    ImGui::BeginChild("##sm_content",
                      ImVec2(cX1 - cX0, bodyH), false,
                      ImGuiWindowFlags_AlwaysVerticalScrollbar);

    switch (ZX_Tab) {
        case 0: { // AIMBOT
            ZX_SonicCheckRow("Aimbot AI",         &Vars.Aimbot);
            ZX_SonicCheckRow("Enable Aimbot",     &ZX_AimKill);
            ZX_SonicCheckRow("Aim Silent v2",     &SilentAim);
            ZX_SonicCheckRow("Visible Check",     &Vars.VisibleCheck);
            ZX_SonicCheckRow("Skip Knocked",      &Vars.IgnoreKnocked);
            ZX_SonicCheckRow("AI Player Aim",     &ZX_AIPlayerAim);
            ZX_PillSlider("Fov",                  &Vars.AimFov, 0.0f, 500.0f);
            break;
        }
        case 1: { // AIMKILL
            ZX_SonicCheckRow("Telekill",          &ZX_Telekill);
            ZX_SonicCheckRow("Mark Teleport",     &ZX_MarkTeleport);
            ZX_SonicCheckRow("Auto Teleport",     &ZX_AutoTeleport);
            ZX_SonicCheckRow("Ammo Speed Fast",   &ZX_AmmoSpeedFast);
            ZX_SonicCheckRow("Bullet Thru Wall",  &ZX_BulletThru);
            ZX_SonicCheckRow("Chain Damage",      &ZX_ChainDamage);
            ZX_PillSlider("Damage",               &ZX_ChainDmgValue, 100.0f, 9999.0f);
            break;
        }
        case 2: { // BUTTON
            ZX_SonicCheckRow("Fast Fire",         &ZX_FastFire);
            ZX_SonicCheckRow("No Reload",         &ZX_NoReload);
            ZX_SonicCheckRow("Long Range",        &ZX_LongRange);
            ZX_SonicCheckRow("Fly Alt",           &ZX_FlyAlt);
            ZX_SonicCheckRow("Free Fly",          &ZX_FreeFly);
            ZX_SonicCheckRow("Blue Map",          &ZX_BlueMap);
            ZX_SonicCheckRow("Camera Left",       &ZX_CameraLeft);
            ZX_PillSlider("Fly Spd",              &ZX_FlySpeed, 1.0f, 20.0f);
            ZX_Slider("Cam Height",               &ZX_CameraHeight, 1.0f, 25.0f);
            break;
        }
        case 3: { // OTHER
            ZX_SonicCheckRow("Enable ESP",        &Vars.Enable);
            ZX_SonicCheckRow("Esp LINE",          &Vars.lines);
            ZX_SonicCheckRow("Esp BOX",           &Vars.Box);
            ZX_SonicCheckRow("Esp2D CORNER",      &ZX_Esp2DCorner);
            ZX_SonicCheckRow("Esp3D BOX",         &ZX_Esp3DBox);
            ZX_SonicCheckRow("Enemies Counter",   &Vars.ESPCount);  // แสดง ENEMIES: X บนจอ
            ZX_SonicCheckRow("Hide ModMenu",      &ZX_HideModMenu);
            ZX_SonicCheckRow("Reset Guest",       &ZX_ResetAcc);   // กดเปิด → ทำงาน 1 ครั้ง แล้วปิดเอง
            break;
        }
    }

    ImGui::EndChild();
    ImGui::PopStyleColor();  // ChildBg

    // ── Bottom bar: Close | HIDE ─────────────────────────────────────────────
    float botY0 = bodyY1;
    float botY1 = wp.y + ws.y;
    float bW    = (ws.x - 3.0f) * 0.5f;

    dl->AddLine(ImVec2(wp.x, botY0), ImVec2(wp.x + ws.x, botY0), ZX_SEP, 1.0f);

    // Close
    dl->AddRectFilled(ImVec2(wp.x + 8, botY0 + 8),
                      ImVec2(wp.x + bW, botY1 - 8),
                      ZX_SIDE_BTN_BG, 8.0f);
    {
        const char* lbl = "Close";
        ImVec2 ts = ImGui::CalcTextSize(lbl);
        float btnH = (botY1 - 8) - (botY0 + 8);
        dl->AddText(ImVec2(wp.x + 8 + (bW - 8 - ts.x) * 0.5f,
                           botY0 + 8 + (btnH - ts.y) * 0.5f),
                    ZX_TAB_TEXT, lbl);
    }
    ImGui::SetCursorScreenPos(ImVec2(wp.x + 8, botY0 + 8));
    if (ImGui::InvisibleButton("##close", ImVec2(bW - 8, botY1 - botY0 - 16)))
        MenDeal = false;

    // เส้นกลาง
    dl->AddLine(ImVec2(wp.x + bW + 1, botY0 + 10),
                ImVec2(wp.x + bW + 1, botY1 - 10), ZX_SEP, 1.0f);

    // HIDE
    float hX0 = wp.x + bW + 3;
    float hW  = (wp.x + ws.x - 8) - hX0;
    dl->AddRectFilled(ImVec2(hX0, botY0 + 8),
                      ImVec2(wp.x + ws.x - 8, botY1 - 8),
                      ZX_SIDE_BTN_BG, 8.0f);
    {
        const char* lbl = "HIDE";
        ImVec2 ts = ImGui::CalcTextSize(lbl);
        float btnH = (botY1 - 8) - (botY0 + 8);
        dl->AddText(ImVec2(hX0 + (hW - ts.x) * 0.5f,
                           botY0 + 8 + (btnH - ts.y) * 0.5f),
                    ZX_TAB_TEXT, lbl);
    }
    ImGui::SetCursorScreenPos(ImVec2(hX0, botY0 + 8));
    if (ImGui::InvisibleButton("##hide", ImVec2(hW, botY1 - botY0 - 16)))
        MenDeal = false;

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
        if (MenDeal) { RenderMenu(); }
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
