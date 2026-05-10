// ImGuiDrawView.mm — Rewritten (clean, no floating switches, redesigned UI)
// ─────────────────────────────────────────────────────────────────────────────
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <vector>
#import <sys/sysctl.h>
#import "pthread.h"
#include <array>
#import <os/log.h>
#include <cmath>
#include <deque>
#include <algorithm>
#include <string>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <cstdint>
#include <cinttypes>

#import "Esp/CaptainHook.h"
#import "Esp/ImGuiDrawView.h"
#import "IMGUI/imgui.h"
#import "IMGUI/imgui_internal.h"
#import "IMGUI/imgui_impl_metal.h"
#import "IMGUI/zzz.h"
#include "oxorany/oxorany_include.h"
#import "Helper/Mem.h"
#include "font.h"
#import "Helper/Vector3.h"
#import "Helper/Vector2.h"
#import "Helper/Quaternion.h"
#import "Helper/Monostring.h"
#include "Helper/font.h"
#include "Helper/data.h"
#include "Helper/Obfuscate.h"
#import "Helper/Hooks.h"
#include "Other/dobby_defines.h"
#import "Other/H5hook.h"
#include "Other/Paste.h"
#import <objc/runtime.h>

// ─── Hook macro ───────────────────────────────────────────────────────────────
#define Hook(x, y, z) \
{ \
    NSString* result_##y = StaticInlineHookPatch(("Frameworks/UnityFramework.framework/UnityFramework"), x, nullptr); \
    if (result_##y) { \
        void* result = StaticInlineHookFunction(("Frameworks/UnityFramework.framework/UnityFramework"), x, (void *) y); \
        *(void **) (&z) = (void*) result; \
    } \
}

static bool MenDeal = true;

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

// ─── Forward declares ─────────────────────────────────────────────────────────
static bool ZX_MarkTeleport = false;
static bool ZX_AutoTeleport = false;

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Interface
// ─────────────────────────────────────────────────────────────────────────────

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id<MTLDevice>       device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
// Floating MENU button (own UIWindow — always on top)
@property (nonatomic, strong) UIWindow *menuWindow;
@property (nonatomic, strong) UIButton *menuButton;
@end

static __weak ImGuiDrawView *g_DrawView = nil;

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - State Variables
// ─────────────────────────────────────────────────────────────────────────────

static int   ZX_Tab            = 0;
static bool  ZX_FlyAlt         = false;
static float ZX_FlySpeed       = 5.0f;
static bool  ZX_FastFire       = false;
static bool  ZX_LongRange      = false;
static bool  ZX_BulletThru     = false;
static bool  ZX_FastSwitch     = false;
static bool  ZX_FastSwitchAuto = false;
static bool  ZX_ChainDamage    = false;
static float ZX_ChainDmgValue  = 1000.0f;
static bool  ZX_Telekill       = false;
static bool  ZX_FreeFly        = false;
static float ZX_FreeFlySpeed   = 8.0f;
static bool  ZX_AimKill        = false;
static bool  ZX_NoRecoil       = false;
static bool  ZX_NoReload       = false;
static bool  ZX_AIPlayerAim    = false;
static bool  ZX_RUN            = false;
static bool  ZX_GHOSTVIP       = false;
static bool  ZX_AmmoSpeedFast  = false;
static bool  ZX_BlueMap        = false;
static bool  ZX_FastMedkit     = false;
static bool  ZX_RealSpeed      = false;
static float ZX_SpeedMult      = 1.8f;
static bool  ZX_AntiBan        = false;
static bool  ZX_DashForward    = false;
static float ZX_DashDistance   = 100.0f;
static bool  ZX_HideModMenu    = false;
static bool  ZX_Esp3DBox       = false;
static bool  ZX_CameraLeft     = false;
static float ZX_CameraHeight   = 5.0f;
static float ZX_CameraSide     = 0.0f;

// Speed presets
static bool  ZX_SpeedX10      = false;
static bool  ZX_SpeedX20      = false;
static bool  ZX_SpeedX50      = false;

// AimKill variants
static bool  ZX_UnderKill     = false;
static bool  ZX_AimKillV1     = false;
static bool  ZX_AimKillV2     = false;
static bool  ZX_AimKillV3     = false;
static bool  ZX_AimKillV4     = false;
static bool  ZX_AimKillV5     = false;

// Fly V2
static bool  ZX_FlyV2         = false;
static float ZX_FlyV2Speed    = 30.0f;

// Extra
static bool  ZX_RapidFire     = false;
static bool  ZX_SuperJump     = false;
static bool  ZX_HeadOnly      = false;
static bool  ZX_WallShoot     = false;
static bool  ZX_MapReveal     = false;
static bool  ZX_AntiFlash     = false;
static bool  ZX_ZoomHack      = false;
static float ZX_ZoomLevel     = 2.0f;

static int   ZX_KillCount     = 0;

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - UI Colors & Layout
// ─────────────────────────────────────────────────────────────────────────────

// Colors — single dark theme, orange accent
static const ImU32 UI_WIN_BG        = IM_COL32( 12,  12,  15, 255);
static const ImU32 UI_HEADER_BG     = IM_COL32(  8,   8,  10, 255);
static const ImU32 UI_SIDEBAR_BG    = IM_COL32( 10,  10,  13, 255);
static const ImU32 UI_SIDEBAR_LINE  = IM_COL32( 28,  28,  34, 255);
static const ImU32 UI_CONTENT_BG    = IM_COL32( 16,  16,  20, 255);
static const ImU32 UI_TAB_ACTIVE    = IM_COL32( 24,  24,  30, 255);
static const ImU32 UI_TAB_BAR       = IM_COL32(255,  95,  30, 255);   // orange accent
static const ImU32 UI_WIN_BORDER    = IM_COL32( 30,  30,  38, 255);
static const ImU32 UI_SEP           = IM_COL32( 26,  26,  32, 255);
static const ImU32 UI_SECTION_BG    = IM_COL32( 10,  10,  13, 255);
static const ImU32 UI_SECTION_TXT   = IM_COL32(120, 120, 130, 255);
static const ImU32 UI_TEXT          = IM_COL32(220, 220, 228, 255);
static const ImU32 UI_TEXT_DIM      = IM_COL32(100, 100, 110, 255);
static const ImU32 UI_HOVER         = IM_COL32(255, 255, 255,   7);
static const ImU32 UI_ORANGE        = IM_COL32(255,  95,  30, 255);
static const ImU32 UI_GREEN         = IM_COL32( 52, 199,  89, 255);
static const ImU32 UI_RED           = IM_COL32(255,  59,  48, 255);
static const ImU32 UI_TGL_ON        = IM_COL32(255,  95,  30, 255);
static const ImU32 UI_TGL_OFF       = IM_COL32( 32,  32,  40, 255);
static const ImU32 UI_TGL_KNOB      = IM_COL32(255, 255, 255, 255);
static const ImU32 UI_SLIDER_BG     = IM_COL32( 30,  30,  38, 255);
static const ImU32 UI_SLIDER_FILL   = IM_COL32(255,  95,  30, 255);
static const ImU32 UI_TAB_TXT_ON    = IM_COL32(255, 255, 255, 255);
static const ImU32 UI_TAB_TXT_OFF   = IM_COL32( 90,  90, 100, 255);

