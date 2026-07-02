#import "vinhtran.hpp"
#import "loading.hxx"
#include <fstream>
#define FMT_HEADER_ONLY
#include "fmt/core.h"

struct Vars_t
{
    // ESP 
    bool Enable = false;
    bool lines = false;
    bool Box = false;
    bool Name = false;
    bool Health = false;
    bool Distance = false;
    bool skeleton = false;
    bool Outline = false;
    bool circlepos = false;
    bool enemycount = false;
    bool OOF = false;

    //  Aimbot 
    bool Aimbot = false;
    bool isAimFov = false;
    bool VisibleCheck = false;
    bool IgnoreKnocked = false;
    float AimFov = 360.0f;
    int AimHitbox = 0;
    int AimWhen = 3;
    int AimMode = 2;

    // Features 
    bool SpeedHack = false;
    float SpeedMult = 10.0f;
    bool RapidFire = false;
    bool FlyHack = false;
    bool AimMagnet = false;
    float MagnetRange = 30.0f;
    bool AimManager = false;
    float AimMgrDist = 20.0f;
    bool PullPlayer = false;
    float PullDist = 15.0f;
} Vars;

class game_sdk_t
{
public:
    void init();
    int (*GetHp)(void *player);
    void *(*Curent_Match)();
    void *(*GetLocalPlayer)(void *Game);
    void *(*GetHeadPositions)(void *player);
    Vector3 (*get_position)(void *player);
    void *(*Component_GetTransform)(void *player);
    void *(*get_camera)();
    Vector3 (*WorldToViewpoint)(void*, Vector3, int);
    bool (*get_isVisible)(void *player);
    bool (*get_isLocalTeam)(void *player);
    bool (*get_IsDieing)(void *player);
    int (*get_MaxHP)(void *player);
    Vector3 (*GetForward)(void *player);
    void (*set_aim)(void *, Quaternion look);
    bool (*get_IsSighting)(void *player);
    bool (*get_IsFiring)(void *player);
    monoString *(*name)(void *player);
};

game_sdk_t *game_sdk = new game_sdk_t();

void game_sdk_t::init()
{
    this->GetHp               = (int (*)(void *))                 getRealOffset(oxo("0x543592C"));
    this->Curent_Match        = (void *(*)())                     getRealOffset(oxo("0x55C4DA4"));
    this->GetLocalPlayer      = (void *(*)(void *))               getRealOffset(oxo("0x2FFE494"));
    this->GetHeadPositions    = (void *(*)(void *))               getRealOffset(oxo("0x54547E0"));
    this->get_position        = (Vector3(*)(void *))              getRealOffset(oxo("0x91CA56C"));
    this->Component_GetTransform = (void *(*)(void *))            getRealOffset(oxo("0x91B82E4"));
    this->get_camera          = (void *(*)())                     getRealOffset(oxo("0x915E9E4"));
    this->WorldToViewpoint    = (Vector3(*)(void*, Vector3, int)) getRealOffset(oxo("0x915E364"));
    this->get_isVisible       = (bool (*)(void *))                getRealOffset(oxo("0x53C8894"));
    this->get_isLocalTeam     = (bool (*)(void *))                getRealOffset(oxo("0x53E20C4"));
    this->get_IsDieing        = (bool (*)(void *))                getRealOffset(oxo("0x53AA18C"));
    this->get_MaxHP           = (int (*)(void *))                 getRealOffset(oxo("0x5435A3C"));
    this->GetForward          = (Vector3(*)(void *))              getRealOffset(oxo("0x91CAF64"));
    this->set_aim             = (void (*)(void *, Quaternion))    getRealOffset(oxo("0x53C4534"));
    this->get_IsSighting      = (bool (*)(void *))                getRealOffset(oxo("0x53B769C"));
    this->get_IsFiring        = (bool (*)(void *))                getRealOffset(oxo("0x53ACC9C"));
    this->name                = (monoString * (*)(void *))        getRealOffset(oxo("0x53BE8E0"));
}

