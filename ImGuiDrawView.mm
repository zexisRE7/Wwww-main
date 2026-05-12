//Require standard library
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

//Imgui library
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

// --- Custom UI Variables (สำหรับเมนูใหม่) ---
static int current_tab = 3; 
static bool b_line_fire = false, b_distance = true, b_nearby = true;
static bool b_nofog = false, b_nospread = false, b_instantloot = false, b_icewall = false, b_aspect = false;
static bool b_autofire = false, b_fps = false, b_spinbot = false;
static bool b_streamproof = false;
static int lang_current = 0;
static const char* languages[] = { "English", "Thai", "Spanish" };

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale

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

    // ========== SAMWILXITER STYLE SETUP (DARK / ORANGE ACCENT) ==========
    ImGuiStyle& style = ImGui::GetStyle();
    
    // ความโค้งมนตามแบบ UI ในรูป
    style.WindowRounding = 10.0f;
    style.ChildRounding = 8.0f;
    style.FrameRounding = 6.0f;
    style.GrabRounding = 6.0f;
    style.ItemSpacing = ImVec2(8, 12);
    style.WindowPadding = ImVec2(0, 0); // เพื่อให้ Sidebar ชิดขอบพอดี
    style.WindowBorderSize = 0.0f;
    style.FrameBorderSize = 0.0f;

    ImVec4* colors = style.Colors;
    
    // โทนสีหลัก
    ImVec4 color_bg = ImVec4(0.06f, 0.07f, 0.09f, 0.98f);
    ImVec4 color_accent = ImVec4(1.00f, 0.33f, 0.00f, 1.00f); // สีส้ม
    ImVec4 color_frame = ImVec4(0.12f, 0.13f, 0.15f, 1.00f);
    ImVec4 color_frame_hover = ImVec4(0.20f, 0.22f, 0.25f, 1.00f);
    ImVec4 color_text = ImVec4(0.90f, 0.90f, 0.90f, 1.00f);

    colors[ImGuiCol_WindowBg]       = color_bg;
    colors[ImGuiCol_Border]         = ImVec4(0.0f, 0.0f, 0.0f, 0.0f);
    colors[ImGuiCol_Text]           = color_text;
    
    // ปุ่มและช่องกรอกข้อมูล
    colors[ImGuiCol_Button]         = color_frame;
    colors[ImGuiCol_ButtonHovered]  = color_frame_hover;
    colors[ImGuiCol_ButtonActive]   = color_accent;
    colors[ImGuiCol_FrameBg]        = color_frame;
    colors[ImGuiCol_FrameBgHovered] = color_frame_hover;
    colors[ImGuiCol_FrameBgActive]  = color_frame; // ตอนติ๊กจะไปเปลี่ยนสีที่โค้ดแทน
    colors[ImGuiCol_CheckMark]      = ImVec4(1.0f, 1.0f, 1.0f, 1.0f); // ติ๊กถูกสีขาว
    colors[ImGuiCol_SliderGrab]     = color_accent;
    colors[ImGuiCol_SliderGrabActive] = ImVec4(1.0f, 0.45f, 0.1f, 1.0f);

    // Load Fonts
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

#pragma mark - Interaction

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