// Layout
static const float UI_WIN_RAD   = 16.0f;
static const float UI_HEADER_H  = 50.0f;
static const float UI_SIDEBAR_W = 68.0f;
static const float UI_STATUS_H  = 38.0f;
static const float UI_TAB_H     = 56.0f;
static const float UI_TAB_GAP   =  4.0f;
static const float UI_ROW_H     = 46.0f;
static const float UI_ROW_GAP   =  0.0f;
static const float UI_PAD       = 14.0f;
static const float UI_SEC_H     = 24.0f;
static const float UI_SL_H      =  5.0f;
static const float UI_KNOB_R    =  9.0f;
static const float UI_FSCALE    =  0.88f;

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - UI Widgets
// ─────────────────────────────────────────────────────────────────────────────

// Section header with left orange accent line
static void UI_Section(const char* label) {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return;
    float aw  = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = w->DC.CursorPos;
    const float H = UI_SEC_H + 8.0f;
    ImGui::ItemSize(ImVec2(aw, H), 0.0f);
    ImDrawList* dl = w->DrawList;
    dl->AddRectFilled(pos, ImVec2(pos.x + aw, pos.y + H), UI_SECTION_BG, 0.0f);
    // orange left bar
    dl->AddRectFilled(ImVec2(pos.x, pos.y + 5.0f),
                      ImVec2(pos.x + 3.0f, pos.y + H - 5.0f),
                      UI_TAB_BAR, 2.0f);
    float cy = pos.y + H * 0.5f;
    dl->AddText(ImVec2(pos.x + UI_PAD + 2.0f, cy - ImGui::GetFontSize() * 0.5f),
                UI_SECTION_TXT, label);
}

// iOS-style toggle row: label left, pill toggle right
static bool UI_Toggle(const char* label, bool* v) {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return false;
    float aw  = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = w->DC.CursorPos;
    const ImGuiID id = w->GetID(label);
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + UI_ROW_H));
    ImGui::ItemSize(ImVec2(aw, UI_ROW_H + UI_ROW_GAP), 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hovered, &held);
    if (pressed) *v = !*v;

    ImDrawList* dl = w->DrawList;
    if (hovered) dl->AddRectFilled(bb.Min, bb.Max, UI_HOVER, 0.0f);

    // separator line
    dl->AddLine(ImVec2(bb.Min.x + UI_PAD, bb.Max.y - 1.0f),
                ImVec2(bb.Max.x,           bb.Max.y - 1.0f), UI_SEP, 1.0f);

    float cy = (bb.Min.y + bb.Max.y) * 0.5f;
    dl->AddText(ImVec2(bb.Min.x + UI_PAD, cy - ImGui::GetFontSize() * 0.5f), UI_TEXT, label);

    // pill toggle
    const float TW = 46.0f, TH = 28.0f, TR = TH * 0.5f;
    float tX = bb.Max.x - TW - UI_PAD;
    float tY = cy - TH * 0.5f;
    ImU32 track = *v ? UI_TGL_ON : UI_TGL_OFF;
    dl->AddRectFilled(ImVec2(tX, tY), ImVec2(tX + TW, tY + TH), track, TR);
    float kX = *v ? (tX + TW - TR) : (tX + TR);
    dl->AddCircleFilled(ImVec2(kX, cy), TR - 2.0f, IM_COL32(0,0,0,20), 24);
    dl->AddCircleFilled(ImVec2(kX, cy), TR - 3.0f, UI_TGL_KNOB, 24);

    return pressed;
}

// Sub-row (indented, light blue left accent — for child options)
static bool UI_SubToggle(const char* label, bool* v) {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return false;
    float aw  = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = w->DC.CursorPos;
    const ImGuiID id = w->GetID(label);
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + UI_ROW_H));
    ImGui::ItemSize(ImVec2(aw, UI_ROW_H), 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hovered, &held);
    if (pressed) *v = !*v;

    ImDrawList* dl = w->DrawList;
    dl->AddRectFilled(bb.Min, bb.Max, IM_COL32(0, 100, 255, 10), 0.0f);
    if (hovered) dl->AddRectFilled(bb.Min, bb.Max, UI_HOVER, 0.0f);
    dl->AddRectFilled(ImVec2(bb.Min.x + UI_PAD, bb.Min.y + 5.0f),
                      ImVec2(bb.Min.x + UI_PAD + 3.0f, bb.Max.y - 5.0f),
                      IM_COL32(0, 122, 255, 180), 2.0f);
    dl->AddLine(ImVec2(bb.Min.x + UI_PAD + 8.0f, bb.Max.y - 1.0f),
                ImVec2(bb.Max.x,                  bb.Max.y - 1.0f), UI_SEP, 1.0f);

    float cy = (bb.Min.y + bb.Max.y) * 0.5f;
    dl->AddText(ImVec2(bb.Min.x + UI_PAD + 16.0f, cy - ImGui::GetFontSize() * 0.5f), UI_TEXT, label);

    const float TW = 46.0f, TH = 28.0f, TR = TH * 0.5f;
    float tX = bb.Max.x - TW - UI_PAD;
    float tY = cy - TH * 0.5f;
    ImU32 track = *v ? UI_TGL_ON : UI_TGL_OFF;
    dl->AddRectFilled(ImVec2(tX, tY), ImVec2(tX + TW, tY + TH), track, TR);
    float kX = *v ? (tX + TW - TR) : (tX + TR);
    dl->AddCircleFilled(ImVec2(kX, cy), TR - 3.0f, UI_TGL_KNOB, 24);

    return pressed;
}

