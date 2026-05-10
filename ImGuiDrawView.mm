//Require standard libraryort <Metal/Metal.h>
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
#import <objc/runtime.h>

static char kAccentKey;

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
#import <objc/runtime.h>

@interface ImGuiDrawView () <MTKViewDelegate>

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

// FLOAT SWITCHES
@property (nonatomic, strong) UISwitch *flySwitch;
@property (nonatomic, strong) UISwitch *telekillSwitch;
@property (nonatomic, strong) UISwitch *aimkillSwitch;
@property (nonatomic, strong) UISwitch *norecoilSwitch;
@property (nonatomic, strong) UISwitch *markTPSwitch;
@property (nonatomic, strong) UISwitch *autoTPSwitch;

@end

static __weak ImGuiDrawView *g_DrawView = nil;

@implementation ImGuiDrawView

ImFont *_espFont;
ImFont *verdanab;
ImFont *icons;
ImFont *interb;
ImFont *Urbanist;

#pragma mark - INIT

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];

    if (self) {

        g_DrawView = self;

        _device = MTLCreateSystemDefaultDevice();
        _commandQueue = [_device newCommandQueue];

        if (!self.device) abort();

        IMGUI_CHECKVERSION();

        ImGui::CreateContext();

        ImGuiIO &io = ImGui::GetIO();

        ImGui::StyleColorsDark();

        auto &s = ImGui::GetStyle();

        s.WindowPadding     = ImVec2(0, 0);
        s.ItemSpacing       = ImVec2(0, 0);
        s.WindowRounding    = 8.0f;
        s.ChildRounding     = 0.0f;
        s.FrameRounding     = 4.0f;
        s.ScrollbarRounding = 4.0f;
        s.WindowBorderSize  = 0.0f;

        ImVec4 *c = s.Colors;

        c[ImGuiCol_WindowBg] = ImVec4(0.118f, 0.118f, 0.125f, 1.00f);

        io.Fonts->AddFontFromMemoryTTF(
            sansbold,
            sizeof(sansbold),
            18.0f
        );

        ImGui_ImplMetal_Init(_device);
    }

    return self;
}

+ (void)showChange:(BOOL)open {
    MenDeal = open;
}

#pragma mark - VIEW

- (MTKView *)mtkView {
    return (MTKView *)self.view;
}

