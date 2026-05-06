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

// ✅ UIButtons ลอย (เฉพาะที่ปลอดภัย)
@property (nonatomic, strong) UIButton *aimbotButton;
@property (nonatomic, strong) UISwitch *aimbotSwitch;
@property (nonatomic, strong) UIButton *espButton;
@property (nonatomic, strong) UISwitch *espSwitch;

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
    
    // สร้างปุ่มลอย (Aimbot + ESP)
    [self createAimbotButton];
    [self createEspButton];
    [self updateFloatButtonsVisibility];
}

// ── UIButton Maker (简约安全版) ───────────────────────────────────────────
- (UIButton *)makeFloatButton:(NSString *)title centerX:(CGFloat)cx centerY:(CGFloat)cy {
    const CGFloat BW = 68.0f, BH = 58.0f;
    UIWindow *win = [UIApplication sharedApplication].keyWindow
                 ?: [UIApplication sharedApplication].windows.firstObject;
    UIButton *btn = [[UIButton alloc] initWithFrame:
        CGRectMake(cx - BW * 0.5f, cy - BH * 0.5f, BW, BH)];

    btn.backgroundColor = [UIColor colorWithRed:0.07 green:0.22 blue:0.13 alpha:0.95];
    btn.layer.cornerRadius   = 12;
    btn.layer.borderWidth    = 1.5f;
    btn.layer.borderColor    = [UIColor colorWithRed:0.18 green:0.55 blue:0.32 alpha:1.0].CGColor;
    btn.layer.masksToBounds  = YES;

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
    sw.transform = CGAffineTransformMakeScale(0.78f, 0.78f);
    sw.center    = CGPointMake(BW * 0.5f, BH * 0.62f);
    sw.onTintColor  = [UIColor colorWithRed:0.20 green:0.78 blue:0.35 alpha:1.0];
    sw.thumbTintColor = [UIColor whiteColor];
    [btn addSubview:sw];
    return sw;
}

- (CGPoint)screenCenter {
    CGSize s = UIScreen.mainScreen.bounds.size;
    return CGPointMake(s.width * 0.5f, s.height * 0.5f);
}

- (void)createAimbotButton {
    CGPoint c = [self screenCenter];
    self.aimbotButton = [self makeFloatButton:@"AIMBOT"
                                      centerX:c.x - 45 centerY:c.y - 35];
    self.aimbotSwitch = [self makeFloatSwitch:self.aimbotButton];
    self.aimbotSwitch.on = ZX_Aimbot;
    [self.aimbotSwitch addTarget:self action:@selector(aimbotSwitchChanged:)
                forControlEvents:UIControlEventValueChanged];
}

- (void)createEspButton {
    CGPoint c = [self screenCenter];
    self.espButton = [self makeFloatButton:@"ESP"
                                   centerX:c.x + 45 centerY:c.y - 35];
    self.espSwitch = [self makeFloatSwitch:self.espButton];
    self.espSwitch.on = ZX_EspEnable;
    [self.espSwitch addTarget:self action:@selector(espSwitchChanged:)
             forControlEvents:UIControlEventValueChanged];
}

- (void)updateFloatButtonsVisibility {
    self.aimbotButton.hidden = !ZX_Aimbot;
    self.espButton.hidden    = !ZX_EspEnable;
    if (self.aimbotSwitch.on != ZX_Aimbot) self.aimbotSwitch.on = ZX_Aimbot;
    if (self.espSwitch.on    != ZX_EspEnable) self.espSwitch.on = ZX_EspEnable;
}

- (void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:button] anyObject];
    CGPoint prev = [touch previousLocationInView:button.superview];
    CGPoint curr = [touch locationInView:button.superview];
    button.center = CGPointMake(button.center.x + (curr.x - prev.x), button.center.y + (curr.y - prev.y));
}

- (void)aimbotSwitchChanged:(UISwitch *)sender {
    ZX_Aimbot = sender.on;
    Vars.Aimbot = ZX_Aimbot;
}

- (void)espSwitchChanged:(UISwitch *)sender {
    ZX_EspEnable = sender.on;
    Vars.Enable = ZX_EspEnable;
}