// Slider row: label top-left, value top-right, track below
static bool UI_Slider(const char* label, float* v, float vmin, float vmax, const char* fmt = "%.1f") {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return false;
    ImGuiContext& g = *GImGui;
    const ImGuiID id = w->GetID(label);
    ImVec2 pos = w->DC.CursorPos;
    float aw = ImGui::GetContentRegionAvail().x;
    const float rowH = UI_ROW_H + 14.0f;
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + rowH));
    ImGui::ItemSize(ImVec2(aw, rowH), 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;

    float t = (*v - vmin) / (vmax - vmin);
    t = t < 0.0f ? 0.0f : (t > 1.0f ? 1.0f : t);

    const float tX0 = pos.x + UI_PAD;
    const float tX1 = pos.x + aw - UI_PAD;
    const float tY  = pos.y + rowH - 14.0f;

    ImRect trackBB(ImVec2(tX0 - UI_KNOB_R, tY - UI_KNOB_R),
                   ImVec2(tX1 + UI_KNOB_R, tY + UI_KNOB_R));
    bool hov, hld;
    bool pressed = ImGui::ButtonBehavior(trackBB, id, &hov, &hld);
    if (hld) {
        float nt = (g.IO.MousePos.x - tX0) / (tX1 - tX0);
        nt = nt < 0.0f ? 0.0f : (nt > 1.0f ? 1.0f : nt);
        *v = vmin + nt * (vmax - vmin); t = nt;
        ImGui::MarkItemEdited(id);
    }

    ImDrawList* dl = w->DrawList;

    // label
    float labelY = pos.y + 10.0f;
    dl->AddText(ImVec2(pos.x + UI_PAD, labelY), UI_TEXT, label);

    // value
    char buf[32]; snprintf(buf, sizeof(buf), fmt, *v);
    ImVec2 vts = ImGui::CalcTextSize(buf);
    dl->AddText(ImVec2(pos.x + aw - UI_PAD - vts.x, labelY), UI_TEXT_DIM, buf);

    // track
    dl->AddRectFilled(ImVec2(tX0, tY - UI_SL_H*.5f), ImVec2(tX1, tY + UI_SL_H*.5f), UI_SLIDER_BG, UI_SL_H);
    dl->AddRectFilled(ImVec2(tX0, tY - UI_SL_H*.5f), ImVec2(tX0+(tX1-tX0)*t, tY + UI_SL_H*.5f), UI_SLIDER_FILL, UI_SL_H);
    float kx = tX0 + (tX1 - tX0) * t;
    dl->AddCircleFilled(ImVec2(kx, tY), UI_KNOB_R + 1.5f, IM_COL32(0,0,0,20), 24);
    dl->AddCircleFilled(ImVec2(kx, tY), UI_KNOB_R, UI_TGL_KNOB, 24);
    dl->AddCircle      (ImVec2(kx, tY), UI_KNOB_R, UI_ORANGE,   24, 1.4f);

    // bottom sep
    dl->AddLine(ImVec2(pos.x + UI_PAD, bb.Max.y - 1.0f),
                ImVec2(pos.x + aw,     bb.Max.y - 1.0f), UI_SEP, 1.0f);

    return hld;
}

// Info row — label left, value right (no toggle)
static void UI_InfoRow(const char* label, const char* value, ImU32 valCol = 0) {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return;
    float aw = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = w->DC.CursorPos;
    ImGui::ItemSize(ImVec2(aw, UI_ROW_H + UI_ROW_GAP), 0.0f);
    ImDrawList* dl = w->DrawList;
    dl->AddLine(ImVec2(pos.x + UI_PAD, pos.y + UI_ROW_H - 1.0f),
                ImVec2(pos.x + aw,     pos.y + UI_ROW_H - 1.0f), UI_SEP, 1.0f);
    float cy = pos.y + UI_ROW_H * 0.5f;
    dl->AddText(ImVec2(pos.x + UI_PAD, cy - ImGui::GetFontSize() * 0.5f), UI_TEXT, label);
    ImU32 vc = valCol ? valCol : UI_ORANGE;
    ImVec2 vts = ImGui::CalcTextSize(value);
    dl->AddText(ImVec2(pos.x + aw - UI_PAD - vts.x, cy - ImGui::GetFontSize() * 0.5f), vc, value);
}

