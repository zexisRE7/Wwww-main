#import "vinhtran.hpp"
#import "loading.hxx"
#include <fstream>
#include <chrono>
#include <algorithm>
#include <cmath>
#define FMT_HEADER_ONLY
#include "fmt/core.h"

bool SilentAim = false;
bool CheckWall1 = false;

enum FireMode { MANUL, AUTO };
enum FireStatus { NONE, FIRING, CANCEL };
static float FireDelay = 0.01f;

struct Vars_t
{
    bool Enable = false;
    bool Box = false;
    bool lines = false;
    bool skeleton = false;
    bool Name = false;
    bool Distance = false;
    bool Health = false;
    bool Outline = false;
    bool enemycount = false;
    bool fovaimglow = false;
    bool OOF = false;
    bool circlepos = false;
    bool ShurikenOnHead = false;    // กงจักรหมุนบนหัว
    bool SnowEffect = false;        // หิมะตกตามเส้น ESP
    
    bool Aimbot = false;
    bool ShowFovCircle = false;
    float AimFov = 500.0f;
    int AimWhen = 3;
    int AimHitbox = 0;
    float AimSpeed = 10.0f;
    bool VisibleCheck = false;
    bool IgnoreKnocked = false;
    bool AutoFire = false;
    bool isAimFov = false;
    
    bool NinjaRun = false;
    float NinjaRunSpeed = 0.1f;
    float NinjaRunHeight = 0.0f;
    bool UpPlayerOne = false;
    bool Telekill = false;
    
    int CurrentTab = 0;
} Vars;

struct HitObjectInfo {
    void *klass;
    void *monitor;
    bool m_IsInPool;
    void *HitObject;
    void *HitCollider;
    Vector3 HitLocation;
    Vector3 HitNormal;
    Vector3 RayDir;
    Vector3 StartPosition;
    int32_t Damage;
    float Distance;
    int32_t ActorLayer;
    int32_t HitGroup;
    void *HitPhysicMaterial;
    bool IgnoreHappens;
    bool ViewBlocked;
    Vector3 OrigStartPosition;
    uint8_t SpecialHitType;
    uint32_t SpecialHitLevelObjID;
};

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
    void *(*_GetHeadPositions)(void *);
    void *(*_newHipMods)(void *);
    void *(*_GetLeftAnkleTF)(void *);
    void *(*_GetRightAnkleTF)(void *);
    void *(*_GetLeftToeTF)(void *);
    void *(*_GetRightToeTF)(void *);
    void *(*_getLeftHandTF)(void *);
    void *(*_getRightHandTF)(void *);
    void *(*_getLeftForeArmTF)(void *);
    void *(*_getRightForeArmTF)(void *);
};

game_sdk_t *game_sdk = new game_sdk_t();
void initAutoFireHook();

void game_sdk_t::init()
{
    this->GetHp = (int (*)(void *))getRealOffset(oxo("0x4A8478C"));
    this->Curent_Match = (void *(*)())getRealOffset(oxo("0x4E355B0"));
    this->GetLocalPlayer = (void *(*)(void *))getRealOffset(oxo("0x28FC854"));
    this->GetHeadPositions = (void *(*)(void *))getRealOffset(oxo("0x4AA1A28"));
    this->get_position = (Vector3(*)(void *))getRealOffset(oxo("0x8552BAC"));
    this->Component_GetTransform = (void *(*)(void *))getRealOffset(oxo("0x854060C"));
    this->get_camera = (void *(*)())getRealOffset(oxo("0x84E7148"));
    this->WorldToViewpoint = (Vector3(*)(void*, Vector3, int))getRealOffset(oxo("0x84E6AC8"));
    this->get_isVisible = (bool (*)(void *))getRealOffset(oxo("0x4A20AF4"));
    this->get_isLocalTeam = (bool (*)(void *))getRealOffset(oxo("0x4A38D90"));
    this->get_IsDieing = (bool (*)(void *))getRealOffset(oxo("0x4A02EA8"));
    this->get_MaxHP = (int (*)(void *))getRealOffset(oxo("0x4A8489C"));
    this->GetForward = (Vector3(*)(void *))getRealOffset(oxo("0x85534CC"));
    this->set_aim = (void (*)(void *, Quaternion))getRealOffset(oxo("0x4A1C91C"));
    this->get_IsSighting = (bool (*)(void *))getRealOffset(oxo("0x4A0FF18"));
    this->get_IsFiring = (bool (*)(void *))getRealOffset(oxo("0x4A05634"));
    this->name = (monoString * (*)(void *player)) getRealOffset(oxo("0x4A16D38"));
    this->_GetHeadPositions = (void *(*)(void *))getRealOffset(oxo("0x4AA1A28"));
    this->_newHipMods = (void *(*)(void *))getRealOffset(oxo("0x4AA1BD8"));
    this->_GetLeftAnkleTF = (void *(*)(void *))getRealOffset(oxo("0x4AA2028"));
    this->_GetRightAnkleTF = (void *(*)(void *))getRealOffset(oxo("0x4AA2134"));
    this->_GetLeftToeTF = (void *(*)(void *))getRealOffset(oxo("0x4AA2240"));
    this->_GetRightToeTF = (void *(*)(void *))getRealOffset(oxo("0x4AA234C"));
    this->_getLeftHandTF = (void *(*)(void *))getRealOffset(oxo("0x4A1B9B4"));
    this->_getRightHandTF = (void *(*)(void *))getRealOffset(oxo("0x4A1BAB8"));
    this->_getLeftForeArmTF = (void *(*)(void *))getRealOffset(oxo("0x4A1BBBC"));
    this->_getRightForeArmTF = (void *(*)(void *))getRealOffset(oxo("0x4A1BCC0"));
}