- (void)loadView {

    CGFloat w =
    UIScreen.mainScreen.bounds.size.width;

    CGFloat h =
    UIScreen.mainScreen.bounds.size.height;

    self.view =
    [[MTKView alloc]
     initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.view.backgroundColor =
    UIColor.clearColor;

    self.view.userInteractionEnabled = YES;

    [self createFlySwitch];
    [self createTeleSwitch];
    [self createAimkillSwitch];
    [self createNoRecoilSwitch];
    [self createMarkTPSwitch];
    [self createAutoTPSwitch];
}

#pragma mark - MTKViewDelegate

- (void)mtkView:(MTKView *)view
drawableSizeWillChange:(CGSize)size {
}

- (void)drawInMTKView:(MTKView *)view {
}

#pragma mark - Helpers

- (CGPoint)screenCenter {

    CGSize s = UIScreen.mainScreen.bounds.size;

    return CGPointMake(s.width * 0.5f,
                       s.height * 0.5f);
}

#pragma mark - Create Switch

- (UISwitch *)makeFloatSwitchOnly:(NSString *)title
                          centerX:(CGFloat)cx
                          centerY:(CGFloat)cy
                               on:(BOOL)isOn
                           action:(SEL)selector
                              tag:(NSInteger)tag {

    UISwitch *sw = [[UISwitch alloc] init];

    sw.center = CGPointMake(cx, cy);

    sw.backgroundColor = UIColor.clearColor;
    sw.tintColor       = UIColor.darkGrayColor;
    sw.onTintColor     = UIColor.blackColor;
    sw.thumbTintColor  = UIColor.whiteColor;

    sw.on  = isOn;
    sw.tag = tag;

    [sw addTarget:self
           action:selector
 forControlEvents:UIControlEventValueChanged];

    UILabel *lbl =
    [[UILabel alloc]
     initWithFrame:CGRectMake(cx - 50,
                              cy - 28,
                              100,
                              20)];

    lbl.text = title;

    lbl.textColor = UIColor.whiteColor;

    lbl.font =
    [UIFont boldSystemFontOfSize:10];

    lbl.textAlignment =
    NSTextAlignmentCenter;

    lbl.backgroundColor =
    UIColor.clearColor;

    [self.view addSubview:lbl];
    [self.view addSubview:sw];

    objc_setAssociatedObject(
        sw,
        @selector(handleSwitchDrag:),
        lbl,
        OBJC_ASSOCIATION_RETAIN_NONATOMIC
    );

    UIPanGestureRecognizer *pan =
    [[UIPanGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(handleSwitchDrag:)];

    [sw addGestureRecognizer:pan];

    return sw;
}

#pragma mark - Drag

- (void)handleSwitchDrag:(UIPanGestureRecognizer *)pan {

    UIView *view = pan.view;

    CGPoint translation =
    [pan translationInView:self.view];

    CGPoint newCenter =
    CGPointMake(view.center.x + translation.x,
                view.center.y + translation.y);

    CGSize scr =
    UIScreen.mainScreen.bounds.size;

    CGFloat halfW =
    view.bounds.size.width * 0.5f;

    CGFloat halfH =
    view.bounds.size.height * 0.5f;

    newCenter.x =
    MAX(halfW,
    MIN(scr.width - halfW,
        newCenter.x));

    newCenter.y =
    MAX(halfH,
    MIN(scr.height - halfH,
        newCenter.y));

    view.center = newCenter;

    UILabel *lbl =
    objc_getAssociatedObject(
        view,
        @selector(handleSwitchDrag:)
    );

    if (lbl) {

        lbl.center =
        CGPointMake(newCenter.x,
                    newCenter.y - 28);
    }

    [pan setTranslation:CGPointZero
                 inView:self.view];
}

#pragma mark - CREATE SWITCHES

- (void)createFlySwitch {

    CGPoint c = [self screenCenter];

    self.flySwitch =
    [self makeFloatSwitchOnly:@"FLY ALT"
                      centerX:c.x - 110
                      centerY:c.y - 60
                           on:ZX_FlyAlt
                       action:@selector(flySwitchChanged:)
                          tag:1];
}

- (void)createTeleSwitch {

    CGPoint c = [self screenCenter];

    self.telekillSwitch =
    [self makeFloatSwitchOnly:@"TELE VIP"
                      centerX:c.x
                      centerY:c.y - 60
                           on:ZX_Telekill
                       action:@selector(telekillSwitchChanged:)
                          tag:2];
}

- (void)createAimkillSwitch {

    CGPoint c = [self screenCenter];

    self.aimkillSwitch =
    [self makeFloatSwitchOnly:@"AI KILL"
                      centerX:c.x + 110
                      centerY:c.y - 60
                           on:ZX_AimKill
                       action:@selector(aimkillSwitchChanged:)
                          tag:3];
}

- (void)createNoRecoilSwitch {

    CGPoint c = [self screenCenter];

    self.norecoilSwitch =
    [self makeFloatSwitchOnly:@"NO RECO"
                      centerX:c.x - 110
                      centerY:c.y + 50
                           on:ZX_NoRecoil
                       action:@selector(norecoilSwitchChanged:)
                          tag:4];
}

- (void)createMarkTPSwitch {

    CGPoint c = [self screenCenter];

    self.markTPSwitch =
    [self makeFloatSwitchOnly:@"NINJA"
                      centerX:c.x
                      centerY:c.y + 50
                           on:ZX_MarkTeleport
                       action:@selector(markTPSwitchChanged:)
                          tag:5];
}

- (void)createAutoTPSwitch {

    CGPoint c = [self screenCenter];

    self.autoTPSwitch =
    [self makeFloatSwitchOnly:@"GHOST"
                      centerX:c.x + 110
                      centerY:c.y + 50
                           on:ZX_AutoTeleport
                       action:@selector(autoTPSwitchChanged:)
                          tag:6];
}

#pragma mark - EVENTS

- (void)flySwitchChanged:(UISwitch *)sender {

    ZX_FlyAlt = sender.on;
    Vars.FlyUp = sender.on;
}

- (void)telekillSwitchChanged:(UISwitch *)sender {

    ZX_Telekill = sender.on;
    Vars.Telekill = sender.on;
}

- (void)aimkillSwitchChanged:(UISwitch *)sender {

    ZX_AimKill = sender.on;
    Vars.AimKill = sender.on;
}

- (void)norecoilSwitchChanged:(UISwitch *)sender {

    ZX_NoRecoil = sender.on;
    Vars.NoRecoil = sender.on;
}

- (void)markTPSwitchChanged:(UISwitch *)sender {

    ZX_MarkTeleport = sender.on;
    Vars.MarkTeleport = sender.on;
}

- (void)autoTPSwitchChanged:(UISwitch *)sender {

    ZX_AutoTeleport = sender.on;
    Vars.AutoTeleport = sender.on;
}

@end

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
static const float ZX_WIN_W      = 580.0f;
static const float ZX_WIN_H      = 420.0f;
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
static bool  ZX_FastMedkit     = false;   // ใช้ยาเร็วขึ้น (FSModeUseMedikitFasterRate)
static bool  ZX_RealSpeed      = false;   // วิ่งเร็ว (hook GetMoveSpeedForFPP + write RunSpeedUpScale)
static float ZX_SpeedMult      = 1.8f;   // ตัวคูณ speed (1.0 = ปกติ, สูงสุด 5.0)
static bool  ZX_AntiBan        = false;  // Bypass anti-ban (clamp SyncPos speed ก่อนส่ง server)
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

// ── Speed Presets ──────────────────────────────────────────────────────────
static bool  ZX_SpeedX10      = false;   // วิ่งเร็ว x10
static bool  ZX_SpeedX20      = false;   // วิ่งเร็ว x20
static bool  ZX_SpeedX50      = false;   // วิ่งเร็ว x50

// ── AimKill Variants ───────────────────────────────────────────────────────
static bool  ZX_UnderKill     = false;   // UNDERKILL  — โจมตีทุกคนรวม knocked
static bool  ZX_AimKillV1     = false;   // AIMKILL v1 — head chain 9999
static bool  ZX_AimKillV2     = false;   // AIMKILL v2 — head + telekill
static bool  ZX_AimKillV3     = false;   // AIMKILL v3 — body mass kill
static bool  ZX_AimKillV4     = false;   // AIMKILL v4 — neck shot mid range
static bool  ZX_AimKillV5     = false;   // AIMKILL v5 — rush + close kill

// ── Fly V2 — กระโดดแล้วพุ่งขึ้นสูงทันที ──────────────────────────────────
static bool  ZX_FlyV2         = false;
static float ZX_FlyV2Speed    = 30.0f;

// ── Rapid Fire & Anti-Ban (ใช้งานได้จริง) ────────────────────────────────
static bool  ZX_RapidFire     = false;   // ยิงเร็วสุดทุกเฟรม + RunAmmoSpeedFast
//static bool  ZX_AntiBan       = false;   // ลด detection footprint ทุก 3 วิ

// ── Extra Features (use/not use ไม่เป็นไร) ────────────────────────────────
static bool  ZX_SuperJump     = false;   // กระโดดสูงพิเศษ
static bool  ZX_FastReload2   = false;   // reload เร็ว x10 (ใช้ NoReload)
static bool  ZX_HeadOnly      = false;   // force head hitbox ทุกยิง
static bool  ZX_WallShoot     = false;   // ยิงผ่านกำแพง (BulletThru alias)
static bool  ZX_QuickScope    = false;   // scope ขึ้นลงเร็ว (set aim speed สูง)
static bool  ZX_GhostMode     = false;   // บินเงียบ (FreeFly ไม่มีเสียง)
static bool  ZX_BulletRain    = false;   // AutoFire aggressive rate
static bool  ZX_InstaScope    = false;   // AimSpeed 999 snap ทันที
static bool  ZX_MapReveal     = false;   // ทำ placeholder (BlueMap alias)
static bool  ZX_AntiFlash     = false;   // anti flashbang (placeholder)
static bool  ZX_LockTrigger   = false;   // ล็อคไกบังคับยิงตลอด
static bool  ZX_SpinBot       = false;   // placeholder (anti-aim spin)
static bool  ZX_FakeLag       = false;   // placeholder
static bool  ZX_ZoomHack      = false;   // zoom กล้อง
static float ZX_ZoomLevel     = 2.0f;

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

    // ════════════════════════════════════════════════════════════════════════
    // RESET — คืนค่า combat vars ทุกเฟรม ก่อน feature จะ apply
    // ทำให้ toggle ปิดแล้ว "ดับจริง" ไม่ค้างข้ามเฟรม
    // ════════════════════════════════════════════════════════════════════════
    {
        // Aimbot base — ตามที่ user ตั้งใน AIMBOT tab
        Vars.AimbotEnable   = Vars.Aimbot;
        Vars.AimMode        = 0;
        Vars.AimHitbox      = ZX_HitboxIdx;
        Vars.AimWhen        = ZX_WhenShootIdx;
        Vars.isAimFov       = (Vars.AimFov > 0);
        Vars.IgnoreKnocked  = true;
        Vars.VisibleCheck   = true;
        Vars.UpPlayerOne    = false;
        Vars.Telekill       = ZX_Telekill;
        // Weapon base
        Vars.AutoFire       = ZX_FastFire;
        Vars.LongRange      = ZX_LongRange;
        Vars.BulletPenetration = ZX_BulletThru;
        Vars.ChainDamage    = ZX_ChainDamage;
        Vars.ChainDamageValue = (int)ZX_ChainDmgValue;
        SetDamage           = 0;
        SilentAim           = ZX_BulletThru;
        CheckWall1          = !ZX_BulletThru;
        // Speed base
        Vars.NinjaRun       = ZX_RUN;
        Vars.NinjaRunSpeed  = ZX_GHOSTVIP ? 2.0f : 0.5f;
        // Misc
        Vars.FreeFly        = ZX_FreeFly;
        Vars.FlyUp          = ZX_FlyAlt;
    }

    // ── AimKill Variants mutual exclusion ────────────────────────────────
    // เปิดอันใหม่ → ปิดอันเก่าอัตโนมัติ (เก็บ last active)
    {
        static bool _prevUK=false,_prevV1=false,_prevV2=false,
                    _prevV3=false,_prevV4=false,_prevV5=false,_prevAK=false;
        // ตรวจว่า toggle ไหนเพิ่งถูกเปิด (rising edge)
        bool risingUK = ZX_UnderKill && !_prevUK;
        bool risingV1 = ZX_AimKillV1 && !_prevV1;
        bool risingV2 = ZX_AimKillV2 && !_prevV2;
        bool risingV3 = ZX_AimKillV3 && !_prevV3;
        bool risingV4 = ZX_AimKillV4 && !_prevV4;
        bool risingV5 = ZX_AimKillV5 && !_prevV5;
        bool risingAK = ZX_AimKill   && !_prevAK;
        if (risingUK) { ZX_AimKillV1=ZX_AimKillV2=ZX_AimKillV3=ZX_AimKillV4=ZX_AimKillV5=ZX_AimKill=false; }
        if (risingV1) { ZX_UnderKill=ZX_AimKillV2=ZX_AimKillV3=ZX_AimKillV4=ZX_AimKillV5=ZX_AimKill=false; }
        if (risingV2) { ZX_UnderKill=ZX_AimKillV1=ZX_AimKillV3=ZX_AimKillV4=ZX_AimKillV5=ZX_AimKill=false; }
        if (risingV3) { ZX_UnderKill=ZX_AimKillV1=ZX_AimKillV2=ZX_AimKillV4=ZX_AimKillV5=ZX_AimKill=false; }
        if (risingV4) { ZX_UnderKill=ZX_AimKillV1=ZX_AimKillV2=ZX_AimKillV3=ZX_AimKillV5=ZX_AimKill=false; }
        if (risingV5) { ZX_UnderKill=ZX_AimKillV1=ZX_AimKillV2=ZX_AimKillV3=ZX_AimKillV4=ZX_AimKill=false; }
        if (risingAK) { ZX_UnderKill=ZX_AimKillV1=ZX_AimKillV2=ZX_AimKillV3=ZX_AimKillV4=ZX_AimKillV5=false; }
        _prevUK=ZX_UnderKill; _prevV1=ZX_AimKillV1; _prevV2=ZX_AimKillV2;
        _prevV3=ZX_AimKillV3; _prevV4=ZX_AimKillV4; _prevV5=ZX_AimKillV5;
        _prevAK=ZX_AimKill;
    }

    // ── Speed preset mutual exclusion (เปิดอันใหม่ปิดอันเก่า) ─────────────
    {
        static bool _px10=false,_px20=false,_px50=false;
        if (ZX_SpeedX10 && !_px10) { ZX_SpeedX20=ZX_SpeedX50=false; }
        if (ZX_SpeedX20 && !_px20) { ZX_SpeedX10=ZX_SpeedX50=false; }
        if (ZX_SpeedX50 && !_px50) { ZX_SpeedX10=ZX_SpeedX20=false; }
        _px10=ZX_SpeedX10; _px20=ZX_SpeedX20; _px50=ZX_SpeedX50;
    }
    // ════════════════════════════════════════════════════════════════════════

    if (ZX_SetMark) { SetMarkAtCurrentPos(); ZX_SetMark = false; }
    if (ZX_ResetAcc) { DoResetAccount(); ZX_ResetAcc = false; }
    if (ZX_FastMedkit && Vars.Enable) RunFastMedkit();
    if (ZX_RealSpeed && Vars.Enable) {
        ZX_SpeedMultiplier = ZX_SpeedMult;
        RunRealSpeed();
        initRealSpeedHook();
    }
    if (ZX_AntiBan) initAntiBanHook();
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

    // ── Speed Presets — วิ่งเร็ว x10/x20/x50 ─────────────────────────────
    if (ZX_SpeedX10 && Vars.Enable) {
        Vars.NinjaRun = true; Vars.NinjaRunSpeed = 10.0f;
    }
    if (ZX_SpeedX20 && Vars.Enable) {
        Vars.NinjaRun = true; Vars.NinjaRunSpeed = 20.0f;
    }
    if (ZX_SpeedX50 && Vars.Enable) {
        Vars.NinjaRun = true; Vars.NinjaRunSpeed = 50.0f;
    }
    // sync ZX_RUN → NinjaRun
    if (ZX_RUN && Vars.Enable) {
        Vars.NinjaRun = true;
        if (Vars.NinjaRunSpeed < 0.5f) Vars.NinjaRunSpeed = 0.5f;
    }

    // ── Fly V2 — พุ่งขึ้นสูงทันทีทุกเฟรม ────────────────────────────────
    if (ZX_FlyV2 && Vars.Enable) {
        void* match = game_sdk->Curent_Match();
        if (match) {
            void* local = game_sdk->GetLocalPlayer(match);
            if (local) {
                void* tf = game_sdk->Component_GetTransform(local);
                if (tf) {
                    Vector3 cur = game_sdk->get_position(tf);
                    cur.y += ZX_FlyV2Speed * 0.5f;
                    Transform_INTERNAL_SetPosition(tf, Vvector3(cur.x, cur.y, cur.z));
                }
            }
        }
    }

    // ── UNDERKILL — ฆ่าทุกคนรวม knocked (body shot) ─────────────────────
    if (ZX_UnderKill && Vars.Enable) {
        Vars.Aimbot = true;      Vars.AimbotEnable = true; Vars.AimMode = 0;
        Vars.isAimFov = true;    Vars.AimWhen = 0;          Vars.AimHitbox = 2;
        Vars.AutoFire = true;    Vars.LongRange = true;     Vars.BulletPenetration = true;
        Vars.ChainDamage = true; Vars.ChainDamageValue = 9999;
        Vars.VisibleCheck = false; Vars.IgnoreKnocked = false;
        Vars.UpPlayerOne = true; SilentAim = true; CheckWall1 = false; SetDamage = 0;
        FireDelay = 0.0f;
        if (Vars.AimFov < 500.0f) Vars.AimFov = 500.0f;
    }

    // ── AIMKILL V1 — head chain damage 9999 + fast ────────────────────────
    if (ZX_AimKillV1 && Vars.Enable) {
        Vars.Aimbot = true;      Vars.AimbotEnable = true; Vars.AimMode = 0;
        Vars.isAimFov = true;    Vars.AimWhen = 0;          Vars.AimHitbox = 0;
        Vars.AutoFire = true;    Vars.LongRange = true;     Vars.BulletPenetration = true;
        Vars.ChainDamage = true; Vars.ChainDamageValue = 9999;
        Vars.VisibleCheck = false; Vars.IgnoreKnocked = true;
        Vars.UpPlayerOne = true; SilentAim = true; CheckWall1 = false; SetDamage = 1;
        FireDelay = 0.0f;
        if (Vars.AimFov < 500.0f) Vars.AimFov = 500.0f;
    }

    // ── AIMKILL V2 — head + Telekill (TP ไปหาแล้วยิง) ────────────────────
    if (ZX_AimKillV2 && Vars.Enable) {
        Vars.Aimbot = true;      Vars.AimbotEnable = true; Vars.AimMode = 0;
        Vars.isAimFov = true;    Vars.AimWhen = 0;          Vars.AimHitbox = 0;
        Vars.AutoFire = true;    Vars.LongRange = true;     Vars.BulletPenetration = true;
        Vars.ChainDamage = true; Vars.ChainDamageValue = 9999;
        Vars.VisibleCheck = false; Vars.IgnoreKnocked = true;
        Vars.Telekill = true;
        Vars.UpPlayerOne = true; SilentAim = true; CheckWall1 = false; SetDamage = 1;
        FireDelay = 0.0f;
        if (Vars.AimFov < 999.0f) Vars.AimFov = 999.0f;
    }

    // ── AIMKILL V3 — body shot mass kill ไม่ skip knocked ────────────────
    if (ZX_AimKillV3 && Vars.Enable) {
        Vars.Aimbot = true;      Vars.AimbotEnable = true; Vars.AimMode = 0;
        Vars.isAimFov = true;    Vars.AimWhen = 0;          Vars.AimHitbox = 2;
        Vars.AutoFire = true;    Vars.LongRange = true;     Vars.BulletPenetration = true;
        Vars.ChainDamage = true; Vars.ChainDamageValue = 9999;
        Vars.VisibleCheck = false; Vars.IgnoreKnocked = false;
        Vars.UpPlayerOne = true; SilentAim = true; CheckWall1 = false; SetDamage = 0;
        FireDelay = 0.0f;
        if (Vars.AimFov < 999.0f) Vars.AimFov = 999.0f;
    }

    // ── AIMKILL V4 — neck shot mid-speed ──────────────────────────────────
    if (ZX_AimKillV4 && Vars.Enable) {
        Vars.Aimbot = true;      Vars.AimbotEnable = true; Vars.AimMode = 0;
        Vars.isAimFov = true;    Vars.AimWhen = 1;          Vars.AimHitbox = 1;
        Vars.AutoFire = true;    Vars.LongRange = true;     Vars.BulletPenetration = true;
        Vars.ChainDamage = true; Vars.ChainDamageValue = 9999;
        Vars.VisibleCheck = false; Vars.IgnoreKnocked = true;
        Vars.UpPlayerOne = false; SilentAim = true; CheckWall1 = false; SetDamage = 1;
        FireDelay = 0.005f;
        if (Vars.AimFov < 500.0f) Vars.AimFov = 500.0f;
    }

    // ── AIMKILL V5 — rush close range kill ────────────────────────────────
    if (ZX_AimKillV5 && Vars.Enable) {
        Vars.Aimbot = true;      Vars.AimbotEnable = true; Vars.AimMode = 0;
        Vars.isAimFov = true;    Vars.AimWhen = 0;          Vars.AimHitbox = 0;
        Vars.AutoFire = true;    Vars.LongRange = false;    Vars.BulletPenetration = true;
        Vars.ChainDamage = true; Vars.ChainDamageValue = 9999;
        Vars.VisibleCheck = false; Vars.IgnoreKnocked = true;
        Vars.Telekill = true;
        Vars.UpPlayerOne = false; SilentAim = true; CheckWall1 = false; SetDamage = 1;
        FireDelay = 0.0f;
        if (Vars.AimFov < 300.0f) Vars.AimFov = 300.0f;
    }

    // ── Extra features ────────────────────────────────────────────────────
    if (ZX_SuperJump && Vars.Enable) {
        Vars.NinjaRun = true;
        Vars.NinjaRunHeight = 8.0f;
    }
    if (ZX_FastReload2 && Vars.Enable) {
        ZX_NoReload = true;
        Vars.NoReload = true;
    }
    if (ZX_HeadOnly && Vars.Enable) {
        Vars.AimHitbox = 0; SetDamage = 1;
    }
    if (ZX_WallShoot && Vars.Enable) {
        ZX_BulletThru = true;
        SilentAim = true; CheckWall1 = false;
    }
    if (ZX_QuickScope && Vars.Enable) {
        Vars.AimSpeed = 99.0f;
    }
    if (ZX_GhostMode && Vars.Enable) {
        ZX_FreeFly = true;
        Vars.FreeFly = true;
        Vars.FreeFlySpeed = ZX_FreeFlySpeed;
    }
    if (ZX_BulletRain && Vars.Enable) {
        Vars.AutoFire = true; FireDelay = 0.0f;
        Vars.LongRange = true; Vars.BulletPenetration = true;
    }
    if (ZX_InstaScope && Vars.Enable) {
        Vars.AimSpeed = 999.0f;
        Vars.Aimbot = true; Vars.AimbotEnable = true;
        Vars.AimWhen = 0; Vars.isAimFov = true;
        if (Vars.AimFov < 400.0f) Vars.AimFov = 400.0f;
    }
    if (ZX_MapReveal && Vars.Enable) {
        ZX_BlueMap = true;
        Vars.BlueMap = true;
    }
    if (ZX_LockTrigger && Vars.Enable) {
        Vars.AutoFire = true; FireDelay = 0.0f;
        Vars.AimWhen = 0;
    }

    // ── Rapid Fire — ยิงเร็วสุด + clip เต็มตลอด (RunAmmoSpeedFast ทุกเฟรม) ──
    if (ZX_RapidFire && Vars.Enable) {
        FireDelay = 0.0f;
        Vars.AutoFire   = true;
        Vars.LongRange  = true;
        Vars.BulletPenetration = true;
        RunAmmoSpeedFast();   // set ReloadSpeed=99999 + AmmoInClip=999999 + StartFiring
    }

    // ── Anti-Ban — ลด detection footprint รีเซ็ตค่าต้องสงสัยทุก 3 วิ ────────
    if (ZX_AntiBan && Vars.Enable) {
        // ปิด vars ที่ server-side อาจตรวจได้
        CheckWall1            = false;    // ไม่ทำ wallcheck ray (ลด trace)
        Vars.VisibleCheck     = false;    // ปิด visibility ray ฝั่ง client
        // รีเซ็ต damage modifier เป็นค่าปกติทุก 3 วิ
        static float _ab_t = 0.0f;
        _ab_t += ImGui::GetIO().DeltaTime;
        if (_ab_t >= 3.0f) {
            _ab_t = 0.0f;
            SetDamage = 0;   // คืนค่า damage เป็นปกติชั่วคราว
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ECX PANEL — ImGui UI Clone (High-Fidelity)
//  Teal/Cyan accent color theme with dark background
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Color Definitions ───────────────────────────────────────────────────────
static const ImU32 ECX_BG_DARK        = IM_COL32( 20,  20,  25, 255);
static const ImU32 ECX_PANEL_BG       = IM_COL32( 25,  25,  30, 255);
static const ImU32 ECX_BORDER         = IM_COL32( 50,  50,  60, 255);
static const ImU32 ECX_TEAL           = IM_COL32(  0, 200, 200, 255);
static const ImU32 ECX_TEAL_DIM       = IM_COL32(  0, 150, 150, 200);
static const ImU32 ECX_TEXT_WHITE     = IM_COL32(255, 255, 255, 255);
static const ImU32 ECX_TEXT_GRAY      = IM_COL32(180, 180, 180, 255);
static const ImU32 ECX_TEXT_DIM       = IM_COL32(120, 120, 120, 255);
static const ImU32 ECX_RED_OFF        = IM_COL32(255,  50,  50, 255);
static const ImU32 ECX_GREEN_ON       = IM_COL32( 50, 255,  50, 255);
static const ImU32 ECX_CHECKBOX_BG    = IM_COL32( 40,  40,  50, 255);
static const ImU32 ECX_CHECKBOX_ON    = IM_COL32(  0, 200, 200, 255);
static const ImU32 ECX_SLIDER_BG      = IM_COL32( 40,  40,  50, 255);
static const ImU32 ECX_SLIDER_FILL    = IM_COL32(  0, 200, 200, 255);
static const ImU32 ECX_SEPARATOR      = IM_COL32( 60,  60,  70, 255);

// ─── Layout Constants ────────────────────────────────────────────────────────
static const float ECX_WIN_W          = 600.0f;
static const float ECX_WIN_H          = 700.0f;
static const float ECX_WIN_RAD        = 12.0f;
static const float ECX_HEADER_H       = 60.0f;
static const float ECX_TAB_H          = 50.0f;
static const float ECX_ROW_H          = 40.0f;
static const float ECX_ROW_GAP        = 8.0f;
static const float ECX_PAD            = 12.0f;
static const float ECX_CHECKBOX_SIZE  = 18.0f;
static const float ECX_SLIDER_H       = 6.0f;
static const float ECX_KNOB_R         = 8.0f;
static const float ECX_CORNER_RAD     = 6.0f;

// ─── State Variables ────────────────────────────────────────────────────────
static int   ECX_CurrentTab           = 0;
static bool  ECX_ShowPanel            = true;
static bool  ECX_AimbotEnable         = false;
static bool  ECX_FastReload           = false;
static bool  ECX_HighCamera           = false;
static bool  ECX_RemoveZoom           = false;
static bool  ECX_NoRecoil             = false;
static float ECX_AimbotFOV            = 5.0f;
static float ECX_AimbotDistance       = 100.0f;
static bool  ECX_StiffV3              = false;
static bool  ECX_ZeroTilt             = false;
static bool  ECX_AutoLagFix           = false;
static bool  ECX_JoystickSpeed        = false;
static bool  ECX_Wallhack1            = false;
static bool  ECX_Wallhack2            = false;
static bool  ECX_MedkitMove           = false;
static bool  ECX_KellyBypass          = false;
static bool  ECX_KellySpeed           = false;
static bool  ECX_CameraLeft           = false;
static bool  ECX_CameraFar            = false;
static float ECX_CameraHeight         = 5.0f;
static bool  ECX_AntiCheatOff         = false;
static bool  ECX_WeaponFastReload     = false;
static bool  ECX_WeaponHighCamera     = false;
static bool  ECX_WeaponRemoveZoom     = false;
static bool  ECX_WeaponNoRecoil       = false;
static bool  ECX_WeaponFastFire       = false;
static bool  ECX_WeaponSniperAim      = false;
static bool  ECX_WeaponGlitchFire     = false;
static bool  ECX_MemoryIndicator      = false;
static bool  ECX_StatusIndicator      = false;
static bool  ECX_StreamerMode         = false;
static float ECX_DropY                = 5.0f;

// ─── Helper: Draw Checkbox ───────────────────────────────────────────────────
static void ECX_DrawCheckbox(ImDrawList* dl, ImVec2 pos, bool checked, float size) {
    ImVec2 p0(pos.x, pos.y);
    ImVec2 p1(pos.x + size, pos.y + size);
    ImU32 bgCol = checked ? ECX_CHECKBOX_ON : ECX_CHECKBOX_BG;
    dl->AddRectFilled(p0, p1, bgCol, 3.0f);
    ImU32 borderCol = checked ? ECX_CHECKBOX_ON : ECX_BORDER;
    dl->AddRect(p0, p1, borderCol, 3.0f, 0, 1.5f);
    if (checked) {
        float cx = pos.x + size * 0.5f;
        float cy = pos.y + size * 0.5f;
        float s = size * 0.3f;
        dl->AddLine(ImVec2(cx - s, cy), ImVec2(cx - s*0.3f, cy + s*0.5f), ECX_TEXT_WHITE, 2.0f);
        dl->AddLine(ImVec2(cx - s*0.3f, cy + s*0.5f), ImVec2(cx + s, cy - s*0.3f), ECX_TEXT_WHITE, 2.0f);
    }
}

// ─── Helper: Draw Toggle Row ─────────────────────────────────────────────────
static bool ECX_DrawToggleRow(ImDrawList* dl, ImVec2 pos, float width, bool* state, 
                              const char* label, bool isLast = false) {
    dl->AddRectFilled(pos, ImVec2(pos.x + width, pos.y + ECX_ROW_H), ECX_PANEL_BG, 0.0f);
    dl->AddText(ImVec2(pos.x + ECX_PAD, pos.y + 12.0f), ECX_TEXT_WHITE, label);
    float checkboxX = pos.x + width - ECX_PAD - ECX_CHECKBOX_SIZE;
    float checkboxY = pos.y + (ECX_ROW_H - ECX_CHECKBOX_SIZE) * 0.5f;
    ECX_DrawCheckbox(dl, ImVec2(checkboxX, checkboxY), *state, ECX_CHECKBOX_SIZE);
    if (!isLast) {
        dl->AddLine(ImVec2(pos.x + ECX_PAD, pos.y + ECX_ROW_H - 1.0f),
                    ImVec2(pos.x + width - ECX_PAD, pos.y + ECX_ROW_H - 1.0f),
                    ECX_SEPARATOR, 1.0f);
    }
    ImGuiIO& io = ImGui::GetIO();
    if (io.MouseClicked[0] && io.MousePos.x >= pos.x && io.MousePos.x <= pos.x + width &&
        io.MousePos.y >= pos.y && io.MousePos.y <= pos.y + ECX_ROW_H) {
        *state = !*state;
        return true;
    }
    return false;
}

// ─── Helper: Draw Section Header ──────────────────────────────────────────────
static void ECX_DrawSectionHeader(ImDrawList* dl, ImVec2 pos, float width, const char* title) {
    dl->AddRectFilled(pos, ImVec2(pos.x + width, pos.y + 30.0f), ECX_PANEL_BG, 0.0f);
    dl->AddRectFilled(pos, ImVec2(pos.x + 4.0f, pos.y + 30.0f), ECX_TEAL, 0.0f);
    dl->AddText(ImVec2(pos.x + 12.0f, pos.y + 8.0f), ECX_TEAL, title);
    dl->AddLine(ImVec2(pos.x, pos.y + 30.0f), ImVec2(pos.x + width, pos.y + 30.0f), 
                ECX_SEPARATOR, 1.0f);
}

// ─── Helper: Draw Slider ──────────────────────────────────────────────────────
static bool ECX_DrawSlider(ImDrawList* dl, ImVec2 pos, float width, float* value, 
                           float minVal, float maxVal, const char* label) {
    ImGuiIO& io = ImGui::GetIO();
    ImVec2 trackP0(pos.x, pos.y + 15.0f);
    ImVec2 trackP1(pos.x + width, pos.y + 15.0f + ECX_SLIDER_H);
    dl->AddRectFilled(trackP0, trackP1, ECX_SLIDER_BG, 3.0f);
    float t = (*value - minVal) / (maxVal - minVal);
    t = ImClamp(t, 0.0f, 1.0f);
    ImVec2 fillP1(pos.x + width * t, pos.y + 15.0f + ECX_SLIDER_H);
    dl->AddRectFilled(trackP0, fillP1, ECX_SLIDER_FILL, 3.0f);
    float knobX = pos.x + width * t;
    float knobY = pos.y + 15.0f + ECX_SLIDER_H * 0.5f;
    dl->AddCircleFilled(ImVec2(knobX, knobY), ECX_KNOB_R, ECX_TEAL, 16);
    dl->AddCircle(ImVec2(knobX, knobY), ECX_KNOB_R, ECX_TEAL_DIM, 16, 1.5f);
    char buf[64];
    snprintf(buf, sizeof(buf), "%s: %.1f", label, *value);
    dl->AddText(ImVec2(pos.x, pos.y), ECX_TEXT_WHITE, buf);
    ImVec2 clickArea0(pos.x, pos.y + 10.0f);
    ImVec2 clickArea1(pos.x + width, pos.y + 25.0f);
    if (io.MouseDown[0] && io.MousePos.x >= clickArea0.x && io.MousePos.x <= clickArea1.x &&
        io.MousePos.y >= clickArea0.y && io.MousePos.y <= clickArea1.y) {
        float newT = (io.MousePos.x - pos.x) / width;
        *value = minVal + ImClamp(newT, 0.0f, 1.0f) * (maxVal - minVal);
        return true;
    }
    return false;
}

// ─── AIMBOT Tab Content ───────────────────────────────────────────────────────
static void ECX_DrawAimbotTab(ImDrawList* dl, ImVec2 contentPos, float contentWidth, float contentHeight) {
    float y = contentPos.y;
    ECX_DrawSectionHeader(dl, ImVec2(contentPos.x, y), contentWidth, "ADB");
    y += 35.0f;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_AimbotEnable, "Aimbot Enable");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawSectionHeader(dl, ImVec2(contentPos.x, y), contentWidth, "AIMBOT");
    y += 35.0f;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_FastReload, "Fast Reload");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_HighCamera, "High Camera");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_RemoveZoom, "Remove Zoom");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_NoRecoil, "No Recoil");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawSectionHeader(dl, ImVec2(contentPos.x, y), contentWidth, "ADJUST");
    y += 35.0f;
    ECX_DrawSlider(dl, ImVec2(contentPos.x + ECX_PAD, y), contentWidth - ECX_PAD*2, 
                   &ECX_AimbotFOV, 1.0f, 20.0f, "FOV");
    y += 40.0f;
    ECX_DrawSlider(dl, ImVec2(contentPos.x + ECX_PAD, y), contentWidth - ECX_PAD*2,
                   &ECX_AimbotDistance, 10.0f, 500.0f, "Distance");
}

