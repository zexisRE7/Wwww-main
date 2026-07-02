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
                ImGui::Begin(oxorany("PREMIUM MENU"), &MenDeal, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);
                
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
                    
                    if (ImGui::BeginTabItem(oxorany("Aimbot"))) {
                        ImGui::Spacing();
                        ImGui::Checkbox(oxorany("Enable Aimbot"), &Vars.Aimbot);
                        
                        ImGui::Separator();
                        ImGui::Checkbox(oxorany("Visibility Check"), &Vars.VisibleCheck);
                        ImGui::SameLine();
                        ImGui::Checkbox(oxorany("Ignore Knocked"), &Vars.IgnoreKnocked);
                        
                        ImGui::Text(oxorany("Aimbot Trigger:"));
                        ImGui::SetNextItemWidth(-1);
                        ImGui::Combo(oxorany("##AimTrigger"), &Vars.AimWhen, Vars.dir, 4);
                        
                        ImGui::Text(oxorany("Target Bone:"));
                        ImGui::SetNextItemWidth(-1);
                        ImGui::Combo(oxorany("##AimBone"), &Vars.AimHitbox, Vars.aimHitboxes, 3);
                        
                        ImGui::Text(oxorany("Aimbot Mode:"));
                        ImGui::SetNextItemWidth(-1);
                        ImGui::Combo(oxorany("##AimMode"), &Vars.AimMode, Vars.aimModes, 3);
                        
                        if (Vars.AimMode == 2) {
                            ImGui::Text(oxorany("Field of View:"));
                            ImGui::SliderFloat(oxorany("##Fov"), &Vars.AimFov, 0.0f, 360.0f, "%.0f°");
                        }
                        
                        ImGui::EndTabItem();
                    }
                    
                    if (ImGui::BeginTabItem(oxorany("Extra"))) {
                          ImGui::Spacing();
                          ImGui::TextColored(ImVec4(0.90f,0.25f,0.50f,1.0f), oxorany("Movement Hacks"));
                          ImGui::Separator();
                          if (ImGui::BeginTable("ExtraTable", 2)) {
                              ImGui::TableNextColumn();
                              ImGui::Checkbox(oxorany("Fly Alt"), &Vars.FlyAlt);
                              ImGui::TableNextColumn();
                              ImGui::Checkbox(oxorany("Stop Move"), &Vars.StopMove);
                              ImGui::TableNextColumn();
                              ImGui::Checkbox(oxorany("XMove"), &Vars.XMove);
                              ImGui::EndTable();
                          }
                          if (Vars.FlyAlt) {
                              ImGui::Text(oxorany("Fly Speed:"));
                              ImGui::SetNextItemWidth(-1);
                              ImGui::SliderFloat(oxorany("##FlySpeed"), &Vars.FlyAltSpeed, 1.0f, 30.0f, "%.1f");
                          }
                          if (Vars.XMove) {
                              ImGui::Text(oxorany("XMove Power:"));
                              ImGui::SetNextItemWidth(-1);
                              ImGui::SliderFloat(oxorany("##XMoveMult"), &Vars.XMoveMult, 1.0f, 20.0f, "%.0fx");
                          }
                          ImGui::Spacing();
                          ImGui::TextColored(ImVec4(0.65f,0.65f,0.65f,1.0f), oxorany("FlyAlt: Jump to fly up"));
                          ImGui::TextColored(ImVec4(0.65f,0.65f,0.65f,1.0f), oxorany("StopMove: Freeze position"));
                          ImGui::TextColored(ImVec4(0.65f,0.65f,0.65f,1.0f), oxorany("XMove: Massive damage"));
                          ImGui::EndTabItem();
                      }
                                          if (ImGui::BeginTabItem(oxorany("Settings"))) {
                        ImGui::Spacing();
                        ImGui::Text(oxorany("Login Fix Utility"));
                        if (ImGui::Button(oxorany("Apply Login Fix"), ImVec2(-1, 30))) {
                            self.view.hidden = YES; 
                            MenDeal = false; 
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fixLoginTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                self.view.hidden = NO; 
                                MenDeal = true; 
                            });
                        }
                        
                        ImGui::Text(oxorany("Fix Timeout (Seconds):"));
                        ImGui::SliderFloat(oxorany("##fixlogin"), &fixLoginTimeout, 40.0f, 80.0f, "%.0fs");
                        
                        ImGui::Separator();
                        ImGui::TextColored(ImVec4(0.28f, 0.56f, 1.00f, 1.00f), oxorany("Developer Info:"));
                        ImGui::Text(oxorany("Telegram: @THEBRAZILI"));
                        
                        ImGui::EndTabItem();
                    }
                    ImGui::EndTabBar();
                }
                ImGui::End();
            }
            
            ImDrawList* draw_list = ImGui::GetBackgroundDrawList();

              // ── Sakura Petal Particle System ─────────────────────────────
              struct SakuraPetal { float x,y,vx,vy,angle,angVel,alpha,size,life,maxLife; };
              static std::vector<SakuraPetal> s_petals;
              static float s_spawnT = 0.0f;
              float pdt = io.DeltaTime, pW = io.DisplaySize.x, pH = io.DisplaySize.y;
              s_spawnT += pdt;
              if (s_spawnT > 0.06f && (int)s_petals.size() < 120) {
                  s_spawnT = 0.0f;
                  for (int si = 0; si < 2; si++) {
                      SakuraPetal p;
                      p.x=((float)rand()/RAND_MAX)*pW; p.y=-12.f;
                      p.vx=(((float)rand()/RAND_MAX)-.5f)*50.f;
                      p.vy=35.f+((float)rand()/RAND_MAX)*55.f;
                      p.angle=((float)rand()/RAND_MAX)*6.28318f;
                      p.angVel=(((float)rand()/RAND_MAX)-.5f)*3.f;
                      p.alpha=.55f+((float)rand()/RAND_MAX)*.45f;
                      p.size=4.5f+((float)rand()/RAND_MAX)*6.f;
                      p.maxLife=p.life=5.5f+((float)rand()/RAND_MAX)*4.f;
                      s_petals.push_back(p);
                  }
              }
              for (auto it=s_petals.begin(); it!=s_petals.end(); ) {
                  it->x+=(it->vx+sinf(it->angle*2.f)*15.f)*pdt;
                  it->y+=it->vy*pdt; it->angle+=it->angVel*pdt; it->life-=pdt;
                  if (it->life<=0.f||it->y>pH+20.f){it=s_petals.erase(it);continue;}
                  float fade=it->alpha*(it->life/it->maxLife), s=it->size, ang=it->angle;
                  ImVec2 pc(it->x,it->y);
                  for (int k=0;k<5;k++) {
                      float pa=ang+k*1.25664f;
                      draw_list->AddCircleFilled(ImVec2(pc.x+cosf(pa)*s*.55f, pc.y+sinf(pa)*s*.55f),
                          s*.48f, ImColor(1.f,.68f+(float)(k&1)*.08f,.80f,fade), 7);
                  }
                  draw_list->AddCircleFilled(pc,s*.28f,ImColor(1.f,.90f,.70f,fade*.9f),6);
                  ++it;
              }
              // ─────────────────────────────────────────────────────────────

              get_players();
            draw_watermark();
            aimbot();
            game_sdk->init();
            
            Vars.isAimFov = (Vars.AimFov > 0);
            
            ImGui::Render();
            ImDrawData* draw_data = ImGui::GetDrawData();
            ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
          
            [renderEncoder popDebugGroup];
            [renderEncoder endEncoding];

            [commandBuffer presentDrawable:view.currentDrawable];
        }

        [commandBuffer commit];
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
}

@end
