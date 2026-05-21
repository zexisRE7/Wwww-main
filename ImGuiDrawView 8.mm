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

// --- Global variables for Floating Button ---
static ImVec2 btnPos = ImVec2(50, 150);
static bool isDragging = false;
static id<MTLTexture> buttonTexture = nil;

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

    ImGui::StyleColorsClassic();
    auto& Style = ImGui::GetStyle();
    Style.WindowPadding = ImVec2(8.0f, 8.0f);
    Style.FramePadding = ImVec2(9.0f, 7.0f);
    Style.ScrollbarRounding = 9.0f;
    
    ImVec4* colors = ImGui::GetStyle().Colors;
    
    // ========== Ã Â¸ÂªÃ Â¸ÂµÃ Â¸ÂÃ Â¸Â³Ã Â¸ÂªÃ Â¸ÂÃ Â¸Â´Ã Â¸ÂÃ Â¸ÂÃ Â¸Â±Ã Â¹ÂÃ Â¸ÂÃ Â¸Â«Ã Â¸Â¡Ã Â¸Â ==========
    colors[ImGuiCol_Text]                   = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    colors[ImGuiCol_WindowBg]               = ImVec4(0.00f, 0.00f, 0.00f, 1.00f); // Ã Â¸ÂÃ Â¸Â³Ã Â¸ÂªÃ Â¸ÂÃ Â¸Â´Ã Â¸Â
    colors[ImGuiCol_ChildBg]                = ImVec4(0.00f, 0.00f, 0.00f, 1.00f); // Ã Â¸ÂÃ Â¸Â³Ã Â¸ÂªÃ Â¸ÂÃ Â¸Â´Ã Â¸Â
    colors[ImGuiCol_PopupBg]                = ImVec4(0.00f, 0.00f, 0.00f, 1.00f); // Ã Â¸ÂÃ Â¸Â³Ã Â¸ÂªÃ Â¸ÂÃ Â¸Â´Ã Â¸Â
    colors[ImGuiCol_TitleBg]                = ImVec4(0.00f, 0.00f, 0.00f, 1.00f); // Ã Â¸ÂÃ Â¸Â³Ã Â¸ÂªÃ Â¸ÂÃ Â¸Â´Ã Â¸Â
    colors[ImGuiCol_TitleBgActive]          = ImVec4(0.00f, 0.47f, 0.81f, 1.00f); 
    colors[ImGuiCol_TitleBgCollapsed]       = ImVec4(0.00f, 0.00f, 0.00f, 1.00f); // Ã Â¸ÂÃ Â¸Â³Ã Â¸ÂªÃ Â¸ÂÃ Â¸Â´Ã Â¸Â
    colors[ImGuiCol_CheckMark]              = ImVec4(0.00f, 0.90f, 1.00f, 1.00f); 
    colors[ImGuiCol_SliderGrab]             = ImVec4(0.00f, 0.70f, 1.00f, 1.00f); 
    colors[ImGuiCol_SliderGrabActive]       = ImVec4(0.00f, 0.50f, 1.00f, 1.00f); 
    
    colors[ImGuiCol_Button]                 = ImVec4(0.00f, 0.47f, 0.81f, 0.40f);
    colors[ImGuiCol_ButtonHovered]          = ImVec4(0.00f, 0.58f, 1.00f, 1.00f); 
    colors[ImGuiCol_ButtonActive]           = ImVec4(0.00f, 0.40f, 0.80f, 1.00f);
    
    colors[ImGuiCol_Header]                 = ImVec4(0.00f, 0.47f, 0.81f, 0.31f); 
    colors[ImGuiCol_HeaderHovered]          = ImVec4(0.00f, 0.58f, 1.00f, 0.80f);
    colors[ImGuiCol_HeaderActive]           = ImVec4(0.00f, 0.47f, 0.81f, 1.00f);
    
    colors[ImGuiCol_SeparatorHovered]       = ImVec4(0.10f, 0.40f, 0.75f, 0.78f);
    colors[ImGuiCol_SeparatorActive]        = ImVec4(0.10f, 0.40f, 0.75f, 1.00f);
    
    colors[ImGuiCol_Tab]                    = ImVec4(0.00f, 0.40f, 0.70f, 0.86f); 
    colors[ImGuiCol_TabHovered]             = ImVec4(0.00f, 0.58f, 1.00f, 0.80f);
    colors[ImGuiCol_TabActive]              = ImVec4(0.00f, 0.47f, 0.81f, 1.00f);

    ImGui::GetStyle().WindowRounding = 8 / 1.5f;
    ImGui::GetStyle().FrameRounding = 4 / 1.5f;
    ImGui::GetStyle().ChildRounding = 6 / 1.5f;
    
    ImFont* font = io.Fonts->AddFontFromMemoryTTF(sansbold, sizeof(sansbold), 15.0f, NULL, io.Fonts->GetGlyphRangesCyrillic());
    verdana_smol = io.Fonts->AddFontFromMemoryTTF(verdana, sizeof verdana, 40, NULL, io.Fonts->GetGlyphRangesCyrillic());
    pixel_big = io.Fonts->AddFontFromMemoryTTF((void*)smallestpixel, sizeof smallestpixel, 128, NULL, io.Fonts->GetGlyphRangesCyrillic());
    pixel_smol = io.Fonts->AddFontFromMemoryTTF((void*)smallestpixel, sizeof smallestpixel, 10*2, NULL, io.Fonts->GetGlyphRangesCyrillic());
    ImGui_ImplMetal_Init(_device);

    [self setupButtonTexture]; // Ã Â¹ÂÃ Â¸Â«Ã Â¸Â¥Ã Â¸ÂÃ Â¸Â£Ã Â¸Â¹Ã Â¸ÂÃ Â¸Â Ã Â¸Â²Ã Â¸ÂÃ Â¸ÂªÃ Â¸Â³Ã Â¸Â«Ã Â¸Â£Ã Â¸Â±Ã Â¸ÂÃ Â¸ÂÃ Â¸Â¸Ã Â¹ÂÃ Â¸Â¡

    return self;
}