// Tab icon drawings (5 tabs)
static void UI_DrawTabIcon(ImDrawList* dl, int idx, ImVec2 c, float s, ImU32 col) {
    switch (idx) {
        case 0: { // Person (ESP)
            dl->AddCircle(ImVec2(c.x, c.y - s*0.30f), s*0.26f, col, 18, 1.8f);
            dl->PathClear();
            dl->PathArcTo(ImVec2(c.x, c.y + s*0.60f), s*0.50f, IM_PI+0.40f, 2.0f*IM_PI-0.40f, 22);
            dl->PathStroke(col, 0, 1.8f);
            break;
        }
        case 1: { // Crosshair (AIMBOT)
            float r = s*0.40f, a = s*0.55f;
            dl->AddCircle(c, r, col, 22, 1.7f);
            dl->AddLine(ImVec2(c.x-a,c.y),      ImVec2(c.x-r*0.5f,c.y),    col, 1.7f);
            dl->AddLine(ImVec2(c.x+r*0.5f,c.y), ImVec2(c.x+a,c.y),         col, 1.7f);
            dl->AddLine(ImVec2(c.x,c.y-a),      ImVec2(c.x,c.y-r*0.5f),    col, 1.7f);
            dl->AddLine(ImVec2(c.x,c.y+r*0.5f), ImVec2(c.x,c.y+a),         col, 1.7f);
            dl->AddCircleFilled(c, s*0.09f, col, 10);
            break;
        }
        case 2: { // Lightning bolt (MISC)
            ImVec2 pts[6] = {
                ImVec2(c.x+s*0.10f, c.y-s*0.55f),
                ImVec2(c.x-s*0.38f, c.y+s*0.05f),
                ImVec2(c.x-s*0.05f, c.y+s*0.05f),
                ImVec2(c.x-s*0.18f, c.y+s*0.55f),
                ImVec2(c.x+s*0.40f, c.y-s*0.10f),
                ImVec2(c.x+s*0.05f, c.y-s*0.10f),
            };
            dl->AddConvexPolyFilled(pts, 6, col);
            break;
        }
        case 3: { // Gear (SETTINGS)
            float ro=s*0.50f, ri=s*0.35f, cr=s*0.16f;
            for (int t=0; t<8; ++t) {
                float ang=(float)t/8.0f*2.0f*IM_PI;
                float ca=cosf(ang), sa=sinf(ang), ex=s*0.09f;
                ImVec2 q[4]={ImVec2(c.x+ca*ri-sa*ex,c.y+sa*ri+ca*ex),
                              ImVec2(c.x+ca*ri+sa*ex,c.y+sa*ri-ca*ex),
                              ImVec2(c.x+ca*ro+sa*ex,c.y+sa*ro-ca*ex),
                              ImVec2(c.x+ca*ro-sa*ex,c.y+sa*ro+ca*ex)};
                dl->AddConvexPolyFilled(q,4,col);
            }
            dl->AddCircleFilled(c,ri,col,24);
            dl->AddCircleFilled(c,cr,UI_WIN_BG,16);
            break;
        }
        case 4: { // List icon (INFO)
            float w=s*0.72f, dy=s*0.28f, dr=s*0.09f;
            float lx0=c.x-w*0.55f+s*0.20f, lx1=c.x+w*0.46f;
            for (int i=-1; i<=1; ++i) {
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

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Forward declares for Hooks.h static functions
// ─────────────────────────────────────────────────────────────────────────────
// These are defined as static in Hooks.h which is #imported before this file.
// Declared here so ZX_ApplyAndRun can call them without warnings.
static void RunAmmoSpeedFast();
static void RunBlueMap();
static void RunFastMedkit();
static void RunRealSpeed();
static void RunDashForward(float distance);
static void RunMarkTeleport();
static void RunAutoTeleport();

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - ZX_ApplyAndRun (game logic, unchanged)
// ─────────────────────────────────────────────────────────────────────────────

static void ZX_ApplyAndRun() {
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
        Vars.Aimbot = true; Vars.AimbotEnable = true; Vars.AimMode = 0;
        Vars.isAimFov = true; Vars.AimWhen = 0; Vars.AimHitbox = 0;
        Vars.AutoFire = true; Vars.FastFire = true; FireDelay = 0.0f;
        Vars.LongRange = true; Vars.BulletPenetration = true;
        Vars.ChainDamage = true; Vars.ChainDamageValue = 9999;
        Vars.VisibleCheck = false; Vars.IgnoreKnocked = true;
        Vars.UpPlayerOne = true; SilentAim = true; CheckWall1 = false; SetDamage = 1;
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
                    cur.x += fwd.x * step; cur.y += fwd.y * step; cur.z += fwd.z * step;
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
    if (ZX_NoReload) RunNoReload();
    if (ZX_FastSwitchAuto) RunFastSwitch();
    if (ZX_AIPlayerAim && Vars.Enable) {
        Vars.Aimbot = true; Vars.AimMode = 0; Vars.isAimFov = true;
        Vars.AimSpeed = (Vars.AimSpeed > 20.0f) ? Vars.AimSpeed : 35.0f;
        Vars.AimManagerHitbox = 0; Vars.VisibleCheck = false;
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
                    Transform_INTERNAL_SetPosition(tf, Vvector3(ePos.x+1.5f, ePos.y-1.0f, ePos.z+1.5f));
                    SilentAim = true; Vars.ChainDamage = true;
                }
            }
        }
    }
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
                    Transform_INTERNAL_SetPosition(cTF, Vvector3(p.x+ZX_CameraSide, p.y+ZX_CameraHeight, p.z));
                }
            }
        }
    }
    if (ZX_SpeedX10 && Vars.Enable) { Vars.NinjaRun = true; Vars.NinjaRunSpeed = 10.0f; }
    if (ZX_SpeedX20 && Vars.Enable) { Vars.NinjaRun = true; Vars.NinjaRunSpeed = 20.0f; }
    if (ZX_SpeedX50 && Vars.Enable) { Vars.NinjaRun = true; Vars.NinjaRunSpeed = 50.0f; }
    if (ZX_RUN && Vars.Enable) {
        Vars.NinjaRun = true;
        if (Vars.NinjaRunSpeed < 0.5f) Vars.NinjaRunSpeed = 0.5f;
    }
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
    if (ZX_UnderKill && Vars.Enable) {
        Vars.Aimbot=true; Vars.AimbotEnable=true; Vars.AimMode=0;
        Vars.isAimFov=true; Vars.AimWhen=0; Vars.AimHitbox=2;
        Vars.AutoFire=true; Vars.LongRange=true; Vars.BulletPenetration=true;
        Vars.ChainDamage=true; Vars.ChainDamageValue=9999;
        Vars.VisibleCheck=false; Vars.IgnoreKnocked=false;
        Vars.UpPlayerOne=true; SilentAim=true; CheckWall1=false; SetDamage=0; FireDelay=0.0f;
        if (Vars.AimFov < 500.0f) Vars.AimFov = 500.0f;
    }
    if (ZX_AimKillV1 && Vars.Enable) {
        Vars.Aimbot=true; Vars.AimbotEnable=true; Vars.AimMode=0;
        Vars.isAimFov=true; Vars.AimWhen=0; Vars.AimHitbox=0;
        Vars.AutoFire=true; Vars.LongRange=true; Vars.BulletPenetration=true;
        Vars.ChainDamage=true; Vars.ChainDamageValue=9999;
        Vars.VisibleCheck=false; Vars.IgnoreKnocked=true;
        Vars.UpPlayerOne=true; SilentAim=true; CheckWall1=false; SetDamage=1; FireDelay=0.0f;
        if (Vars.AimFov < 500.0f) Vars.AimFov = 500.0f;
    }
    if (ZX_AimKillV2 && Vars.Enable) {
        Vars.Aimbot=true; Vars.AimbotEnable=true; Vars.AimMode=0;
        Vars.isAimFov=true; Vars.AimWhen=0; Vars.AimHitbox=0;
        Vars.AutoFire=true; Vars.LongRange=true; Vars.BulletPenetration=true;
        Vars.ChainDamage=true; Vars.ChainDamageValue=9999;
        Vars.VisibleCheck=false; Vars.IgnoreKnocked=true; Vars.Telekill=true;
        Vars.UpPlayerOne=true; SilentAim=true; CheckWall1=false; SetDamage=1; FireDelay=0.0f;
        if (Vars.AimFov < 999.0f) Vars.AimFov = 999.0f;
    }

    // Sync ZX_ booleans into Vars fields that Hooks.h functions still check
    Vars.NoReload    = ZX_NoReload;
    Vars.MarkTeleport = ZX_MarkTeleport;
    Vars.AutoTeleport = ZX_AutoTeleport;
    Vars.AmmoSpeedFast = ZX_AmmoSpeedFast;
    Vars.BlueMap     = ZX_BlueMap;

    // Feature calls driven by ZX_ flags
    if (ZX_AmmoSpeedFast  && Vars.Enable) RunAmmoSpeedFast();
    if (ZX_BlueMap)                        RunBlueMap();
    if (ZX_FastMedkit)                     RunFastMedkit();
    if (ZX_RealSpeed      && Vars.Enable) { initRealSpeedHook(); RunRealSpeed(); }
    if (ZX_AntiBan)                        initAntiBanHook();
    if (ZX_DashForward    && Vars.Enable)  RunDashForward(ZX_DashDistance);
    if (ZX_MarkTeleport   && Vars.Enable)  RunMarkTeleport();
    if (ZX_AutoTeleport   && Vars.Enable)  RunAutoTeleport();
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - RenderMenu
// ─────────────────────────────────────────────────────────────────────────────