#pragma mark - MTKViewDelegate

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
            ImVec4 color_accent = ImVec4(1.00f, 0.33f, 0.00f, 1.00f);

            // เซ็ตขนาดเมนู เริ่มต้น 650x420
            ImGui::SetNextWindowSize(ImVec2(650, 420), ImGuiCond_FirstUseEver);
            ImGui::Begin(oxorany("VINRADIN|MENU"), &MenDeal, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);

            // ==========================================
            // SIDEBAR (คอลัมน์ซ้าย)
            // ==========================================
            ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.04f, 0.05f, 0.06f, 1.00f));
            ImGui::BeginChild("Sidebar", ImVec2(110, 0), false);
            ImGui::PopStyleColor();
            
            ImGui::SetCursorPosY(20); 
            
            const char* tab_names[] = { "Aimbot", "Visuals", "Misc", "Settings" };
            const char* tab_icons[] = { "(+)", "(O)", "[_]", "{S}" }; // ไอคอนชั่วคราว
            
            for (int i = 0; i < 4; i++) {
                bool is_selected = (current_tab == i);
                ImGui::PushID(i);
                
                ImVec2 pos = ImGui::GetCursorScreenPos();
                ImVec2 size = ImVec2(110, 75); // ขนาดปุ่มเมนู
                
                if (ImGui::InvisibleButton("##tab", size)) current_tab = i;
                
                ImDrawList* draw_list = ImGui::GetWindowDrawList();
                
                if (is_selected) {
                    draw_list->AddRectFilled(ImVec2(pos.x, pos.y), ImVec2(pos.x + size.x, pos.y + size.y), IM_COL32(20, 22, 26, 255)); // พื้นหลังไฮไลท์
                    draw_list->AddRectFilled(ImVec2(pos.x + size.x - 3, pos.y + 15), ImVec2(pos.x + size.x, pos.y + size.y - 15), IM_COL32(255, 85, 0, 255), 2.0f); // แถบส้ม
                }

                ImVec2 text_size = ImGui::CalcTextSize(tab_names[i]);
                ImVec2 icon_size = ImGui::CalcTextSize(tab_icons[i]);
                ImU32 text_col = is_selected ? IM_COL32(255, 255, 255, 255) : IM_COL32(120, 125, 135, 255);
                
                draw_list->AddText(ImVec2(pos.x + (size.x - icon_size.x) * 0.5f, pos.y + 15), text_col, tab_icons[i]);
                draw_list->AddText(ImVec2(pos.x + (size.x - text_size.x) * 0.5f, pos.y + 40), text_col, tab_names[i]);

                ImGui::PopID();
            }
            ImGui::EndChild();

            ImGui::SameLine(0, 0);

            // ==========================================
            // MAIN CONTENT (คอลัมน์ขวา)
            // ==========================================
            ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(20, 20));
            ImGui::BeginChild("MainContent", ImVec2(0, 0), false, ImGuiWindowFlags_AlwaysUseWindowPadding);
            
            // Helper สำหรับวาด Header และ Checkbox ให้มีสีส้มเมื่อติ๊ก
            auto DrawHeader = [&](const char* icon, const char* title, const char* desc) {
                ImVec2 p = ImGui::GetCursorScreenPos();
                ImDrawList* dl = ImGui::GetWindowDrawList();
                dl->AddRectFilled(p, ImVec2(p.x + ImGui::GetContentRegionAvail().x, p.y + 40), IM_COL32(10, 12, 15, 255), 8.0f);
                dl->AddText(ImVec2(p.x + 15, p.y + 12), IM_COL32(255, 85, 0, 255), icon);
                dl->AddText(ImVec2(p.x + 40, p.y + 12), IM_COL32(255, 85, 0, 255), title);
                dl->AddText(ImVec2(p.x + 115, p.y + 12), IM_COL32(80, 85, 95, 255), "|");
                dl->AddText(ImVec2(p.x + 130, p.y + 12), IM_COL32(150, 155, 165, 255), desc);
                ImGui::Dummy(ImVec2(0, 40));
            };

            auto DrawCheckbox = [&](const char* label, bool* v) {
                ImGui::PushStyleColor(ImGuiCol_FrameBg, *v ? color_accent : ImGui::GetStyle().Colors[ImGuiCol_FrameBg]);
                ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, *v ? ImVec4(1.0f, 0.45f, 0.1f, 1.0f) : ImGui::GetStyle().Colors[ImGuiCol_FrameBgHovered]);
                ImGui::Checkbox(label, v);
                ImGui::PopStyleColor(2);
            };

            // ------------------------------------
            // TAB 0: AIMBOT
            // ------------------------------------
            if (current_tab == 0) {
                DrawHeader("(+)", "AIMBOT", "Aim assist options.");
                ImGui::Spacing();
                
                DrawCheckbox("Enable Aimbot", &Vars.Aimbot);
                DrawCheckbox("SilentAim", &SilentAim);
                DrawCheckbox("Visible Check", &Vars.VisibleCheck);
                DrawCheckbox("Ignore Knocked", &Vars.IgnoreKnocked); 
                
                ImGui::Separator();
                ImGui::SetNextItemWidth(250);
                ImGui::Combo("Aim Mode", &Vars.AimMode, Vars.aimModes, 3);
                ImGui::SetNextItemWidth(250);
                ImGui::SliderFloat("Aim FOV", &Vars.AimFov, 0.0f, 180.0f, "%.0f");
            }
            
            // ------------------------------------
            // TAB 1: VISUALS
            // ------------------------------------
            else if (current_tab == 1) {
                DrawHeader("(O)", "VISUALS", "Visual improvements.");
                ImGui::Spacing();

                DrawCheckbox("Enemy ESP", &Vars.Enable); // ลิ้งค์กับ Vars.Enable ของเดิม
                
                DrawCheckbox("Line", &Vars.lines);
                ImGui::SameLine(ImGui::GetWindowWidth() - 50); ImGui::ColorButton("##linec", ImVec4(1,1,1,1), ImGuiColorEditFlags_NoTooltip | ImGuiColorEditFlags_NoBorder, ImVec2(20,20));

                DrawCheckbox("Line fire material", &b_line_fire);

                DrawCheckbox("Box", &Vars.Box);
                ImGui::SameLine(ImGui::GetWindowWidth() - 75); ImGui::ColorButton("##boxc1", ImVec4(1,0,0,1), ImGuiColorEditFlags_NoTooltip | ImGuiColorEditFlags_NoBorder, ImVec2(20,20));
                ImGui::SameLine(ImGui::GetWindowWidth() - 50); ImGui::ColorButton("##boxc2", ImVec4(0,1,0,1), ImGuiColorEditFlags_NoTooltip | ImGuiColorEditFlags_NoBorder, ImVec2(20,20));

                DrawCheckbox("Health", &Vars.Health);
                DrawCheckbox("Nickname", &Vars.Name);
                DrawCheckbox("Distance", &b_distance);
                
                DrawCheckbox("Skeleton", &Vars.skeleton);
                ImGui::SameLine(ImGui::GetWindowWidth() - 75); ImGui::ColorButton("##skelc1", ImVec4(1,0,0,1), ImGuiColorEditFlags_NoTooltip | ImGuiColorEditFlags_NoBorder, ImVec2(20,20));
                ImGui::SameLine(ImGui::GetWindowWidth() - 50); ImGui::ColorButton("##skelc2", ImVec4(0,1,0,1), ImGuiColorEditFlags_NoTooltip | ImGuiColorEditFlags_NoBorder, ImVec2(20,20));

                ImGui::Separator();

                DrawCheckbox("Nearby enemies count", &b_nearby);

                ImGui::Text("Counter text color");
                ImGui::SameLine(ImGui::GetWindowWidth() - 50); ImGui::ColorButton("##ctc", ImVec4(1,0,0,1), ImGuiColorEditFlags_NoTooltip | ImGuiColorEditFlags_NoBorder, ImVec2(20,20));
                
                ImGui::Text("Counter text size");
                ImGui::SameLine(); ImGui::TextColored(color_accent, "25.0px");
            }
            
            // ------------------------------------
            // TAB 2: MISC
            // ------------------------------------
            else if (current_tab == 2) {
                DrawHeader("[_]", "MISC", "Game enhancements.");
                ImGui::Spacing();
                
                ImGui::Text("These features are only for fun and may be unsafe.");
                ImGui::Text("Use them at your own risk!");
                ImGui::Spacing();

                DrawCheckbox("No fog", &b_nofog);
                DrawCheckbox("No weapon spread", &b_nospread);
                DrawCheckbox("Instant loot", &b_instantloot);
                DrawCheckbox("Inverted IceWall rotation", &b_icewall);
                DrawCheckbox("Aspect ratio", &b_aspect);
                DrawCheckbox("Auto-fire", &b_autofire);
                DrawCheckbox("FPS unlocker", &b_fps);
                DrawCheckbox("Spinbot", &b_spinbot);
            }
            
            // ------------------------------------
            // TAB 3: SETTINGS
            // ------------------------------------
            else if (current_tab == 3) {
                DrawHeader("{S}", "SETTINGS", "Configure options.");
                ImGui::Spacing();
                
                ImGui::Text("3.0 (608315a981a0f73) (null | 7ffffbb3fffffff) (0/0/1) (0|0|0|0|0)");
                
                ImGui::Text("Accent color");
                ImGui::SameLine(ImGui::GetWindowWidth() - 50); 
                ImGui::ColorButton("##accent", color_accent, ImGuiColorEditFlags_NoTooltip | ImGuiColorEditFlags_NoBorder, ImVec2(20,20));

                ImGui::Text("Subscription time left:"); ImGui::SameLine();
                ImGui::TextColored(color_accent, "5 days, 4 hours, 11 seconds");
                
                ImGui::Text("Build at"); ImGui::SameLine(0, 4);
                ImGui::TextColored(color_accent, "Apr 28 2026 19:22:59"); ImGui::SameLine(0, 4);
                ImGui::Text("-"); ImGui::SameLine(0, 4);
                ImGui::TextColored(color_accent, "1.7.5"); ImGui::SameLine(0, 4);
                ImGui::Text("for game version"); ImGui::SameLine(0, 4);
                ImGui::TextColored(color_accent, "1.123.X");

                DrawCheckbox("Streamproof", &b_streamproof);

                ImGui::Spacing();
                ImGui::Text("Language");
                ImGui::SetNextItemWidth(-1); 
                ImGui::Combo("##lang", &lang_current, languages, IM_ARRAYSIZE(languages));
                
                ImGui::Spacing(); ImGui::Spacing();
                
                // ปุ่ม Full width 3 ปุ่ม
                ImGui::PushStyleColor(ImGuiCol_Button, color_accent);
                ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(1.0f, 0.45f, 0.1f, 1.0f));
                ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.8f, 0.25f, 0.0f, 1.0f));
                ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(1,1,1,1));
                
                if (ImGui::Button("Disable silent mode", ImVec2(-1, 35))) { /* Action */ }
                if (ImGui::Button("Save settings", ImVec2(-1, 35))) { /* Action */ }
                if (ImGui::Button("Load settings", ImVec2(-1, 35))) { /* Action */ }
                
                ImGui::PopStyleColor(4);
            }

            ImGui::EndChild(); // End MainContent
            ImGui::PopStyleVar(); // Pop WindowPadding
            ImGui::End();
        }
        
        // --- Game Functions (เอาคอมเมนต์ออกเพื่อให้เกมรันฟังก์ชัน Hack ตามปกติ) ---
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