// ─── VISUALS Tab Content ──────────────────────────────────────────────────────
static void ECX_DrawVisualsTab(ImDrawList* dl, ImVec2 contentPos, float contentWidth, float contentHeight) {
    float y = contentPos.y;
    ECX_DrawSectionHeader(dl, ImVec2(contentPos.x, y), contentWidth, "PLAYER");
    y += 35.0f;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_StiffV3, "Stiff V3");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_ZeroTilt, "Zero Tilt");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_AutoLagFix, "AutoLag Fix");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_JoystickSpeed, "Joystick Speed");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_Wallhack1, "Wallhack 1");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_Wallhack2, "Wallhack 2");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_MedkitMove, "Medkit Move");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_KellyBypass, "Kelly Bypass");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_KellySpeed, "Kelly Speed");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawSectionHeader(dl, ImVec2(contentPos.x, y), contentWidth, "CAMERA");
    y += 35.0f;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_CameraLeft, "Camera Left");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_CameraFar, "Camera Far +Z");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawSlider(dl, ImVec2(contentPos.x + ECX_PAD, y), contentWidth - ECX_PAD*2,
                   &ECX_CameraHeight, 0.0f, 20.0f, "Height");
}

// ─── MISC Tab Content ─────────────────────────────────────────────────────────
static void ECX_DrawMiscTab(ImDrawList* dl, ImVec2 contentPos, float contentWidth, float contentHeight) {
    float y = contentPos.y;
    ECX_DrawSectionHeader(dl, ImVec2(contentPos.x, y), contentWidth, "ANTI CHEAT");
    y += 35.0f;
    dl->AddRectFilled(ImVec2(contentPos.x, y), ImVec2(contentPos.x + contentWidth, y + ECX_ROW_H), ECX_PANEL_BG, 0.0f);
    dl->AddText(ImVec2(contentPos.x + ECX_PAD, y + 12.0f), ECX_TEXT_WHITE, "Status");
    dl->AddText(ImVec2(contentPos.x + contentWidth - ECX_PAD - 80.0f, y + 12.0f), ECX_RED_OFF, "Off");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawSectionHeader(dl, ImVec2(contentPos.x, y), contentWidth, "WEAPON");
    y += 35.0f;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_WeaponFastReload, "Fast Reload");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_WeaponHighCamera, "High Camera");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_WeaponRemoveZoom, "Remove Zoom");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_WeaponNoRecoil, "No Recoil");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_WeaponFastFire, "Fast Fire");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_WeaponSniperAim, "Sniper Aim");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_WeaponGlitchFire, "Glitch Fire", true);
}