static void Transform_INTERNAL_SetPosition(void *transform, Vvector3 in) {
    void (*_Transform_INTERNAL_SetPosition)(void *transform, Vvector3 in) =
        (void (*)(void *, Vvector3))getRealOffset(oxo("0x8552CE8"));
    _Transform_INTERNAL_SetPosition(transform, in);
}

bool IsGod(void *player){ return *(bool *)((uint64_t)player + 0xF4C); }
void *get_gameObject(void *Pthis) { return ((void* (*)(void *))getRealOffset(0x854065C))(Pthis); }
static void *GetWeaponOnHand1(void *local) { void *(*_GetWeaponOnHand1)(void *local) = (void *(*)(void *))getRealOffset(0x4A16560); return _GetWeaponOnHand1(local); }
static Vector3 Transform_INTERNAL_GetPosition(void *player) { Vector3 out = Vector3::zero(); void (*_Transform_INTERNAL_GetPosition)(void *transform, Vector3 * out) = (void (*)(void *, Vector3 *))getRealOffset(ENCRYPTOFFSET("0x8552C10")); _Transform_INTERNAL_GetPosition(player, &out); return out; }

static Vector3 lastNinjaRunPos = Vector3::zero();
static bool lastNinjaWasActive = false;

void SetNinjaRunSpeedPreset(int preset) {
    switch (preset) { case 0: Vars.NinjaRunSpeed = 0.5f; break; case 1: Vars.NinjaRunSpeed = 1.0f; break; case 2: Vars.NinjaRunSpeed = 2.5f; break; case 3: Vars.NinjaRunSpeed = 5.0f; break; default: break; }
}

void RunNinjaRun() {
    if (!Vars.Enable || !Vars.NinjaRun) return;
    void* match = game_sdk->Curent_Match();
    if (!match) return;
    void* local = game_sdk->GetLocalPlayer(match);
    if (!local) return;
    void* transform = game_sdk->Component_GetTransform(local);
    if (!transform) return;
    Vector3 currentPos = game_sdk->get_position(transform);
    Vector3 forward = game_sdk->GetForward(transform);
    float moveAmount = Vars.NinjaRunSpeed * 0.1f;
    currentPos.x += forward.x * moveAmount;
    currentPos.y += forward.y * moveAmount;
    currentPos.z += forward.z * moveAmount;
    currentPos.y += Vars.NinjaRunHeight * 0.01f;
    lastNinjaRunPos = currentPos;
    lastNinjaWasActive = true;
    Vvector3 newPos;
    newPos.X = currentPos.x;
    newPos.Y = currentPos.y;
    newPos.Z = currentPos.z;
    Transform_INTERNAL_SetPosition(transform, newPos);
}

namespace Camera$$WorldToScreen
{
    ImVec2 Regular(Vector3 pos) {
        auto cam = game_sdk->get_camera();
        if (!cam) return {0,0};
        Vector3 worldPoint = game_sdk->WorldToViewpoint(cam,pos, 2);
        Vector3 location;
        int ScreenWidth = ImGui::GetIO().DisplaySize.x;
        int ScreenHeight = ImGui::GetIO().DisplaySize.y;
        location.x = ScreenWidth * worldPoint.x;
        location.y = ScreenHeight = ScreenHeight - worldPoint.y * ScreenHeight;
        location.z = worldPoint.z;
        return {location.x, location.y};
    }
    
