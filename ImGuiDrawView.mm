// ==================================================================================
// VINRADIN MOD MENU - FULL SOURCE FILE
// ==================================================================================

// Require standard library
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include <iostream>
#include <UIKit/UIKit.h>
#include <vector>
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

// Imgui library
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

// --- Variables ---
static float fixLoginTimeout = 60.0f;
static bool MenDeal = true;

// --- Custom UI Variables ---
static int current_tab = 0;
static bool b_line_fire = false, b_distance = true, b_nearby = true;
static bool b_nofog = false, b_nospread = false, b_instantloot = false, b_icewall = false, b_aspect = false;
static bool b_autofire = false, b_fps = false, b_spinbot = false;
static bool b_streamproof = false;
static int lang_current = 0;
static const char* languages[] = { "English", "Thai", "Spanish" };

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale

// ==================================================================================
// UI HELPER FUNCTIONS (C++ Style)
// ==================================================================================

// ฟังก์ชันวาด Checkbox สี่เหลี่ยมมน (แบบที่เห็นใน Mod Menu Pro)
void DrawCustomCheckbox(const char* label, bool* value) {
    ImGui::BeginGroup();
    ImVec2 p = ImGui::GetCursorScreenPos();
    float width = ImGui::GetContentRegionAvail().x;
    float height = 38.0f; 

    ImDrawList* dl = ImGui::GetWindowDrawList();

    // 1. Row Background (สีดำเทา)
    dl->AddRectFilled(p, ImVec2(p.x + width, p.y + height), IM_COL32(25, 27, 32, 255), 8.0f);

    // 2. Label Text (สีขาวนวล)
    dl->AddText(ImVec2(p.x + 15, p.y + 11), IM_COL32(200, 200, 200, 255), label);

    // 3. Square Checkbox (สีส้มเมื่อเปิด / สีเทาเมื่อปิด)
    ImVec2 cb_pos = ImVec2(p.x + width - 30, p.y + 10);
    ImVec2 cb_size = ImVec2(20, 20);
    ImU32 cb_col = *value ? IM_COL32(255, 85, 0, 255) : IM_COL32(45, 48, 55, 255);
    dl->AddRectFilled(cb_pos, ImVec2(cb_pos.x + cb_size.x, cb_pos.y + cb_size.y), cb_col, 5.0f);

    // Interaction
    ImGui::SetCursorScreenPos(p);
    ImGui::InvisibleButton("##cb", ImVec2(width, height));
    if (ImGui::IsItemClicked()) {
        *value = !(*value);
    }
    ImGui::EndGroup();
    ImGui::Spacing();
}

// ฟังก์ชันวาด Header ของแท็บ (มีสัญลักษณ์และปุ่มควบคุม)
void DrawCustomHeader(const char* symbol, const char* title) {
    ImVec2 p = ImGui::GetCursorScreenPos();
    ImDrawList* dl = ImGui::GetWindowDrawList();
    float width = ImGui::GetContentRegionAvail().x;
    float height = 45.0f;

    // Header Background
    dl->AddRectFilled(p, ImVec2(p.x + width, p.y + height), IM_COL32(15, 17, 22, 255), 8.0f);
    
    // Symbol & Title (สีส้ม)
    dl->AddText(ImVec2(p.x + 15, p.y + 14), IM_COL32(255, 85, 0, 255), symbol);
    dl->AddText(ImVec2(p.x + 45, p.y + 14), IM_COL32(255, 85, 0, 255), title);

    // Top Right Controls (🌙 และ ✕)
    dl->AddText(ImVec2(p.x + width - 55, p.y + 14), IM_COL32(150, 150, 150, 255), "☾");
    dl->AddText(ImVec2(p.x + width - 30, p.y + 14), IM_COL32(150, 150, 150, 255), "✕");

    ImGui::Dummy(ImVec2(0, height));
}

// ==================================================================================
// IMGUI DRAW VIEW IMPLEMENTATION
// ==================================================================================

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@end

