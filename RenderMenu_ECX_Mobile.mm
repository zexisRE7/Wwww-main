// ══════════════════════════════════════════════════════════════════════════════
//  RenderMenu_ECX_Mobile.mm
//  แทนที่ RenderMenu() เดิมในไฟล์ ImGuiDrawView.mm
//
//  UI ตรงตาม ECX PANEL ในรูป + ปรับขนาดพอดีมือถือ
//  - ขนาด Window: เต็มจอ (หรือ 95% ขนาดจอ)
//  - แถบ Sidebar ซ้าย: ADB / AIMBOT / VISUALS / MISC / SETTINGS
//  - Header: "ECX PANEL" + ปุ่มปิด X
//  - Content: Toggle rows, Sliders ทุก feature ตามรูป
//  - Bottom status bar: Version / Discord / Hooking %
//
//  วิธีใช้:
//  1. ลบ/คอมเมนต์ static void RenderMenu() { ... } เดิมออก
//  2. #include หรือ paste ไฟล์นี้ก่อน drawInMTKView
//  3. ไม่ต้องเปลี่ยนโค้ดส่วนอื่น — ฟังก์ชัน RenderMenu() ยังเรียกเหมือนเดิม
// ══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
//  COLOR PALETTE  (ECX Dark theme — black/dark-gray + orange accent)
// ─────────────────────────────────────────────────────────────────────────────
static const ImU32 ECX_WIN_BG        = IM_COL32( 18,  18,  20, 255);   // main bg
static const ImU32 ECX_HEADER_BG     = IM_COL32( 10,  10,  12, 255);   // top title bar
static const ImU32 ECX_SIDEBAR_BG    = IM_COL32( 14,  14,  16, 255);   // left sidebar
static const ImU32 ECX_SIDEBAR_BORD  = IM_COL32( 28,  28,  32, 255);   // sidebar right edge
static const ImU32 ECX_TAB_ACTIVE    = IM_COL32( 30,  30,  36, 255);   // active tab bg
static const ImU32 ECX_TAB_INACTIVE  = IM_COL32( 14,  14,  16, 255);   // inactive tab bg
static const ImU32 ECX_TAB_ACTIVE_LINE = IM_COL32(255, 95, 30, 255);   // orange left bar
static const ImU32 ECX_TAB_TEXT_ON   = IM_COL32(255, 255, 255, 255);
static const ImU32 ECX_TAB_TEXT_OFF  = IM_COL32(120, 120, 130, 255);
static const ImU32 ECX_PANEL_BG      = IM_COL32( 22,  22,  26, 255);   // section panels
static const ImU32 ECX_SECTION_TITLE = IM_COL32( 28,  28,  34, 255);   // section header bg
static const ImU32 ECX_SECTION_TEXT  = IM_COL32(255,  95,  30, 255);   // orange section label
static const ImU32 ECX_ROW_BG        = IM_COL32( 22,  22,  26, 255);
static const ImU32 ECX_ROW_HOVER     = IM_COL32(255, 255, 255,  10);
static const ImU32 ECX_ROW_SEP       = IM_COL32( 32,  32,  36, 255);
static const ImU32 ECX_TEXT          = IM_COL32(220, 220, 220, 255);
static const ImU32 ECX_TEXT_DIM      = IM_COL32(100, 100, 110, 255);
static const ImU32 ECX_ORANGE        = IM_COL32(255,  95,  30, 255);
static const ImU32 ECX_GREEN         = IM_COL32( 48, 209,  88, 255);
static const ImU32 ECX_RED           = IM_COL32(255,  59,  48, 255);
static const ImU32 ECX_BLUE          = IM_COL32(  0, 122, 255, 255);
static const ImU32 ECX_TGL_ON        = IM_COL32(255,  95,  30, 255);   // orange toggle ON
static const ImU32 ECX_TGL_OFF       = IM_COL32( 50,  50,  56, 255);   // dark toggle OFF
static const ImU32 ECX_TGL_KNOB      = IM_COL32(255, 255, 255, 255);
static const ImU32 ECX_SLIDER_TRACK  = IM_COL32( 40,  40,  48, 255);
static const ImU32 ECX_SLIDER_FILL   = IM_COL32(255,  95,  30, 255);
static const ImU32 ECX_BTN_BG        = IM_COL32( 36,  36,  42, 255);
static const ImU32 ECX_BTN_ACTIVE    = IM_COL32(255,  95,  30, 255);
static const ImU32 ECX_STATUS_BG     = IM_COL32( 10,  10,  12, 255);
static const ImU32 ECX_BORDER        = IM_COL32( 42,  42,  50, 255);
static const ImU32 ECX_WARN_BG       = IM_COL32(255,  95,  30,  22);
static const ImU32 ECX_WARN_BORDER   = IM_COL32(255,  95,  30, 100);