// Ã Â¸ÂÃ Â¸Â±Ã Â¸ÂÃ Â¸ÂÃ Â¹ÂÃ Â¸ÂÃ Â¸Â±Ã Â¸ÂÃ Â¹ÂÃ Â¸Â«Ã Â¸Â¥Ã Â¸ÂÃ Â¸Â£Ã Â¸Â¹Ã Â¸ÂÃ Â¸Â Ã Â¸Â²Ã Â¸ÂÃ Â¸ÂÃ Â¸Â²Ã Â¸Â Base64 Ã Â¹ÂÃ Â¸ÂÃ Â¹ÂÃ Â¸Â²Ã Â¸ÂªÃ Â¸Â¹Ã Â¹Â Metal Texture
- (void)setupButtonTexture {
    NSString *base64String = @"/9j/4AAQSkZJRgABAQAAAQABAAD/4SLSRXhpZgAATU0AKgAAAAgABQEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAAITAAMAAAABAAEAAIdpAAQAAAABAAAAWgAAALQAAABIAAAAAQAAAEgAAAABAAeQAAAHAAAABDAyMjGRAQAHAAAABAECAwCgAAAHAAAABDAxMDCgAQADAAAAAQABAACgAgAEAAAAAQAAAiqgAwAEAAAAAQAAAiqkBgADAAAAAQAAAAAAAAAAAAYBAwADAAAAAQAGAAABGgAFAAAAAQAAAQIBGwAFAAAAAQAAAQoBKAADAAAAAQACAAACAQAEAAAAAQAAARICAgAEAAAAAQAAIbYAAAAAAAAASAAAAAEAAABIAAAAAf/Y/9sAhAABAQEBAQECAQECAwICAgMEAwMDAwQFBAQEBAQFBgUFBQUFBQYGBgYGBgYGBwcHBwcHCAgICAgJCQkJCQkJCQkJAQEBAQICAgQCAgQJBgUGCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQn/3QAEAAr/wAARCACgAKADASIAAhEBAxEB/8QBogAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoLEAACAQMDAgQDBQUEBAAAAX0BAgMABBEFEiExQQYTUWEHInEUMoGRoQgjQrHBFVLR8CQzYnKCCQoWFxgZGiUmJygpKjQ1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4eLj5OXm5+jp6vHy8/T19vf4+foBAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKCxEAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4eLj5OXm5+jp6vHy8/T19vf4+foBAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKCxEAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDc8dfAK603Q7e+vrcJ9st3ZMKRkBc4PGD6cV+ZHjHQVsb13Taw3ttAGcY61/RF8RPBXjf4saH4PfXlTSdKkmls7eJAwlOEA8yRvfAG0DFfjN+0L8KW+H/iAqiM9q0vls/fcpIbj0GK+tyrMoSl7O5+f4zLnGHMlofn34gt3xt2KA3buMV5JqyJAhVmXYwx2H1/LHSvrfxn4VFlL58YDAA7fRsdCPp2xXzJ4q06NHNu/wDGRg5HB9v5V9pgMVf3WeJKk0eLag0ULkDaI+o/H0x06Vzlx5JdlfkDop6DjgCur1CxiUugGSOcD+nsK4m5wjE4PTHrya9YyKXlxR7cABm/zz07U9ZnVQUZW5xzjjt0xTFYi1ztLHdjHA+XHtWULu3icRKpLdQvr9KybVzqpxVjtNP04yy7JVyMH0wOnr/nivQrDSbUWoWNTkKA2Oenp/hXk1r4x+yT/ZC4gdnRvoK7rw14z06/u3tbjNuHYcjkBm+nT29q8bHqV7o9zA1IJ8jO7giFtOpYkK/3Rx6enpXuHgK4c7UABiUZP1NeS63p32KK3DHarAEZ/wA9816L8N7uYTIgT+PaFHf0/wA+1fLZjJeyZ9Pg4Pm5T7F0TRi1vHcBFfIBxtB4GOOmO1cZrlrbR3EsgjChvlH+e1e7eHrfy9JWRo/LZV6n7v0x/KvFvGmz7WIQzeXJ8xHv+VfBxrc0mj6yNJKCPJru3twxI5UZyMcj6Dnis5pbeB2WFI/xwOntWB411OTwuUl1CQQqV4DI44/9K+frv45+HIGJMzMyfKAqnt6n/Jr1qeFqVFeKOd16cFqeteK5xCdsgX94A2Ao6V8PfFeWG9nIjTayLjKr7/AMq9E8R/G3Q9XZlsZSFTjLKQeRz6V8869rdnqFySZshzjJPHt+gr3ctwtWGslY8TGV4TVr6Hnjj7PKU3ZRTjaB7dulWLAC6yhyQR0P8AdB5x+hxVW4ZfteI/mCsQcd/8+1WLYJGwiP3jjHsK9py6nj0aHLLU/9D+gjxL4WtT8LtJ1K+jaX+zr6OYtbqCV8s85HoV64r5C/al/ZT8OePIr54QLaPWRutpjzHHcEZVWP8AD5nY9M8HrX6beDLaPU/CEnkL9psruFfPhAI29NxXPQryPpmvLfEMul33hyXwrdoM2KvaOHAwfLbCkZ6qRgj0r5mWLnQlzw3Or2MKkeSSP5R/iL8JdU8KWg0HxREYb6xJgZivB28KRnqCBxXwj8SPClzp7yxKu5VG5HTn5c/5/Kv6B/2qtFkhM+j+L4t80pZrS6H3nCdmOemK/Hj4jaRNphlnmjWbyxtLBfvRngH6/wBa/UOHc4daCmfC5vl0absj839Vs5JziMZ4I9Mj8OnTpXmOpxRRXJifO09hz+GfavpHxZo8dlcMbYZGOBjGPr6Y/lXjV7Z8iUrznp3B7j6cV+iU6nPFNHyMlY5CG0MitEigr1zgf/WqrF4eNxcBd2znGfQe2P0rtrC0W45A8sqQNwA578f54rvtN8PRxTIFTILcgc9AOK5sRieTRHqYHCSloeSP8OIpSGS7Kg/KNq+ntXS2PgKyieO0ld5UdgSy4XOOOw9K97tPDRlRZkjXdgDGeF/D9P0rSbw7HbrmUbnPQKvQ9uRxXgV8xv7sj6TD5Sk1I4XUEuTHbWfVIUK57YBGP0r1j4Y2NxLrEJjI+Rgee3Ht24riL6L5XMoC7sAegx1HFe6/BLQZrzU0YHEYw3A4yPx/yK+fzSqo0pHv4WD57H2RFHENNitcbnMYBUdBxznqOvTivFdcsPM8Qxyzx7kAyc98cYr27WLX7MkTIvRQMD5e3WuA1GJ7lhLgj0AHcV+c08QoybPr1S9zlPif9oLwVN4q1qPUEuNqwD93Ay5jJxnn+Q44r88vGnw28brql3d6XZb4J2J2xkHb07HHT6V+1XiLwmutWB+QbhkgAc9O5r5v1f4fv5zSAMjcDI4HHp/LtX12U504qx42LyfnPyhXwrqelWkkeo27rdP8oDIfk9TnGAa4KXT5IpcZIfcM45P+NfpN4i8I6jc3U029nWP7nH3iex6dK+cPEfgt44TeLGFlDb8gcc9K+lw+YKpueJWylU9z5ru0aM7puGYHd2J9qZYzSyuYUyBnBP8AIYrf8TxmymUzKMY2jj0rkrSZiCUwqrx15x0z/wDWrs5la5yOEufyP//R/pQ+BviC38LaqPDGv3Zb7VKyDeCNjryvUAASZx9Ripvjbomnpqt1LaoI4JFRHK9S2MqSCOhGB+FcBpbaX4p8MxeHzME1HcIN+4J5i8shB6b0bv7gHpx4Z8U/FfxK0S+n07xRObuJW2M2MOuzgB0HcY6187mFC8bo1w1W0uZHxn+0TNcz2P8AZmo2wu7SJ+JSMNHweMkZHHFfin8T0i8LvdwLM00dxjyWZdy4PGOOOK/fDxrc6P478HSz+estz/CBj5SP7w7ivxw+O/gxdJmlSD99s6w4A3Z7pX0/CdflspHzmf0HJ3R+ZfiSyVN5U53H5W+nX+VeH6tZyLK4xwzdAPSvo7xlo0qTTSWbEp1CHgr64H4V5bPowu4lEWTu67cZHuB6V+s4HExjE+AlBp2Z55o04gvNoG1c8+hr2OyZDMGlI3bh1Ge2Og/CvE9Z0u60y53lG2EjDY7D1/wr1HwL4htrsixnbbKnryMHj9K58yh9qJ9Flda0uVntNnETDvYbM4AI9KwdTjH2QkHAjbAY9Pb+ldrp20Qm3yBIOmOvT8wKwfEqSDR5tpAXZlfT07cV8XN+8fexSaPHIbo6hfjTU+Y5BPHC8f8As1ffHwQ0FGmiSOMAt83Hp/8AWHFfFPhvR7e3MOo3BBz97PTngAD9BX3v8MPHeh6FDDIo+dBg+nI5/wD1V4/EWKap8qR6WTYZc/Mz2PxjbvZ2/ncAlB8vAAOfavKI7+KdikZ4B+6MY9NwH9K7bxL41s/EEyW6nKsvP6YwBxivO9Z02XSZobxSVRmCkDpnH+e1fCxT6o+plNI12tFaABsFiOP8jFedeINLihVkjQhQpPr0GOOO+OK9lsk+1KjxL/DjoeRjqPf9Kz9U8NxTuFAbaOvPBbH8xinGtbRF+w5lex8g654ZVdFaFUxJMcgY6f8A6q+cPHnheT+yp1hU4jUbc4Py+w6YFfoNqWiLcW83mDYq9OSCT7Y7V8ueONL3WU5ZTsZWxnjGO35dPp {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:self.device];
            buttonTexture = [loader newTextureWithCGImage:image.CGImage options:nil error:nil];
        }
    }
}

