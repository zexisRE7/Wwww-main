นี่คือโค้ดตัวเต็ม (Full File) ที่นำโค้ดเดิมของคุณมาปรับแต่ง UI ให้กลายเป็นสไตล์
SamwilXiter Mod (แดง-ดำ, แท็บมน, จัด Layout ใหม่) และ ตัด Emoji ออกทั้งหมด
ตามที่คุณต้องการครับ

คุณสามารถก๊อปปี้ไปวางทับไฟล์เดิมได้เลย:

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

    // ========== SAMWILXITER STYLE SETUP ==========
    ImGuiStyle& style = ImGui::GetStyle();
    
    // ความโค้งมน (Rounding)
    style.WindowRounding = 8.0f;
    style.FrameRounding = 4.0f;
    style.TabRounding = 10.0f;    // แท็บโค้งมนสูงเหมือนในรูป
    style.ScrollbarRounding = 10.0f;
    style.PopupRounding = 6.0f;
    style.GrabRounding = 4.0f;
    
    // ระยะห่างและการจัดวาง
    style.WindowPadding = ImVec2(10.0f, 10.0f);
    style.FramePadding = ImVec2(6.0f, 5.0f);
    style.ItemSpacing = ImVec2(10.0f, 8.0f);
    style.WindowTitleAlign = ImVec2(0.5f, 0.5f); // ชื่อหน้าต่างอยู่ตรงกลาง
    style.WindowBorderSize = 1.0f;

    ImVec4* colors = style.Colors;

    // พื้นหลังดำสนิท
    colors[ImGuiCol_WindowBg]       = ImVec4(0.05f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_TitleBg]        = ImVec4(0.60f, 0.00f, 0.00f, 1.00f); // หัวแดงเข้ม
    colors[ImGuiCol_TitleBgActive]  = ImVec4(0.70f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_Border]         = ImVec4(0.50f, 0.00f, 0.00f, 0.40f);

    // แท็บ (Tabs)
    colors[ImGuiCol_Tab]            = ImVec4(0.30f, 0.00f, 0.00f, 1.00f); // แดงมืด
    colors[ImGuiCol_TabHovered]     = ImVec4(0.85f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_TabActive]      = ImVec4(0.85f, 0.00f, 0.00f, 1.00f); // แดงสว่าง (แท็บที่เลือก)

    // Checkbox & Inputs
    colors[ImGuiCol_FrameBg]        = ImVec4(0.12f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_FrameBgHovered] = ImVec4(0.20f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_FrameBgActive]  = ImVec4(0.30f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_CheckMark]      = ImVec4(0.90f, 0.00f, 0.00f, 1.00f);

    // ปุ่ม
    colors[ImGuiCol_Button]         = ImVec4(0.40f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_ButtonHovered]  = ImVec4(0.60f, 0.00f, 0.00f, 1.00f);
    colors[ImGuiCol_ButtonActive]   = ImVec4(0.80f, 0.00f, 0.00f, 1.00f);
    
    // ข้อความ
    colors[ImGuiCol_Text]           = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);

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
            ImGui::SetNextWindowSize(ImVec2(380, 290), ImGuiCond_FirstUseEver);
            ImGui::Begin(oxorany("SamwilXiter Mod New Update Free Fire"), &MenDeal, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);

            if (ImGui::BeginTabBar(oxorany("##MainTabs"), ImGuiTabBarFlags_None)) {
                
                // ========== TAB 1: ESP ==========
                if (ImGui::BeginTabItem(oxorany("Esp"))) {
                    ImGui::Spacing();
                    
                    // จัด Layout 2 คอลัมน์สำหรับแถวแรกตามรูป
                    ImGui::Columns(2, NULL, false);
                    ImGui::Checkbox(oxorany("Enable Esp"), &Vars.Enable);
                    ImGui::NextColumn();
                    ImGui::Checkbox(oxorany("Stream Mode"), &Vars.OOF);
                    ImGui::Columns(1);
                    
                    ImGui::Separator();
                    ImGui::Spacing();

                    ImGui::Checkbox(oxorany("Esp Line"), &Vars.lines);
                    ImGui::Checkbox(oxorany("Esp Name"), &Vars.Name);
                    ImGui::Checkbox(oxorany("Esp Box"), &Vars.Box);
                    ImGui::Checkbox(oxorany("Esp Skeleton"), &Vars.skeleton);
                    ImGui::Checkbox(oxorany("Esp Vida"), &Vars.Health);
                    
                    ImGui::EndTabItem();
                }
                
                // ========== TAB 2: AIMBOT ==========
                if (ImGui::BeginTabItem(oxorany("Aimbot"))) {
                    ImGui::Spacing();
                    ImGui::Checkbox(oxorany("Enable Aimbot"), &Vars.Aimbot);
                    ImGui::Checkbox(oxorany("SilentAim"), &SilentAim);
                    ImGui::Checkbox(oxorany("Visible Check"), &Vars.VisibleCheck);
                    ImGui::Checkbox(oxorany("Ignore Knocked"), &Vars.IgnoreKnocked); 
                    
                    ImGui::Separator();
                    ImGui::SetNextItemWidth(180);
                    ImGui::Combo(oxorany("Aim Mode"), &Vars.AimMode, Vars.aimModes, 3);
                    ImGui::SetNextItemWidth(180);
                    ImGui::SliderFloat(oxorany("Aim FOV"), &Vars.AimFov, 0.0f, 180.0f, "%.0f");
                    
                    ImGui::EndTabItem();
                }
                
                // ========== TAB 3: MISC ==========
                if (ImGui::BeginTabItem(oxorany("Misc"))) {
                    ImGui::Spacing();
                    ImGui::Checkbox(oxorany("Spin Bot"), &Vars.Box);
                    ImGui::Checkbox(oxorany("Aim Kill"), &Vars.Enable);
                    
                    ImGui::Separator();
                    if (ImGui::Button(oxorany("Fix Login"), ImVec2(-1, 35))) {
                        self.view.hidden = YES; 
                        MenDeal = false; 
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fixLoginTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.view.hidden = NO; 
                            MenDeal = true; 
                        });
                    }
                    ImGui::EndTabItem();
                }
                
                // ========== TAB 4: SETTING ==========
                if (ImGui::BeginTabItem(oxorany("Setting"))) {
                    ImGui::Spacing();
                    ImGui::SliderFloat(oxorany("Transparency"), &ImGui::GetStyle().Alpha, 0.1f, 1.0f, "%.2f");
                    ImGui::SliderFloat(oxorany("Scale Factor"), &fixLoginTimeout, 40.0f, 80.0f, "Fix: %.0f");
                    ImGui::EndTabItem();
                }
                
                ImGui::EndTabBar();
            }
            ImGui::End();
        }
        
        // --- Game Functions ---
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