namespace Camera$$WorldToScreen
{
    ImVec2 Regular(Vector3 pos) {
        auto cam = game_sdk->get_camera();
        if (!cam) return {0,0};
        Vector3 worldPoint = game_sdk->WorldToViewpoint(cam, pos, 2);
        return {ImGui::GetIO().DisplaySize.x * worldPoint.x,
                ImGui::GetIO().DisplaySize.y - worldPoint.y * ImGui::GetIO().DisplaySize.y};
    }

    ImVec2 Checker(Vector3 pos, bool &checker) {
        auto cam = game_sdk->get_camera();
        if (!cam) { checker = false; return {0,0}; }
        Vector3 worldPoint = game_sdk->WorldToViewpoint(cam, pos, 4);
        checker = worldPoint.z > 0.01f;
        return {ImGui::GetIO().DisplaySize.x * worldPoint.x,
                ImGui::GetIO().DisplaySize.y - worldPoint.y * ImGui::GetIO().DisplaySize.y};
    }
}

Vector3 getPosition(void *player) {
    if (!player) return Vector3::zero();
    void* tf = game_sdk->Component_GetTransform(player);
    return tf ? game_sdk->get_position(tf) : Vector3::zero();
}

Vector3 GetHeadPosition(void *player) {
    if (!player) return Vector3::zero();
    void* head = game_sdk->GetHeadPositions(player);
    return head ? game_sdk->get_position(head) : Vector3::zero();
}

static Vector3 CameraMain() {
    void* cam = game_sdk->get_camera();
    if (!cam) return Vector3::zero();
    void* tf = game_sdk->Component_GetTransform(cam);
    return tf ? game_sdk->get_position(tf) : Vector3::zero();
}

Quaternion GetRotationToTheLocation(Vector3 Target, float Height, Vector3 MyEnemy) {
    Vector3 direction = (Target + Vector3(0, Height, 0)) - MyEnemy;
    return Quaternion::LookRotation(direction, Vector3(0, 1, 0));
}

#include "Helper/Ext.h"


static void (*_ForceSetPos)(void*, Vector3) = nullptr;

static void ensureForceSetPos() {
    if (!_ForceSetPos)
        _ForceSetPos = (void(*)(void*, Vector3))getRealOffset(oxo("0x6081B1C"));
}

static Dictionary<uint8_t *, void **> *getPlayerDict(void *Match) {
    return *(Dictionary<uint8_t *, void **> **)((long)Match + 0x148);
}

void *GetClosestEnemy()
{
    try {
        float best = 9999.0f;
        void *closest = NULL;
        void *Match = game_sdk->Curent_Match();
        if (!Match) return NULL;
        void *LocalPlayer = game_sdk->GetLocalPlayer(Match);
        if (!LocalPlayer) return NULL;
        auto *players = getPlayerDict(Match);
        if (!players) return NULL;
        for (int u = 0; u < players->getSize(); u++) {
            void *p = players->getValues()[u];
            if (!p || p == LocalPlayer) continue;
            if (game_sdk->get_IsDieing(p) || game_sdk->get_isLocalTeam(p)) continue;
            float d = Vector3::Distance(getPosition(LocalPlayer), getPosition(p));
            if (d < 200 && d < best) { best = d; closest = p; }
        }
        return closest;
    } catch (...) { return NULL; }
}

void ProcessAimbot() {
    if (!Vars.Aimbot) return;
    void *Match = game_sdk->Curent_Match();
    void *LocalPlayer = game_sdk->GetLocalPlayer(Match);
    void *closestEnemy = GetClosestEnemy();
    if (!LocalPlayer || !closestEnemy) return;
    Vector3 EnemyLocation = GetHeadPosition(closestEnemy);
    Vector3 PlayerLocation = CameraMain();
    if (EnemyLocation == Vector3::zero() || PlayerLocation == Vector3::zero()) return;
    bool shouldAim = (Vars.AimWhen == 0) ||
                     (Vars.AimWhen == 1 && game_sdk->get_IsFiring(LocalPlayer)) ||
                     (Vars.AimWhen == 2 && game_sdk->get_IsSighting(LocalPlayer)) ||
                     (Vars.AimWhen == 3 && (game_sdk->get_IsFiring(LocalPlayer) || game_sdk->get_IsSighting(LocalPlayer)));
    if (shouldAim) {
        Quaternion TargetLook = GetRotationToTheLocation(EnemyLocation, 0.05f, PlayerLocation);
        if (game_sdk->set_aim) game_sdk->set_aim(LocalPlayer, TargetLook);
    }
}


