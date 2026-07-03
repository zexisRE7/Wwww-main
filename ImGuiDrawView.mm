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
#include <stdint.h>
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

    // --- Sakura Theme ---
      auto& Style = ImGui::GetStyle();
      Style.WindowPadding     = ImVec2(14, 14);
      Style.WindowRounding    = 12.0f;
      Style.FramePadding      = ImVec2(6, 4);
      Style.FrameRounding     = 8.0f;
      Style.ItemSpacing       = ImVec2(10, 7);
      Style.ItemInnerSpacing  = ImVec2(6, 5);
      Style.IndentSpacing     = 20.0f;
      Style.ScrollbarSize     = 10.0f;
      Style.ScrollbarRounding = 8.0f;
      Style.GrabMinSize       = 6.0f;
      Style.GrabRounding      = 6.0f;
      Style.WindowTitleAlign  = ImVec2(0.5f, 0.5f);
      Style.WindowBorderSize  = 1.0f;

      ImVec4* colors = Style.Colors;
      colors[ImGuiCol_Text]                  = ImVec4(0.25f, 0.05f, 0.12f, 1.00f);
      colors[ImGuiCol_TextDisabled]          = ImVec4(0.75f, 0.55f, 0.62f, 1.00f);
      colors[ImGuiCol_WindowBg]              = ImVec4(1.00f, 0.97f, 0.98f, 0.15f);
      colors[ImGuiCol_ChildBg]               = ImVec4(1.00f, 0.93f, 0.96f, 0.10f);
      colors[ImGuiCol_PopupBg]               = ImVec4(1.00f, 0.95f, 0.97f, 0.92f);
      colors[ImGuiCol_Border]                = ImVec4(1.00f, 0.60f, 0.75f, 0.60f);
      colors[ImGuiCol_BorderShadow]          = ImVec4(1.00f, 0.60f, 0.75f, 0.00f);
      colors[ImGuiCol_FrameBg]               = ImVec4(1.00f, 0.88f, 0.92f, 0.55f);
      colors[ImGuiCol_FrameBgHovered]        = ImVec4(1.00f, 0.75f, 0.85f, 0.70f);
      colors[ImGuiCol_FrameBgActive]         = ImVec4(1.00f, 0.60f, 0.75f, 0.85f);
      colors[ImGuiCol_TitleBg]               = ImVec4(1.00f, 0.80f, 0.88f, 0.40f);
      colors[ImGuiCol_TitleBgActive]         = ImVec4(1.00f, 0.65f, 0.78f, 0.60f);
      colors[ImGuiCol_TitleBgCollapsed]      = ImVec4(1.00f, 0.85f, 0.90f, 0.20f);
      colors[ImGuiCol_MenuBarBg]             = ImVec4(1.00f, 0.88f, 0.92f, 0.30f);
      colors[ImGuiCol_ScrollbarBg]           = ImVec4(1.00f, 0.90f, 0.94f, 0.20f);
      colors[ImGuiCol_ScrollbarGrab]         = ImVec4(1.00f, 0.60f, 0.75f, 0.60f);
      colors[ImGuiCol_ScrollbarGrabHovered]  = ImVec4(1.00f, 0.50f, 0.68f, 0.80f);
      colors[ImGuiCol_ScrollbarGrabActive]   = ImVec4(0.90f, 0.30f, 0.55f, 1.00f);
      colors[ImGuiCol_CheckMark]             = ImVec4(0.90f, 0.20f, 0.45f, 1.00f);
      colors[ImGuiCol_SliderGrab]            = ImVec4(1.00f, 0.55f, 0.72f, 1.00f);
      colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.90f, 0.25f, 0.50f, 1.00f);
      colors[ImGuiCol_Button]                = ImVec4(1.00f, 0.72f, 0.82f, 0.55f);
      colors[ImGuiCol_ButtonHovered]         = ImVec4(1.00f, 0.55f, 0.72f, 0.85f);
      colors[ImGuiCol_ButtonActive]          = ImVec4(0.90f, 0.25f, 0.50f, 1.00f);
      colors[ImGuiCol_Header]                = ImVec4(1.00f, 0.72f, 0.82f, 0.45f);
      colors[ImGuiCol_HeaderHovered]         = ImVec4(1.00f, 0.55f, 0.72f, 0.70f);
      colors[ImGuiCol_HeaderActive]          = ImVec4(0.90f, 0.30f, 0.55f, 1.00f);
      colors[ImGuiCol_Separator]             = ImVec4(1.00f, 0.65f, 0.78f, 0.50f);
      colors[ImGuiCol_SeparatorHovered]      = ImVec4(1.00f, 0.45f, 0.65f, 0.80f);
      colors[ImGuiCol_SeparatorActive]       = ImVec4(0.90f, 0.25f, 0.50f, 1.00f);
      colors[ImGuiCol_ResizeGrip]            = ImVec4(1.00f, 0.60f, 0.75f, 0.30f);
      colors[ImGuiCol_ResizeGripHovered]     = ImVec4(1.00f, 0.50f, 0.68f, 0.70f);
      colors[ImGuiCol_ResizeGripActive]      = ImVec4(0.90f, 0.25f, 0.50f, 0.95f);
      colors[ImGuiCol_Tab]                   = ImVec4(1.00f, 0.85f, 0.90f, 0.35f);
      colors[ImGuiCol_TabHovered]            = ImVec4(1.00f, 0.60f, 0.75f, 0.75f);
      colors[ImGuiCol_TabActive]             = ImVec4(1.00f, 0.55f, 0.72f, 0.90f);
      colors[ImGuiCol_TabUnfocused]          = ImVec4(1.00f, 0.88f, 0.92f, 0.25f);
      colors[ImGuiCol_TabUnfocusedActive]    = ImVec4(1.00f, 0.75f, 0.84f, 0.55f);
      colors[ImGuiCol_PlotLines]             = ImVec4(1.00f, 0.55f, 0.72f, 1.00f);
      colors[ImGuiCol_PlotLinesHovered]      = ImVec4(0.90f, 0.20f, 0.45f, 1.00f);
      colors[ImGuiCol_PlotHistogram]         = ImVec4(1.00f, 0.60f, 0.75f, 1.00f);
      colors[ImGuiCol_PlotHistogramHovered]  = ImVec4(0.90f, 0.25f, 0.50f, 1.00f);
      colors[ImGuiCol_TextSelectedBg]        = ImVec4(1.00f, 0.60f, 0.75f, 0.40f);
      colors[ImGuiCol_DragDropTarget]        = ImVec4(1.00f, 0.40f, 0.65f, 0.90f);
      colors[ImGuiCol_NavHighlight]          = ImVec4(1.00f, 0.55f, 0.72f, 1.00f);
      colors[ImGuiCol_NavWindowingHighlight] = ImVec4(1.00f, 0.80f, 0.88f, 0.70f);
      colors[ImGuiCol_NavWindowingDimBg]     = ImVec4(1.00f, 0.85f, 0.90f, 0.20f);
      colors[ImGuiCol_ModalWindowDimBg]      = ImVec4(1.00f, 0.75f, 0.84f, 0.35f);

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
    self.view = [[MTKView alloc] initWithFrame:[UIScreen mainScreen].bounds device:_device];
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor clearColor];
    self.mtkView.layer.opaque = NO;
}

- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    ImGuiIO& io = ImGui::GetIO();
    UITouch *anyTouch = [event.allTouches anyObject];
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

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
        
        if (MenDeal == true) 
        {
            [self.view setUserInteractionEnabled:YES];
        } 
        else 
        {
            [self.view setUserInteractionEnabled:NO];
        }

        MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
        if (renderPassDescriptor != nil)
        {
            id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
            [renderEncoder pushDebugGroup:@"ImGui Jane"];

            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui::NewFrame();
            
            CGFloat x = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width) - 400) / 2;
            CGFloat y = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height) - 300) / 2;
            ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
            ImGui::SetNextWindowSize(ImVec2(400, 320), ImGuiCond_FirstUseEver);
            
            if (MenDeal == true)
            {                
                ImGui::Begin(oxorany("FluckMenu | OB54")), &MenDeal, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);
                
                if (ImGui::BeginTabBar(oxorany("MainTabs"), ImGuiTabBarFlags_None)) {
                    
                    if (ImGui::BeginTabItem(oxorany("Visuals"))) {
                        ImGui::Spacing();
                        ImGui::Checkbox(oxorany("Enable Visuals"), &Vars.Enable);
                        ImGui::Separator();
                        
                        if (ImGui::BeginTable("VisualsTable", 2))
                        {
                            ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Line ESP"), &Vars.lines);
                            ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Box ESP"), &Vars.Box);
                            ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Health Bar"), &Vars.Health);
                            ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Player Name"), &Vars.Name);
                            ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Skeleton"), &Vars.skeleton);
                            ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Distance"), &Vars.Distance);
                            ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("3D Circle"), &Vars.circlepos);
                            ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Outline"), &Vars.Outline);
                            ImGui::EndTable();
                        }
                        
                        ImGui::Separator();
                        ImGui::Checkbox(oxorany("Out of Screen Indicator"), &Vars.OOF);
                        ImGui::SameLine();
                        ImGui::Checkbox(oxorany("Enemy Count"), &Vars.enemycount);
                        
                        ImGui::EndTabItem();
                    }
                    
                    
                      if (ImGui::BeginTabItem(oxorany("Extra"))) {
                          ImGui::Spacing();

                          // ── 🌸 FLY HACKS ─────────────────────────────────────────
                          ImGui::TextColored(ImVec4(0.90f,0.25f,0.50f,1.0f), oxorany("✈  Fly Hacks"));
                          ImGui::Separator();
                          ImGui::Checkbox(oxorany("Fly Alt"), &Vars.FlyAlt);
                          ImGui::SameLine();
                          ImGui::Checkbox(oxorany("Fly Untra (Noclip)"), &Vars.FlyUntra);
                          if (Vars.FlyAlt) {
                              ImGui::Text(oxorany("Fly Alt Speed:"));
                              ImGui::SetNextItemWidth(-1);
                              ImGui::SliderFloat(oxorany("##FlyAltSpd"), &Vars.FlyAltSpeed, 1.0f, 30.0f, "%.1f");
                          }
                          if (Vars.FlyUntra) {
                              ImGui::Text(oxorany("Noclip Speed:"));
                              ImGui::SetNextItemWidth(-1);
                              ImGui::SliderFloat(oxorany("##FlyUntraSpd"), &Vars.FlyUntraSpeed, 1.0f, 40.0f, "%.1f");
                          }

                          ImGui::Spacing();
                          // ── 🌸 MOVEMENT ──────────────────────────────────────────
                          ImGui::TextColored(ImVec4(0.90f,0.25f,0.50f,1.0f), oxorany("🏃  Movement"));
                          ImGui::Separator();
                          ImGui::Checkbox(oxorany("Stop Move"), &Vars.StopMove);
                          ImGui::SameLine();
                          ImGui::Checkbox(oxorany("Speed Holizon"), &Vars.SpeedHolizon);
                          if (Vars.SpeedHolizon) {
                              ImGui::Text(oxorany("Slow Factor (0=stop, 1=normal):"));
                              ImGui::SetNextItemWidth(-1);
                              ImGui::SliderFloat(oxorany("##SpeedHolizonMult"), &Vars.SpeedHolizonMult, 0.01f, 1.0f, "%.2f");
                          }

                          ImGui::Spacing();
                          // ── 🌸 UNDERKILL ─────────────────────────────────────────
                          ImGui::TextColored(ImVec4(0.90f,0.25f,0.50f,1.0f), oxorany("⬇  UnderKill"));
                          ImGui::Separator();
                          ImGui::Checkbox(oxorany("UnderKill (Go Underground)"), &Vars.UnderKill);
                          if (Vars.UnderKill) {
                              ImGui::Text(oxorany("Depth (meters):"));
                              ImGui::SetNextItemWidth(-1);
                              ImGui::SliderFloat(oxorany("##UnderKillDepth"), &Vars.UnderKillDepth, 0.5f, 20.0f, "%.1fm");
                          }

                          ImGui::Spacing();
                          // ── 🌸 ATTACK ────────────────────────────────────────────
                          ImGui::TextColored(ImVec4(0.90f,0.25f,0.50f,1.0f), oxorany("⚔  Attack"));
                          ImGui::Separator();
                          ImGui::Checkbox(oxorany("XMove (High DMG)"), &Vars.XMove);
                          ImGui::SameLine();
                          ImGui::Checkbox(oxorany("UpPlayer (Lift Enemy)"), &Vars.UpPlayer);
                          if (Vars.XMove) {
                              ImGui::Text(oxorany("XMove Power:"));
                              ImGui::SetNextItemWidth(-1);
                              ImGui::SliderFloat(oxorany("##XMoveMult"), &Vars.XMoveMult, 1.0f, 20.0f, "%.0fx");
                          }
                          if (Vars.UpPlayer) {
                              ImGui::Text(oxorany("Lift Speed:"));
                              ImGui::SetNextItemWidth(-1);
                              ImGui::SliderFloat(oxorany("##UpPlayerSpd"), &Vars.UpPlayerSpeed, 5.0f, 60.0f, "%.1f");
                          }
                          ImGui::Checkbox(oxorany("AimKill Send (Bypass Patch)"), &Vars.AimKillSend);
                          if (Vars.AimKillSend) {
                              ImGui::SameLine();
                              ImGui::TextColored(ImVec4(0.20f,0.80f,0.30f,1.0f), oxorany(" ✓ ACTIVE"));
                          }