// Ã Â¸ÂÃ Â¸Â±Ã Â¸ÂÃ Â¸ÂÃ Â¹ÂÃ Â¸ÂÃ Â¸Â±Ã Â¸ÂÃ Â¸Â§Ã Â¸Â²Ã Â¸ÂÃ Â¸ÂÃ Â¸Â¸Ã Â¹ÂÃ Â¸Â¡Ã Â¸Â¥Ã Â¸Â­Ã Â¸Â¢Ã Â¸ÂÃ Â¹ÂÃ Â¸Â§Ã Â¸Â¢ ImGui
- (void)drawFloatingButton {
    ImGuiIO& io = ImGui::GetIO();
    ImDrawList* draw_list = ImGui::GetForegroundDrawList();
    
    float btnSize = 60.0f;
    ImVec2 btnMin = btnPos;
    ImVec2 btnMax = ImVec2(btnPos.x + btnSize, btnPos.y + btnSize);

    // Ã Â¸Â¥Ã Â¸Â²Ã Â¸ÂÃ Â¸ÂÃ Â¸Â¸Ã Â¹ÂÃ Â¸Â¡
    if (ImGui::IsMouseHoveringRect(btnMin, btnMax)) {
        if (ImGui::IsMouseClicked(0)) {
            isDragging = true;
        }
    }
    
    if (isDragging) {
        if (ImGui::IsMouseDown(0)) {
            btnPos.x += io.MouseDelta.x;
            btnPos.y += io.MouseDelta.y;
        } else {
            isDragging = false;
            // Tap to open/close menu
            // We check if it was a quick tap (not a long drag)
            if (ImGui::GetIO().MouseDragMaxDistanceSqr[0] < 10.0f) {
                MenDeal = !MenDeal;
            }
        }
    }

    // Ã Â¸Â§Ã Â¸Â²Ã Â¸ÂÃ Â¹ÂÃ Â¸ÂÃ Â¸Â²
    draw_list->AddCircleFilled(ImVec2(btnPos.x + btnSize/2 + 2, btnPos.y + btnSize/2 + 2), btnSize/2, ImColor(0, 0, 0, 100), 36);
    
    // Ã Â¸Â§Ã Â¸Â²Ã Â¸ÂÃ Â¸Â£Ã Â¸Â¹Ã Â¸ÂÃ Â¸Â Ã Â¸Â²Ã Â¸ÂÃ Â¸ÂÃ Â¹ÂÃ Â¸Â²Ã Â¸Â¡Ã Â¸Âµ Texture
    if (buttonTexture) {
        draw_list->AddImage((void*)buttonTexture, btnMin, btnMax, ImVec2(0,0), ImVec2(1,1), ImColor(255, 255, 255, 255));
    } else {
        // Ã Â¸Â§Ã Â¸Â²Ã Â¸ÂÃ Â¸ÂªÃ Â¸Â³Ã Â¸Â£Ã Â¸Â­Ã Â¸ÂÃ Â¸ÂÃ Â¹ÂÃ Â¸Â²Ã Â¹ÂÃ Â¸Â«Ã Â¸Â¥Ã Â¸ÂÃ Â¸Â£Ã Â¸Â¹Ã Â¸ÂÃ Â¹ÂÃ Â¸Â¡Ã Â¹ÂÃ Â¸ÂªÃ Â¸Â³Ã Â¹ÂÃ Â¸Â£Ã Â¹ÂÃ Â¸Â
        draw_list->AddCircleFilled(ImVec2(btnPos.x + btnSize/2, btnPos.y + btnSize/2), btnSize/2, ImColor(0, 122, 255, 200), 36); // Blue color like iOS
        ImGui::SetWindowFontScale(1.5f);
        draw_list->AddText(ImVec2(btnPos.x + 22, btnPos.y + 18), ImColor(255, 255, 255), "M");
        ImGui::SetWindowFontScale(1.0f);
    }
    
    // Ã Â¸Â§Ã Â¸Â²Ã Â¸ÂÃ Â¸ÂÃ Â¸Â­Ã Â¸ÂÃ Â¸Â§Ã Â¸ÂÃ Â¸ÂÃ Â¸Â¥Ã Â¸Â¡Ã Â¸ÂªÃ Â¸ÂµÃ Â¸ÂÃ Â¸Â²Ã Â¸Â§
    draw_list->AddCircle(ImVec2(btnPos.x + btnSize/2, btnPos.y + btnSize/2), btnSize/2, ImColor(255, 255, 255, 255), 36, 2.0f);
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
    self.view.backgroundColor = [UIColor blackColor]; // Ã Â¸ÂÃ Â¸Â³Ã Â¸ÂªÃ Â¸ÂÃ Â¸Â´Ã Â¸Â
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0); // Ã Â¸ÂÃ Â¸Â³Ã Â¸ÂÃ Â¸Â¶Ã Â¸Â
    self.mtkView.backgroundColor = [UIColor blackColor]; // Ã Â¸ÂÃ Â¸Â³Ã Â¸ÂªÃ Â¸ÂÃ Â¸Â´Ã Â¸Â
    self.mtkView.clipsToBounds = YES;
    self.mtkView.opaque = YES; // Ã Â¹ÂÃ Â¸ÂÃ Â¸Â´Ã Â¹ÂÃ Â¸Â¡Ã Â¸ÂÃ Â¸Â§Ã Â¸Â²Ã Â¸Â¡Ã Â¸ÂÃ Â¸Â¶Ã Â¸Â
    
    Hook(0x4EB3E88 , BLAGCMCGEJG1, old_BLAGCMCGEJG1);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (NSArray<UIKeyCommand *> *)keyCommands {
    return @[
        [UIKeyCommand keyCommandWithInput:@"m" modifierFlags:0 action:@selector(toggleMenuByHotkey)]
    ];
}