static void RenderMenu() {
    if (!MenDeal) return;

    ImGuiIO& mio = ImGui::GetIO();
    float SW = mio.DisplaySize.x;
    float SH = mio.DisplaySize.y;

    float winW = SW * 0.94f; if (winW > 600.0f) winW = 600.0f;
    float winH = SH * 0.80f; if (winH > 500.0f) winH = 500.0f;

    ImGui::PushStyleColor(ImGuiCol_WindowBg,      ImVec4(12/255.f,12/255.f,15/255.f,1.f));
    ImGui::PushStyleColor(ImGuiCol_Border,        ImVec4(0,0,0,0));
    ImGui::PushStyleColor(ImGuiCol_ScrollbarBg,   ImVec4(0,0,0,0));
    ImGui::PushStyleColor(ImGuiCol_ScrollbarGrab, ImVec4(0.20f,0.20f,0.24f,1.f));
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding,   UI_WIN_RAD);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding,    ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing,      ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ScrollbarSize,    3.0f);

    ImGui::SetNextWindowSize(ImVec2(winW, winH), ImGuiCond_Always);
    ImGui::SetNextWindowPos(ImVec2((SW-winW)*0.5f, (SH-winH)*0.5f), ImGuiCond_FirstUseEver);
    ImGui::Begin("##ZX_MENU", nullptr,
        ImGuiWindowFlags_NoTitleBar  | ImGuiWindowFlags_NoResize    |
        ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse  |
        ImGuiWindowFlags_NoBringToFrontOnFocus);
    ImGui::SetWindowFontScale(UI_FSCALE);

    ImDrawList* dl = ImGui::GetWindowDrawList();
    ImVec2 wp = ImGui::GetWindowPos();
    ImVec2 ws = ImGui::GetWindowSize();

    // Window bg + border
    dl->AddRectFilled(wp, ImVec2(wp.x+ws.x, wp.y+ws.y), UI_WIN_BG, UI_WIN_RAD);
    dl->AddRect(wp, ImVec2(wp.x+ws.x, wp.y+ws.y), UI_WIN_BORDER, UI_WIN_RAD, 0, 1.0f);

    // ── HEADER ───────────────────────────────────────────────────────────────
    {
        dl->AddRectFilled(wp, ImVec2(wp.x+ws.x, wp.y+UI_HEADER_H),
                          UI_HEADER_BG, UI_WIN_RAD, ImDrawFlags_RoundCornersTop);
        dl->AddLine(ImVec2(wp.x, wp.y+UI_HEADER_H),
                    ImVec2(wp.x+ws.x, wp.y+UI_HEADER_H), UI_WIN_BORDER, 1.0f);

        // orange left accent pill
        dl->AddRectFilled(ImVec2(wp.x+14.0f, wp.y+14.0f),
                          ImVec2(wp.x+18.0f, wp.y+UI_HEADER_H-14.0f),
                          UI_ORANGE, 2.0f);

        float hCY = wp.y + UI_HEADER_H * 0.5f;

        const char* ttl = "ECX PANEL";
        ImVec2 tts = ImGui::CalcTextSize(ttl);
        dl->AddText(ImVec2(wp.x + 26.0f, hCY - tts.y * 0.5f), UI_ORANGE, ttl);

        const char* ver = "v1.0";
        ImVec2 vts2 = ImGui::CalcTextSize(ver);
        dl->AddText(ImVec2(wp.x + 26.0f + tts.x + 8.0f, hCY - vts2.y * 0.5f + 1.0f),
                    UI_TEXT_DIM, ver);

        // ✕ close button
        float xR  = 14.0f;
        float xCX = wp.x + ws.x - xR - 14.0f;
        dl->AddCircleFilled(ImVec2(xCX, hCY), xR, IM_COL32(32,32,40,255), 20);
        float xs = 4.5f;
        dl->AddLine(ImVec2(xCX-xs, hCY-xs), ImVec2(xCX+xs, hCY+xs), UI_TEXT, 1.8f);
        dl->AddLine(ImVec2(xCX+xs, hCY-xs), ImVec2(xCX-xs, hCY+xs), UI_TEXT, 1.8f);
        ImGui::SetCursorScreenPos(ImVec2(xCX-xR, hCY-xR));
        if (ImGui::InvisibleButton("##zxX", ImVec2(xR*2, xR*2))) MenDeal = false;
    }

    // ── ZONES ────────────────────────────────────────────────────────────────
    float zY0 = wp.y + UI_HEADER_H;
    float zY1 = wp.y + ws.y - UI_STATUS_H;
    float zH  = zY1 - zY0;

    dl->AddLine(ImVec2(wp.x + UI_SIDEBAR_W, zY0),
                ImVec2(wp.x + UI_SIDEBAR_W, zY1), UI_SIDEBAR_LINE, 1.0f);
    dl->AddLine(ImVec2(wp.x, zY1), ImVec2(wp.x+ws.x, zY1), UI_WIN_BORDER, 1.0f);

    // ── SIDEBAR TABS ─────────────────────────────────────────────────────────
    static const char* kTabNames[] = { "ESP", "AIM", "MISC", "SET", "INFO" };
    static const int   kTabCount   = 5;

    float totalTH = (float)kTabCount * UI_TAB_H + (float)(kTabCount-1) * UI_TAB_GAP;
    float tabSY   = zY0 + (zH - totalTH) * 0.5f;
    if (tabSY < zY0 + 4.0f) tabSY = zY0 + 4.0f;

    for (int i = 0; i < kTabCount; ++i) {
        float tY0 = tabSY + (float)i * (UI_TAB_H + UI_TAB_GAP);
        float tY1 = tY0 + UI_TAB_H;
        float tX0 = wp.x + 4.0f;
        float tX1 = wp.x + UI_SIDEBAR_W - 4.0f;
        bool  act  = (ZX_Tab == i);

        if (act) dl->AddRectFilled(ImVec2(tX0, tY0), ImVec2(tX1, tY1), UI_TAB_ACTIVE, 8.0f);
        if (act) dl->AddRectFilled(ImVec2(tX0, tY0+6.0f), ImVec2(tX0+3.0f, tY1-6.0f), UI_TAB_BAR, 2.0f);

        float midX = (tX0 + tX1) * 0.5f;
        float midY = (tY0 + tY1) * 0.5f;
        ImU32 ic = act ? UI_TAB_TXT_ON : UI_TAB_TXT_OFF;

        UI_DrawTabIcon(dl, i, ImVec2(midX, midY - 11.0f), 16.0f, ic);

        ImVec2 nts = ImGui::CalcTextSize(kTabNames[i]);
        dl->AddText(ImVec2(midX - nts.x * 0.5f, midY + 5.0f), ic, kTabNames[i]);

        ImGui::SetCursorScreenPos(ImVec2(tX0, tY0));
        char bid[16]; snprintf(bid, sizeof(bid), "##zt%d", i);
        if (ImGui::InvisibleButton(bid, ImVec2(tX1-tX0, UI_TAB_H))) ZX_Tab = i;
    }

    // ── CONTENT AREA ─────────────────────────────────────────────────────────
    float rcX = wp.x + UI_SIDEBAR_W;
    float rcW = ws.x - UI_SIDEBAR_W;

    ImGui::SetCursorScreenPos(ImVec2(rcX, zY0));
    ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(16/255.f, 16/255.f, 20/255.f, 1.f));
    ImGui::BeginChild("##zx_rc", ImVec2(rcW, zH), false,
                      ImGuiWindowFlags_AlwaysVerticalScrollbar);
    ImGui::SetWindowFontScale(UI_FSCALE);

    switch (ZX_Tab) {

        // ────────────────── TAB 0: ESP ───────────────────────────────────────
        case 0: {
            UI_Section("ESP");
            UI_Toggle("Enable ESP",   &Vars.Enable);
            UI_Toggle("Line ESP",     &Vars.lines);
            UI_Toggle("Box ESP",      &Vars.Box);
            UI_Toggle("3D Box",       &ZX_Esp3DBox);
            UI_Toggle("Health Bar",   &Vars.Health);
            UI_Toggle("Name",         &Vars.Name);
            UI_Toggle("Distance",     &Vars.Distance);
            UI_Toggle("Skeleton",     &Vars.skeleton);
            UI_Toggle("OOF Arrow",    &Vars.OOF);
            UI_Toggle("Enemy Count",  &Vars.enemycount);

            UI_Section("CAMERA");
            UI_Toggle("Camera Shift", &ZX_CameraLeft);
            if (ZX_CameraLeft) {
                UI_SubToggle("Height Control", &ZX_CameraLeft);
                UI_Slider("Height", &ZX_CameraHeight, 0.0f, 20.0f, "%.1f");
                UI_Slider("Side",   &ZX_CameraSide,  -10.0f, 10.0f, "%.1f");
            }

            UI_Section("EXTRA");
            UI_Toggle("Blue Map",   &ZX_BlueMap);
            UI_Toggle("Map Reveal", &ZX_MapReveal);
            break;
        }

        // ────────────────── TAB 1: AIMBOT ────────────────────────────────────
        case 1: {
            UI_Section("AIMBOT");
            UI_Toggle("Enable Aimbot",  &Vars.Aimbot);
            UI_Toggle("Silent Aim",     &SilentAim);
            UI_Toggle("Auto Fire",      &Vars.AutoFire);
            UI_Toggle("Aim Kill",       &ZX_AimKill);
            UI_Toggle("No Recoil",      &ZX_NoRecoil);
            UI_Toggle("Visible Check",  &Vars.VisibleCheck);
            UI_Toggle("Ignore Knocked", &Vars.IgnoreKnocked);
            {
                static float fovA = 90.0f;
                Vars.AimFov = fovA;
                UI_Slider("FOV",       &fovA,          1.0f, 360.0f, "%.0f");
                UI_Slider("Aim Speed", &Vars.AimSpeed, 1.0f,  50.0f, "%.1f");
            }

            UI_Section("AIMKILL VARIANTS");
            UI_Toggle("UNDERKILL",   &ZX_UnderKill);
            UI_Toggle("AIMKILL v1",  &ZX_AimKillV1);
            UI_Toggle("AIMKILL v2",  &ZX_AimKillV2);
            UI_Toggle("AIMKILL v3",  &ZX_AimKillV3);
            UI_Toggle("AIMKILL v4",  &ZX_AimKillV4);
            UI_Toggle("AIMKILL v5",  &ZX_AimKillV5);

            UI_Section("AI AIM");
            UI_Toggle("AI Player Aim", &ZX_AIPlayerAim);
            UI_Toggle("Fast Switch",   &ZX_FastSwitch);
            break;
        }

        // ────────────────── TAB 2: MISC ──────────────────────────────────────
        case 2: {
            UI_Section("MOVEMENT");
            UI_Toggle("Fly Alt",    &ZX_FlyAlt);
            if (ZX_FlyAlt) UI_Slider("Fly Speed", &ZX_FlySpeed, 1.0f, 30.0f, "%.1f");
            UI_Toggle("Free Fly",   &ZX_FreeFly);
            if (ZX_FreeFly) UI_Slider("FreeFly Speed", &ZX_FreeFlySpeed, 1.0f, 50.0f, "%.1f");
            UI_Toggle("Fly V2",     &ZX_FlyV2);
            if (ZX_FlyV2) UI_Slider("FlyV2 Speed", &ZX_FlyV2Speed, 5.0f, 100.0f, "%.0f");
            UI_Toggle("Dash Fwd",   &ZX_DashForward);
            if (ZX_DashForward) UI_Slider("Dash Dist", &ZX_DashDistance, 10.0f, 500.0f, "%.0f");

            UI_Section("SPEED");
            UI_Toggle("Run",       &ZX_RUN);
            UI_Toggle("Speed x10", &ZX_SpeedX10);
            UI_Toggle("Speed x20", &ZX_SpeedX20);
            UI_Toggle("Speed x50", &ZX_SpeedX50);
            UI_Toggle("Real Speed",&ZX_RealSpeed);
            if (ZX_RealSpeed) UI_Slider("Multiplier", &ZX_SpeedMult, 1.0f, 5.0f, "%.1f");

            UI_Section("TELEPORT");
            UI_Toggle("Mark Teleport",  &ZX_MarkTeleport);
            UI_Toggle("Auto Teleport",  &ZX_AutoTeleport);

            UI_Section("WEAPON");
            UI_Toggle("No Reload",    &ZX_NoReload);
            UI_Toggle("Rapid Fire",   &ZX_RapidFire);
            UI_Toggle("Ammo Fast",    &ZX_AmmoSpeedFast);
            UI_Toggle("Fast Medkit",  &ZX_FastMedkit);
            UI_Toggle("Telekill",     &ZX_Telekill);

            UI_Section("MISC");
            UI_Toggle("Anti-Ban",   &ZX_AntiBan);
            UI_Toggle("Head Only",  &ZX_HeadOnly);
            UI_Toggle("Wall Shoot", &ZX_WallShoot);
            UI_Toggle("Anti Flash", &ZX_AntiFlash);
            UI_Toggle("Zoom Hack",  &ZX_ZoomHack);
            if (ZX_ZoomHack) UI_Slider("Zoom Lv", &ZX_ZoomLevel, 1.0f, 10.0f, "%.1f");
            UI_Toggle("Ghost VIP",  &ZX_GHOSTVIP);
            break;
        }

        // ────────────────── TAB 3: SETTINGS ─────────────────────────────────
        case 3: {
            UI_Section("DISPLAY");
            UI_Toggle("Hide Menu (re-tap MENU)", &ZX_HideModMenu);

            UI_Section("KILL COUNTER");
            {
                char kbuf[32]; snprintf(kbuf, sizeof(kbuf), "%d", ZX_KillCount);
                UI_InfoRow("Kills this session", kbuf, UI_ORANGE);
            }
            // +/- buttons
            {
                ImGuiWindow* cw = ImGui::GetCurrentWindow();
                float aw = ImGui::GetContentRegionAvail().x;
                ImVec2 pos = cw->DC.CursorPos;
                const float BH = 40.0f, BW = (aw - UI_PAD*2 - 10.0f) * 0.5f;
                ImGui::ItemSize(ImVec2(aw, BH + 10.0f), 0.0f);
                ImDrawList* cdl = cw->DrawList;

                // - button
                float mX0=pos.x+UI_PAD, mX1=mX0+BW;
                float mY0=pos.y+6.0f,   mY1=mY0+BH;
                cdl->AddRectFilled(ImVec2(mX0,mY0), ImVec2(mX1,mY1), IM_COL32(50,50,60,255), 10.0f);
                ImVec2 mts = ImGui::CalcTextSize("- KILL");
                cdl->AddText(ImVec2((mX0+mX1)*0.5f-mts.x*0.5f,(mY0+mY1)*0.5f-mts.y*0.5f), UI_TEXT, "- KILL");
                ImGui::SetCursorScreenPos(ImVec2(mX0, mY0));
                if (ImGui::InvisibleButton("##km", ImVec2(BW, BH)) && ZX_KillCount > 0) ZX_KillCount--;

                float pX0=mX1+10.0f, pX1=pX0+BW;
                cdl->AddRectFilled(ImVec2(pX0,mY0), ImVec2(pX1,mY1), IM_COL32(255,95,30,200), 10.0f);
                ImVec2 pts = ImGui::CalcTextSize("+ KILL");
                cdl->AddText(ImVec2((pX0+pX1)*0.5f-pts.x*0.5f,(mY0+mY1)*0.5f-pts.y*0.5f), UI_TEXT, "+ KILL");
                ImGui::SetCursorScreenPos(ImVec2(pX0, mY0));
                if (ImGui::InvisibleButton("##kp", ImVec2(BW, BH))) ZX_KillCount++;

                ImGui::SetCursorScreenPos(ImVec2(pos.x, mY1 + 10.0f));
            }
            break;
        }

        // ────────────────── TAB 4: INFO ──────────────────────────────────────
        case 4: {
            UI_Section("DEVICE");
            {
                // iOS device info
                size_t memSize = 0;
                size_t len = sizeof(memSize);
                sysctlbyname("hw.memsize", &memSize, &len, nullptr, 0);
                char memBuf[32]; snprintf(memBuf, sizeof(memBuf), "%.0f MB", (float)memSize/1048576.0f);
                UI_InfoRow("RAM", memBuf);

                char cpuBuf[64] = "unknown";
                size_t cpuLen = sizeof(cpuBuf);
                sysctlbyname("hw.machine", cpuBuf, &cpuLen, nullptr, 0);
                UI_InfoRow("Device", cpuBuf);
            }

            UI_Section("STATUS");
            UI_InfoRow("Hooks",   "Active", UI_GREEN);
            UI_InfoRow("Version", "1.0.0",  UI_TEXT_DIM);
            break;
        }
    }

    ImGui::EndChild();
    ImGui::PopStyleColor(); // ChildBg

    // ── STATUS BAR ───────────────────────────────────────────────────────────
    {
        float cy = zY1 + UI_STATUS_H * 0.5f;
        const char* disc = "ECX v1.0 — for educational purposes only";
        ImVec2 dts = ImGui::CalcTextSize(disc);
        dl->AddText(ImVec2(wp.x + UI_PAD, cy - dts.y * 0.5f), UI_TEXT_DIM, disc);

        // animated hooking % indicator
        static float hkPct = 0.0f;
        hkPct += ImGui::GetIO().DeltaTime * 18.0f;
        if (hkPct > 100.0f) hkPct = 0.0f;
        char hkBuf[24]; snprintf(hkBuf, sizeof(hkBuf), "Hooking %d%%", (int)hkPct);
        ImVec2 hts = ImGui::CalcTextSize(hkBuf);
        dl->AddText(ImVec2(wp.x+ws.x-UI_PAD-hts.x, cy-dts.y*0.5f), UI_ORANGE, hkBuf);
    }

    ImGui::End();
    ImGui::PopStyleVar(5);
    ImGui::PopStyleColor(4);
}

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - Hook inits
// (initAutoFireHook / initRealSpeedHook / initAntiBanHook bodies are in Hooks.h)
// Forward declarations satisfy the linker; definitions live alongside their hooks.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
#pragma mark - ImGuiDrawView Implementation
// ─────────────────────────────────────────────────────────────────────────────