    ImVec2 Checker(Vector3 pos, bool &checker) {
        auto cam = game_sdk->get_camera();
        if (!cam) return {0, 0};
        Vector3 worldPoint = game_sdk->WorldToViewpoint(cam,pos, 4);
        Vector3 location;
        int ScreenWidth = ImGui::GetIO().DisplaySize.x;
        int ScreenHeight = ImGui::GetIO().DisplaySize.y;
        location.x = ScreenWidth * worldPoint.x;
        location.y = ScreenHeight = ScreenHeight - worldPoint.y * ScreenHeight;
        location.z = worldPoint.z;
        checker = location.z > 1;
        return {location.x, location.y};
    }
}

Vector3 GetBonePosition(void *player, void *(*transformGetter)(void *)) {
    if (!player || !transformGetter) return Vector3();
    void *transform = transformGetter(player);
    return transform ? game_sdk->get_position(game_sdk->Component_GetTransform(transform)) : Vector3();
}

Vector3 GetHitboxPosition(void* player, int hitbox) {
    if (!player) return Vector3::zero();
    switch (hitbox) {
        case 0: return GetBonePosition(player, game_sdk->GetHeadPositions);
        case 1: { Vector3 headPos = GetBonePosition(player, game_sdk->GetHeadPositions); return headPos == Vector3::zero() ? headPos : Vector3(headPos.x, headPos.y - 0.2f, headPos.z); }
        case 2: { Vector3 headPos = GetBonePosition(player, game_sdk->GetHeadPositions); return headPos == Vector3::zero() ? headPos : Vector3(headPos.x, headPos.y - 0.4f, headPos.z); }
        default: return GetBonePosition(player, game_sdk->GetHeadPositions);
    }
}

Vector3 getPosition(void *player) { return game_sdk->get_position(game_sdk->Component_GetTransform(player)); }
Vector3 GetHeadPosition(void *player) { return game_sdk->get_position(game_sdk->GetHeadPositions(player)); }
static Vector3 CameraMain(void *player) { return game_sdk->get_position(*(void **)((uint64_t)player + oxo("0x390"))); }

Quaternion GetRotationToTheLocation(Vector3 Target, float Height, Vector3 MyEnemy) {
    Vector3 direction = (Target + Vector3(0, Height, 0)) - MyEnemy;
    return Quaternion::LookRotation(direction, Vector3(0, 1, 0));
}

Quaternion GetCurrentRotation(void* player) {
    void* transform = game_sdk->Component_GetTransform(player);
    if (!transform) return Quaternion();
    return Quaternion::LookRotation(game_sdk->GetForward(transform), Vector3(0, 1, 0));
}

#include "Helper/Ext.h"

class tanghinh {
public:
    static Vector3 Transform_GetPosition(void *player) {
        Vector3 out = Vector3::zero();
        void (*_Transform_GetPosition)(void *transform, Vector3 *out) = (void (*)(void *, Vector3 *))getRealOffset(oxo("0x8552C10"));
        _Transform_GetPosition(player, &out);
        return out;
    }
    static void *Player_GetHeadCollider(void *player) {
        void *(*_Player_GetHeadCollider)(void *players) = (void *(*)(void *))getRealOffset(oxo("0x4A1A9D4"));
        return _Player_GetHeadCollider(player);
    }
    static bool Physics_Raycast(Vector3 camLocation, Vector3 headLocation, unsigned int LayerID, void *collider) {
        bool (*_Physics_Raycast)(Vector3 camLocation, Vector3 headLocation, unsigned int LayerID, void *collider) = (bool (*)(Vector3, Vector3, unsigned int, void *))getRealOffset(oxo("0x5580870"));
        return _Physics_Raycast(camLocation, headLocation, LayerID, collider);
    }
    static bool isVisible(void *enemy) {
        if (enemy != NULL) {
            void *hitObj = NULL;
            auto Camera = Transform_GetPosition(game_sdk->Component_GetTransform(game_sdk->get_camera()));
            auto Target = Transform_GetPosition(game_sdk->Component_GetTransform(Player_GetHeadCollider(enemy)));
            return !Physics_Raycast(Camera, Target, 12, &hitObj);
        }
        return false;
    }
};

void AddDashedLine(ImDrawList* draw, ImVec2 p1, ImVec2 p2, ImU32 col, float thickness, float dash_len, float gap_len) {
    float len = sqrtf((p2.x-p1.x)*(p2.x-p1.x)+(p2.y-p1.y)*(p2.y-p1.y));
    if(len<0.001f) return;
    float dx=(p2.x-p1.x)/len, dy=(p2.y-p1.y)/len;
    for(float t=0; t<len; t+=dash_len+gap_len) {
        ImVec2 s(p1.x+dx*t,p1.y+dy*t), e(p1.x+dx*(t+dash_len),p1.y+dy*(t+dash_len));
        draw->AddLine(s,e,col,thickness);
    }
}