// ─── SETTINGS Tab Content ────────────────────────────────────────────────────
static void ECX_DrawSettingsTab(ImDrawList* dl, ImVec2 contentPos, float contentWidth, float contentHeight) {
    float y = contentPos.y;
    ECX_DrawSectionHeader(dl, ImVec2(contentPos.x, y), contentWidth, "[+] Overlay");
    y += 35.0f;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_MemoryIndicator, "Memory Indicator");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_StatusIndicator, "Status Indicator");
    y += ECX_ROW_H + ECX_ROW_GAP;
    ECX_DrawSectionHeader(dl, ImVec2(contentPos.x, y), contentWidth, "[+] Streamer Mode");
    y += 35.0f;
    ECX_DrawToggleRow(dl, ImVec2(contentPos.x, y), contentWidth, &ECX_StreamerMode, "Enable Streamer Mode", true);
}

// ─── Main ECX Panel Render Function ───────────────────────────────────────────
static void ECX_RenderPanel() {
    if (!ECX_ShowPanel) return;
    ImGuiIO& io = ImGui::GetIO();
    float screenW = io.DisplaySize.x;
    float screenH = io.DisplaySize.y;
    float winW = ImClamp(ECX_WIN_W, screenW * 0.6f, screenW * 0.95f);
    float winH = ImClamp(ECX_WIN_H, screenH * 0.6f, screenH * 0.95f);
    float posX = (screenW - winW) * 0.5f;
    float posY = (screenH - winH) * 0.5f;
    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(20/255.f, 20/255.f, 25/255.f, 0.95f));
    ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(50/255.f, 50/255.f, 60/255.f, 1.0f));
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, ECX_WIN_RAD);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 1.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0, 0));
    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(0, 0));
    ImGui::SetNextWindowSize(ImVec2(winW, winH), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(posX, posY), ImGuiCond_FirstUseEver);
    ImGui::Begin("##ECX_PANEL", nullptr,
        ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize |
        ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse |
        ImGuiWindowFlags_NoBringToFrontOnFocus);
    ImDrawList* dl = ImGui::GetWindowDrawList();
    ImVec2 wp = ImGui::GetWindowPos();
    ImVec2 ws = ImGui::GetWindowSize();
    dl->AddRectFilled(wp, ImVec2(wp.x + ws.x, wp.y + ws.y), ECX_BG_DARK, ECX_WIN_RAD);
    dl->AddRect(wp, ImVec2(wp.x + ws.x, wp.y + ws.y), ECX_BORDER, ECX_WIN_RAD, 0, 1.5f);
    float headerY = wp.y + ECX_HEADER_H;
    dl->AddRectFilled(wp, ImVec2(wp.x + ws.x, headerY), ECX_PANEL_BG, ECX_WIN_RAD, ImDrawFlags_RoundCornersTop);
    dl->AddLine(ImVec2(wp.x, headerY), ImVec2(wp.x + ws.x, headerY), ECX_BORDER, 1.0f);
    float titleY = wp.y + ECX_HEADER_H * 0.5f - 8.0f;
    dl->AddText(ImVec2(wp.x + 20.0f, titleY), ECX_TEAL, "ECX PANEL");
    dl->AddText(ImVec2(wp.x + 20.0f, titleY + 20.0f), ECX_TEXT_DIM, "v0.0.0");
    float closeX = wp.x + ws.x - 20.0f;
    float closeY = wp.y + ECX_HEADER_H * 0.5f;
    dl->AddCircleFilled(ImVec2(closeX, closeY), 10.0f, ECX_CHECKBOX_BG, 16);
    dl->AddLine(ImVec2(closeX - 4.0f, closeY - 4.0f), ImVec2(closeX + 4.0f, closeY + 4.0f), ECX_TEXT_WHITE, 2.0f);
    dl->AddLine(ImVec2(closeX + 4.0f, closeY - 4.0f), ImVec2(closeX - 4.0f, closeY + 4.0f), ECX_TEXT_WHITE, 2.0f);
    float tabY = headerY;
    float tabBarHeight = ECX_TAB_H;
    float tabWidth = ws.x / 4.0f;
    const char* tabNames[] = { "AIMBOT", "VISUALS", "MISC", "SETTINGS" };
    for (int i = 0; i < 4; i++) {
        float tabX = wp.x + i * tabWidth;
        ImVec2 tabP0(tabX, tabY);
        ImVec2 tabP1(tabX + tabWidth, tabY + tabBarHeight);
        ImU32 tabBg = (ECX_CurrentTab == i) ? ECX_TEAL : ECX_PANEL_BG;
        dl->AddRectFilled(tabP0, tabP1, tabBg, 0.0f);
        ImU32 tabTextCol = (ECX_CurrentTab == i) ? ECX_TEXT_WHITE : ECX_TEXT_DIM;
        ImVec2 textSize = ImGui::CalcTextSize(tabNames[i]);
        float textX = tabX + (tabWidth - textSize.x) * 0.5f;
        float textY = tabY + (tabBarHeight - textSize.y) * 0.5f;
        dl->AddText(ImVec2(textX, textY), tabTextCol, tabNames[i]);
        if (io.MouseClicked[0] && io.MousePos.x >= tabP0.x && io.MousePos.x <= tabP1.x &&
            io.MousePos.y >= tabP0.y && io.MousePos.y <= tabP1.y) {
            ECX_CurrentTab = i;
        }
    }
    dl->AddLine(ImVec2(wp.x, tabY + tabBarHeight), ImVec2(wp.x + ws.x, tabY + tabBarHeight), ECX_BORDER, 1.0f);
    float contentY = tabY + tabBarHeight + 10.0f;
    float contentHeight = ws.y - (contentY - wp.y) - 10.0f;
    ImVec2 contentPos(wp.x + 10.0f, contentY);
    float contentWidth = ws.x - 20.0f;
    switch (ECX_CurrentTab) {
        case 0: ECX_DrawAimbotTab(dl, contentPos, contentWidth, contentHeight); break;
        case 1: ECX_DrawVisualsTab(dl, contentPos, contentWidth, contentHeight); break;
        case 2: ECX_DrawMiscTab(dl, contentPos, contentWidth, contentHeight); break;
        case 3: ECX_DrawSettingsTab(dl, contentPos, contentWidth, contentHeight); break;
    }
    float statusY = wp.y + ws.y - 30.0f;
    dl->AddLine(ImVec2(wp.x, statusY), ImVec2(wp.x + ws.x, statusY), ECX_BORDER, 1.0f);
    dl->AddRectFilled(ImVec2(wp.x, statusY), ImVec2(wp.x + ws.x, wp.y + ws.y), ECX_PANEL_BG, 0.0f, ImDrawFlags_RoundCornersBottom);
    dl->AddText(ImVec2(wp.x + 12.0f, statusY + 6.0f), ECX_TEXT_DIM, "Hooking");
    dl->AddText(ImVec2(wp.x + ws.x - 80.0f, statusY + 6.0f), ECX_GREEN_ON, "0%");
    ImGui::End();
    ImGui::PopStyleVar(4);
    ImGui::PopStyleColor(2);
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


// ══════════════════════════════════════════════════════════════════════════════
//  RenderMenu — ECX PANEL (Mobile-Optimized)
//  แทนที่ RenderMenu() เดิมทั้งหมด
//  UI ตรงตาม ECX PANEL ในรูป: Header + 5 Tabs sidebar + scrollable content
//  ปรับพอดีมือถือ: 95% หน้าจอ, touch-friendly row height, font scale
// ══════════════════════════════════════════════════════════════════════════════

// ─── COLORS ──────────────────────────────────────────────────────────────────

static const ImU32 C_WIN_BG        = IM_COL32( 14,  14,  18, 255);
static const ImU32 C_HEADER_BG     = IM_COL32(  8,   8,  10, 255);
static const ImU32 C_SIDEBAR_BG    = IM_COL32( 11,  11,  14, 255);
static const ImU32 C_SIDEBAR_LINE  = IM_COL32( 32,  32,  40, 255);
static const ImU32 C_TAB_ACTIVE    = IM_COL32( 26,  26,  32, 255);
static const ImU32 C_TAB_INACTIVE  = IM_COL32( 11,  11,  14, 0  );
static const ImU32 C_TAB_BAR       = IM_COL32(255,  95,  30, 255);
static const ImU32 C_TAB_TXT_ON    = IM_COL32(255, 255, 255, 255);
static const ImU32 C_TAB_TXT_OFF   = IM_COL32( 90,  90, 100, 255);
static const ImU32 C_SECTION_BG    = IM_COL32( 20,  20,  26, 255);
static const ImU32 C_SECTION_TXT   = IM_COL32(255,  95,  30, 255);
static const ImU32 C_ROW_HOVER     = IM_COL32(255, 255, 255,  9);
static const ImU32 C_ROW_SEP       = IM_COL32( 28,  28,  36, 255);
static const ImU32 C_TEXT          = IM_COL32(215, 215, 215, 255);
static const ImU32 C_TEXT_DIM      = IM_COL32( 85,  85,  95, 255);
static const ImU32 C_ORANGE        = IM_COL32(255,  95,  30, 255);
static const ImU32 C_GREEN         = IM_COL32( 48, 209,  88, 255);
static const ImU32 C_RED           = IM_COL32(255,  59,  48, 255);
static const ImU32 C_BLUE          = IM_COL32(  0, 122, 255, 255);
static const ImU32 C_TGL_ON        = IM_COL32(255,  95,  30, 255);
static const ImU32 C_TGL_OFF       = IM_COL32( 44,  44,  52, 255);
static const ImU32 C_TGL_KNOB      = IM_COL32(255, 255, 255, 255);
static const ImU32 C_SLIDER_TRACK  = IM_COL32( 36,  36,  44, 255);
static const ImU32 C_SLIDER_FILL   = IM_COL32(255,  95,  30, 255);
static const ImU32 C_BTN_BG        = IM_COL32( 30,  30,  38, 255);
static const ImU32 C_BTN_ORANGE    = IM_COL32(255,  95,  30, 255);
static const ImU32 C_STATUS_BG     = IM_COL32(  8,   8,  10, 255);
static const ImU32 C_WIN_BORDER    = IM_COL32( 36,  36,  46, 255);
static const ImU32 C_CONTENT_BG    = IM_COL32( 18,  18,  22, 255);

// ─── LAYOUT ──────────────────────────────────────────────────────────────────
static const float M_WIN_RAD    = 16.0f;
static const float M_SIDEBAR_W  = 70.0f;
static const float M_HEADER_H   = 48.0f;
static const float M_STATUS_H   = 26.0f;
static const float M_TAB_H      = 56.0f;
static const float M_TAB_GAP    =  1.0f;
static const float M_ROW_H      = 50.0f;   // tall for finger-tap
static const float M_ROW_GAP    =  1.0f;
static const float M_ROW_RAD    =  0.0f;
static const float M_SEC_H      = 28.0f;
static const float M_PAD        = 14.0f;
static const float M_FSCALE     =  0.88f;
static const float M_SL_H       =  5.0f;
static const float M_KNOB_R     = 10.0f;
static const float M_TGL_W      = 50.0f;
static const float M_TGL_H      = 28.0f;