// ========================= SAFE UI — ZEXIS I9 STYLE ==========================
static const ImU32 M_WIN_BG       = IM_COL32( 30,  30,  32, 255);
static const ImU32 M_TAB_INACTIVE = IM_COL32( 52,  52,  55, 255);
static const ImU32 M_TAB_ACTIVE   = IM_COL32( 47,  72,  87, 255);
static const ImU32 M_TGL_ON       = IM_COL32( 90, 200, 250, 255);
static const ImU32 M_TGL_OFF      = IM_COL32( 62,  62,  66, 255);
static const ImU32 M_KNOB         = IM_COL32(255, 255, 255, 255);
static const ImU32 M_TEXT         = IM_COL32(255, 255, 255, 255);
static const ImU32 M_BTN_BG       = IM_COL32( 62,  62,  66, 255);
static const ImU32 M_SEP          = IM_COL32( 50,  50,  54, 255);
static const ImU32 M_HOVER        = IM_COL32(255, 255, 255,  14);

static const float WIN_W     = 340.0f;
static const float WIN_H     = 400.0f;
static const float WIN_RAD   = 16.0f;
static const float SB_W      = 80.0f;
static const float HDR_H     = 44.0f;
static const float BOT_H     = 48.0f;
static const float ROW_H     = 42.0f;
static const float TAB_H     = 38.0f;
static const float TAB_GAP   = 6.0f;
static const float PAD       = 12.0f;

static int  ZX_Tab = 0;
static bool ZX_Aimbot   = false;
static bool ZX_Silent   = false;
static bool ZX_EspEnable= false;
static bool ZX_EspBox   = false;
static bool ZX_EspLine  = false;
static bool ZX_EspName  = false;
static bool ZX_EspDist  = false;
static bool ZX_EspSkel  = false;
static bool ZX_NoRecoil = false;
static bool ZX_FastSw   = false;
static bool ZX_RealSpeed= false;
static float ZX_SpeedMult = 1.3f;
static bool ZX_NoFogHelper = false;
static bool ZX_HideModMenu = false;
static void ZX_ApplyAndRun() {
    Vars.Enable       = ZX_EspEnable;
    Vars.Box          = ZX_EspBox;
    Vars.lines        = ZX_EspLine;
    Vars.Name         = ZX_EspName;
    Vars.Distance     = ZX_EspDist;
    Vars.skeleton     = ZX_EspSkel;
    Vars.Aimbot       = ZX_Aimbot;
    SilentAim         = ZX_Silent;
    Vars.NoRecoil     = ZX_NoRecoil;
    Vars.FastSwitch   = ZX_FastSw;
    Vars.VisibleCheck = false;
    Vars.IgnoreKnocked= true;

    if (ZX_RealSpeed) {
        ZX_SpeedMultiplier = ZX_SpeedMult;
        RunRealSpeed();
        initRealSpeedHook();
    }
}

static void EasyToggleRow(const char* label, bool* v, bool last = false) {
    ImGuiWindow* cw = ImGui::GetCurrentWindow();
    ImVec2 pos = cw->DC.CursorPos;
    float aw = ImGui::GetContentRegionAvail().x;
    ImGui::InvisibleButton("##dummy", ImVec2(aw, ROW_H));
    ImDrawList* dl = cw->DrawList;
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + ROW_H));
    dl->AddRectFilled(bb.Min, bb.Max, IM_COL32(30,30,35,255), 6.0f);
    if (!last) dl->AddLine(ImVec2(bb.Min.x + PAD, bb.Max.y - 1),
                           ImVec2(bb.Max.x - PAD, bb.Max.y - 1), M_SEP, 1.0f);
    float cy = (bb.Min.y + bb.Max.y) * 0.5f;
    dl->AddText(ImVec2(bb.Min.x + PAD, cy - ImGui::GetFontSize() * 0.5f), M_TEXT, label);
    const float TW = 51.0f, TH = 31.0f, TR = TH * 0.5f;
    float tX = bb.Max.x - TW - PAD;
    float tY = cy - TH * 0.5f;
    ImU32 track = *v ? M_TGL_ON : M_TGL_OFF;
    dl->AddRectFilled(ImVec2(tX, tY), ImVec2(tX + TW, tY + TH), track, TR);
    float kX = *v ? (tX + TW - TR) : (tX + TR);
    dl->AddCircleFilled(ImVec2(kX, cy), TR - 2.5f, M_KNOB, 28);
    ImGui::SetCursorScreenPos(bb.Min);
    const ImGuiID id = cw->GetID(label);
    bool hov, hld;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hov, &hld);
    if (pressed) *v = !*v;
}