// ─────────────────────────────────────────────────────────────────────────────
//  LAYOUT CONSTANTS  (mobile-friendly: ใช้ 95% ของหน้าจอ)
// ─────────────────────────────────────────────────────────────────────────────
static float ECX_screenW    = 0.0f;   // set each frame
static float ECX_screenH    = 0.0f;

static const float ECX_WIN_RAD      = 14.0f;
static const float ECX_SIDEBAR_W    = 72.0f;   // ความกว้าง sidebar ซ้าย (ไอคอน+ชื่อ)
static const float ECX_HEADER_H     = 46.0f;   // ความสูง header
static const float ECX_STATUS_H     = 28.0f;   // ความสูง status bar ล่าง
static const float ECX_TAB_H        = 54.0f;   // ความสูงของแต่ละ tab button
static const float ECX_TAB_GAP      =  2.0f;
static const float ECX_ROW_H        = 46.0f;   // ความสูงแต่ละ row
static const float ECX_ROW_GAP      =  2.0f;
static const float ECX_ROW_RAD      =  8.0f;
static const float ECX_SECTION_H    = 24.0f;
static const float ECX_PAD          = 12.0f;
static const float ECX_FONT_SCALE   =  0.85f;  // scale เล็กลงเพื่อมือถือ
static const float ECX_SLIDER_H     =  5.0f;
static const float ECX_KNOB_R       =  9.0f;
static const float ECX_TGL_W        = 46.0f;
static const float ECX_TGL_H        = 26.0f;

// State
static int   ECX_Tab        = 0;   // 0=ADB 1=AIMBOT 2=VISUALS 3=MISC 4=SETTINGS
static float ECX_HookPct    = 0.0f;