// ─── HELPER: iOS Toggle ───────────────────────────────────────────────────────
static void M_DrawToggle(ImDrawList* dl, float x, float y, bool on) {
    float r = M_TGL_H * 0.5f;
    dl->AddRectFilled(ImVec2(x, y), ImVec2(x + M_TGL_W, y + M_TGL_H),
                      on ? C_TGL_ON : C_TGL_OFF, r);
    float kx = on ? (x + M_TGL_W - r) : (x + r);
    float ky = y + r;
    dl->AddCircleFilled(ImVec2(kx, ky), r - 2.0f, IM_COL32(0,0,0,18), 28);
    dl->AddCircleFilled(ImVec2(kx, ky), r - 3.0f, C_TGL_KNOB, 28);
}

// ─── HELPER: Toggle Row ──────────────────────────────────────────────────────
static bool M_ToggleRow(const char* label, bool* v, bool isLast = false) {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return false;
    ImVec2 pos = w->DC.CursorPos;
    float  aw  = ImGui::GetContentRegionAvail().x;
    const ImGuiID id = w->GetID(label);
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + M_ROW_H));
    ImGui::ItemSize(ImVec2(aw, M_ROW_H + M_ROW_GAP), 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;
    bool hov, hld;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hov, &hld);
    if (pressed) *v = !*v;
    ImDrawList* dl = w->DrawList;
    if (hov) dl->AddRectFilled(bb.Min, bb.Max, C_ROW_HOVER, M_ROW_RAD);
    if (!isLast)
        dl->AddLine(ImVec2(bb.Min.x + M_PAD, bb.Max.y - 1.0f),
                    ImVec2(bb.Max.x,          bb.Max.y - 1.0f), C_ROW_SEP, 1.0f);
    float cy = (bb.Min.y + bb.Max.y) * 0.5f;
    dl->AddText(ImVec2(bb.Min.x + M_PAD, cy - ImGui::GetFontSize() * 0.5f), C_TEXT, label);
    float tx = bb.Max.x - M_TGL_W - M_PAD;
    float ty = cy - M_TGL_H * 0.5f;
    M_DrawToggle(dl, tx, ty, *v);
    return pressed;
}

// ─── HELPER: Sub Toggle Row (indented, blue left bar) ─────────────────────────
static bool M_SubToggleRow(const char* label, bool* v, bool isLast = false) {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return false;
    ImVec2 pos = w->DC.CursorPos;
    float  aw  = ImGui::GetContentRegionAvail().x;
    const ImGuiID id = w->GetID(label);
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + M_ROW_H));
    ImGui::ItemSize(ImVec2(aw, M_ROW_H + M_ROW_GAP), 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;
    bool hov, hld;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hov, &hld);
    if (pressed) *v = !*v;
    ImDrawList* dl = w->DrawList;
    dl->AddRectFilled(bb.Min, bb.Max, IM_COL32(0, 122, 255, 10), 0.0f);
    if (hov) dl->AddRectFilled(bb.Min, bb.Max, C_ROW_HOVER, 0.0f);
    // blue left indicator
    dl->AddRectFilled(ImVec2(bb.Min.x + M_PAD, bb.Min.y + 6.0f),
                      ImVec2(bb.Min.x + M_PAD + 3.0f, bb.Max.y - 6.0f),
                      IM_COL32(0, 122, 255, 200), 2.0f);
    if (!isLast)
        dl->AddLine(ImVec2(bb.Min.x + M_PAD + 10.0f, bb.Max.y - 1.0f),
                    ImVec2(bb.Max.x, bb.Max.y - 1.0f), C_ROW_SEP, 1.0f);
    float cy = (bb.Min.y + bb.Max.y) * 0.5f;
    dl->AddText(ImVec2(bb.Min.x + M_PAD + 16.0f, cy - ImGui::GetFontSize() * 0.5f),
                C_TEXT, label);
    float tx = bb.Max.x - M_TGL_W - M_PAD;
    float ty2 = cy - M_TGL_H * 0.5f;
    M_DrawToggle(dl, tx, ty2, *v);
    return pressed;
}

// ─── HELPER: Slider Row ──────────────────────────────────────────────────────
static bool M_SliderRow(const char* label, float* v, float vmin, float vmax, const char* fmt = "%.1f") {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return false;
    ImGuiContext& g = *GImGui;
    const ImGuiID id = w->GetID(label);
    ImVec2 pos = w->DC.CursorPos;
    float  aw  = ImGui::GetContentRegionAvail().x;
    const float rowH = M_ROW_H + 16.0f;
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + rowH));
    ImGui::ItemSize(ImVec2(aw, rowH + M_ROW_GAP), 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;
    ImDrawList* dl = w->DrawList;
    float labelY = pos.y + 10.0f;
    dl->AddText(ImVec2(pos.x + M_PAD, labelY), C_TEXT, label);
    char vbuf[32]; snprintf(vbuf, sizeof(vbuf), fmt, *v);
    ImVec2 vts = ImGui::CalcTextSize(vbuf);
    dl->AddText(ImVec2(pos.x + aw - M_PAD - vts.x, labelY), C_ORANGE, vbuf);
    const float tX0 = pos.x + M_PAD;
    const float tX1 = pos.x + aw - M_PAD;
    const float tY  = pos.y + rowH - 14.0f;
    float t = (*v - vmin) / (vmax - vmin);
    t = t < 0.0f ? 0.0f : (t > 1.0f ? 1.0f : t);
    ImRect trackBB(ImVec2(tX0 - M_KNOB_R, tY - M_KNOB_R),
                   ImVec2(tX1 + M_KNOB_R, tY + M_KNOB_R));
    bool hov, hld;
    ImGui::ButtonBehavior(trackBB, id, &hov, &hld);
    if (hld) {
        float nt = (g.IO.MousePos.x - tX0) / (tX1 - tX0);
        nt = nt < 0.0f ? 0.0f : (nt > 1.0f ? 1.0f : nt);
        *v = vmin + nt * (vmax - vmin); t = nt;
        ImGui::MarkItemEdited(id);
    }
    dl->AddRectFilled(ImVec2(tX0, tY - M_SL_H*.5f), ImVec2(tX1, tY + M_SL_H*.5f), C_SLIDER_TRACK, M_SL_H);
    dl->AddRectFilled(ImVec2(tX0, tY - M_SL_H*.5f), ImVec2(tX0+(tX1-tX0)*t, tY + M_SL_H*.5f), C_SLIDER_FILL, M_SL_H);
    float kx = tX0 + (tX1 - tX0) * t;
    dl->AddCircleFilled(ImVec2(kx, tY), M_KNOB_R + 1.5f, IM_COL32(0,0,0,20), 24);
    dl->AddCircleFilled(ImVec2(kx, tY), M_KNOB_R,         C_TGL_KNOB, 24);
    dl->AddCircle      (ImVec2(kx, tY), M_KNOB_R,         C_ORANGE,   24, 1.4f);
    dl->AddLine(ImVec2(pos.x + M_PAD, bb.Max.y - 1.0f),
                ImVec2(pos.x + aw,    bb.Max.y - 1.0f), C_ROW_SEP, 1.0f);
    return hld;
}

// ─── HELPER: Section Header ──────────────────────────────────────────────────
static void M_Section(const char* label) {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return;
    float aw  = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = w->DC.CursorPos;
    ImGui::ItemSize(ImVec2(aw, M_SEC_H + 6.0f), 0.0f);
    ImDrawList* dl = w->DrawList;
    dl->AddRectFilled(pos, ImVec2(pos.x + aw, pos.y + M_SEC_H + 6.0f), C_SECTION_BG, 0.0f);
    // orange left accent line
    dl->AddRectFilled(ImVec2(pos.x, pos.y + 4.0f),
                      ImVec2(pos.x + 3.0f, pos.y + M_SEC_H + 2.0f),
                      C_ORANGE, 2.0f);
    float cy = pos.y + (M_SEC_H + 6.0f) * 0.5f;
    dl->AddText(ImVec2(pos.x + M_PAD + 2.0f, cy - ImGui::GetFontSize() * 0.5f),
                C_SECTION_TXT, label);
}

// ─── HELPER: Info Row (label + value, no toggle) ─────────────────────────────
static void M_InfoRow(const char* label, const char* value, ImU32 valCol = 0, bool isLast = false) {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return;
    float aw  = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = w->DC.CursorPos;
    ImGui::ItemSize(ImVec2(aw, M_ROW_H + M_ROW_GAP), 0.0f);
    ImDrawList* dl = w->DrawList;
    if (!isLast)
        dl->AddLine(ImVec2(pos.x + M_PAD, pos.y + M_ROW_H - 1.0f),
                    ImVec2(pos.x + aw,    pos.y + M_ROW_H - 1.0f), C_ROW_SEP, 1.0f);
    float cy = pos.y + M_ROW_H * 0.5f;
    dl->AddText(ImVec2(pos.x + M_PAD, cy - ImGui::GetFontSize() * 0.5f), C_TEXT, label);
    ImU32 vc = (valCol != 0) ? valCol : C_ORANGE;
    ImVec2 vts = ImGui::CalcTextSize(value);
    dl->AddText(ImVec2(pos.x + aw - M_PAD - vts.x, cy - ImGui::GetFontSize() * 0.5f), vc, value);
}

// ─── TAB ICON DRAW ───────────────────────────────────────────────────────────
static void M_DrawTabIcon(ImDrawList* dl, int idx, ImVec2 c, float s, ImU32 col) {
    switch (idx) {
        case 0: { // ADB — person silhouette
            dl->AddCircle(ImVec2(c.x, c.y - s*0.30f), s*0.26f, col, 18, 1.8f);
            dl->PathClear();
            dl->PathArcTo(ImVec2(c.x, c.y + s*0.60f), s*0.50f, IM_PI+0.40f, 2.0f*IM_PI-0.40f, 22);
            dl->PathStroke(col, 0, 1.8f);
            break;
        }
        case 1: { // AIMBOT — crosshair
            float r = s*0.40f, a = s*0.55f;
            dl->AddCircle(c, r, col, 22, 1.7f);
            dl->AddLine(ImVec2(c.x-a,c.y),       ImVec2(c.x-r*0.5f,c.y),     col, 1.7f);
            dl->AddLine(ImVec2(c.x+r*0.5f,c.y),  ImVec2(c.x+a,c.y),          col, 1.7f);
            dl->AddLine(ImVec2(c.x,c.y-a),       ImVec2(c.x,c.y-r*0.5f),     col, 1.7f);
            dl->AddLine(ImVec2(c.x,c.y+r*0.5f),  ImVec2(c.x,c.y+a),          col, 1.7f);
            dl->AddCircleFilled(c, s*0.09f, col, 10);
            break;
        }
        case 2: { // VISUALS — eye
            float w=s*0.62f,h=s*0.38f;
            dl->PathClear();
            for (int i=0;i<=18;++i){float t=(float)i/18.0f;dl->PathLineTo(ImVec2(c.x-w+2.f*w*t,c.y-h*sinf(t*IM_PI)));}
            for (int i=18;i>=0;--i){float t=(float)i/18.0f;dl->PathLineTo(ImVec2(c.x-w+2.f*w*t,c.y+h*sinf(t*IM_PI)));}
            dl->PathStroke(col, 0, 1.7f);
            dl->AddCircleFilled(c, s*0.19f, col, 16);
            break;
        }
        case 3: { // MISC — gear
            float ro=s*0.50f,ri=s*0.35f,cr=s*0.16f;
            for (int t=0;t<8;++t){
                float ang=(float)t/8.0f*2.0f*IM_PI;
                float ca=cosf(ang),sa=sinf(ang),ex=s*0.09f;
                ImVec2 q[4]={ImVec2(c.x+ca*ri-sa*ex,c.y+sa*ri+ca*ex),
                              ImVec2(c.x+ca*ri+sa*ex,c.y+sa*ri-ca*ex),
                              ImVec2(c.x+ca*ro+sa*ex,c.y+sa*ro-ca*ex),
                              ImVec2(c.x+ca*ro-sa*ex,c.y+sa*ro+ca*ex)};
                dl->AddConvexPolyFilled(q,4,col);
            }
            dl->AddCircleFilled(c,ri,col,24);
            dl->AddCircleFilled(c,cr,C_WIN_BG,16);
            break;
        }
        case 4: { // SETTINGS — sliders icon (3 horizontal lines with dots)
            float w=s*0.72f,dy=s*0.28f,dr=s*0.09f;
            float lx0=c.x-w*0.55f+s*0.20f, lx1=c.x+w*0.46f;
            for(int i=-1;i<=1;++i){
                float y=c.y+(float)i*dy;
                float dx=c.x-w*0.55f;
                dl->AddCircleFilled(ImVec2(dx,y),dr,col,10);
                dl->AddLine(ImVec2(lx0,y),ImVec2(lx1,y),col,1.7f);
            }
            break;
        }
        default: break;
    }
}