void DrawSkeleton(void *player, ImDrawList *drawList) {
    if(!player||!drawList) return;
    Vector3 headPos = GetBonePosition(player, game_sdk->_GetHeadPositions);
    Vector3 hipPos = GetBonePosition(player, game_sdk->_newHipMods);
    Vector3 leftAnklePos = GetBonePosition(player, game_sdk->_GetLeftAnkleTF);
    Vector3 rightAnklePos = GetBonePosition(player, game_sdk->_GetRightAnkleTF);
    Vector3 leftToePos = GetBonePosition(player, game_sdk->_GetLeftToeTF);
    Vector3 rightToePos = GetBonePosition(player, game_sdk->_GetRightToeTF);
    Vector3 leftHandPos = GetBonePosition(player, game_sdk->_getLeftHandTF);
    Vector3 rightHandPos = GetBonePosition(player, game_sdk->_getRightHandTF);
    Vector3 leftForeArmPos = GetBonePosition(player, game_sdk->_getLeftForeArmTF);
    Vector3 rightForeArmPos = GetBonePosition(player, game_sdk->_getRightForeArmTF);
    bool visible;
    ImVec2 headScreen = Camera$$WorldToScreen::Checker(headPos, visible);
    if(!visible) return;
    ImVec2 hipScreen = Camera$$WorldToScreen::Regular(hipPos);
    ImVec2 leftAnkleScreen = Camera$$WorldToScreen::Regular(leftAnklePos);
    ImVec2 rightAnkleScreen = Camera$$WorldToScreen::Regular(rightAnklePos);
    ImVec2 leftToeScreen = Camera$$WorldToScreen::Regular(leftToePos);
    ImVec2 rightToeScreen = Camera$$WorldToScreen::Regular(rightToePos);
    ImVec2 leftHandScreen = Camera$$WorldToScreen::Regular(leftHandPos);
    ImVec2 rightHandScreen = Camera$$WorldToScreen::Regular(rightHandPos);
    ImVec2 leftForeArmScreen = Camera$$WorldToScreen::Regular(leftForeArmPos);
    ImVec2 rightForeArmScreen = Camera$$WorldToScreen::Regular(rightForeArmPos);
    ImColor boneColor = ImColor(255,165,0);
    float thickness=2.5f;
    drawList->AddCircle(headScreen,2.0f,boneColor,12,thickness);
    drawList->AddLine(headScreen,hipScreen,boneColor,thickness);
    drawList->AddLine(headScreen,leftForeArmScreen,boneColor,thickness);
    drawList->AddLine(headScreen,rightForeArmScreen,boneColor,thickness);
    drawList->AddLine(leftForeArmScreen,leftHandScreen,boneColor,thickness);
    drawList->AddLine(rightForeArmScreen,rightHandScreen,boneColor,thickness);
    drawList->AddLine(hipScreen,leftAnkleScreen,boneColor,thickness);
    drawList->AddLine(hipScreen,rightAnkleScreen,boneColor,thickness);
    drawList->AddLine(leftAnkleScreen,leftToeScreen,boneColor,thickness);
    drawList->AddLine(rightAnkleScreen,rightToeScreen,boneColor,thickness);
}

bool isFov(Vector3 vec1, Vector3 vec2, int radius) {
    int x = vec1.x, y = vec1.y, x0 = vec2.x, y0 = vec2.y;
    return ((x-x0)*(x-x0)+(y-y0)*(y-y0)) <= radius*radius;
}