- (void)toggleMenuByHotkey {
    MenDeal = !MenDeal;
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
        
    if (MenDeal == true) 
    {
        [self.view setUserInteractionEnabled:YES];
    } 
    else if (MenDeal == false) 
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
        
        // --- Ã Â¸Â§Ã Â¸Â²Ã Â¸ÂÃ Â¸ÂÃ Â¸Â¸Ã Â¹ÂÃ Â¸Â¡Ã Â¸Â¥Ã Â¸Â­Ã Â¸Â¢Ã Â¸ÂÃ Â¹ÂÃ Â¸Â§Ã Â¸Â¢ ImGui ---
        [self drawFloatingButton];

        CGFloat x = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width) - 380) / 2;
        CGFloat y = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height) - 260) / 2;
        ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
        ImGui::SetNextWindowSize(ImVec2(365, 270), ImGuiCond_FirstUseEver);
        
        if (MenDeal == true)
        {                
            ImGui::Begin(oxorany("SLUMZICK"), &MenDeal);
            if (ImGui::BeginTabBar(oxorany("Tab"),ImGuiTabBarFlags_FittingPolicyScroll)) {
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
                    ImGui::Checkbox(oxorany("Out of Screen"), &Vars.OOF); ImGui::SameLine();
                    ImGui::Checkbox(oxorany("Enemy Count"), &Vars.enemycount);
                   
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
                    ImGui::TextDisabled("hakari@ue4");
                    ImGui::TextDisabled("zexisy@ue4");
                    ImGui::TextDisabled("vinnisy7x");
                    ImGui::TextDisabled("jezsyi9@ue4");
                    ImGui::TextDisabled("fitloy7x"); 
                    ImGui::TextDisabled("x86/x64debug");
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