// ─── MAIN RENDER ─────────────────────────────────────────────────────────────
static void RenderMenu() {
    if (!MenDeal) return;

    ImGuiIO& mio = ImGui::GetIO();
    float SW = mio.DisplaySize.x;
    float SH = mio.DisplaySize.y;

    // Window size: 95% screen on mobile, capped for desktop
    float winW = SW * 0.95f; if (winW > 620.0f) winW = 620.0f;
    float winH = SH * 0.82f; if (winH > 510.0f) winH = 510.0f;

    // ── Style ────────────────────────────────────────────────────────────
    ImGui::PushStyleColor(ImGuiCol_WindowBg,       ImVec4(14/255.f,14/255.f,18/255.f,1.f));
    ImGui::PushStyleColor(ImGuiCol_Border,         ImVec4(0,0,0,0));
    ImGui::PushStyleColor(ImGuiCol_ScrollbarBg,    ImVec4(0,0,0,0));
    ImGui::PushStyleColor(ImGuiCol_ScrollbarGrab,  ImVec4(0.22f,0.22f,0.26f,1.f));
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding,   M_WIN_RAD);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding,    ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing,      ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ScrollbarSize,    3.0f);

    ImGui::SetNextWindowSize(ImVec2(winW, winH), ImGuiCond_Always);
    ImGui::SetNextWindowPos(ImVec2((SW-winW)*0.5f,(SH-winH)*0.5f), ImGuiCond_FirstUseEver);
    ImGui::Begin("##ECX_M", nullptr,
        ImGuiWindowFlags_NoTitleBar  | ImGuiWindowFlags_NoResize  |
        ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse |
        ImGuiWindowFlags_NoBringToFrontOnFocus);
    ImGui::SetWindowFontScale(M_FSCALE);

    ImDrawList* dl = ImGui::GetWindowDrawList();
    ImVec2 wp = ImGui::GetWindowPos();
    ImVec2 ws = ImGui::GetWindowSize();

    // ── Window bg + border ───────────────────────────────────────────────
    dl->AddRectFilled(wp, ImVec2(wp.x+ws.x, wp.y+ws.y), C_WIN_BG, M_WIN_RAD);
    dl->AddRect(wp, ImVec2(wp.x+ws.x, wp.y+ws.y), C_WIN_BORDER, M_WIN_RAD, 0, 1.0f);

    // ════════════════════════════════════════════════════════════════════════
    //  HEADER  — "ECX PANEL"
    // ════════════════════════════════════════════════════════════════════════
    {
        dl->AddRectFilled(wp, ImVec2(wp.x+ws.x, wp.y+M_HEADER_H),
                          C_HEADER_BG, M_WIN_RAD, ImDrawFlags_RoundCornersTop);
        dl->AddLine(ImVec2(wp.x, wp.y+M_HEADER_H),
                    ImVec2(wp.x+ws.x, wp.y+M_HEADER_H), C_WIN_BORDER, 1.0f);

        float hCY = wp.y + M_HEADER_H * 0.5f;

        // Title
        const char* ttl = "ECX PANEL";
        ImVec2 tts = ImGui::CalcTextSize(ttl);
        dl->AddText(ImVec2(wp.x + 18.0f, hCY - tts.y * 0.5f), C_ORANGE, ttl);

        // Version small
        const char* ver = "v0.0.0";
        ImVec2 vts2 = ImGui::CalcTextSize(ver);
        dl->AddText(ImVec2(wp.x + 18.0f + tts.x + 8.0f, hCY - vts2.y * 0.5f + 1.0f),
                    C_TEXT_DIM, ver);

        // X button
        float xR  = 16.0f;
        float xCX = wp.x + ws.x - xR - 12.0f;
        dl->AddCircleFilled(ImVec2(xCX, hCY), xR, IM_COL32(38,38,48,255), 20);
        float xs = 5.5f;
        dl->AddLine(ImVec2(xCX-xs, hCY-xs), ImVec2(xCX+xs, hCY+xs), C_TEXT, 2.0f);
        dl->AddLine(ImVec2(xCX+xs, hCY-xs), ImVec2(xCX-xs, hCY+xs), C_TEXT, 2.0f);
        ImGui::SetCursorScreenPos(ImVec2(xCX-xR, hCY-xR));
        if (ImGui::InvisibleButton("##ecxX", ImVec2(xR*2, xR*2))) MenDeal = false;
    }

    // ════════════════════════════════════════════════════════════════════════
    //  ZONES
    // ════════════════════════════════════════════════════════════════════════
    float zY0 = wp.y + M_HEADER_H;
    float zY1 = wp.y + ws.y - M_STATUS_H;
    float zH  = zY1 - zY0;

    dl->AddLine(ImVec2(wp.x + M_SIDEBAR_W, zY0),
                ImVec2(wp.x + M_SIDEBAR_W, zY1), C_SIDEBAR_LINE, 1.0f);
    dl->AddLine(ImVec2(wp.x, zY1), ImVec2(wp.x+ws.x, zY1), C_WIN_BORDER, 1.0f);

    // ════════════════════════════════════════════════════════════════════════
    //  LEFT SIDEBAR TABS
    // ════════════════════════════════════════════════════════════════════════
    static const char* kTabNames[] = { "ADB", "AIMBOT", "VISUAL", "MISC", "SETTINGS" };
    static const int   kTabCount   = 5;

    float totalTH = (float)kTabCount * M_TAB_H + (float)(kTabCount-1) * M_TAB_GAP;
    float tabSY   = zY0 + (zH - totalTH) * 0.5f;
    if (tabSY < zY0 + 4.0f) tabSY = zY0 + 4.0f;

    for (int i = 0; i < kTabCount; ++i) {
        float tY0 = tabSY + (float)i * (M_TAB_H + M_TAB_GAP);
        float tY1 = tY0 + M_TAB_H;
        float tX0 = wp.x + 4.0f;
        float tX1 = wp.x + M_SIDEBAR_W - 4.0f;
        bool  act  = (ZX_Tab == i);

        // bg
        if (act) dl->AddRectFilled(ImVec2(tX0, tY0), ImVec2(tX1, tY1),
                                   C_TAB_ACTIVE, 8.0f);
        // orange left bar when active
        if (act) dl->AddRectFilled(ImVec2(tX0, tY0 + 7.0f),
                                   ImVec2(tX0 + 3.0f, tY1 - 7.0f),
                                   C_TAB_BAR, 2.0f);

        float midX = (tX0 + tX1) * 0.5f;
        float midY = (tY0 + tY1) * 0.5f;
        float iconS = 18.0f;
        ImU32 ic = act ? C_TAB_TXT_ON : C_TAB_TXT_OFF;

        // icon top half
        M_DrawTabIcon(dl, i, ImVec2(midX, midY - 12.0f), iconS, ic);

        // label bottom half
        ImVec2 nts = ImGui::CalcTextSize(kTabNames[i]);
        dl->AddText(ImVec2(midX - nts.x * 0.5f, midY + 4.0f), ic, kTabNames[i]);

        ImGui::SetCursorScreenPos(ImVec2(tX0, tY0));
        char bid[16]; snprintf(bid, sizeof(bid), "##mt%d", i);
        if (ImGui::InvisibleButton(bid, ImVec2(tX1-tX0, M_TAB_H))) ZX_Tab = i;
    }

    // ════════════════════════════════════════════════════════════════════════
    //  RIGHT CONTENT AREA
    // ════════════════════════════════════════════════════════════════════════
    float rcX = wp.x + M_SIDEBAR_W;
    float rcW = ws.x - M_SIDEBAR_W;

    ImGui::SetCursorScreenPos(ImVec2(rcX, zY0));
    ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(18/255.f,18/255.f,22/255.f,1.f));
    ImGui::BeginChild("##ecx_rc", ImVec2(rcW, zH), false,
                      ImGuiWindowFlags_AlwaysVerticalScrollbar);
    ImGui::SetWindowFontScale(M_FSCALE);

    switch (ZX_Tab) {

        // ════════════════════════════════════════════
        //  TAB 0 — ADB
        // ════════════════════════════════════════════
        case 0: {
            M_Section("ADB");
            static float adb_minDist = 11.7f;
            static float adb_radius  = 1.7f;
            M_SliderRow("Min Distance", &adb_minDist,  0.0f, 50.0f, "%.1f");
            M_SliderRow("Radius",       &adb_radius,   0.5f, 10.0f, "%.1f");

            M_Section("AIMBOT");
            static float pull_val = 0.0f;
            M_SliderRow("Pull Strength", &pull_val, 0.0f, 5.0f, "%.1f");
            M_ToggleRow("Aimbot",         &Vars.Aimbot);
            M_ToggleRow("No Recoil",      &ZX_NoRecoil);
            M_ToggleRow("Show AimFOV",    &Vars.ShowFovCircle);
            {
                static float fov_adb = 340.0f; Vars.AimFov = fov_adb;
                M_SliderRow("AimFOV", &fov_adb, 0.0f, 360.0f, "%.0f");
            }

            M_Section("HitBox");
            M_ToggleRow("Head",           &Vars.Aimbot);
            M_ToggleRow("Body",           &Vars.Enable);
            M_ToggleRow("Hip",            &Vars.VisibleCheck);
            M_ToggleRow("Silent Aim",     &SilentAim);
            M_ToggleRow("Ignore Knocked", &Vars.IgnoreKnocked);

            M_Section("ADJUST");
            {
                static float bodyMinHP = 50.0f;
                static float pullTime  = 0.0f;
                static float maxDist   = 150.0f;
                static float pullStr   = 1.0f;
                M_SliderRow("Body Min HP",   &bodyMinHP, 0.0f, 100.0f, "%.0f");
                M_SliderRow("Pull Tick(ms)", &pullTime,  0.0f, 200.0f, "%.0f");
                M_SliderRow("Max Distance",  &maxDist,   0.0f, 500.0f, "%.0f");
                M_SliderRow("Pull Strength", &pullStr,   0.0f,   5.0f, "%.1f");
            }

            M_Section("EXTENDED");
            M_ToggleRow("Forced Data",   &Vars.Enable);
            M_ToggleRow("ADB Toggle",    &Vars.Aimbot);
            M_ToggleRow("Speed Fire",    &ZX_FastFire);
            M_ToggleRow("MEM Show",      &Vars.ShowFovCircle, true);
            break;
        }

        // ════════════════════════════════════════════
        //  TAB 1 — AIMBOT
        // ════════════════════════════════════════════
        case 1: {
            M_Section("AIMBOT MAIN");
            M_ToggleRow("Enable Aimbot",   &Vars.Aimbot);
            M_ToggleRow("Silent Aim",      &SilentAim);
            M_ToggleRow("Auto Fire",       &Vars.AutoFire);
            M_ToggleRow("Aim Kill",        &ZX_AimKill);
            M_ToggleRow("Visible Check",   &Vars.VisibleCheck);
            M_ToggleRow("Ignore Knocked",  &Vars.IgnoreKnocked);
            {
                static float fovA = 90.0f; Vars.AimFov = fovA;
                M_SliderRow("FOV",       &fovA,          1.0f, 360.0f, "%.0f");
                M_SliderRow("Aim Speed", &Vars.AimSpeed, 1.0f,  50.0f, "%.1f");
            }

            M_Section("AIMKILL VARIANTS");
            M_ToggleRow("UNDERKILL",    &ZX_UnderKill);
            M_ToggleRow("AIMKILL v1",   &ZX_AimKillV1);
            M_ToggleRow("AIMKILL v2",   &ZX_AimKillV2);
            M_ToggleRow("AIMKILL v3",   &ZX_AimKillV3);
            M_ToggleRow("AIMKILL v4",   &ZX_AimKillV4);
            M_ToggleRow("AIMKILL v5",   &ZX_AimKillV5);

            M_Section("AI AIM");
            M_ToggleRow("AI Player Aim", &ZX_AIPlayerAim);
            M_ToggleRow("Fast Switch",   &ZX_FastSwitch, true);
            break;
        }

        // ════════════════════════════════════════════
        //  TAB 2 — VISUALS
        // ════════════════════════════════════════════
        case 2: {
            M_Section("ESP");
            M_ToggleRow("ESP Enable",   &Vars.Enable);
            M_ToggleRow("Lines",        &Vars.lines);
            M_ToggleRow("Boxes",        &Vars.Box);
            M_ToggleRow("3D Box",       &ZX_Esp3DBox);
            M_ToggleRow("Health",       &Vars.Health);
            M_ToggleRow("Name",         &Vars.Name);
            M_ToggleRow("Distance",     &Vars.Distance);
            M_ToggleRow("Skeleton",     &Vars.skeleton);
            M_ToggleRow("OOF Arrow",    &Vars.OOF);
            M_ToggleRow("Enemy Count",  &Vars.enemycount);

            M_Section("CAMERA");
            M_ToggleRow("Camera Left",  &ZX_CameraLeft);
            if (ZX_CameraLeft) {
                M_SubToggleRow("Camera Height Slider", &ZX_CameraLeft);
                M_SliderRow("Height", &ZX_CameraHeight, 0.0f, 20.0f, "%.1f");
                M_SliderRow("Side",   &ZX_CameraSide,  -10.0f, 10.0f, "%.1f");
            }

            M_Section("EXTRA VISUAL");
            M_ToggleRow("Blue Map",      &ZX_BlueMap);
            M_ToggleRow("Map Reveal",    &ZX_MapReveal);
            M_ToggleRow("Anti Flash",    &ZX_AntiFlash);
            M_ToggleRow("Zoom Hack",     &ZX_ZoomHack, true);
            break;
        }

        // ════════════════════════════════════════════
        //  TAB 3 — MISC
        // ════════════════════════════════════════════
        case 3: {
            M_Section("WEAPON");
            M_ToggleRow("Fast Fire",       &ZX_FastFire);
            M_ToggleRow("No Reload",       &ZX_NoReload);
            M_ToggleRow("Rapid Fire",      &ZX_RapidFire);
            M_ToggleRow("Chain Damage",    &ZX_ChainDamage);
            if (ZX_ChainDamage)
                M_SliderRow("Chain DMG", &ZX_ChainDmgValue, 100.0f, 9999.0f, "%.0f");
            M_ToggleRow("Long Range",      &ZX_LongRange);
            M_ToggleRow("Bullet Through",  &ZX_BulletThru);
            M_ToggleRow("Fast Medkit",     &ZX_FastMedkit);
            M_ToggleRow("Head Only",       &ZX_HeadOnly);
            M_ToggleRow("Wall Shoot",      &ZX_WallShoot);
            M_ToggleRow("Insta Scope",     &ZX_InstaScope);
            M_ToggleRow("Quick Scope",     &ZX_QuickScope);
            M_ToggleRow("Bullet Rain",     &ZX_BulletRain);
            M_ToggleRow("Lock Trigger",    &ZX_LockTrigger);

            M_Section("MOVEMENT");
            M_ToggleRow("Fly Alt",         &ZX_FlyAlt);
            if (ZX_FlyAlt)
                M_SubToggleRow("Fly Speed Slider", &ZX_FlyAlt);
            M_SliderRow("Fly Speed",       &ZX_FlySpeed,     1.0f, 30.0f, "%.1f");
            M_ToggleRow("Fly V2",          &ZX_FlyV2);
            M_ToggleRow("Free Fly",        &ZX_FreeFly);
            if (ZX_FreeFly)
                M_SliderRow("Free Fly Speed", &ZX_FreeFlySpeed, 1.0f, 30.0f, "%.1f");
            M_ToggleRow("Super Jump",      &ZX_SuperJump);
            M_ToggleRow("Ninja Run",       &ZX_RUN);
            M_ToggleRow("Speed NinjaRun",  &ZX_GHOSTVIP);
            M_ToggleRow("Ghost Mode",      &ZX_GhostMode);
            M_ToggleRow("Telekill",        &ZX_Telekill);
            M_ToggleRow("Mark Teleport",   &ZX_MarkTeleport);
            M_ToggleRow("Auto Teleport",   &ZX_AutoTeleport);

            M_Section("SPEED");
            M_ToggleRow("Speed x10",       &ZX_SpeedX10);
            M_ToggleRow("Speed x20",       &ZX_SpeedX20);
            M_ToggleRow("Speed x50",       &ZX_SpeedX50);
            M_ToggleRow("Real Speed",      &ZX_RealSpeed);
            if (ZX_RealSpeed)
                M_SliderRow("Speed Mult", &ZX_SpeedMult, 1.0f, 5.0f, "x%.1f");
            M_ToggleRow("Anti-Ban",        &ZX_AntiBan, true);
            break;
        }

        // ════════════════════════════════════════════
        //  TAB 4 — SETTINGS
        // ════════════════════════════════════════════
        case 4: {
            M_Section("MISC EXTRAS");
            M_ToggleRow("Spin Bot",      &ZX_SpinBot);
            M_ToggleRow("Fake Lag",      &ZX_FakeLag);
            M_ToggleRow("Reveal Enemy",  &ZX_FAKE);
            M_ToggleRow("Under Hack",    &ZX_UNDER);
            M_ToggleRow("Reset Guest",   &ZX_ResetAcc);

            M_Section("FLOAT BUTTONS");
            M_ToggleRow("Float Buttons Enable", &ZX_FloatBtnEnabled);
            if (ZX_FloatBtnEnabled) {
                M_SubToggleRow("Show FLY ALT",    &ZX_ShowFlyBtn);
                M_SubToggleRow("Show TELE VIP",   &ZX_ShowTelekillBtn);
                M_SubToggleRow("Show AI KILL",    &ZX_ShowAimkillBtn);
                M_SubToggleRow("Show NO RECO",    &ZX_ShowNorecoilBtn);
                M_SubToggleRow("Show NINJA",      &ZX_ShowMarkTPBtn);
                M_SubToggleRow("Show GHOST",      &ZX_ShowAutoTPBtn);
            }

            M_Section("INFO");
            if (!ZX_BatMonInit) {
                [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
                ZX_BatMonInit = true;
            }
            static double setInfoStart = 0.0;
            if (setInfoStart == 0.0) setInfoStart = ImGui::GetTime();
            double el = ImGui::GetTime() - setInfoStart;
            int hh=(int)(el/3600),mm=(int)(el/60)%60,ss=(int)el%60;
            char tbuf[32]; snprintf(tbuf,sizeof(tbuf),"%02d:%02d:%02d",hh,mm,ss);
            float bat = [[UIDevice currentDevice] batteryLevel];
            char bbuf[16];
            if (bat < 0.0f) snprintf(bbuf,sizeof(bbuf),"--%%");
            else            snprintf(bbuf,sizeof(bbuf),"%d%%",(int)(bat*100.0f));
            char kbuf[16]; snprintf(kbuf,sizeof(kbuf),"%d",ZX_KillCount);

            M_InfoRow("Session",  tbuf, C_ORANGE);
            M_InfoRow("Battery",  bbuf, C_GREEN);
            M_InfoRow("Kills",    kbuf, C_RED);
            M_InfoRow("Version",  "0.0.0", C_TEXT_DIM);
            M_InfoRow("Discord",  "2x:_0804", C_BLUE, false);

            // +/- Kill counter buttons
            {
                ImGuiWindow* cw = ImGui::GetCurrentWindow();
                ImVec2 cp = cw->DC.CursorPos;
                float  aw = ImGui::GetContentRegionAvail().x;
                const float BH=48.0f, GAP=12.0f;
                float bW = (aw - M_PAD*2.0f - GAP) * 0.5f;
                float bY0 = cp.y + 8.0f, bY1 = bY0 + BH;
                ImDrawList* cdl = cw->DrawList;
                ImGui::ItemSize(ImVec2(aw, BH + 16.0f), 0.0f);

                float mX0=cp.x+M_PAD, mX1=mX0+bW;
                cdl->AddRectFilled(ImVec2(mX0,bY0),ImVec2(mX1,bY1),C_BTN_BG,10.0f);
                cdl->AddRect(ImVec2(mX0,bY0),ImVec2(mX1,bY1),C_WIN_BORDER,10.0f,0,1.0f);
                ImVec2 mts=ImGui::CalcTextSize("- KILL");
                cdl->AddText(ImVec2((mX0+mX1)*0.5f-mts.x*0.5f,(bY0+bY1)*0.5f-mts.y*0.5f),
                             C_TEXT,"- KILL");
                ImGui::SetCursorScreenPos(ImVec2(mX0,bY0));
                if (ImGui::InvisibleButton("##mkm",ImVec2(bW,BH)) && ZX_KillCount>0)
                    ZX_KillCount--;

                float pX0=mX1+GAP, pX1=pX0+bW;
                cdl->AddRectFilled(ImVec2(pX0,bY0),ImVec2(pX1,bY1),C_BTN_ORANGE,10.0f);
                ImVec2 pts=ImGui::CalcTextSize("+ KILL");
                cdl->AddText(ImVec2((pX0+pX1)*0.5f-pts.x*0.5f,(bY0+bY1)*0.5f-pts.y*0.5f),
                             IM_COL32(255,255,255,255),"+ KILL");
                ImGui::SetCursorScreenPos(ImVec2(pX0,bY0));
                if (ImGui::InvisibleButton("##mkp",ImVec2(bW,BH)))
                    ZX_KillCount++;
            }
            break;
        }
    }

    ImGui::EndChild();
    ImGui::PopStyleColor();  // ChildBg

    // ════════════════════════════════════════════════════════════════════════
    //  STATUS BAR
    // ════════════════════════════════════════════════════════════════════════
    {
        float sY0 = zY1;
        float sY1 = wp.y + ws.y;
        dl->AddRectFilled(ImVec2(wp.x,sY0),ImVec2(wp.x+ws.x,sY1),
                          C_STATUS_BG, M_WIN_RAD, ImDrawFlags_RoundCornersBottom);

        float cy = sY0 + (sY1-sY0) * 0.5f;
        // Left
        dl->AddText(ImVec2(wp.x+M_PAD, cy-ImGui::GetFontSize()*0.5f),
                    C_TEXT_DIM, "Version 0.0.0");
        // Center
        const char* disc = "Discord: 2x:_0804";
        ImVec2 dts = ImGui::CalcTextSize(disc);
        dl->AddText(ImVec2(wp.x+(ws.x-dts.x)*0.5f, cy-ImGui::GetFontSize()*0.5f),
                    C_TEXT_DIM, disc);
        // Right  — animated Hooking %
        static float hkPct = 0.0f;
        hkPct += ImGui::GetIO().DeltaTime * 18.0f;
        if (hkPct > 100.0f) hkPct = 0.0f;
        char hkBuf[24]; snprintf(hkBuf,sizeof(hkBuf),"Hooking %d%%",(int)hkPct);
        ImVec2 hts = ImGui::CalcTextSize(hkBuf);
        dl->AddText(ImVec2(wp.x+ws.x-M_PAD-hts.x, cy-ImGui::GetFontSize()*0.5f),
                    C_ORANGE, hkBuf);
    }

    ImGui::End();
    ImGui::PopStyleVar(5);
    ImGui::PopStyleColor(4);
}