@implementation ImGuiDrawView
ImFont *_espFont;
ImFont* verdanab;
ImFont* icons;
ImFont* interb;
ImFont* Urbanist;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    if (!self.device) abort();

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    // ========== VINRADIN GLOBAL STYLE SETUP ==========
    ImGuiStyle& style = ImGui::GetStyle();
    style.WindowRounding = 10.0f;
    style.ChildRounding = 8.0f;
    style.FrameRounding = 6.0f;
    style.GrabRounding = 6.0f;
    style.ItemSpacing = ImVec2(8, 12);
    style.WindowPadding = ImVec2(0, 0);
    style.WindowBorderSize = 0.0f;
    style.FrameBorderSize = 0.0f;

    ImVec4* colors = style.Colors;
    colors[ImGuiCol_WindowBg]       = ImVec4(0.06f, 0.07f, 0.09f, 0.98f);
    colors[ImGuiCol_Border]         = ImVec4(0.0f, 0.0f, 0.0f, 0.0f);
    colors[ImGuiCol_Text]           = ImVec4(0.90f, 0.90f, 0.90f, 1.00f);
    colors[ImGuiCol_Button]         = ImVec4(0.12f, 0.13f, 0.15f, 1.00f);
    colors[ImGuiCol_ButtonHovered]  = ImVec4(0.20f, 0.22f, 0.25f, 1.00f);
    colors[ImGuiCol_ButtonActive]   = ImVec4(1.00f, 0.33f, 0.00f, 1.00f);
    colors[ImGuiCol_FrameBg]        = ImVec4(0.12f, 0.13f, 0.15f, 1.00f);
    colors[ImGuiCol_FrameBgHovered] = ImVec4(0.20f, 0.22f, 0.25f, 1.00f);
    colors[ImGuiCol_FrameBgActive]  = ImVec4(0.12f, 0.13f, 0.15f, 1.00f);
    colors[ImGuiCol_CheckMark]      = ImVec4(1.0f, 1.0f, 1.0f, 1.00f);

    ImFont* font = io.Fonts->AddFontFromMemoryTTF(sansbold, sizeof(sansbold), 15.0f, NULL, io.Fonts->GetGlyphRangesCyrillic());
    verdana_smol = io.Fonts->AddFontFromMemoryTTF(verdana, sizeof verdana, 40, NULL, io.Fonts->GetGlyphRangesCyrillic());
    pixel_big = io.Fonts->AddFontFromMemoryTTF((void*)smallestpixel, sizeof smallestpixel, 128, NULL, io.Fonts->GetGlyphRangesCyrillic());
    pixel_smol = io.Fonts->AddFontFromMemoryTTF((void*)smallestpixel, sizeof smallestpixel, 10*2, NULL, io.Fonts->GetGlyphRangesCyrillic());
    
    ImGui_ImplMetal_Init(_device);

    return self;
}

+ (void)showChange:(BOOL)open
{
    MenDeal = open;
}

- (MTKView *)mtkView
{
    return (MTKView *)self.view;
}

- (void)loadView
{
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
}

- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches)
    {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
        {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }

- (void)drawInMTKView:(MTKView*)view
{
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;

    CGFloat framebufferScale = view.window.screen.nativeScale ?: UIScreen.mainScreen.nativeScale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 60);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    [self.view setUserInteractionEnabled:MenDeal];

    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui Main"];

        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        if (MenDeal)
        {                
            ImGui::SetNextWindowSize(ImVec2(520, 380), ImGuiCond_FirstUseEver);
            ImGui::Begin(oxorany("VINRADIN|MENU"), &MenDeal, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);

            // ==========================================
            // 1. SIDEBAR (Left Panel)
            // ==========================================
            ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.04f, 0.04f, 0.05f, 1.00f));
            ImGui::BeginChild("Sidebar", ImVec2(100, 0), false);
            ImGui::PopStyleColor();
            
            ImGui::SetCursorPosY(20); 
            
            // สัญลักษณ์สไตล์ C++ / Dev แทน Emoji
            const char* tab_names[] = { "Aimbot", "Visuals", "Misc", "Settings", "Account" };
            const char* tab_icons[] = { "[ + ]", "( V )", "[ M ]", "{ S }", "< A >" };
            
            for (int i = 0; i < 5; i++) {
                bool is_selected = (current_tab == i);
                ImGui::PushID(i);
                
                ImVec2 pos = ImGui::GetCursorScreenPos();
                ImVec2 size = ImVec2(100, 70);
                
                ImGui::InvisibleButton("##tab", size);
                if (ImGui::IsItemClicked()) current_tab = i;
                
                ImDrawList* dl = ImGui::GetWindowDrawList();
                
                if (is_selected) {
                    // Highlight background
                    dl->AddRectFilled(ImVec2(pos.x, pos.y), ImVec2(pos.x + size.x, pos.y + size.y), IM_COL32(30, 32, 38, 255), 0.0f);
                    // Right Accent Bar (สีส้ม)
                    dl->AddRectFilled(ImVec2(pos.x + size.x - 3, pos.y + 10), ImVec2(pos.x + size.x, pos.y + size.y - 10), IM_COL32(255, 85, 0, 255), 2.0f);
                }

                ImVec2 text_size = ImGui::CalcTextSize(tab_names[i]);
                ImVec2 icon_size = ImGui::CalcTextSize(tab_icons[i]);
                ImU32 col = is_selected ? IM_COL32(255, 255, 255, 255) : IM_COL32(120, 120, 130, 255);
                
                dl->AddText(ImVec2(pos.x + (size.x - icon_size.x) * 0.5f, pos.y + 15), col, tab_icons[i]);
                dl->AddText(ImVec2(pos.x + (size.x - text_size.x) * 0.5f, pos.y + 40), col, tab_names[i]);

                ImGui::PopID();
            }
            ImGui::EndChild();

            ImGui::SameLine(0, 0);

            // ==========================================================
            // 2. MAIN CONTENT (Right Panel)
            // ==========================================================
            ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(15, 15));
            ImGui::BeginChild("MainContent", ImVec2(0, 0), false, ImGuiWindowFlags_AlwaysUseWindowPadding);
            
            // TAB 0: AIMBOT
            if (current_tab == 0) {
                DrawCustomHeader("[ + ]", "AIMBOT");
                ImGui::Spacing();
                DrawCustomCheckbox("Enable Aimbot", &Vars.Aimbot);
                DrawCustomCheckbox("Silent Aim", &SilentAim);
                DrawCustomCheckbox("Visible Check", &Vars.VisibleCheck);
                DrawCustomCheckbox("Ignore Knocked", &Vars.IgnoreKnocked); 
                
                ImGui::Spacing();
                ImGui::SetNextItemWidth(-1);
                ImGui::Combo("##AimMode", &Vars.AimMode, Vars.aimModes, 3);
                ImGui::SetNextItemWidth(-1);
                ImGui::SliderFloat("##AimFov", &Vars.AimFov, 0.0f, 180.0f, "FOV: %.0f");
            }
            
            // TAB 1: VISUALS
            else if (current_tab == 1) {
                DrawCustomHeader("( V )", "VISUALS");
                ImGui::Spacing();
                DrawCustomCheckbox("Enemy ESP", &Vars.Enable);
                DrawCustomCheckbox("Line ESP", &Vars.lines);
                DrawCustomCheckbox("Line Fire Material", &b_line_fire);
                DrawCustomCheckbox("Box ESP", &Vars.Box);
                DrawCustomCheckbox("Health Bar", &Vars.Health);
                DrawCustomCheckbox("Nickname", &Vars.Name);
                DrawCustomCheckbox("Distance", &b_distance);
                DrawCustomCheckbox("Skeleton", &Vars.skeleton);
                DrawCustomCheckbox("Nearby Count", &b_nearby);
            }
            
            // TAB 2: MISC
            else if (current_tab == 2) {
                DrawCustomHeader("[ M ]", "MISC");
                ImGui::Spacing();
                DrawCustomCheckbox("No Fog", &b_nofog);
                DrawCustomCheckbox("No Spread", &b_nospread);
                DrawCustomCheckbox("Instant Loot", &b_instantloot);
                DrawCustomCheckbox("IceWall Rotation", &b_icewall);
                DrawCustomCheckbox("Aspect Ratio", &b_aspect);
                DrawCustomCheckbox("Auto-Fire", &b_autofire);
                DrawCustomCheckbox("FPS Unlocker", &b_fps);
                DrawCustomCheckbox("Spin Bot", &b_spinbot);
            }
            
            // TAB 3: SETTINGS
            else if (current_tab == 3) {
                DrawCustomHeader("{ S }", "SETTINGS");
                ImGui::Spacing();
                DrawCustomCheckbox("Stream Proof", &b_streamproof);
                ImGui::Spacing();
                ImGui::Text("Select Language");
                ImGui::SetNextItemWidth(-1);
                ImGui::Combo("##lang", &lang_current, languages, IM_ARRAYSIZE(languages));
                ImGui::Spacing();
                
                ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(1.0f, 0.33f, 0.0f, 1.0f));
                if (ImGui::Button("Save Settings", ImVec2(-1, 35))) { /* Save logic */ }
                ImGui::PopStyleColor();
            }

            // TAB 4: ACCOUNT
            else if (current_tab == 4) {
                DrawCustomHeader("< A >", "ACCOUNT");
                ImGui::Spacing();
                ImGui::TextColored(ImVec4(1.0f, 0.3f, 0.0f, 1.0f), "SUBSCRIPTION: PRO");
                ImGui::Text("Expiry: 29 Days, 20 Hours");
                ImGui::Separator();
                ImGui::Text("Build Ver: 1.4.4");
                ImGui::Text("Game Ver: 1.123.X");
                ImGui::Spacing();
                
                ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.15f, 0.16f, 0.20f, 1.0f));
                if (ImGui::Button("Feedback", ImVec2(-1, 35))) { }
                if (ImGui::Button("Logout", ImVec2(-1, 35))) { }
                ImGui::PopStyleColor();
            }

            ImGui::EndChild();
            ImGui::PopStyleVar();
            ImGui::End();
        }
        
        // Game Functions
        ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
        get_players();
        draw_watermark();
        aimbot();
        game_sdk->init();
        
        if (Vars.AimFov > 0) { Vars.isAimFov = true; } else { Vars.isAimFov = false; }
        
        ImGui::Render();
        ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, renderEncoder);
      
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size {}

@end