static void RenderMenu() {
    if (!MenDeal) return;
    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(30/255.,30/255.,32/255.,1));
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, WIN_RAD);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0,0));
    ImGui::SetNextWindowSize(ImVec2(WIN_W, WIN_H), ImGuiCond_Always);
    ImGui::Begin("##SafeMenu", nullptr,
        ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize |
        ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse);
    ImGui::SetWindowFontScale(1.0f);
    ImDrawList* dl = ImGui::GetWindowDrawList();
    ImVec2 wp = ImGui::GetWindowPos();
    ImVec2 ws = ImGui::GetWindowSize();
    dl->AddRectFilled(wp, ImVec2(wp.x+ws.x, wp.y+ws.y), M_WIN_BG, WIN_RAD);
    float hCY = wp.y + HDR_H * 0.5f;
    ImVec2 tts = ImGui::CalcTextSize("ZEXIS I9");
    dl->AddText(ImVec2(wp.x + (ws.x - tts.x) * 0.5f, hCY - tts.y * 0.5f), IM_COL32(180,180,210,255), "ZEXIS I9");
    dl->AddLine(ImVec2(wp.x, wp.y + HDR_H), ImVec2(wp.x+ws.x, wp.y + HDR_H), M_SEP, 1.0f);
    float zoneY0 = wp.y + HDR_H;
    float zoneY1 = wp.y + WIN_H - BOT_H;
    float rcX = wp.x + SB_W;
    float rcW = ws.x - SB_W;
    // LEFT SIDEBAR
    const char* kTabNames[] = { "ESP", "AIM", "MISC" };
    const int kTabCount = 3;
    float totalH = kTabCount * TAB_H + (kTabCount-1) * TAB_GAP;
    float tabsY0 = zoneY0 + ( (zoneY1-zoneY0) - totalH) * 0.5f;
    for (int i=0; i<kTabCount; ++i) {
        float bY0 = tabsY0 + i*(TAB_H+TAB_GAP);
        float bX0 = wp.x + 8, bX1 = wp.x + SB_W - 8;
        bool active = (ZX_Tab == i);
        dl->AddRectFilled(ImVec2(bX0, bY0), ImVec2(bX1, bY0+TAB_H), active ? M_TAB_ACTIVE : M_TAB_INACTIVE, 10.0f);
        ImVec2 lts = ImGui::CalcTextSize(kTabNames[i]);
        dl->AddText(ImVec2((bX0+bX1)*0.5f - lts.x*0.5f, bY0 + (TAB_H - lts.y)*0.5f), M_TEXT, kTabNames[i]);
        ImGui::SetCursorScreenPos(ImVec2(bX0, bY0));
        char bid[16]; snprintf(bid, 16, "##tab%d", i);
        if (ImGui::InvisibleButton(bid, ImVec2(bX1-bX0, TAB_H))) ZX_Tab = i;
    }
    // CONTENT
    ImGui::SetCursorScreenPos(ImVec2(rcX, zoneY0));
    ImGui::BeginChild("##safe_content", ImVec2(rcW, zoneY1-zoneY0), false);
    if (ZX_Tab == 0) {
        EasyToggleRow("Enable ESP", &ZX_EspEnable, false);
        EasyToggleRow("Box ESP",    &ZX_EspBox,    false);
        EasyToggleRow("Line ESP",   &ZX_EspLine,   false);
        EasyToggleRow("Name ESP",   &ZX_EspName,   false);
        EasyToggleRow("Distance",   &ZX_EspDist,   false);
        EasyToggleRow("Skeleton",   &ZX_EspSkel,   true);
    } else if (ZX_Tab == 1) {
        EasyToggleRow("Aimbot",     &ZX_Aimbot,    false);
        EasyToggleRow("Silent Aim", &ZX_Silent,    false);
        EasyToggleRow("No Recoil",  &ZX_NoRecoil,  true);
    } else if (ZX_Tab == 2) {
        EasyToggleRow("Fast Switch", &ZX_FastSw,   false);
        EasyToggleRow("Real Speed",  &ZX_RealSpeed,false);
        if (ZX_RealSpeed) {
            ImGui::SetNextItemWidth(rcW - 20);
            ImGui::SliderFloat("##SpdMult", &ZX_SpeedMult, 1.0f, 1.5f, "Speed x%.2f");
        }
        ImGui::Spacing(); EasyToggleRow("No Fog", &ZX_NoFogHelper, true);
    }
    ImGui::EndChild();

    // BOTTOM BUTTONS
    float bbCY = zoneY1 + BOT_H * 0.5f;
    float bh = 36.0f;
    float bw = (ws.x - PAD*2 - 12) * 0.5f;
    float cX0 = wp.x + PAD, cX1 = cX0 + bw;
    float y0 = bbCY - bh*0.5f;
    dl->AddRectFilled(ImVec2(cX0, y0), ImVec2(cX1, y0+bh), M_BTN_BG, 10.0f);
    ImVec2 cts = ImGui::CalcTextSize("Close");
    dl->AddText(ImVec2(cX0+(bw-cts.x)*0.5f, y0+(bh-cts.y)*0.5f), M_TEXT, "Close");
    ImGui::SetCursorScreenPos(ImVec2(cX0, y0));
    if (ImGui::InvisibleButton("##close", ImVec2(bw, bh))) MenDeal = false;
    float hX0 = cX1 + 12, hX1 = hX0 + bw;
    dl->AddRectFilled(ImVec2(hX0, y0), ImVec2(hX1, y0+bh), M_BTN_BG, 10.0f);
    ImVec2 hts = ImGui::CalcTextSize("HIDE");
    dl->AddText(ImVec2(hX0+(bw-hts.x)*0.5f, y0+(bh-hts.y)*0.5f), M_TEXT, "HIDE");
    ImGui::SetCursorScreenPos(ImVec2(hX0, y0));
    if (ImGui::InvisibleButton("##hide", ImVec2(bw, bh))) ZX_HideModMenu = !ZX_HideModMenu;
    ImGui::End();
    ImGui::PopStyleVar(2);
    ImGui::PopStyleColor();
}