@implementation ImGuiDrawView

#pragma mark - Init

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        g_DrawView = self;

        _device       = MTLCreateSystemDefaultDevice();
        _commandQueue = [_device newCommandQueue];
        if (!self.device) abort();

        IMGUI_CHECKVERSION();
        ImGui::CreateContext();
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
        c[ImGuiCol_WindowBg] = ImVec4(0.047f, 0.047f, 0.059f, 1.00f);

        ImGuiIO &io = ImGui::GetIO();
        io.Fonts->AddFontFromMemoryTTF(sansbold, sizeof(sansbold), 18.0f);

        ImGui_ImplMetal_Init(_device);
    }
    return self;
}

+ (void)showChange:(BOOL)open {
    MenDeal = open;
}

#pragma mark - View

- (MTKView *)mtkView {
    return (MTKView *)self.view;
}

- (void)loadView {
    CGFloat w = UIScreen.mainScreen.bounds.size.width;
    CGFloat h = UIScreen.mainScreen.bounds.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor        = UIColor.clearColor;
    self.view.userInteractionEnabled = YES;
    [self createMenuButton];
}

#pragma mark - Menu Button (floating, draggable)

- (void)createMenuButton {
    const CGFloat MW = 68.0f, MH = 34.0f;
    CGSize scr = UIScreen.mainScreen.bounds.size;

    self.menuWindow = [[UIWindow alloc] initWithFrame:
        CGRectMake(20.0f, scr.height * 0.35f, MW, MH)];
    self.menuWindow.backgroundColor     = UIColor.clearColor;
    self.menuWindow.windowLevel         = UIWindowLevelAlert + 100;
    self.menuWindow.hidden              = NO;
    self.menuWindow.userInteractionEnabled = YES;

    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = UIColor.clearColor;
    self.menuWindow.rootViewController = vc;

    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(0, 0, MW, MH);
    self.menuButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.92f];
    self.menuButton.layer.cornerRadius  = MH * 0.5f;
    self.menuButton.layer.masksToBounds = YES;
    [self.menuButton setTitle:@"MENU" forState:UIControlStateNormal];
    [self.menuButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.menuButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];

    [self.menuButton addTarget:self action:@selector(menuButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
        initWithTarget:self action:@selector(menuButtonDragged:)];
    [self.menuButton addGestureRecognizer:pan];

    [self.menuWindow addSubview:self.menuButton];
}