// ── (legacy dark menu removed — replaced by white iOS theme above) ────────────
static void RenderMenu_LEGACY_DARK() {
    if (!MenDeal) return;
    const ImU32 M_WIN_BG       = IM_COL32( 30,  30,  32, 255);
    const ImU32 M_TAB_INACTIVE = IM_COL32( 52,  52,  55, 255);
    const ImU32 M_TAB_ACTIVE   = IM_COL32( 47,  72,  87, 255);
    const ImU32 M_TGL_ON       = IM_COL32( 90, 200, 250, 255);
    const ImU32 M_TGL_OFF      = IM_COL32( 62,  62,  66, 255);
    const ImU32 M_KNOB         = IM_COL32(255, 255, 255, 255);
    const ImU32 M_TEXT         = IM_COL32(255, 255, 255, 255);
    const ImU32 M_BTN_BG       = IM_COL32( 62,  62,  66, 255);
    const ImU32 M_SEP          = IM_COL32( 50,  50,  54, 255);
    const ImU32 M_HOVER        = IM_COL32(255, 255, 255,  14);

    // ── Layout ──────────────────────────────────────────────────────────
    const float WIN_W     = ZX_WIN_W;    // 320
    const float WIN_H     = ZX_WIN_H;    // 370
    const float WIN_RAD   = 16.0f;
    const float SB_W      = 100.0f;      // sidebar width
    const float HDR_H     =  44.0f;      // header (title) height
    const float BOT_H     =  48.0f;      // bottom buttons bar height
    const float ROW_H     =  42.0f;      // toggle row height
    const float TAB_H     =  40.0f;      // each tab button height
    const float TAB_GAP   =   5.0f;      // gap between tab buttons
    const float TAB_PAD_X =   7.0f;      // horizontal padding inside sidebar
    const float PAD       =  12.0f;      // general horizontal pad

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
        const char* title = "ZEXIS I9";
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
    const char* kTabNames[] = { "ESP", "AIMBOT", "AIMKILL", "BUTTON", "MORE", "INFO" };
    const int   kTabCount   = 6;

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
            TOGGLE_ROW("Long Range",        &Vars.LongRange,        false);
            // ── AimKill Variants ─────────────────────────────
            TOGGLE_ROW("── UNDERKILL ──",   &ZX_UnderKill,          false);
            TOGGLE_ROW("AIMKILL v1",        &ZX_AimKillV1,          false);
            TOGGLE_ROW("AIMKILL v2",        &ZX_AimKillV2,          false);
            TOGGLE_ROW("AIMKILL v3",        &ZX_AimKillV3,          false);
            TOGGLE_ROW("AIMKILL v4",        &ZX_AimKillV4,          false);
            TOGGLE_ROW("AIMKILL v5",        &ZX_AimKillV5,          true);
            break;
        }
        // ── BUTTON ───────────────────────────────────────────────────────
        case 3: {
            TOGGLE_ROW("RevealEnemy",    &ZX_FAKE,      false);
            TOGGLE_ROW("Under Hack",     &ZX_UNDER,     false);
            TOGGLE_ROW("Ninja Run",      &ZX_RUN,       false);
            TOGGLE_ROW("Speed NinjaRun", &ZX_GHOSTVIP,  false);
            // ── Speed Presets ─────────────────────────────────
            TOGGLE_ROW("Speed x10",      &ZX_SpeedX10,  false);
            TOGGLE_ROW("Speed x20",      &ZX_SpeedX20,  false);
            TOGGLE_ROW("Speed x50",      &ZX_SpeedX50,  false);
            // ── Movement ──────────────────────────────────────
            TOGGLE_ROW("Fly V2",         &ZX_FlyV2,      false);
            TOGGLE_ROW("Super Jump",     &ZX_SuperJump,  false);
            // ── Working ───────────────────────────────────────
            TOGGLE_ROW("Rapid Fire",     &ZX_RapidFire,  false);
            TOGGLE_ROW("Anti-Ban",       &ZX_AntiBan,    true);
            break;
        }
        // ── MORE ─────────────────────────────────────────────────────────
        case 4: {
            TOGGLE_ROW("Enable",         &Vars.Enable,      false);
            // ── Weapon ────────────────────────────────────────
            TOGGLE_ROW("Fast Medkit",    &ZX_FastMedkit,    false);
            TOGGLE_ROW("Fast Reload",    &ZX_FastReload2,   false);
            TOGGLE_ROW("Bullet Rain",    &ZX_BulletRain,    false);
            TOGGLE_ROW("Wall Shoot",     &ZX_WallShoot,     false);
            TOGGLE_ROW("Head Only",      &ZX_HeadOnly,      false);
            TOGGLE_ROW("Lock Trigger",   &ZX_LockTrigger,   false);
            TOGGLE_ROW("Insta Scope",    &ZX_InstaScope,    false);
            TOGGLE_ROW("Quick Scope",    &ZX_QuickScope,    false);
            // ── Movement ──────────────────────────────────────
            TOGGLE_ROW("Real Speed",     &ZX_RealSpeed,     false);
            // Speed multiplier slider (แสดงเฉพาะเมื่อ Real Speed เปิด)
            if (ZX_RealSpeed) {
                ImGui::SetNextItemWidth(ImGui::GetContentRegionAvail().x - 8.0f);
                ImGui::SliderFloat("##SpeedMult", &ZX_SpeedMult, 1.0f, 5.0f, "Speed x%.1f");
            }
            TOGGLE_ROW("Ghost Mode",     &ZX_GhostMode,     false);
            // ── Visual ────────────────────────────────────────
            TOGGLE_ROW("Map Reveal",     &ZX_MapReveal,     false);
            TOGGLE_ROW("Anti Flash",     &ZX_AntiFlash,     false);
            TOGGLE_ROW("Zoom Hack",      &ZX_ZoomHack,      false);
            // ── Misc (placeholder) ────────────────────────────
            TOGGLE_ROW("Spin Bot",       &ZX_SpinBot,       false);
            TOGGLE_ROW("Fake Lag",       &ZX_FakeLag,       false);
            // ── Account / Protection ──────────────────────────
            TOGGLE_ROW("Anti-ban",       &ZX_AntiBan,       false);
            TOGGLE_ROW("Reset Guest",    &ZX_ResetAcc,      true);
            break;
        }
        // ── INFO ─────────────────────────────────────────────────────────
        case 5: {
            // Init battery monitor once
            if (!ZX_BatMonInit) {
                [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
                ZX_BatMonInit = true;
            }
            // Session timer
            static double ZX_InfoSessionStart = 0.0;
            if (ZX_InfoSessionStart == 0.0) ZX_InfoSessionStart = ImGui::GetTime();
            double elapsed = ImGui::GetTime() - ZX_InfoSessionStart;
            int hh = (int)(elapsed / 3600);
            int mm = (int)(elapsed / 60) % 60;
            int ss = (int)elapsed % 60;
            char timeBuf[32];
            snprintf(timeBuf, sizeof(timeBuf), "%02d:%02d:%02d", hh, mm, ss);

            // Battery
            float batLevel = [[UIDevice currentDevice] batteryLevel];
            char batBuf[16];
            if (batLevel < 0.0f) snprintf(batBuf, sizeof(batBuf), "--%% ");
            else snprintf(batBuf, sizeof(batBuf), "%d%%", (int)(batLevel * 100.0f));

            // Kill counter buf
            char killBuf[16];
            snprintf(killBuf, sizeof(killBuf), "%d", ZX_KillCount);

            // Info row helper (label left, value right — no toggle)
            struct InfoRow {
                static void Draw(const char* label, const char* value,
                                 ImU32 textCol, ImU32 valCol,
                                 ImU32 sep, ImU32 hover,
                                 float rowH, float pad, bool lastRow) {
                    ImGuiWindow* cw = ImGui::GetCurrentWindow();
                    if (cw->SkipItems) return;
                    ImVec2 pos = cw->DC.CursorPos;
                    float  aw  = ImGui::GetContentRegionAvail().x;
                    const ImGuiID id = cw->GetID(label);
                    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + rowH));
                    ImGui::ItemSize(ImVec2(aw, rowH), 0.0f);
                    ImGui::ItemAdd(bb, id);
                    ImDrawList* cdl = cw->DrawList;
                    if (!lastRow)
                        cdl->AddLine(ImVec2(bb.Min.x + pad, bb.Max.y - 1.0f),
                                     ImVec2(bb.Max.x - pad, bb.Max.y - 1.0f), sep, 1.0f);
                    float cy = (bb.Min.y + bb.Max.y) * 0.5f;
                    float fs = ImGui::GetFontSize();
                    // label left
                    cdl->AddText(ImVec2(bb.Min.x + pad, cy - fs * 0.5f), textCol, label);
                    // value right
                    ImVec2 vts = ImGui::CalcTextSize(value);
                    cdl->AddText(ImVec2(bb.Max.x - pad - vts.x, cy - fs * 0.5f), valCol, value);
                }
            };

            const ImU32 VAL_COL = IM_COL32(90, 200, 250, 255);  // same sky-blue as toggle ON

            InfoRow::Draw("KEY",     killBuf, M_TEXT, VAL_COL, M_SEP, M_HOVER, ROW_H, PAD, false);
            InfoRow::Draw("Battery", batBuf,  M_TEXT, VAL_COL, M_SEP, M_HOVER, ROW_H, PAD, false);
            InfoRow::Draw("Time",    timeBuf, M_TEXT, VAL_COL, M_SEP, M_HOVER, ROW_H, PAD, true);

            // +/- Kill counter buttons
            ImGuiWindow* cw2 = ImGui::GetCurrentWindow();
            ImVec2 cp = cw2->DC.CursorPos;
            float  aw2 = ImGui::GetContentRegionAvail().x;
            const float BTN_H = 40.0f, GAP2 = 10.0f;
            float btnW = (aw2 - PAD * 2.0f - GAP2) * 0.5f;
            ImDrawList* cdl2 = cw2->DrawList;

            const ImU32 BTN_BG2 = IM_COL32(52, 52, 55, 255);
            const ImU32 BTN_ACT = IM_COL32(47, 72, 87, 255);

            // — KILL button
            float mX0 = cp.x + PAD, mX1 = mX0 + btnW;
            float mY0 = cp.y + 8.0f, mY1 = mY0 + BTN_H;
            cdl2->AddRectFilled(ImVec2(mX0, mY0), ImVec2(mX1, mY1), BTN_BG2, 10.0f);
            ImVec2 mts = ImGui::CalcTextSize("- KILL");
            cdl2->AddText(ImVec2((mX0+mX1)*0.5f - mts.x*0.5f, (mY0+mY1)*0.5f - mts.y*0.5f),
                          M_TEXT, "- KILL");
            ImGui::SetCursorScreenPos(ImVec2(mX0, mY0));
            if (ImGui::InvisibleButton("##km", ImVec2(btnW, BTN_H)) && ZX_KillCount > 0)
                ZX_KillCount--;

            // + KILL button
            float pX0 = mX1 + GAP2, pX1 = pX0 + btnW;
            cdl2->AddRectFilled(ImVec2(pX0, mY0), ImVec2(pX1, mY1), BTN_ACT, 10.0f);
            ImVec2 pts2 = ImGui::CalcTextSize("+ KILL");
            cdl2->AddText(ImVec2((pX0+pX1)*0.5f - pts2.x*0.5f, (mY0+mY1)*0.5f - pts2.y*0.5f),
                          M_TEXT, "+ KILL");
            ImGui::SetCursorScreenPos(ImVec2(pX0, mY0));
            if (ImGui::InvisibleButton("##kp", ImVec2(btnW, BTN_H)))
                ZX_KillCount++;

            ImGui::SetCursorScreenPos(ImVec2(cp.x, mY1 + 8.0f));
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