// Hooks / touch handlers (คงเดิม)
void SetNinjaRunSpeedPreset(int preset);
extern void old_AutoFire(void *_this, int32_t pFireStatus, int32_t pFireMode);
extern void (*_AutoFire)(void *_this, int32_t pFireStatus, int32_t pFireMode);
void initAutoFireHook(void);
void initRealSpeedHook(void);

void initRealSpeedHook(void) {
    static bool done = false;
    if (done) return;
    done = true;
    NSString *r = StaticInlineHookPatch(("Frameworks/UnityFramework.framework/UnityFramework"), 0x4B23770, nullptr);
    void *orig = StaticInlineHookFunction(("Frameworks/UnityFramework.framework/UnityFramework"), 0x4B23770, (void*)hook_GetMoveSpeedForFPP);
    if (orig) *(void**)(&orig_GetMoveSpeedForFPP) = orig;
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
// Dummy hook for AutoFire (safe version doesn't need real hook)
void initAutoFireHook(void) {
    // does nothing, only to satisfy linker
}
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
        ImGui::SetNextWindowPos(ImVec2((screenW-WIN_W)*0.5f, (screenH-WIN_H)*0.5f), ImGuiCond_FirstUseEver);
        if (MenDeal) RenderMenu();
        ZX_ApplyAndRun();
        [self updateFloatButtonsVisibility];
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