void *GetClosestEnemy() {
    try {
        float shortestDistance = 9999.0f;
        void *closestEnemy = NULL;
        void *get_MatchGame = game_sdk->Curent_Match();
        if (!get_MatchGame) return NULL;
        void *LocalPlayer = game_sdk->GetLocalPlayer(get_MatchGame);
        if (!LocalPlayer || !game_sdk->Component_GetTransform(LocalPlayer)) return NULL;
        if (!Vars.Enable) return NULL;
        Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)get_MatchGame + oxo("0x148"));
        if (!players) return NULL;
        for (int u = 0; u < players->getSize(); u++) {
            void *Player = players->getValues()[u];
            if (!Player) continue;
            if (Player == LocalPlayer) continue;
            if (!game_sdk->get_MaxHP(Player)) continue;
            if (game_sdk->get_IsDieing(Player)) continue;
            if (!game_sdk->get_isVisible(Player)) continue;
            if (game_sdk->get_isLocalTeam(Player)) continue;
            Vector3 PlayerPos = getPosition(Player);
            Vector3 LocalPlayerPos = getPosition(LocalPlayer);
            ImVec2 screenPos = Camera$$WorldToScreen::Regular(PlayerPos);
            bool isFov1 = isFov(Vector3(screenPos.x, screenPos.y), Vector3(ImGui::GetIO().DisplaySize.x / 2, ImGui::GetIO().DisplaySize.y / 2), Vars.AimFov);
            float distance = Vector3::Distance(LocalPlayerPos, PlayerPos);
            if (distance < 200) {
                Vector3 targetDir = Vector3::Normalized(PlayerPos - LocalPlayerPos);
                float angle = Vector3::Angle(targetDir, game_sdk->GetForward(game_sdk->Component_GetTransform(game_sdk->get_camera()))) * 100.0f;
                if (angle <= Vars.AimFov && isFov1 && angle < shortestDistance) {
                    if (tanghinh::isVisible(Player)) {
                        shortestDistance = angle;
                        closestEnemy = Player;
                    }
                }
            }
        }
        return closestEnemy;
    } catch(...){return NULL;}
}

void ProcessAimbot() {
    if(!Vars.Aimbot) return;
    void *CurrentMatch = game_sdk->Curent_Match();
    if(!CurrentMatch) return;
    void *LocalPlayer = game_sdk->GetLocalPlayer(CurrentMatch);
    if(!LocalPlayer||!game_sdk->Component_GetTransform(LocalPlayer)) return;
    void *closestEnemy = GetClosestEnemy();
    if(!closestEnemy||!game_sdk->Component_GetTransform(closestEnemy)) return;
    Vector3 EnemyLocation = GetHitboxPosition(closestEnemy, Vars.AimHitbox);
    if(EnemyLocation==Vector3::zero()) return;
    Vector3 PlayerLocation = CameraMain(LocalPlayer);
    if(PlayerLocation==Vector3::zero()) return;
    bool IsScopeOn = game_sdk->get_IsSighting(LocalPlayer);
    bool IsFiring = game_sdk->get_IsFiring(LocalPlayer);
    bool shouldAim = (Vars.AimWhen==0)||(Vars.AimWhen==1&&IsFiring)||(Vars.AimWhen==2&&IsScopeOn)||(Vars.AimWhen==3&&(IsFiring||IsScopeOn));
    if(shouldAim&&(!Vars.VisibleCheck||tanghinh::isVisible(closestEnemy))){
        Quaternion TargetLook = GetRotationToTheLocation(EnemyLocation,0.05f,PlayerLocation);
        game_sdk->set_aim(LocalPlayer,TargetLook);
    }
}

void RunTelekill() {
    if(!Vars.Enable||!Vars.Telekill) return;
    void *match = game_sdk->Curent_Match();
    if(!match) return;
    void *local = game_sdk->GetLocalPlayer(match);
    if(!local||!game_sdk->Component_GetTransform(local)) return;
    Dictionary<uint8_t*,void**>* players = *(Dictionary<uint8_t*,void**>**)((long)match+0x148);
    if(!players||!players->getValues()) return;
    void *localTF = game_sdk->Component_GetTransform(local);
    Vector3 localPos = game_sdk->get_position(localTF);
    Vector3 forward = game_sdk->GetForward(localTF);
    for(int i=0;i<players->getNumValues();i++){
        void* enemy = players->getValues()[i];
        if(!enemy||enemy==local) continue;
        if(!game_sdk->Component_GetTransform(enemy)) continue;
        if(!game_sdk->get_MaxHP(enemy)) continue;
        if(game_sdk->get_IsDieing(enemy)) continue;
        if(game_sdk->GetHp(enemy)<=0) continue;
        if(game_sdk->get_isLocalTeam(enemy)) continue;
        void *enemyTF = game_sdk->Component_GetTransform(enemy);
        Vector3 enemyPos = game_sdk->get_position(enemyTF);
        if(Vector3::Distance(localPos,enemyPos)>8.0f) continue;
        Vector3 stableFront = localPos + forward*0.5f;
        stableFront.y = localPos.y;
        Transform_INTERNAL_SetPosition(enemyTF, Vvector3(stableFront.x,stableFront.y,stableFront.z));
    }
}

void SpeedAuto() {
    void* match = game_sdk->Curent_Match();
    if(!match) return;
    void* player = game_sdk->GetLocalPlayer(match);
    if(!player) return;
    void* PlayerAttributes = *(void**)((uint64_t)player+0x708);
    if(PlayerAttributes) *(float*)((uintptr_t)PlayerAttributes+0x250)=1.9f;
}