// ─────────────────────────────────────────────────────────────────────────────
//  HELPER: iOS-style Toggle
// ─────────────────────────────────────────────────────────────────────────────
static void ECX_DrawToggle(ImDrawList* dl, ImVec2 pos, bool on) {
    float tR = ECX_TGL_H * 0.5f;
    ImU32 track = on ? ECX_TGL_ON : ECX_TGL_OFF;
    dl->AddRectFilled(pos, ImVec2(pos.x + ECX_TGL_W, pos.y + ECX_TGL_H), track, tR);
    float kX = on ? (pos.x + ECX_TGL_W - tR) : (pos.x + tR);
    float kY = pos.y + tR;
    dl->AddCircleFilled(ImVec2(kX, kY), tR - 2.0f, IM_COL32(0,0,0,20), 28);
    dl->AddCircleFilled(ImVec2(kX, kY), tR - 3.0f, ECX_TGL_KNOB, 28);
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPER: Toggle Row (label left + toggle right)
// ─────────────────────────────────────────────────────────────────────────────
static bool ECX_ToggleRow(const char* label, bool* v, bool isLast = false) {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return false;
    ImVec2 pos = w->DC.CursorPos;
    float  aw  = ImGui::GetContentRegionAvail().x;
    const ImGuiID id = w->GetID(label);
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + ECX_ROW_H));
    ImGui::ItemSize(ImVec2(aw, ECX_ROW_H + ECX_ROW_GAP), 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;
    bool hov, hld;
    bool pressed = ImGui::ButtonBehavior(bb, id, &hov, &hld);
    if (pressed) *v = !*v;
    ImDrawList* dl = w->DrawList;
    if (hov) dl->AddRectFilled(bb.Min, bb.Max, ECX_ROW_HOVER, ECX_ROW_RAD);
    if (!isLast)
        dl->AddLine(ImVec2(bb.Min.x + ECX_PAD, bb.Max.y - 1.0f),
                    ImVec2(bb.Max.x - ECX_PAD, bb.Max.y - 1.0f), ECX_ROW_SEP, 1.0f);
    float cy = (bb.Min.y + bb.Max.y) * 0.5f;
    dl->AddText(ImVec2(bb.Min.x + ECX_PAD, cy - ImGui::GetFontSize() * 0.5f), ECX_TEXT, label);
    ImVec2 tPos(bb.Max.x - ECX_TGL_W - ECX_PAD, cy - ECX_TGL_H * 0.5f);
    ECX_DrawToggle(dl, tPos, *v);
    return pressed;
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPER: Slider Row
// ─────────────────────────────────────────────────────────────────────────────
static bool ECX_SliderRow(const char* label, float* v, float vmin, float vmax, const char* fmt = "%.1f") {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return false;
    ImGuiContext& g = *GImGui;
    const ImGuiID id = w->GetID(label);
    ImVec2 pos = w->DC.CursorPos;
    float  aw  = ImGui::GetContentRegionAvail().x;
    const float rowH = ECX_ROW_H + 14.0f;
    ImRect bb(pos, ImVec2(pos.x + aw, pos.y + rowH));
    ImGui::ItemSize(ImVec2(aw, rowH + ECX_ROW_GAP), 0.0f);
    if (!ImGui::ItemAdd(bb, id)) return false;
    ImDrawList* dl = w->DrawList;

    float labelY = pos.y + 10.0f;
    dl->AddText(ImVec2(pos.x + ECX_PAD, labelY), ECX_TEXT, label);
    char vbuf[32]; snprintf(vbuf, sizeof(vbuf), fmt, *v);
    ImVec2 vts = ImGui::CalcTextSize(vbuf);
    dl->AddText(ImVec2(pos.x + aw - ECX_PAD - vts.x, labelY), ECX_ORANGE, vbuf);

    const float tX0 = pos.x + ECX_PAD;
    const float tX1 = pos.x + aw - ECX_PAD;
    const float tY  = pos.y + rowH - 12.0f;
    float t = (*v - vmin) / (vmax - vmin);
    t = t < 0.0f ? 0.0f : (t > 1.0f ? 1.0f : t);

    ImRect trackBB(ImVec2(tX0 - ECX_KNOB_R, tY - ECX_KNOB_R),
                   ImVec2(tX1 + ECX_KNOB_R, tY + ECX_KNOB_R));
    bool hov, hld;
    ImGui::ButtonBehavior(trackBB, id, &hov, &hld);
    if (hld) {
        float nt = (g.IO.MousePos.x - tX0) / (tX1 - tX0);
        nt = nt < 0.0f ? 0.0f : (nt > 1.0f ? 1.0f : nt);
        *v = vmin + nt * (vmax - vmin); t = nt;
        ImGui::MarkItemEdited(id);
    }
    dl->AddRectFilled(ImVec2(tX0, tY - ECX_SLIDER_H * 0.5f),
                      ImVec2(tX1, tY + ECX_SLIDER_H * 0.5f), ECX_SLIDER_TRACK, ECX_SLIDER_H);
    dl->AddRectFilled(ImVec2(tX0, tY - ECX_SLIDER_H * 0.5f),
                      ImVec2(tX0 + (tX1-tX0)*t, tY + ECX_SLIDER_H * 0.5f), ECX_SLIDER_FILL, ECX_SLIDER_H);
    float kX = tX0 + (tX1-tX0)*t;
    dl->AddCircleFilled(ImVec2(kX, tY), ECX_KNOB_R + 1.0f, IM_COL32(0,0,0,22), 24);
    dl->AddCircleFilled(ImVec2(kX, tY), ECX_KNOB_R, ECX_TGL_KNOB, 24);
    dl->AddCircle(ImVec2(kX, tY), ECX_KNOB_R, ECX_ORANGE, 24, 1.3f);
    dl->AddLine(ImVec2(pos.x + ECX_PAD, bb.Max.y - 1.0f),
                ImVec2(pos.x + aw, bb.Max.y - 1.0f), ECX_ROW_SEP, 1.0f);
    return hld;
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPER: Section header label
// ─────────────────────────────────────────────────────────────────────────────
static void ECX_SectionHeader(const char* label) {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return;
    float aw  = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = w->DC.CursorPos;
    ImGui::ItemSize(ImVec2(aw, ECX_SECTION_H + 4.0f), 0.0f);
    ImDrawList* dl = w->DrawList;
    dl->AddRectFilled(pos, ImVec2(pos.x + aw, pos.y + ECX_SECTION_H + 4.0f),
                      ECX_SECTION_TITLE, 0.0f);
    float cy = pos.y + (ECX_SECTION_H + 4.0f) * 0.5f;
    dl->AddText(ImVec2(pos.x + ECX_PAD, cy - ImGui::GetFontSize() * 0.5f),
                ECX_SECTION_TEXT, label);
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPER: Info Row (label + value, no toggle)
// ─────────────────────────────────────────────────────────────────────────────
static void ECX_InfoRow(const char* label, const char* value, ImU32 valColor = 0) {
    ImGuiWindow* w = ImGui::GetCurrentWindow();
    if (w->SkipItems) return;
    float aw  = ImGui::GetContentRegionAvail().x;
    ImVec2 pos = w->DC.CursorPos;
    ImGui::ItemSize(ImVec2(aw, ECX_ROW_H + ECX_ROW_GAP), 0.0f);
    ImDrawList* dl = w->DrawList;
    dl->AddLine(ImVec2(pos.x + ECX_PAD, pos.y + ECX_ROW_H - 1.0f),
                ImVec2(pos.x + aw, pos.y + ECX_ROW_H - 1.0f), ECX_ROW_SEP, 1.0f);
    float cy = pos.y + ECX_ROW_H * 0.5f;
    dl->AddText(ImVec2(pos.x + ECX_PAD, cy - ImGui::GetFontSize() * 0.5f), ECX_TEXT, label);
    ImU32 vc = (valColor != 0) ? valColor : ECX_ORANGE;
    ImVec2 vts = ImGui::CalcTextSize(value);
    dl->AddText(ImVec2(pos.x + aw - ECX_PAD - vts.x, cy - ImGui::GetFontSize() * 0.5f), vc, value);
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN RENDER FUNCTION
// ─────────────────────────────────────────────────────────────────────────────
static void RenderMenu() {
    // ── ดึงขนาดหน้าจอปัจจุบัน ───────────────────────────────────────────
    ImGuiIO& io = ImGui::GetIO();
    ECX_screenW = io.DisplaySize.x;
    ECX_screenH = io.DisplaySize.y;

    // ── ขนาด Window: 95% ของหน้าจอ, ไม่เกิน 620×480 (desktop fallback) ──
    float winW = ECX_screenW * 0.95f;
    float winH = ECX_screenH * 0.80f;
    // cap desktop ให้ไม่ใหญ่เกิน
    if (winW > 620.0f) winW = 620.0f;
    if (winH > 500.0f) winH = 500.0f;

    // ── Style push ───────────────────────────────────────────────────────
    ImGui::PushStyleColor(ImGuiCol_WindowBg,       ImVec4(18.0f/255,18.0f/255,20.0f/255,1.0f));
    ImGui::PushStyleColor(ImGuiCol_Border,         ImVec4(0,0,0,0));
    ImGui::PushStyleColor(ImGuiCol_ScrollbarBg,    ImVec4(0,0,0,0));
    ImGui::PushStyleColor(ImGuiCol_ScrollbarGrab,  ImVec4(0.22f,0.22f,0.26f,1.0f));
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding,   ECX_WIN_RAD);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding,    ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing,      ImVec2(0,0));
    ImGui::PushStyleVar(ImGuiStyleVar_ScrollbarSize,    3.0f);

    ImGui::SetNextWindowSize(ImVec2(winW, winH), ImGuiCond_Always);
    ImGui::SetNextWindowPos(
        ImVec2((ECX_screenW - winW) * 0.5f, (ECX_screenH - winH) * 0.5f),
        ImGuiCond_FirstUseEver
    );
    ImGui::Begin("##ECX_Panel", nullptr,
        ImGuiWindowFlags_NoTitleBar  | ImGuiWindowFlags_NoResize  |
        ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse |
        ImGuiWindowFlags_NoBringToFrontOnFocus);
    ImGui::SetWindowFontScale(ECX_FONT_SCALE);

    ImDrawList* dl = ImGui::GetWindowDrawList();
    ImVec2 wp = ImGui::GetWindowPos();
    ImVec2 ws = ImGui::GetWindowSize();

    // ── Window background ────────────────────────────────────────────────
    dl->AddRectFilled(wp, ImVec2(wp.x+ws.x, wp.y+ws.y), ECX_WIN_BG, ECX_WIN_RAD);
    dl->AddRect(wp, ImVec2(wp.x+ws.x, wp.y+ws.y), ECX_BORDER, ECX_WIN_RAD, 0, 1.2f);

    // ════════════════════════════════════════════════════════════════════════
    //  HEADER  — "ECX PANEL"  +  ปุ่ม [X] ปิด
    // ════════════════════════════════════════════════════════════════════════
    {
        float hY0 = wp.y;
        float hY1 = wp.y + ECX_HEADER_H;
        dl->AddRectFilled(ImVec2(wp.x, hY0), ImVec2(wp.x+ws.x, hY1),
                          ECX_HEADER_BG, ECX_WIN_RAD, ImDrawFlags_RoundCornersTop);
        dl->AddLine(ImVec2(wp.x, hY1), ImVec2(wp.x+ws.x, hY1), ECX_BORDER, 1.0f);

        // Title text  — "ECX PANEL"
        const char* title = "ECX PANEL";
        ImVec2 tts = ImGui::CalcTextSize(title);
        float  hCY = wp.y + ECX_HEADER_H * 0.5f;
        dl->AddText(ImVec2(wp.x + 16.0f, hCY - tts.y * 0.5f), ECX_ORANGE, title);

        // Close [X] button
        float xR  = 14.0f;
        float xCX = wp.x + ws.x - xR - 10.0f;
        dl->AddCircleFilled(ImVec2(xCX, hCY), xR, IM_COL32(48,48,56,255), 20);
        float xs = 5.0f;
        dl->AddLine(ImVec2(xCX-xs, hCY-xs), ImVec2(xCX+xs, hCY+xs), ECX_TEXT, 2.0f);
        dl->AddLine(ImVec2(xCX+xs, hCY-xs), ImVec2(xCX-xs, hCY+xs), ECX_TEXT, 2.0f);
        ImGui::SetCursorScreenPos(ImVec2(xCX - xR, hCY - xR));
        if (ImGui::InvisibleButton("##ecx_close", ImVec2(xR*2, xR*2)))
            MenDeal = false;
    }

    // ════════════════════════════════════════════════════════════════════════
    //  LAYOUT ZONES
    // ════════════════════════════════════════════════════════════════════════
    float zoneY0 = wp.y + ECX_HEADER_H;
    float zoneY1 = wp.y + ws.y - ECX_STATUS_H;
    float zoneH  = zoneY1 - zoneY0;

    // ── Sidebar right border line ─────────────────────────────────────────
    dl->AddLine(ImVec2(wp.x + ECX_SIDEBAR_W, zoneY0),
                ImVec2(wp.x + ECX_SIDEBAR_W, zoneY1), ECX_SIDEBAR_BORD, 1.0f);

    // ════════════════════════════════════════════════════════════════════════
    //  LEFT SIDEBAR TABS
    //  ไอคอน+ชื่อ:  🎯 ADB / 🏹 AIMBOT / 👁 VISUALS / 🔧 MISC / ⚙️ SETTINGS
    // ════════════════════════════════════════════════════════════════════════
    struct TabDef { const char* icon; const char* name; };
    static const TabDef kTabs[] = {
        { "ADB",  "ADB"      },
        { "AIM",  "AIMBOT"   },
        { "ESP",  "VISUALS"  },
        { "MISC", "MISC"     },
        { "SET",  "SETTINGS" },
    };
    static const int kTabCount = 5;

    float totalTabH = (float)kTabCount * ECX_TAB_H + (float)(kTabCount-1) * ECX_TAB_GAP;
    float tabStartY = zoneY0 + (zoneH - totalTabH) * 0.5f;

    for (int i = 0; i < kTabCount; ++i) {
        float tY0 = tabStartY + (float)i * (ECX_TAB_H + ECX_TAB_GAP);
        float tY1 = tY0 + ECX_TAB_H;
        float tX0 = wp.x + 4.0f;
        float tX1 = wp.x + ECX_SIDEBAR_W - 4.0f;
        bool  active = (ECX_Tab == i);

        // Tab background
        dl->AddRectFilled(ImVec2(tX0, tY0), ImVec2(tX1, tY1),
                          active ? ECX_TAB_ACTIVE : ECX_TAB_INACTIVE, 8.0f);

        // Active indicator — orange left bar
        if (active)
            dl->AddRectFilled(ImVec2(tX0, tY0 + 6.0f),
                              ImVec2(tX0 + 3.0f, tY1 - 6.0f),
                              ECX_TAB_ACTIVE_LINE, 2.0f);

        // Icon label (tiny text top)
        float midX = (tX0 + tX1) * 0.5f;
        float midY = (tY0 + tY1) * 0.5f;
        ImVec2 nts = ImGui::CalcTextSize(kTabs[i].name);
        dl->AddText(ImVec2(midX - nts.x * 0.5f, midY - nts.y * 0.5f),
                    active ? ECX_TAB_TEXT_ON : ECX_TAB_TEXT_OFF, kTabs[i].name);

        // Invisible hit area
        ImGui::SetCursorScreenPos(ImVec2(tX0, tY0));
        char bid[16]; snprintf(bid, sizeof(bid), "##ecxtab%d", i);
        if (ImGui::InvisibleButton(bid, ImVec2(tX1-tX0, ECX_TAB_H)))
            ECX_Tab = i;
    }

    // ════════════════════════════════════════════════════════════════════════
    //  RIGHT CONTENT AREA (scrollable)
    // ════════════════════════════════════════════════════════════════════════
    float rcX = wp.x + ECX_SIDEBAR_W;
    float rcW = ws.x - ECX_SIDEBAR_W;

    ImGui::SetCursorScreenPos(ImVec2(rcX, zoneY0));
    ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(22.0f/255, 22.0f/255, 26.0f/255, 1.0f));
    ImGui::BeginChild("##ecx_content", ImVec2(rcW, zoneH), false,
                      ImGuiWindowFlags_AlwaysVerticalScrollbar);
    ImGui::SetWindowFontScale(ECX_FONT_SCALE);

    switch (ECX_Tab) {

        // ══════════════════════════════════════════════════════════════════
        //  TAB 0: ADB  — ADB Controls + Aimbot + HitBox + Adjust
        // ══════════════════════════════════════════════════════════════════
        case 0: {
            // ── ADB section ──────────────────────────────────────────────
            ECX_SectionHeader("ADB");
            {
                static float ADB_MinDist = 11.7f;
                static float ADB_Radius  = 1.7f;
                ECX_SliderRow("Min Distance", &ADB_MinDist, 0.0f, 50.0f, "%.1f");
                ECX_SliderRow("Radius",       &ADB_Radius,  0.5f, 10.0f, "%.1f");
                ECX_ToggleRow("Teleport Key",  &Vars.Enable);
            }

            // ── AIMBOT section ────────────────────────────────────────────
            ECX_SectionHeader("AIMBOT");
            {
                static float PullVal = 0.0f;
                ECX_SliderRow("Pull Strength", &PullVal, 0.0f, 5.0f, "%.1f");
                ECX_ToggleRow("Aimbot",        &Vars.Aimbot);
                ECX_ToggleRow("No Recoil",     &ZX_NoRecoil);
                ECX_ToggleRow("Show AimFOV",   &Vars.ShowFovCircle);
                {
                    static float AimFOV = 340.0f;
                    Vars.AimFov = AimFOV;
                    ECX_SliderRow("AimFOV", &AimFOV, 0.0f, 360.0f, "%.0f");
                }
            }

            // ── HitBox section ────────────────────────────────────────────
            ECX_SectionHeader("HitBox");
            ECX_ToggleRow("Head",        &Vars.Aimbot);
            ECX_ToggleRow("Body",        &Vars.Enable);
            ECX_ToggleRow("Hip",         &Vars.VisibleCheck);
            ECX_ToggleRow("Silent Aim",  &SilentAim);
            ECX_ToggleRow("Ignore Knocked", &Vars.IgnoreKnocked);

            // ── ADJUST section ────────────────────────────────────────────
            ECX_SectionHeader("ADJUST");
            {
                static float BodyMinHP = 50.0f;
                static float PullTime  = 0.0f;
                static float MaxDist   = 150.0f;
                static float PullStr   = 1.0f;
                ECX_SliderRow("Body Min HP",    &BodyMinHP, 0.0f, 100.0f, "%.0f");
                ECX_SliderRow("Pull Tick(ms)",  &PullTime,  0.0f,  200.0f, "%.0f");
                ECX_SliderRow("Max Distance",   &MaxDist,   0.0f,  500.0f, "%.0f");
                ECX_SliderRow("Pull Strength",  &PullStr,   0.0f,    5.0f, "%.1f");
            }

            // ── Extra toggles ─────────────────────────────────────────────
            ECX_SectionHeader("EXTRA");
            ECX_ToggleRow("Forced Data",  &Vars.Enable);
            ECX_ToggleRow("ADB",          &Vars.Aimbot);
            ECX_ToggleRow("Speed Fire",   &ZX_FastFire);
            ECX_ToggleRow("MEM Show",     &Vars.ShowFovCircle, true);
            break;
        }

        // ══════════════════════════════════════════════════════════════════
        //  TAB 1: AIMBOT
        // ══════════════════════════════════════════════════════════════════
        case 1: {
            ECX_SectionHeader("AIMBOT MAIN");
            ECX_ToggleRow("Enable Aimbot",   &Vars.Aimbot);
            ECX_ToggleRow("Silent Aim",      &SilentAim);
            ECX_ToggleRow("Auto Fire",       &Vars.AutoFire);
            ECX_ToggleRow("Aim Kill",        &ZX_AimKill);
            ECX_ToggleRow("Visible Check",   &Vars.VisibleCheck);
            ECX_ToggleRow("Ignore Knocked",  &Vars.IgnoreKnocked);
            {
                static float fovV = 90.0f; Vars.AimFov = fovV;
                ECX_SliderRow("FOV",          &fovV,          1.0f, 360.0f, "%.0f");
                ECX_SliderRow("Aim Speed",    &Vars.AimSpeed, 1.0f,  50.0f, "%.1f");
            }

            ECX_SectionHeader("AIMKILL VARIANTS");
            ECX_ToggleRow("UNDERKILL",     &ZX_UnderKill);
            ECX_ToggleRow("AIMKILL v1",    &ZX_AimKillV1);
            ECX_ToggleRow("AIMKILL v2",    &ZX_AimKillV2);
            ECX_ToggleRow("AIMKILL v3",    &ZX_AimKillV3);
            ECX_ToggleRow("AIMKILL v4",    &ZX_AimKillV4);
            ECX_ToggleRow("AIMKILL v5",    &ZX_AimKillV5, true);
            break;
        }

        // ══════════════════════════════════════════════════════════════════
        //  TAB 2: VISUALS  (ESP)
        // ══════════════════════════════════════════════════════════════════
        case 2: {
            ECX_SectionHeader("ESP");
            ECX_ToggleRow("ESP Enable",   &Vars.Enable);
            ECX_ToggleRow("Lines",        &Vars.lines);
            ECX_ToggleRow("Boxes",        &Vars.Box);
            ECX_ToggleRow("3D Box",       &ZX_Esp3DBox);
            ECX_ToggleRow("Health",       &Vars.Health);
            ECX_ToggleRow("Name",         &Vars.Name);
            ECX_ToggleRow("Distance",     &Vars.Distance);
            ECX_ToggleRow("Skeleton",     &Vars.skeleton);
            ECX_ToggleRow("OOF Arrow",    &Vars.OOF);
            ECX_ToggleRow("Enemy Count",  &Vars.enemycount, true);

            ECX_SectionHeader("CAMERA");
            ECX_ToggleRow("Camera Left",  &ZX_CameraLeft);
            {
                ECX_SliderRow("Camera Height", &ZX_CameraHeight, 0.0f, 20.0f, "%.1f");
                ECX_SliderRow("Camera Side",   &ZX_CameraSide,  -10.0f,10.0f, "%.1f");
            }
            break;
        }

        // ══════════════════════════════════════════════════════════════════
        //  TAB 3: MISC  (Combat / Movement / Weapon)
        // ══════════════════════════════════════════════════════════════════
        case 3: {
            ECX_SectionHeader("WEAPON");
            ECX_ToggleRow("Fast Fire",       &ZX_FastFire);
            ECX_ToggleRow("No Reload",       &ZX_NoReload);
            ECX_ToggleRow("Rapid Fire",      &ZX_RapidFire);
            ECX_ToggleRow("Chain Damage",    &ZX_ChainDamage);
            if (ZX_ChainDamage)
                ECX_SliderRow("Chain DMG Value", &ZX_ChainDmgValue, 100.0f, 9999.0f, "%.0f");
            ECX_ToggleRow("Long Range",      &ZX_LongRange);
            ECX_ToggleRow("Bullet Through",  &ZX_BulletThru);
            ECX_ToggleRow("Fast Medkit",     &ZX_FastMedkit);
            ECX_ToggleRow("Head Only",       &ZX_HeadOnly);
            ECX_ToggleRow("Wall Shoot",      &ZX_WallShoot);
            ECX_ToggleRow("Insta Scope",     &ZX_InstaScope);
            ECX_ToggleRow("Quick Scope",     &ZX_QuickScope);
            ECX_ToggleRow("Bullet Rain",     &ZX_BulletRain);
            ECX_ToggleRow("Lock Trigger",    &ZX_LockTrigger, true);

            ECX_SectionHeader("MOVEMENT");
            ECX_ToggleRow("Fly Alt",         &ZX_FlyAlt);
            if (ZX_FlyAlt)
                ECX_SliderRow("Fly Speed",   &ZX_FlySpeed, 1.0f, 30.0f, "%.1f");
            ECX_ToggleRow("Fly V2",          &ZX_FlyV2);
            ECX_ToggleRow("Free Fly",        &ZX_FreeFly);
            if (ZX_FreeFly)
                ECX_SliderRow("Free Fly Speed", &ZX_FreeFlySpeed, 1.0f, 30.0f, "%.1f");
            ECX_ToggleRow("Super Jump",      &ZX_SuperJump);
            ECX_ToggleRow("Ninja Run",       &ZX_RUN);
            ECX_ToggleRow("Speed NinjaRun",  &ZX_GHOSTVIP);
            ECX_ToggleRow("Ghost Mode",      &ZX_GhostMode);
            ECX_ToggleRow("Telekill",        &ZX_Telekill);
            ECX_ToggleRow("Mark Teleport",   &ZX_MarkTeleport);
            ECX_ToggleRow("Auto Teleport",   &ZX_AutoTeleport, true);

            ECX_SectionHeader("SPEED PRESETS");
            ECX_ToggleRow("Speed x10",       &ZX_SpeedX10);
            ECX_ToggleRow("Speed x20",       &ZX_SpeedX20);
            ECX_ToggleRow("Speed x50",       &ZX_SpeedX50);
            ECX_ToggleRow("Real Speed",      &ZX_RealSpeed);
            if (ZX_RealSpeed)
                ECX_SliderRow("Speed Mult", &ZX_SpeedMult, 1.0f, 5.0f, "x%.1f");
            ECX_ToggleRow("Anti-Ban",        &ZX_AntiBan, true);
            break;
        }

        // ══════════════════════════════════════════════════════════════════
        //  TAB 4: SETTINGS  (Misc + Info)
        // ══════════════════════════════════════════════════════════════════
        case 4: {
            ECX_SectionHeader("VISUAL EXTRAS");
            ECX_ToggleRow("Blue Map",        &ZX_BlueMap);
            ECX_ToggleRow("Map Reveal",      &ZX_MapReveal);
            ECX_ToggleRow("Anti Flash",      &ZX_AntiFlash);
            ECX_ToggleRow("Zoom Hack",       &ZX_ZoomHack);
            ECX_ToggleRow("Spin Bot",        &ZX_SpinBot);
            ECX_ToggleRow("Fake Lag",        &ZX_FakeLag);
            ECX_ToggleRow("AI Player Aim",   &ZX_AIPlayerAim);
            ECX_ToggleRow("Fast Switch",     &ZX_FastSwitch);
            ECX_ToggleRow("Reset Guest",     &ZX_ResetAcc, true);

            ECX_SectionHeader("INFO");
            // Init battery once
            if (!ZX_BatMonInit) {
                [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
                ZX_BatMonInit = true;
            }
            static double infoStartTime = 0.0;
            if (infoStartTime == 0.0) infoStartTime = ImGui::GetTime();
            double elapsed = ImGui::GetTime() - infoStartTime;
            int hh=(int)(elapsed/3600), mm=(int)(elapsed/60)%60, ss=(int)elapsed%60;
            char timeBuf[32]; snprintf(timeBuf, sizeof(timeBuf), "%02d:%02d:%02d", hh, mm, ss);

            float bat = [[UIDevice currentDevice] batteryLevel];
            char batBuf[16];
            if (bat < 0.0f) snprintf(batBuf, sizeof(batBuf), "--%%" );
            else            snprintf(batBuf, sizeof(batBuf), "%d%%", (int)(bat*100.0f));

            char killBuf[16]; snprintf(killBuf, sizeof(killBuf), "%d", ZX_KillCount);

            ECX_InfoRow("Session Time", timeBuf, ECX_ORANGE);
            ECX_InfoRow("Battery",      batBuf,  ECX_GREEN);
            ECX_InfoRow("Kills",        killBuf, ECX_RED);
            ECX_InfoRow("Version",      "0.0.0", ECX_TEXT_DIM);
            break;
        }
    }

    ImGui::EndChild();
    ImGui::PopStyleColor();   // ChildBg

    // ════════════════════════════════════════════════════════════════════════
    //  STATUS BAR  — Version / Discord / Hooking %
    // ════════════════════════════════════════════════════════════════════════
    {
        float sY0 = zoneY1;
        float sY1 = wp.y + ws.y;
        dl->AddRectFilled(ImVec2(wp.x, sY0), ImVec2(wp.x+ws.x, sY1),
                          ECX_STATUS_BG, ECX_WIN_RAD, ImDrawFlags_RoundCornersBottom);
        dl->AddLine(ImVec2(wp.x, sY0), ImVec2(wp.x+ws.x, sY0), ECX_BORDER, 1.0f);

        float cy = sY0 + (sY1 - sY0) * 0.5f;

        // Left: Version
        const char* ver = "Version 0.0.0";
        dl->AddText(ImVec2(wp.x + ECX_PAD, cy - ImGui::GetFontSize() * 0.5f),
                    ECX_TEXT_DIM, ver);

        // Center: Discord
        const char* disc = "Discord: 2x:_0804";
        ImVec2 dts = ImGui::CalcTextSize(disc);
        dl->AddText(ImVec2(wp.x + (ws.x - dts.x) * 0.5f, cy - ImGui::GetFontSize() * 0.5f),
                    ECX_TEXT_DIM, disc);

        // Right: Hooking %
        static float hookAnim = 0.0f;
        hookAnim += ImGui::GetIO().DeltaTime * 20.0f;
        if (hookAnim > 100.0f) hookAnim = 0.0f;
        char hookBuf[32]; snprintf(hookBuf, sizeof(hookBuf), "Hooking  %d%%", (int)hookAnim);
        ImVec2 hts = ImGui::CalcTextSize(hookBuf);
        dl->AddText(ImVec2(wp.x + ws.x - ECX_PAD - hts.x, cy - ImGui::GetFontSize() * 0.5f),
                    ECX_ORANGE, hookBuf);
    }

    ImGui::End();
    ImGui::PopStyleVar(5);
    ImGui::PopStyleColor(4);
}
