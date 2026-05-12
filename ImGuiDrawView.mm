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

    // ========== DARK GRAY MONOCHROME THEME (โปร่งใสสุด) ==========
    ImGuiStyle& style = ImGui::GetStyle();
    style.WindowPadding = ImVec2(10.0f, 10.0f);
    style.FramePadding = ImVec2(9.0f, 7.0f);
    style.ScrollbarRounding = 9.0f;
    style.WindowRounding = 14.0f;
    style.FrameRounding = 6.0f;
    style.ChildRounding = 8.0f;
    style.GrabRounding = 4.0f;
    style.PopupRounding = 8.0f;
    style.TabRounding = 6.0f;
    style.WindowBorderSize = 0.5f;
    
    ImVec4* colors = ImGui::GetStyle().Colors;
    
    // ===== พื้นหลังหลัก — โปร่งใสสุด! =====
    colors[ImGuiCol_WindowBg]       = ImVec4(0.04f, 0.04f, 0.06f, 0.75f); // โปร่งแสง เห็นเกมชัด
    colors[ImGuiCol_ChildBg]        = ImVec4(0.03f, 0.03f, 0.04f, 0.60f);
    colors[ImGuiCol_PopupBg]        = ImVec4(0.05f, 0.05f, 0.07f, 0.85f);
    
    // ===== ข้อความ =====
    colors[ImGuiCol_Text]           = ImVec4(0.95f, 0.95f, 0.98f, 1.00f); // ขาวอมเทา
    colors[ImGuiCol_TextDisabled]   = ImVec4(0.55f, 0.55f, 0.60f, 1.00f);
    
    // ===== เส้นขอบและ Separator (เทาจาง) =====
    colors[ImGuiCol_Border]         = ImVec4(0.65f, 0.65f, 0.70f, 0.40f);
    colors[ImGuiCol_Separator]      = ImVec4(0.65f, 0.65f, 0.70f, 0.35f);
    colors[ImGuiCol_SeparatorActive] = ImVec4(0.80f, 0.80f, 0.85f, 0.60f);
    colors[ImGuiCol_SeparatorHovered] = ImVec4(0.75f, 0.75f, 0.80f, 0.50f);
    
    // ===== ปุ่ม (Gray Scale) =====
    colors[ImGuiCol_Button]         = ImVec4(0.30f, 0.30f, 0.35f, 0.65f);
    colors[ImGuiCol_ButtonHovered]  = ImVec4(0.50f, 0.50f, 0.55f, 0.85f);
    colors[ImGuiCol_ButtonActive]   = ImVec4(0.65f, 0.65f, 0.70f, 0.95f);
    
    // ===== Checkmark =====
    colors[ImGuiCol_CheckMark]      = ImVec4(0.80f, 0.80f, 0.85f, 1.00f);
    
    // ===== Slider =====
    colors[ImGuiCol_SliderGrab]     = ImVec4(0.50f, 0.50f, 0.55f, 0.85f);
    colors[ImGuiCol_SliderGrabActive] = ImVec4(0.70f, 0.70f, 0.75f, 1.00f);
    
    // ===== Header (Tab) =====
    colors[ImGuiCol_Header]         = ImVec4(0.25f, 0.25f, 0.30f, 0.60f);
    colors[ImGuiCol_HeaderHovered]  = ImVec4(0.45f, 0.45f, 0.50f, 0.80f);
    colors[ImGuiCol_HeaderActive]   = ImVec4(0.60f, 0.60f, 0.65f, 0.90f);
    
    // ===== Tab =====
    colors[ImGuiCol_Tab]            = ImVec4(0.20f, 0.20f, 0.25f, 0.65f);
    colors[ImGuiCol_TabHovered]     = ImVec4(0.40f, 0.40f, 0.45f, 0.80f);
    colors[ImGuiCol_TabActive]      = ImVec4(0.55f, 0.55f, 0.60f, 0.95f);
    
    // ===== Frame =====
    colors[ImGuiCol_FrameBg]        = ImVec4(0.15f, 0.15f, 0.18f, 0.55f);
    colors[ImGuiCol_FrameBgHovered] = ImVec4(0.25f, 0.25f, 0.30f, 0.70f);
    colors[ImGuiCol_FrameBgActive]  = ImVec4(0.35f, 0.35f, 0.40f, 0.85f);
    
    // ===== Title Bar =====
    colors[ImGuiCol_TitleBg]        = ImVec4(0.20f, 0.20f, 0.25f, 0.70f);
    colors[ImGuiCol_TitleBgActive]  = ImVec4(0.35f, 0.35f, 0.40f, 0.85f);
    
    // ===== Scrollbar =====
    colors[ImGuiCol_ScrollbarBg]    = ImVec4(0.08f, 0.08f, 0.10f, 0.50f);
    colors[ImGuiCol_ScrollbarGrab]  = ImVec4(0.35f, 0.35f, 0.40f, 0.65f);
    colors[ImGuiCol_ScrollbarGrabHovered] = ImVec4(0.50f, 0.50f, 0.55f, 0.80f);
    colors[ImGuiCol_ScrollbarGrabActive] = ImVec4(0.65f, 0.65f, 0.70f, 1.00f);
    
    // ===== Resize Grip =====
    colors[ImGuiCol_ResizeGrip]     = ImVec4(0.35f, 0.35f, 0.40f, 0.50f);
    colors[ImGuiCol_ResizeGripHovered] = ImVec4(0.50f, 0.50f, 0.55f, 0.70f);
    colors[ImGuiCol_ResizeGripActive] = ImVec4(0.70f, 0.70f, 0.75f, 0.90f);
    
    // ===== Modal Dim (พื้นหลังเมนู) =====
    colors[ImGuiCol_ModalWindowDimBg] = ImVec4(0.0f, 0.0f, 0.0f, 0.30f); // จางมาก
    
    // ==========================================================
    
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
        
    [self.view setUserInteractionEnabled:MenDeal];

    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui Jane"];

        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        CGFloat x = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width) - 380) / 2;
        CGFloat y = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height) - 260) / 2;
        ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
        ImGui::SetNextWindowSize(ImVec2(365, 270), ImGuiCond_FirstUseEver);
        
        if (MenDeal == true)
        {                
            ImGui::Begin(oxorany("I AM FROM TAI WAN"), &MenDeal);
            if (ImGui::BeginTabBar(oxorany("Tab"), ImGuiTabBarFlags_FittingPolicyScroll)) {
                if (ImGui::BeginTabItem(("ESP"))) {
                    ImGui::Checkbox(oxorany("Enable Cheats"), &Vars.Enable);
                    if (ImGui::BeginTable("split", 4))
                    {
                        ImGui::TableNextColumn();
                        ImGui::Checkbox(oxorany("Line"), &Vars.lines);
                        ImGui::TableNextColumn();
                        ImGui::Checkbox(oxorany("Box"), &Vars.Box);
                        ImGui::TableNextColumn();
                        ImGui::Checkbox(oxorany("Health"), &Vars.Health);
                        ImGui::TableNextColumn();
                        ImGui::Checkbox(oxorany("Name"), &Vars.Name);
                        ImGui::TableNextColumn();
                        ImGui::Checkbox(oxorany("Skeleton"), &Vars.skeleton);
                        ImGui::TableNextColumn();
                        ImGui::Checkbox(oxorany("Distance"), &Vars.Distance);
                        ImGui::TableNextColumn();
                        ImGui::Checkbox(oxorany("3D Circle"), &Vars.circlepos);
                        ImGui::TableNextColumn();
                        ImGui::Checkbox(oxorany("Outline"), &Vars.Outline);
                    }
                    ImGui::EndTable();
                    ImGui::Checkbox(oxorany("Out of Screen"), &Vars.OOF);
                    ImGui::SameLine();
                    ImGui::Checkbox(oxorany("Enemy Count"), &Vars.enemycount);
                    
                    // Fix Login Button
                    if (ImGui::Button(oxorany("Fix Login"))) {
                        self.view.hidden = YES; 
                        MenDeal = false; 
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fixLoginTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.view.hidden = NO; 
                            MenDeal = true; 
                        });
                    }
                    ImGui::SameLine();
                    ImGui::SetNextItemWidth(100);
                    ImGui::SliderFloat(oxorany("##fixlogin"), &fixLoginTimeout, 40.0f, 80.0f, oxorany("Fix %.0f"));
                    ImGui::Separator();
                    ImGui::EndTabItem();
                }
                if (ImGui::BeginTabItem(("AimBot"))) {
                    ImGui::Spacing();
                    ImGui::Checkbox(oxorany("SilentAim"), &SilentAim);
                    ImGui::Checkbox(oxorany("CheckIsVisible"), &CheckWall1);
                    ImGui::Checkbox("Enable Aimbot", &Vars.Aimbot);
                    ImGui::SameLine();
                    ImGui::Checkbox("Visible", &Vars.VisibleCheck);
                    ImGui::SameLine();
                    ImGui::Checkbox("Knocked", &Vars.IgnoreKnocked); 
                    ImGui::Combo("##1", &Vars.AimWhen, Vars.dir, 4);
                    ImGui::Combo("##2", &Vars.AimHitbox, Vars.aimHitboxes, 3);
                    ImGui::Combo("##3", &Vars.AimMode, Vars.aimModes, 3);
                    if (Vars.AimMode == 2) {
                        ImGui::SliderFloat(oxorany("##Fov"), &Vars.AimFov, 0.0f, 360.0f, oxorany("AimFov %.0f"));
                    }
                    ImGui::EndTabItem();
                }
                if (ImGui::BeginTabItem(("Info Developer"))) {
                    ImGui::TextDisabled("MONALISA");
                    ImGui::TextDisabled("JAY");
                    ImGui::TextDisabled("SIX X86");
                    ImGui::TextDisabled("JIN422");
                    ImGui::TextDisabled("DILET499"); 
                    ImGui::TextDisabled("HOPGX32");
                    ImGui::EndTabItem();
                }
                ImGui::EndTabBar();
            }
            ImGui::End();
        }
        
        ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
        get_players();
        draw_watermark();
        aimbot();
        game_sdk->init();
        
        if (Vars.AimFov > 0) {
            Vars.isAimFov = true;
        } else {
            Vars.isAimFov = false;
        }
        
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