void get_players() {
    ImDrawList *draw_list = ImGui::GetBackgroundDrawList();
    if (!draw_list) return;
    initAutoFireHook();
    if (!Vars.Enable) return;
    static int g_EnemyCount = 0;
    static int g_KnockedCount = 0;
    
    // Throttle: วาดทุก 2 เฟรม
    static int frame=0;
    frame++;
    if(frame%2!=0) return;
    
    try {
        if(Vars.Enable){
            ProcessAimbot();
            if(Vars.UpPlayerOne){
                // UpOneEnemy ซ่อนไว้สั้นลง
            }
            if(Vars.NinjaRun) RunNinjaRun();
        }
        RunTelekill();
        SpeedAuto();
        
        void *current_Match = game_sdk->Curent_Match();
        if(!current_Match) return;
        void *local_player = game_sdk->GetLocalPlayer(current_Match);
        if(!local_player) return;
        Dictionary<uint8_t*,void**>* players = *(Dictionary<uint8_t*,void**>**)((long)current_Match+0x148);
        if(!players) return;
        g_EnemyCount=0; g_KnockedCount=0;
        
        for(int u=0; u<players->getSize(); u++){
            void *closestEnemy = players->getValues()[u];
            if(!closestEnemy) continue;
            if(closestEnemy==local_player) continue;
            if(!game_sdk->get_MaxHP(closestEnemy)) continue;
            if(game_sdk->get_isLocalTeam(closestEnemy)) continue;
            if(game_sdk->get_IsDieing(closestEnemy)){ g_KnockedCount++; continue; }
            if(!game_sdk->get_isVisible(closestEnemy)) continue;
            g_EnemyCount++;
            
            Vector3 pos = getPosition(closestEnemy);
            Vector3 localPos = getPosition(local_player);
            float distance = Vector3::Distance(pos,localPos);
            if(distance>200.0f) continue;
            
            bool w2sc;
            ImVec2 top_pos = Camera$$WorldToScreen::Regular(pos+Vector3(0,1.6,0));
            ImVec2 bot_pos = Camera$$WorldToScreen::Regular(pos);
            ImVec2 pos_3 = Camera$$WorldToScreen::Checker(pos,w2sc);
            auto pmtXtop=top_pos.x, pmtXbottom=bot_pos.x;
            if(top_pos.x>bot_pos.x){ pmtXtop=bot_pos.x; pmtXbottom=top_pos.x; }
            Camera$$WorldToScreen::Checker(pos+Vector3(0,0.75f,0),w2sc);
            float cp = fabs((top_pos.y-bot_pos.y)*(0.0092f/0.019f)/2);
            ImRect rect(ImVec2(pmtXtop-cp,top_pos.y), ImVec2(pmtXbottom+cp,bot_pos.y));
            
            if(w2sc){
                // ----- ESP เส้นล่างจอ (foot line) แทนเส้นบน -----
                if(Vars.lines){
                    ImU32 lineColor = IM_COL32(100,210,255,200); // น้ำเงินฟ้าอ่อน
                    float screenW = ImGui::GetIO().DisplaySize.x;
                    float screenH = ImGui::GetIO().DisplaySize.y;
                    ImVec2 footBase = ImVec2(rect.GetCenter().x, rect.Max.y);
                    ImVec2 startBase = ImVec2(rect.GetCenter().x, screenH);
                    draw_list->AddLine(startBase, footBase, lineColor, 1.8f);
                    
                    // สโนว์เอฟเฟกต์หิมะตกตามเส้น ESP
                    if(Vars.SnowEffect){
                        static float snowTime=0;
                        snowTime += ImGui::GetIO().DeltaTime*5.0f;
                        for(int i=0;i<3;i++){
                            float offset = fmodf(snowTime+(i*0.7f),1.0f);
                            ImVec2 snowPoint(
                                rect.GetCenter().x + (sinf(snowTime*8.0f+i)*3.0f),
                                screenH - (screenH - rect.Max.y)*offset
                            );
                            draw_list->AddCircleFilled(snowPoint, 2.0f, IM_COL32(180,230,255,200));
                        }
                    }
                }
                
                // Box + Name + Health + Distance (คงเดิม ใส่สีเขียวฟ้าอ่อน)
                if(Vars.Box){
                    if(game_sdk->get_IsDieing(closestEnemy)) draw_list->AddRect(rect.Min,rect.Max, ImColor(255,0,0));
                    else draw_list->AddRect(rect.Min,rect.Max, ImColor(100,210,255));
                    if(Vars.Outline){ draw_list->AddRect(ImVec2(rect.Min.x-1,rect.Min.y-1),ImVec2(rect.Max.x+1,rect.Max.y+1),ImColor(0,0,0),0.65,0,1);
                                      draw_list->AddRect(ImVec2(rect.Min.x+1,rect.Min.y+1),ImVec2(rect.Max.x-1,rect.Max.y-1),ImColor(0,0,0),0.65,0,1); }
                }
                if(Vars.Name){
                    auto pname = game_sdk->name(closestEnemy);
                    std::string names = pname ? pname->toCPPString() : "null";
                    std::transform(names.begin(),names.end(),names.begin(),::tolower);
                    ImVec2 ts = verdana_smol->CalcTextSizeA(8,FLT_MAX,0,names.c_str());
                    ImVec2 np = { rect.Min.x+(rect.GetWidth()/2)-ts.x/2, rect.Min.y-2-ts.y };
                    AddText(verdana_smol,8,false,Vars.Outline,np,ImColor(100,210,255),names);
                }
                if(Vars.Health){
                    int hp = game_sdk->GetHp(closestEnemy);
                    int mhp = game_sdk->get_MaxHP(closestEnemy);
                    float pm = (float)hp/(float)mhp;
                    float hpX=rect.Min.x-4;
                    draw_list->AddLine({hpX,rect.Min.y-1},{hpX,rect.Max.y},ImColor(0,0,0,100),3);
                    draw_list->AddLine({hpX-0.5f,rect.Max.y},{hpX-0.5f,rect.Max.y-(rect.GetHeight()+1)*pm},ImColor(100,210,255),3);
                    std::string hpt=fmt::format(oxorany("{}HP"),hp);
                    ImVec2 thp = pixel_smol->CalcTextSizeA(8,FLT_MAX,0,hpt.c_str());
                    ImVec2 php = { rect.Min.x+(rect.GetWidth()/2)-thp.x/2, rect.Max.y };
                    AddText(pixel_smol,8,false,true,php,ImColor(100,210,255),hpt);
                }
                if(Vars.Distance){
                    std::string dst=fmt::format(oxorany("{}M"),(int)distance);
                    AddText(pixel_smol,8,false,true,{rect.Max.x+4,rect.Min.y},ImColor(100,210,255),dst);
                }
                
                // Skeleton
                if(Vars.skeleton) DrawSkeleton(closestEnemy,draw_list);
                
                // HEAD QUAD + INFO BOX (สีเขียวฟ้าอ่อน)
                Vector3 headPos = GetHeadPosition(closestEnemy);
                bool w2sh;
                ImVec2 hs = Camera$$WorldToScreen::Checker(headPos,w2sh);
                if(w2sh){
                    const float ds=24.0f;
                    const ImU32 aquaColor = IM_COL32(100,210,255,255);
                    const ImU32 aquaFill = IM_COL32(100,210,255,50);
                    ImVec2 dTop={hs.x,hs.y-ds}, dRgt={hs.x+ds,hs.y}, dBot={hs.x,hs.y+ds}, dLft={hs.x-ds,hs.y};
                    draw_list->AddQuad(dTop,dRgt,dBot,dLft,aquaColor,2.0f);
                    draw_list->AddQuadFilled(dTop,dRgt,dBot,dLft,aquaFill);
                    
                    int hp = game_sdk->GetHp(closestEnemy);
                    int maxHP = game_sdk->get_MaxHP(closestEnemy);
                    if(maxHP<=0) maxHP=200;
                    const float bx=hs.x+32.0f, by=hs.y-28.0f, bw=114.0f, bh=58.0f, rad=5.0f;
                    draw_list->AddRectFilled({bx,by},{bx+bw,by+bh},IM_COL32(0,0,0,230),rad);
                    draw_list->AddRect({bx,by},{bx+bw,by+bh},IM_COL32(100,210,255,100),rad,0,1.0f);
                    char distBuf[32]; snprintf(distBuf,32,"DIST: %dm",(int)distance);
                    draw_list->AddText(ImGui::GetFont(),13.0f,{bx+8.0f,by+7.0f},aquaColor,distBuf);
                    const float barX0=bx+6.0f, barY0=by+27.0f, barW=bw-12.0f, barH=8.0f;
                    float hpFrac = (float)hp/(float)maxHP; if(hpFrac>1.0f) hpFrac=1.0f;
                    draw_list->AddRectFilled({barX0,barY0},{barX0+barW,barY0+barH},IM_COL32(30,30,30,255),4.0f);
                    draw_list->AddRectFilled({barX0,barY0},{barX0+barW*hpFrac,barY0+barH},aquaColor,4.0f);
                    char hpBuf[32]; snprintf(hpBuf,32,"HP: %d/%d",hp,maxHP);
                    draw_list->AddText(ImGui::GetFont(),13.0f,{bx+8.0f,by+39.0f},aquaColor,hpBuf);
                }
                
                // ========== กงจักรหมุนบนหัว (Shuriken) ==========
                if(Vars.ShurikenOnHead && w2sh){
                    float time = ImGui::GetTime();
                    float rot = time * 5.0f;
                    const int blades=6;
                    const float rOut=18.0f, rIn=6.0f;
                    ImVec2 center = hs;
                    for(int i=0;i<blades;i++){
                        float ang = rot + (i * (2*M_PI/blades));
                        ImVec2 out(center.x+cosf(ang)*rOut, center.y+sinf(ang)*rOut);
                        draw_list->AddLine(center,out, aquaColor,2.0f);
                        float angIn = ang + (M_PI/blades);
                        ImVec2 inn(center.x+cosf(angIn)*rIn, center.y+sinf(angIn)*rIn);
                        draw_list->AddLine(center,inn, aquaFill,1.5f);
                    }
                    draw_list->AddCircleFilled(center,4.0f, aquaColor);
                    draw_list->AddCircle(center,rOut+2.0f, aquaColor,0,1.5f);
                }
            }
        }
        
        // Enemy counter (ด้านบน)
        if(Vars.enemycount){
            char ecBuf[64];
            snprintf(ecBuf,64,"ENEMIES: %d (Knocked: %d)",g_EnemyCount,g_KnockedCount);
            ImVec2 sz = ImGui::GetIO().DisplaySize;
            ImVec2 ts = ImGui::GetFont()->CalcTextSizeA(16.0f,FLT_MAX,0,ecBuf);
            float ex = sz.x*0.5f-ts.x*0.5f, ey=52.0f, pad=5.0f;
            draw_list->AddRectFilled(ImVec2(ex-pad,ey-pad),ImVec2(ex+ts.x+pad,ey+16.0f+pad),ImColor(180,0,0,200),4.0f);
            draw_list->AddRect(ImVec2(ex-pad,ey-pad),ImVec2(ex+ts.x+pad,ey+16.0f+pad),ImColor(100,210,255,220),4.0f);
            draw_list->AddText(ImGui::GetFont(),16.0f,ImVec2(ex+1.0f,ey+1.0f),IM_COL32(0,0,0,220),ecBuf);
            draw_list->AddText(ImGui::GetFont(),16.0f,ImVec2(ex,ey),IM_COL32(100,210,255,255),ecBuf);
        }
    } catch(...){ return; }
}