void ProcessSpeedHack() {
    if (!Vars.SpeedHack) return;
    try {
        void *m = game_sdk->Curent_Match(); if (!m) return;
        void *lp = game_sdk->GetLocalPlayer(m); if (!lp) return;
        static void (*_fn)(void*, float) = (void(*)(void*, float))getRealOffset(oxo("0x5DABABC"));
        if (_fn) _fn(lp, Vars.SpeedMult);
    } catch (...) {}
}


void ProcessRapidFire() {
    if (!Vars.RapidFire) return;
    try {
        void *m = game_sdk->Curent_Match(); if (!m) return;
        void *lp = game_sdk->GetLocalPlayer(m); if (!lp) return;
        static void *(*_GetWeapon)(void*) = (void*(*)(void*))getRealOffset(oxo("0x53BE110"));
        static void (*_setFS)(void*, float) = (void(*)(void*, float))getRealOffset(oxo("0x609AD70"));
        if (!_GetWeapon || !_setFS) return;
        void *weapon = _GetWeapon(lp); if (!weapon) return;
        _setFS(weapon, 0.01f);
    } catch (...) {}
}


static float s_flyTargetY = -99999.f;
void ProcessFlyHack() {
    if (!Vars.FlyHack) {
        s_flyTargetY = -99999.f;  // reset 
        return;
    }
    try {
        void *m = game_sdk->Curent_Match(); if (!m) return;
        void *lp = game_sdk->GetLocalPlayer(m); if (!lp) return;
        ensureForceSetPos();
        if (!_ForceSetPos) return;
        Vector3 myPos = getPosition(lp);
        if (myPos == Vector3::zero()) return;
        // Y-8m
        if (s_flyTargetY < -99998.f)
            s_flyTargetY = myPos.y + 8.0f;
        //  Y à¹à¸«à¹à¸à¸´à¹à¸
        _ForceSetPos(lp, Vector3(myPos.x, s_flyTargetY, myPos.z));
    } catch (...) {}
}


void ProcessAimMagnet() {
    if (!Vars.AimMagnet) return;
    try {
        void *m = game_sdk->Curent_Match(); if (!m) return;
        void *lp = game_sdk->GetLocalPlayer(m); if (!lp) return;
        // scope à¸­à¸¢à¸¹à¹
        if (!game_sdk->get_IsFiring(lp) && !game_sdk->get_IsSighting(lp)) return;
        ensureForceSetPos();
        if (!_ForceSetPos) return;
        Vector3 myPos = getPosition(lp);
        auto *pl = getPlayerDict(m); if (!pl) return;
        for (int u = 0; u < pl->getSize(); u++) {
            void *e = pl->getValues()[u];
            if (!e || e == lp) continue;
            if (!game_sdk->get_MaxHP(e) || game_sdk->get_IsDieing(e) || game_sdk->get_isLocalTeam(e)) continue;
            Vector3 ep = getPosition(e);
            float dist = Vector3::Distance(myPos, ep);
            if (dist > Vars.MagnetRange || dist < 1.5f) continue;
            
            Vector3 dir = Vector3::Normalized(myPos - ep);
            _ForceSetPos(e, ep + dir * 4.0f);
        }
    } catch (...) {}
}


void ProcessAimManager() {
    if (!Vars.AimManager) return;
    try {
        void *m = game_sdk->Curent_Match(); if (!m) return;
        void *lp = game_sdk->GetLocalPlayer(m); if (!lp) return;
        ensureForceSetPos();
        if (!_ForceSetPos) return;
        void *cam = game_sdk->get_camera(); if (!cam) return;
        void *camTf = game_sdk->Component_GetTransform(cam); if (!camTf) return;
        Vector3 camPos = game_sdk->get_position(camTf);
        Vector3 camFwd = game_sdk->GetForward(camTf);
        auto *pl = getPlayerDict(m); if (!pl) return;
        for (int u = 0; u < pl->getSize(); u++) {
            void *e = pl->getValues()[u];
            if (!e || e == lp) continue;
            if (!game_sdk->get_MaxHP(e) || game_sdk->get_IsDieing(e) || game_sdk->get_isLocalTeam(e)) continue;
        
            if (game_sdk->get_isVisible(e)) continue;
            float dist = Vector3::Distance(camPos, getPosition(e));
            if (dist > 200.f) continue;
      
            Vector3 newPos = camPos + camFwd * Vars.AimMgrDist;
            newPos.y = getPosition(e).y;
            _ForceSetPos(e, newPos);
        }
    } catch (...) {}
}