// ── Real Speed Hook: GetMoveSpeedForFPPMode (RVA: 0x4B23770) ─────────────────
extern float (*orig_GetMoveSpeedForFPP)(void*);
extern float hook_GetMoveSpeedForFPP(void*);

void initRealSpeedHook(void) {
    static bool done = false;
    if (done) return;
    done = true;
    NSString *r = StaticInlineHookPatch(("Frameworks/UnityFramework.framework/UnityFramework"), 0x4B23770, nullptr);
    NSLog(@"[RealSpeed] patch: %@", r ?: @"<nil>");
    void *orig = StaticInlineHookFunction(("Frameworks/UnityFramework.framework/UnityFramework"), 0x4B23770, (void*)hook_GetMoveSpeedForFPP);
    if (orig) *(void**)(&orig_GetMoveSpeedForFPP) = orig;
}

// ── Anti-ban Hook: SyncPos (RVA: 0x1186A50) — clamp speed ก่อนส่ง server ─────
extern void (*orig_SyncPos)(void*, uint32_t, Vector3, Quaternion, Vector3);
extern void hook_SyncPos(void*, uint32_t, Vector3, Quaternion, Vector3);

void initAntiBanHook(void) {
    static bool done = false;
    if (done) return;
    done = true;
    NSString *r = StaticInlineHookPatch(("Frameworks/UnityFramework.framework/UnityFramework"), 0x1186A50, nullptr);
    NSLog(@"[AntiBan] patch: %@", r ?: @"<nil>");
    void *orig = StaticInlineHookFunction(("Frameworks/UnityFramework.framework/UnityFramework"), 0x1186A50, (void*)hook_SyncPos);
    if (orig) *(void**)(&orig_SyncPos) = orig;
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

        // ── Floating MENU Button — โชว์ตลอด กด = เปิด/ปิดเมนู ค้าง = ลาก ──
        {
            static ImVec2 menuBtnPos(20.0f, screenH * 0.35f);
            static bool   menuDragging   = false;
            static ImVec2 menuDragOffset(0.0f, 0.0f);

            const float MW = 68.0f, MH = 34.0f, MR = 17.0f;
            ImVec2 mMin = menuBtnPos;
            ImVec2 mMax = ImVec2(mMin.x + MW, mMin.y + MH);

            ImGuiIO& mio = ImGui::GetIO();
            bool mHov = mio.MousePos.x >= mMin.x && mio.MousePos.x <= mMax.x &&
                        mio.MousePos.y >= mMin.y && mio.MousePos.y <= mMax.y;

            if (mHov && ImGui::IsMouseClicked(0))
                menuDragOffset = ImVec2(mio.MousePos.x - mMin.x, mio.MousePos.y - mMin.y);
            if (ImGui::IsMouseDown(0) && mHov && mio.MouseDownDuration[0] > 0.3f)
                menuDragging = true;
            if (menuDragging)
                menuBtnPos = ImVec2(mio.MousePos.x - menuDragOffset.x,
                                    mio.MousePos.y - menuDragOffset.y);
            if (!ImGui::IsMouseDown(0)) menuDragging = false;

            if (mHov && ImGui::IsMouseReleased(0) && !menuDragging)
                MenDeal = !MenDeal;

            ImDrawList* mdl = ImGui::GetForegroundDrawList();
            // White iOS theme — orange when open, white when closed
            ImU32 mColor = MenDeal
                         ? IM_COL32(255,  95,  30, 235)   // orange = open
                         : IM_COL32(  0,   0,   0, 235);   // black  = closed
            ImU32 mBorder = MenDeal
                         ? IM_COL32(255, 120,  60, 180)
                         : IM_COL32( 60,  60,  64, 255);
            ImU32 mTxtCol = IM_COL32(255, 255, 255, 255);
            if (mHov && !menuDragging) {
                mColor   = IM_COL32(255,  75,  10, 245);
                mTxtCol  = IM_COL32(255, 255, 255, 255);
            }
            // Drop shadow for floating button
            mdl->AddRectFilled(ImVec2(mMin.x - 1, mMin.y + 2),
                               ImVec2(mMax.x + 1, mMax.y + 4),
                               IM_COL32(0,0,0,22), MR + 1.0f);
            mdl->AddRectFilled(mMin, mMax, mColor, MR);
            mdl->AddRect(mMin, mMax, mBorder, MR, 0, 1.2f);

            const char* mtxt = MenDeal ? "CLOSE" : "MENU";
            ImVec2 mts = ImGui::CalcTextSize(mtxt);
            mdl->AddText(ImVec2(mMin.x + (MW - mts.x) * 0.5f,
                                mMin.y + (MH - mts.y) * 0.5f),
                         mTxtCol, mtxt);
        }

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