// ========== Aimbot + FOV แบบเส้นแทนวงกลม ==========
void aimbot() {
    if(!Vars.Aimbot) return;
    ImDrawList* dl = ImGui::GetBackgroundDrawList();
    if(!dl) return;
    
    float cx = ImGui::GetIO().DisplaySize.x/2;
    float cy = ImGui::GetIO().DisplaySize.y/2;
    ImVec2 center(cx,cy);
    
    if(Vars.isAimFov && Vars.AimFov>0){
        // FOV แบบเส้นกากบาท + เส้นขวางแนวตั้ง
        const ImU32 fovColor = IM_COL32(100,210,255,200);
        float r = Vars.AimFov;
        dl->AddLine(ImVec2(cx-r,cy), ImVec2(cx+r,cy), fovColor, 1.2f);
        dl->AddLine(ImVec2(cx,cy-r), ImVec2(cx,cy+r), fovColor, 1.2f);
        // วงแหวนบางเบา (ให้ดูมีมิติ)
        dl->AddCircle(center, r, fovColor, 64, 0.8f);
    }
    
    void *Match = game_sdk->Curent_Match();
    if(!Match) return;
    void *LocalPlayer = game_sdk->GetLocalPlayer(Match);
    if(!LocalPlayer) return;
    void *target = GetClosestEnemy();
    if(!target) return;
    ImVec2 enemyPos = Camera$$WorldToScreen::Regular(GetHeadPosition(target));
    dl->AddLine(center, enemyPos, IM_COL32(100,210,255,220), 1.8f);
}

void draw_watermark(){
    std::string wm = "2K COMMUNITY/monalisa";
    ImVec2 sz = ImGui::GetIO().DisplaySize;
    ImVec2 ts = verdana_smol->CalcTextSizeA(18,FLT_MAX,0,wm.c_str());
    ImVec2 pos(sz.x-ts.x-10, sz.y-ts.y-10);
    AddText(verdana_smol,18,false,true,pos,ImColor(100,210,255),wm);
}