void ProcessPullPlayer() {
    if (!Vars.PullPlayer) return;
    try {
        void *m = game_sdk->Curent_Match(); if (!m) return;
        void *lp = game_sdk->GetLocalPlayer(m); if (!lp) return;
        ensureForceSetPos();
        if (!_ForceSetPos) return;
        void *cam = game_sdk->get_camera(); if (!cam) return;
        void *camTf = game_sdk->Component_GetTransform(cam); if (!camTf) return;
        Vector3 camPos = game_sdk->get_position(camTf);
        Vector3 camFwd = game_sdk->GetForward(camTf);
        auto *pl = getPlayerDict(m); if (!pl) return;
       
        float nearDist = 9999.f;
        void *target = nullptr;
        for (int u = 0; u < pl->getSize(); u++) {
            void *e = pl->getValues()[u];
            if (!e || e == lp) continue;
            if (!game_sdk->get_MaxHP(e) || game_sdk->get_IsDieing(e) || game_sdk->get_isLocalTeam(e)) continue;
            float d = Vector3::Distance(getPosition(e), camPos);
            if (d < nearDist) { nearDist = d; target = e; }
        }
        if (!target) return;
   
        Vector3 pullPos = camPos + camFwd * Vars.PullDist;
        pullPos.y = getPosition(target).y;  // à¸£à¸±à¸à¸©à¸² Y à¸à¸­à¸à¸¨à¸±à¸à¸£à¸¹à¹à¸§à¹
        _ForceSetPos(target, pullPos);
    } catch (...) {}
}

void get_players()
{
    if (!Vars.Enable) return;
    try {
        ProcessAimbot();
        ProcessSpeedHack();
        ProcessRapidFire();
        ProcessFlyHack();
        ProcessAimMagnet();
        ProcessAimManager();
        ProcessPullPlayer();

        void *Match = game_sdk->Curent_Match();
        if (!Match) return;
        void *LocalPlayer = game_sdk->GetLocalPlayer(Match);
        if (!LocalPlayer) return;
        auto *players = getPlayerDict(Match);
        if (!players) return;

        ImDrawList *draw_list = ImGui::GetBackgroundDrawList();
        for (int u = 0; u < players->getSize(); u++) {
            void *enemy = players->getValues()[u];
            if (!enemy || enemy == LocalPlayer) continue;
            if (game_sdk->get_IsDieing(enemy) || game_sdk->get_isLocalTeam(enemy)) continue;

            Vector3 pos = getPosition(enemy);
            bool w2sc;
            ImVec2 bot_pos = Camera$$WorldToScreen::Checker(pos, w2sc);
            if (!w2sc) continue;

            if (Vars.lines) draw_list->AddLine(ImVec2(ImGui::GetIO().DisplaySize.x / 2, 0), bot_pos, ImColor(255, 255, 255));
            if (Vars.Box)   draw_list->AddRect(ImVec2(bot_pos.x - 20, bot_pos.y - 40), ImVec2(bot_pos.x + 20, bot_pos.y), ImColor(255, 255, 255));
            if (Vars.Name) {
                auto pname = game_sdk->name(enemy);
                if (pname) AddText(verdana_smol, 8, false, true, ImVec2(bot_pos.x - 20, bot_pos.y - 55), ImColor(255, 255, 255), pname->toCPPString().c_str());
            }
        }
    } catch (...) {}
}

void aimbot() {
    if (Vars.Aimbot && Vars.isAimFov) {
        ImVec2 center(ImGui::GetIO().DisplaySize.x / 2, ImGui::GetIO().DisplaySize.y / 2);
        ImGui::GetBackgroundDrawList()->AddCircle(center, Vars.AimFov, ImColor(255, 255, 255), 100);
    }
}