- (void)menuButtonTapped:(UIButton *)btn {
    MenDeal = !MenDeal;
    [btn setTitle:(MenDeal ? @"CLOSE" : @"MENU") forState:UIControlStateNormal];
    UIColor *bg = MenDeal
        ? [UIColor colorWithRed:1.0f green:0.373f blue:0.118f alpha:0.92f]
        : [UIColor colorWithRed:0.0f green:0.0f   blue:0.0f   alpha:0.92f];
    btn.backgroundColor = bg;
}

- (void)menuButtonDragged:(UIPanGestureRecognizer *)pan {
    UIWindow *win = (UIWindow *)pan.view.window;
    CGPoint t     = [pan translationInView:win];
    CGSize scr    = UIScreen.mainScreen.bounds.size;
    CGRect f = win.frame;
    f.origin.x = MAX(0.0f, MIN(scr.width  - f.size.width,  f.origin.x + t.x));
    f.origin.y = MAX(0.0f, MIN(scr.height - f.size.height, f.origin.y + t.y));
    win.frame = f;
    [pan setTranslation:CGPointZero inView:win];
}

#pragma mark - Touch

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint cur = [touch locationInView:self.view];
    CGPoint prv = [touch previousLocationInView:self.view];
    ImGui::GetIO().MouseWheel  = (prv.y - cur.y) / 8.0f;
    ImGui::GetIO().MouseWheelH = (cur.x - prv.x) / 8.0f;
    [self updateIOWithTouchEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView *)view {
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    CGFloat fbScale = view.window.screen.nativeScale ?: UIScreen.mainScreen.nativeScale;
    io.DisplayFramebufferScale = ImVec2(fbScale, fbScale);
    io.DeltaTime = 1.0f / (float)(view.preferredFramesPerSecond ?: 60);

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    [self.view setUserInteractionEnabled:YES];

    MTLRenderPassDescriptor *rpd = view.currentRenderPassDescriptor;
    if (rpd) {
        id<MTLRenderCommandEncoder> enc = [commandBuffer renderCommandEncoderWithDescriptor:rpd];
        [enc pushDebugGroup:@"ImGui"];

        ImGui_ImplMetal_NewFrame(rpd);
        ImGui::NewFrame();

        CGFloat screenW = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
        CGFloat screenH = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
        ImGui::SetNextWindowPos(ImVec2((screenW - 600.0f) * 0.5f, (screenH - 500.0f) * 0.5f), ImGuiCond_FirstUseEver);

        if (MenDeal && !ZX_HideModMenu) { RenderMenu(); }

        ZX_ApplyAndRun();

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

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {}

@end
