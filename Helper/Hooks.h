#import "vinhtran.hpp"
#import "loading.hxx"
#include <fstream>
#include <chrono>
#define FMT_HEADER_ONLY
#include "fmt/core.h"

bool SilentAim = false;
bool CheckWall1 = false;

enum FireMode { 
    MANUL,
    AUTO
}; 

enum FireStatus { 
    NONE,
    FIRING,
    CANCEL
};

static float FireDelay = 0.01f;   // ปรับได้ตอนรัน (Fast Fire จะลด delay ลง)

struct Vars_t
{
    bool Enable = {};
    bool AimbotEnable = {};
    bool Aimbot = {};
    bool ShowFovCircle = true;
   
    float AimFov = 500.0f;
    int AimCheck = {};
    bool ESPCount = {};
    int AimType = {};
    int AimWhen = 3;
    int AimMode = 2;
    bool isAimFov = {};
    int AimHitbox = 0; 
    const char* aimHitboxes[3] = {"Head", "Neck", "Body"};
    const char *dir[4] = {"None", "Fire", "Scope", "Fire + Scope"};
    const char *aimModes[3] = {"Aim 360°", "Aim 180°", "Aim Fov"};
    bool VisibleCheck = true;
    bool lines = {};
    bool Box = {};
    bool Outline = {};
    bool Name = {};
    bool Health = {};
    bool Distance = {};
    bool fovaimglow = {};
    bool NinjaRun = {};
    float NinjaRunSpeed = 0.1f;
    float NinjaRunHeight = 0.0f;
    bool UpPlayerOne = {};
   // AimTarget Target = HEAD;
    bool circlepos = {};
    bool skeleton = {};
    bool OOF = {};
    bool enemycount = {};
    float fovLineColor[4] = {1.0f, 1.0f, 1.0f, 1.0f};
    ImVec4 boxColor = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
    float AimSpeed = 10.0f;
    bool IgnoreKnocked = true;
    bool AutoFire = false;

    // ── Senic Mode: Fast Fire / Fly Alt ──
    bool  FastFire = false;
    bool  FlyUp    = false;
    float FlySpeed = 5.0f;

    // ── Combat: Long Range / Bullet Penetration / Chain Damage / Fast Switch ──
    bool  LongRange         = false;
    bool  BulletPenetration = false;
    bool  ChainDamage       = false;
    int   ChainDamageValue  = 1000;
    bool  FastSwitch        = false;

    // ── Pro: Telekill / Free Fly / AimKill ──
    bool  Telekill          = false;     // เทเลพอร์ตไปข้างศัตรูแล้วยิง
    bool  FreeFly           = false;     // บินทุกทิศตามกล้อง
    float FreeFlySpeed      = 8.0f;      // 1..30
    bool  AimKill           = false;     // master: Aimbot+AutoFire+ChainDmg+BulletThru

    // ── Aim Manager: NoRecoil / NoReload / AI Player Aim / Aim Manager ──
    bool  NoRecoil          = false;     // ล็อคเล็งเมื่อยิง = ไม่มีแรงดีดให้เห็น
    bool  NoReload          = false;     // ใช้ผ่าน FastFire + Hook set_AmmoInClip
    bool  AIPlayerAim       = false;     // AI ช่วยเล็งศัตรูใกล้สุดแบบ headshot
    int   AimManagerHitbox  = 0;         // 0=Head 1=Neck 2=Body
    float AimManagerSpeed   = 30.0f;     // 1..50  ความเร็ว aim
    // RVA reference (สำหรับ hook อนาคต):
    //   set_AmmoInClip  = 0x61C8308
    //   set_ReloadSpeed = 0x61C82F8
    //   set_OnceAmmo    = 0x61C82E8

    // ── New OB53 features ทุกตัว toggle 
    bool  MarkTeleport      = false;     // เปิด → teleport ไป mark ที่บันทึกไว้ (loop ขณะเปิด)
    bool  AutoTeleport      = false;     // เปิด → teleport ไปข้างศัตรูใกล้สุดเป็นจังหวะ
    bool  AmmoSpeedFast     = false;     // เปิด → reload speed สูงสุด + clip เต็มตลอด
    bool  BlueMap           = false;     // เปิด → tint ฉาก/หมอกเป็นสีน้ำเงิน
    bool  ActionSetMark     = false;     // ปุ่ม: บันทึกตำแหน่งปัจจุบันเป็น mark
    bool  ActionResetAcc    = false;     // ปุ่ม: เรียก GarenaMSDK_ResetGuest

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
    struct Vector3 OrigStartPosition;
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

bool IsGod(void *player){
return *(bool *)((uint64_t) player + 0xF4C);
}


void *get_gameObject(void *Pthis)
{
    return ((void* (*)(void *))getRealOffset(0x854065C))(Pthis);
}

static void *GetWeaponOnHand1(void *local) {
    void *(*_GetWeaponOnHand1)(void *local) = (void *(*)(void *))getRealOffset(0x4A16560);
    return _GetWeaponOnHand1(local);
}


static Vector3 Transform_INTERNAL_GetPosition(void *player) {
    Vector3 out = Vector3::zero();
    void (*_Transform_INTERNAL_GetPosition)(void *transform, Vector3 * out) = (void (*)(void *, Vector3 *))getRealOffset(ENCRYPTOFFSET("0x8552C10"));
    _Transform_INTERNAL_GetPosition(player, &out);
    return out;
}

static Vector3 lastNinjaRunPos = Vector3::zero();
static bool lastNinjaWasActive = false;

void SetNinjaRunSpeedPreset(int preset) {
    switch (preset) {
        case 0: Vars.NinjaRunSpeed = 0.5f; break;
        case 1: Vars.NinjaRunSpeed = 1.0f; break;
        case 2: Vars.NinjaRunSpeed = 2.5f; break;
        case 3: Vars.NinjaRunSpeed = 5.0f; break;
        default: break;
    }
}

void RunNinjaRun() {
    if (!Vars.Enable || !Vars.NinjaRun)
        return;

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
    location.y = ScreenHeight - worldPoint.y * ScreenHeight;
    location.z  = worldPoint.z;

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
    location.y = ScreenHeight - worldPoint.y * ScreenHeight;
    location.z = worldPoint.z;
 
    checker = location.z > 1;
 
    return {location.x, location.y};
}
}

Vector3 GetBonePosition(void *player, void *(*transformGetter)(void *)) {
    if (!player || !transformGetter)
        return Vector3();
    void *transform = transformGetter(player);
    return transform ? game_sdk->get_position(game_sdk->Component_GetTransform(transform)) : Vector3();
}

Vector3 GetHitboxPosition(void* player, int hitbox) {
    if (!player) return Vector3::zero();
    
    switch (hitbox) {
        case 0: return GetBonePosition(player, game_sdk->GetHeadPositions);
        case 1: {
            Vector3 headPos = GetBonePosition(player, game_sdk->GetHeadPositions);
            return headPos == Vector3::zero() ? headPos : Vector3(headPos.x, headPos.y - 0.2f, headPos.z);
        }
        case 2: {
            Vector3 headPos = GetBonePosition(player, game_sdk->GetHeadPositions);
            return headPos == Vector3::zero() ? headPos : Vector3(headPos.x, headPos.y - 0.4f, headPos.z);
        }
        default: return GetBonePosition(player, game_sdk->GetHeadPositions);
    }
}

Vector3 getPosition(void *player) {
    return game_sdk->get_position(game_sdk->Component_GetTransform(player));
}

Vector3 GetHeadPosition(void *player) {
    return game_sdk->get_position(game_sdk->GetHeadPositions(player));
}

static Vector3 CameraMain(void *player) {
    return game_sdk->get_position(*(void **)((uint64_t)player + oxo("0x390")));//public Transform MainCameraTransform;
}

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
        void (*_Transform_GetPosition)(void *transform, Vector3 *out) = (void (*)(void *, Vector3 *))getRealOffset(oxo("0x8552C10"));//private void get_position_Injected(out Vector3 ret) { }
        _Transform_GetPosition(player, &out);
        return out;
    }

    static void *Player_GetHeadCollider(void *player)
    {
        void *(*_Player_GetHeadCollider)(void *players) = (void *(*)(void *))getRealOffset(oxo("0x4A1A9D4"));//public virtual Collider get_HeadCollider() { }
        return _Player_GetHeadCollider(player);
    }

    static bool Physics_Raycast(Vector3 camLocation, Vector3 headLocation, unsigned int LayerID, void *collider)
    {
        bool (*_Physics_Raycast)(Vector3 camLocation, Vector3 headLocation, unsigned int LayerID, void *collider) = (bool (*)(Vector3, Vector3, unsigned int, void *))getRealOffset(oxo("0x5580870"));//public static bool SingleLineCheck(Vector3 startTrace, Vector3 endTrace, uint traceFlag, ref HitObjectInfo hitObjectInfo) { }
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


void DrawSkeleton(void *player, ImDrawList *drawList)
{
    if (!player || !drawList)
        return;
    bool isPlayerVisible = tanghinh::isVisible(player);
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

    // Chuyển đổi vị trí xương sang tọa độ màn hình
    bool visible;
    ImVec2 headScreen = Camera$$WorldToScreen::Checker(headPos, visible);
    if (!visible)
        return;

    ImVec2 hipScreen = Camera$$WorldToScreen::Regular(hipPos);
    ImVec2 leftAnkleScreen = Camera$$WorldToScreen::Regular(leftAnklePos);
    ImVec2 rightAnkleScreen = Camera$$WorldToScreen::Regular(rightAnklePos);
    ImVec2 leftToeScreen = Camera$$WorldToScreen::Regular(leftToePos);
    ImVec2 rightToeScreen = Camera$$WorldToScreen::Regular(rightToePos);
    ImVec2 leftHandScreen = Camera$$WorldToScreen::Regular(leftHandPos);
    ImVec2 rightHandScreen = Camera$$WorldToScreen::Regular(rightHandPos);
    ImVec2 leftForeArmScreen = Camera$$WorldToScreen::Regular(leftForeArmPos);
    ImVec2 rightForeArmScreen = Camera$$WorldToScreen::Regular(rightForeArmPos);
    ImColor boneColor = isPlayerVisible ? ImColor(0, 255, 0) : ImColor(255, 255, 255);
    float thickness = 1.0f;

    // Vẽ đầu
    drawList->AddCircle(headScreen, 2.0f, boneColor, 12, thickness);
    // Vẽ thân
    drawList->AddLine(headScreen, hipScreen, boneColor, thickness);
    // Vẽ tay
    drawList->AddLine(headScreen, leftForeArmScreen, boneColor, thickness);
    drawList->AddLine(headScreen, rightForeArmScreen, boneColor, thickness);
    drawList->AddLine(leftForeArmScreen, leftHandScreen, boneColor, thickness);
    drawList->AddLine(rightForeArmScreen, rightHandScreen, boneColor, thickness);
    // Vẽ chân
    drawList->AddLine(hipScreen, leftAnkleScreen, boneColor, thickness);
    drawList->AddLine(hipScreen, rightAnkleScreen, boneColor, thickness);
    drawList->AddLine(leftAnkleScreen, leftToeScreen, boneColor, thickness);
    drawList->AddLine(rightAnkleScreen, rightToeScreen, boneColor, thickness);
}

bool isFov(Vector3 vec1, Vector3 vec2, int radius)
{
    int x = vec1.x;
    int y = vec1.y;
    int x0 = vec2.x;
    int y0 = vec2.y;
    if ((pow(x - x0, 2) + pow(y - y0, 2)) <= pow(radius, 2))
    {
        return true;
    }
    return false;
}

void *GetClosestEnemy()
{
    try
    {
        float shortestDistance = 9999.0f;
        void *closestEnemy = NULL;
        void *get_MatchGame = game_sdk->Curent_Match();
        if (!get_MatchGame)
            return NULL;
        void *LocalPlayer = game_sdk->GetLocalPlayer(get_MatchGame);
        if (!LocalPlayer || !game_sdk->Component_GetTransform(LocalPlayer))
            return NULL;
        if (!Vars.Enable)
            return NULL;
        Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)get_MatchGame + oxo("0x148"));
        if (!players )
            return NULL;
        for (int u = 0; u < players->getSize(); u++)
        {
            void *Player = players->getValues()[u];
            if (!Player)
                continue;
            if (Player == LocalPlayer)
                continue;
            if (!game_sdk->get_MaxHP(Player))
                continue;
            if (game_sdk->get_IsDieing(Player))
                continue;
            if (!game_sdk->get_isVisible(Player))
                continue;
            if (game_sdk->get_isLocalTeam(Player))
                continue;
            Vector3 PlayerPos = getPosition(Player);
            Vector3 LocalPlayerPos = getPosition(LocalPlayer);
            ImVec2 screenPos = Camera$$WorldToScreen::Regular(PlayerPos);
            bool isFov1 = isFov(Vector3(screenPos.x, screenPos.y), Vector3(ImGui::GetIO().DisplaySize.x / 2, ImGui::GetIO().DisplaySize.y / 2), Vars.AimFov);
            float distance = Vector3::Distance(LocalPlayerPos, PlayerPos);
            if (distance < 200)
            {
                Vector3 targetDir = Vector3::Normalized(PlayerPos - LocalPlayerPos);
                float angle = Vector3::Angle(targetDir, game_sdk->GetForward(game_sdk->Component_GetTransform(game_sdk->get_camera()))) * 100.0f;
                if (angle <= Vars.AimFov && isFov1 && angle < shortestDistance)
                {
                    if (tanghinh::isVisible(Player))
                    {
                        shortestDistance = angle;
                        closestEnemy = Player;
                    }
                }
            }
        }
        return closestEnemy;
    }
    catch (...)
    {
        return NULL;
    }
}

void *GetClosestEnemysilent()
{
    try
    {
        float shortestDistance = 99999.0f;
        void *closestEnemy = NULL;

        void *get_MatchGame = game_sdk->Curent_Match();
        if (!get_MatchGame)
            return NULL;

        void *LocalPlayer = game_sdk->GetLocalPlayer(get_MatchGame);
        if (!LocalPlayer || !game_sdk->Component_GetTransform(LocalPlayer))
            return NULL;

        if (!Vars.Enable)
            return NULL;

        Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long) get_MatchGame + 0x148);
if (!players )
return NULL;

        ImVec2 screenSize = ImGui::GetIO().DisplaySize;

        ImVec2 center(screenSize.x / 2, screenSize.y / 2);

        for (int i = 0; i < players->getSize(); i++) {
void *Player = players->getValues()[i];

            if (!Player || Player == LocalPlayer)
                continue;

            if (!game_sdk->get_MaxHP(Player))
                continue;

            if (game_sdk->get_IsDieing(Player))
                continue;

    if (game_sdk->get_isLocalTeam(Player))
                continue;

            if (IsGod(Player))
                continue;

            int hp = game_sdk->GetHp(Player);
            if (Vars.IgnoreKnocked && hp <= 0)
                continue;

            bool isInsideCamera = false;
            Vector3 pos = getPosition(Player);
            ImVec2 screenPos = Camera$$WorldToScreen::Checker(pos, isInsideCamera);

            if (!isInsideCamera)
                continue;

            if (screenPos.x < 0 || screenPos.x > screenSize.x ||
                screenPos.y < 0 || screenPos.y > screenSize.y)
                continue;

    if (CheckWall1)
            {
                if (!game_sdk->get_isVisible(Player))
                    continue;

                if (!tanghinh::isVisible(Player))
                    continue;
            }

        float dx = screenPos.x - center.x;
            float dy = screenPos.y - center.y;
            float screenDist = sqrtf(dx * dx + dy * dy);

        if (screenDist < shortestDistance)
            {
                shortestDistance = screenDist;
                closestEnemy = Player;
            }
        }

        return closestEnemy;
    }
catch (...)
    {
        return NULL;
    }
}

int SetDamage = 1;

void *getItransform(void *itransform) {
    void * (*_itransformNode)(void *_this) = (void*(*)(void*))getRealOffset(0x5C52CFC);
    return _itransformNode(itransform);
}

static float get_Range(void *pthis)
{
    return ((float (*)(void *))getRealOffset(ENCRYPTOFFSET("0x4E8703C")))(pthis);
}

bool isEnemyInRangeWeapon(void *player, void *enemy, void* weapon)
{
    if (player != nullptr && enemy != nullptr && weapon != nullptr)
    {
        Vector3 EnemyHeadPosition = GetHeadPosition(enemy);
        Vector3 PlayerHeadPosition = GetHeadPosition(player);
        float distance = Vector3::Distance(PlayerHeadPosition, EnemyHeadPosition);
        float range = get_Range(weapon);

        if (distance <= range) {
            return true;
        }
    }
    return false;
}


Vector3 GetHipPosition(void* player) {
    void *HipITF= *(void **)((uint64_t) player + 0x648);
    void *HipTF = getItransform(HipITF);
    Vector3 Hip = Transform_INTERNAL_GetPosition(HipTF);
    return Hip;
}

int (*old_BLAGCMCGEJG1)(void *, HitObjectInfo *);
int BLAGCMCGEJG1(void *ist, HitObjectInfo *HitObject) {
    if (SilentAim && HitObject) {
        void *match = game_sdk->Curent_Match();
        if (match) {
            void *localPlayer = game_sdk->GetLocalPlayer(match);
            if (localPlayer) {
                void *weapon = GetWeaponOnHand1(localPlayer);
                void *enemy = GetClosestEnemysilent();
                if (enemy && weapon) {
                    // ── Long Range: ข้าม range check ของอาวุธ ──
                    bool inRange = Vars.LongRange ? true : isEnemyInRangeWeapon(localPlayer, enemy, weapon);
                    if (inRange) {
                        Vector3 enemyPos;
                        if (SetDamage == 1)
                            enemyPos = GetHeadPosition(enemy);
                        else
                            enemyPos = GetHipPosition(enemy);
                        Vector3 startPos = GetHeadPosition(localPlayer);
                        HitObject->HitObject = get_gameObject(tanghinh::Player_GetHeadCollider(enemy));
                        HitObject->HitCollider = tanghinh::Player_GetHeadCollider(enemy);
                        HitObject->HitLocation = enemyPos;
                        HitObject->HitNormal = enemyPos;
                        HitObject->RayDir = Vector3::Normalized(enemyPos - startPos);
                        HitObject->StartPosition = startPos;
                        HitObject->OrigStartPosition = startPos;
                        HitObject->HitGroup = 1; 
                        HitObject->SpecialHitType = 0;
                        HitObject->IgnoreHappens = false;
                        HitObject->ViewBlocked = false;

                        // ── Chain Damage: ดาเมจสูง 1 นัดน็อค ──
                        if (Vars.ChainDamage) {
                            HitObject->Damage = Vars.ChainDamageValue;
                        }
                    }
                }
            }
        }
    }

    return old_BLAGCMCGEJG1(ist, HitObject);
}

void UpOneEnemy() {
    if (!Vars.Enable || !Vars.UpPlayerOne)
        return;

    void *match = game_sdk->Curent_Match();
    if (!match) return;

    void *local = game_sdk->GetLocalPlayer(match);
    if (!local || !game_sdk->Component_GetTransform(local)) return;

    Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)match + oxo("0x148"));
    if (!players || players->getValues().empty()) return;

    Vector3 localPos = game_sdk->get_position(game_sdk->Component_GetTransform(local));

    for (int i = 0; i < players->getSize(); i++) {
        void *enemy = players->getValues()[i];
        if (!enemy || enemy == local) continue;
        if (!game_sdk->Component_GetTransform(enemy)) continue;
        if (!game_sdk->get_MaxHP(enemy)) continue;
        if (game_sdk->get_IsDieing(enemy)) continue;
        if (game_sdk->get_isLocalTeam(enemy)) continue;

        void *enemyTF = game_sdk->Component_GetTransform(enemy);
        Vector3 enemyPos = game_sdk->get_position(enemyTF);
        float distance = Vector3::Distance(localPos, enemyPos);
        if (distance <= 10.0f) continue;

        float targetY = enemyPos.y + 5.7f;
        float step = 0.35f;

        if (enemyPos.y < targetY - 0.1f)
            enemyPos.y += step;
        else if (enemyPos.y > targetY + 0.1f)
            enemyPos.y -= step;

        Transform_INTERNAL_SetPosition(enemyTF, Vvector3(enemyPos.x, enemyPos.y, enemyPos.z));
    }
}

void ProcessAimbot() {
    if (!Vars.Aimbot)
        return;
    void *CurrentMatch = game_sdk->Curent_Match();
    if (!CurrentMatch)
        return;
    void *LocalPlayer = game_sdk->GetLocalPlayer(CurrentMatch);
    if (!LocalPlayer || !game_sdk->Component_GetTransform(LocalPlayer))
        return;
    void *closestEnemy = GetClosestEnemy();
    if (!closestEnemy || !game_sdk->Component_GetTransform(closestEnemy))
        return;

    Vector3 EnemyLocation = GetHitboxPosition(closestEnemy, Vars.AimHitbox);
    if (EnemyLocation == Vector3::zero())
        return;
    Vector3 PlayerLocation = CameraMain(LocalPlayer);
    if (PlayerLocation == Vector3::zero())
        return;

    bool IsScopeOn = game_sdk->get_IsSighting(LocalPlayer);
    bool IsFiring = game_sdk->get_IsFiring(LocalPlayer);
    bool shouldAim =
        (Vars.AimWhen == 0) ||                        
        (Vars.AimWhen == 1 && IsFiring) ||             
        (Vars.AimWhen == 2 && IsScopeOn) ||           
        (Vars.AimWhen == 3 && (IsFiring || IsScopeOn)); 

    if (shouldAim && (!Vars.VisibleCheck || tanghinh::isVisible(closestEnemy))) {
        if (game_sdk->get_IsDieing(closestEnemy) && Vars.IgnoreKnocked) {
            float shortestDistance = 9999.0f;
            void *newTarget = NULL;
            Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)CurrentMatch + oxo("0x148"));
             if (players) {
              for (int u = 0; u < players->getSize(); u++) {
                void *Player = players->getValues()[u];
                    if (!Player || Player == LocalPlayer || !game_sdk->get_MaxHP(Player) || game_sdk->get_isLocalTeam(Player) || Player == closestEnemy)
                        continue;

                    if (Vars.IgnoreKnocked && game_sdk->get_IsDieing(Player))
                        continue;
                    if (Vars.VisibleCheck && !tanghinh::isVisible(Player))
                        continue;

                    Vector3 PlayerPos = GetHitboxPosition(Player, Vars.AimHitbox);
                    float distance = Vector3::Distance(PlayerLocation, PlayerPos);
                    if (distance < 300 && distance < shortestDistance) {
                        shortestDistance = distance;
                        newTarget = Player;
                    }
                }
            }

            if (newTarget) {
                EnemyLocation = GetHitboxPosition(newTarget, Vars.AimHitbox);
                closestEnemy = newTarget;
            } else {
                return;
            }
        }

        Quaternion TargetLook = GetRotationToTheLocation(EnemyLocation, 0.05f, PlayerLocation);
        game_sdk->set_aim(LocalPlayer, TargetLook);
    }

}

void get_players()
{
    ImDrawList *draw_list = ImGui::GetBackgroundDrawList();
    if (!draw_list)
        return;

    initAutoFireHook();

    if (!Vars.Enable)
        return;

    // ── นับศัตรูที่มองเห็น (ENEMIES counter) ────────────────────────────────
    static int g_EnemyCount  = 0;
    static int g_KnockedCount = 0;

    try
    {
        if (Vars.Enable) {
            ProcessAimbot();

            if (Vars.UpPlayerOne) {
                UpOneEnemy();
            }
            if (Vars.NinjaRun) {
                RunNinjaRun();
            }
}

        void *current_Match = game_sdk->Curent_Match();
        if (!current_Match)
            return;

        void *local_player = game_sdk->GetLocalPlayer(current_Match);
        if (!local_player)
            return;

        Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)current_Match + 0x148);
        if (!players )
            return;

        void *camera = game_sdk->get_camera();
        if (!camera)
            return;

        // รีเซ็ต counter ทุก frame
        g_EnemyCount  = 0;
        g_KnockedCount = 0;

        for (int u = 0; u < players->getSize(); u++)
        {
            void *closestEnemy = players->getValues()[u];
            if (!closestEnemy)
                continue;
            if (!game_sdk->Component_GetTransform(closestEnemy))
                continue;
            if (closestEnemy == local_player)
                continue;
            if (!game_sdk->get_MaxHP(closestEnemy))
                continue;
            if (game_sdk->get_isLocalTeam(closestEnemy))
                continue;
            if (game_sdk->get_IsDieing(closestEnemy)) {
                g_KnockedCount++;
                continue;
            }
            if (!game_sdk->get_isVisible(closestEnemy))
                continue;

            // นับศัตรูที่ผ่านการ filter
            g_EnemyCount++;

            Vector3 pos = getPosition(closestEnemy);
            Vector3 pos2 = getPosition(local_player);
            float distance = Vector3::Distance(pos, pos2);
            if (distance > 200.0f)
                continue;
            ImColor line_color = ImColor(255, 255, 255);
            bool w2sc;
            ImVec2 top_pos = Camera$$WorldToScreen::Regular(pos + Vector3(0, 1.6, 0));
            ImVec2 bot_pos = Camera$$WorldToScreen::Regular(pos);
            ImVec2 pos_3 = Camera$$WorldToScreen::Checker(pos, w2sc);
            auto pmtXtop = top_pos.x;
            auto pmtXbottom = bot_pos.x;
            if (top_pos.x > bot_pos.x)
            {
                pmtXtop = bot_pos.x;
                pmtXbottom = top_pos.x;
            }
            Camera$$WorldToScreen::Checker(pos + Vector3(0, 0.75f, 0), w2sc);
            float calculatedPosition = fabs((top_pos.y - bot_pos.y) * (0.0092f / 0.019f) / 2);

            ImRect rect(
                ImVec2(pmtXtop - calculatedPosition, top_pos.y),
                ImVec2(pmtXbottom + calculatedPosition, bot_pos.y));
            const auto &viewpos = game_sdk->get_position(game_sdk->Component_GetTransform(game_sdk->get_camera()));
            if (w2sc)
            {
                if (Vars.lines)
                {
                    if (game_sdk->get_IsDieing(closestEnemy))
                    {
                        draw_list->AddLine(ImVec2(ImGui::GetIO().DisplaySize.x / 2, 0), ImVec2(rect.GetCenter().x, rect.Min.y), ImColor(255, 0, 0));
                    }
                    else
                    {
                        draw_list->AddLine(ImVec2(ImGui::GetIO().DisplaySize.x / 2, 0), ImVec2(rect.GetCenter().x, rect.Min.y), line_color);
                    }
                }
                if (Vars.Box)
                {
                    if (game_sdk->get_IsDieing(closestEnemy))
                    {
                        draw_list->AddRect(rect.Min, rect.Max, ImColor(255, 0, 0));
                    }
                    else
                    {
                        draw_list->AddRect(rect.Min, rect.Max, ImColor(255, 255, 255));
                    }
                    
                    if (Vars.Outline)
                    {
                        draw_list->AddRect(ImVec2(rect.Min.x - 1, rect.Min.y - 1), ImVec2(rect.Max.x + 1, rect.Max.y + 1), ImColor(0, 0, 0), 0.65, 0, 1);
                        draw_list->AddRect(ImVec2(rect.Min.x + 1, rect.Min.y + 1), ImVec2(rect.Max.x - 1, rect.Max.y - 1), ImColor(0, 0, 0), 0.65, 0, 1);
                    }
                }
                if (Vars.Name)
                {
                    auto pname = game_sdk->name(closestEnemy);
                    std::string names = "null";
                    if (pname)
                        names = pname->toCPPString();
                    std::transform(names.begin(), names.end(), names.begin(), ::tolower);
                    auto playername = names;
                    std::string name = names;
                    ImVec2 text_size = verdana_smol->CalcTextSizeA(8, FLT_MAX, 0, names.c_str());
                    ImVec2 name_pos = {
                        rect.Min.x + (rect.GetWidth() / 2) - text_size.x / 2,
                        rect.Min.y - 2 - text_size.y};
                    AddText(verdana_smol, 8, false, Vars.Outline, name_pos, ImColor(255, 255, 255), name);
                }
                if (Vars.Health)
                {
                    auto health = game_sdk->GetHp(closestEnemy);
                    auto maxhealth = game_sdk->get_MaxHP(closestEnemy);
                    float health_multiplier = (float)health / (float)maxhealth;
                    float health_bar_pos = rect.Min.x - 4;
                    draw_list->AddLine({health_bar_pos, rect.Min.y - 1}, {health_bar_pos, rect.Max.y}, ImColor(0, 0, 0, 100), 3);
                    draw_list->AddLine({health_bar_pos - 0.5f, rect.Max.y}, {health_bar_pos - 0.5f, rect.Max.y - (rect.GetHeight() + 1) * health_multiplier}, ImColor(0, 255, 0), 3);
                    if (Vars.Outline)
                        draw_list->AddRect({health_bar_pos - 2, rect.Min.y - 1}, {health_bar_pos + 2, rect.Max.y + 1}, ImColor(0, 0, 0));
                    std::string hpstr = fmt::format(oxorany("{}HP"), static_cast<int>(health));
                    ImVec2 text_size_hp = pixel_smol->CalcTextSizeA(8, FLT_MAX, 0, hpstr.c_str());
                    ImVec2 text_pos = {
                        rect.Min.x + (rect.GetWidth() / 2) - text_size_hp.x / 2,
                        rect.Max.y};
                    AddText(pixel_smol, 8, false, true, text_pos, ImColor(0, 255, 0), hpstr.c_str());
                }
                if (Vars.Distance)
                {
                    std::string distancestr = fmt::format(oxorany("{}M"), static_cast<int>(distance));
                    ImVec2 distance_pos = {
                        rect.Max.x + 4,
                        rect.Min.y};
                    AddText(pixel_smol, 8, false, true, distance_pos, ImColor(255, 255, 255), distancestr.c_str());
                }
                if (Vars.circlepos)
                {
                    Draw3DCircle(pos, 1.0f, 0.5f, ImColor(255, 0, 0), 36, false, 0.5f);
                }
                if (Vars.skeleton)
                {
                    DrawSkeleton(closestEnemy, draw_list);
                }

                // ════════════════════════════════════════════════════════════
                // DIAMOND CROSSHAIR  (◇ + เส้น +) — ตรงหัวศัตรู
                // ════════════════════════════════════════════════════════════
                {
                    Vector3 headPos = GetHeadPosition(closestEnemy);
                    bool w2sh;
                    ImVec2 hs = Camera$$WorldToScreen::Checker(headPos, w2sh);
                    if (w2sh) {
                        const float ds    = 24.0f;
                        const ImU32 dCol  = IM_COL32(220, 30, 30, 230);
                        const ImU32 dFill = IM_COL32(220, 30, 30,  50);

                        ImVec2 dTop = {hs.x,       hs.y - ds};
                        ImVec2 dRgt = {hs.x + ds,  hs.y     };
                        ImVec2 dBot = {hs.x,       hs.y + ds};
                        ImVec2 dLft = {hs.x - ds,  hs.y     };

                        draw_list->AddQuad(dTop, dRgt, dBot, dLft, dCol, 2.0f);
                        draw_list->AddQuadFilled(dTop, dRgt, dBot, dLft, dFill);

                        const float gap = 9.0f, arm = 20.0f;
                        draw_list->AddLine({hs.x - arm, hs.y}, {hs.x - gap, hs.y}, dCol, 1.8f);
                        draw_list->AddLine({hs.x + gap, hs.y}, {hs.x + arm, hs.y}, dCol, 1.8f);
                        draw_list->AddLine({hs.x, hs.y - arm}, {hs.x, hs.y - gap}, dCol, 1.8f);
                        draw_list->AddLine({hs.x, hs.y + gap}, {hs.x, hs.y + arm}, dCol, 1.8f);
                        draw_list->AddCircleFilled(hs, 3.0f, dCol, 8);

                        // ════════════════════════════════════════════════════
                        // INFO BOX — DIST + HP bar + HP text
                        // ════════════════════════════════════════════════════
                        int hp    = game_sdk->GetHp(closestEnemy);
                        int maxHP = game_sdk->get_MaxHP(closestEnemy);
                        if (maxHP <= 0) maxHP = 200;
                        if (hp < 0)     hp    = 0;
                        if (hp > maxHP) hp    = maxHP;
                        int distM = (int)distance;

                        const float bx = hs.x + ds + 8.0f;
                        const float by = hs.y - 28.0f;
                        const float bw = 114.0f, bh = 58.0f, rad = 5.0f;

                        draw_list->AddRectFilled({bx, by}, {bx + bw, by + bh},
                                                 IM_COL32(12, 12, 12, 210), rad);
                        draw_list->AddRect({bx, by}, {bx + bw, by + bh},
                                           IM_COL32(70, 70, 70, 180), rad, 0, 1.0f);

                        char distBuf[32];
                        snprintf(distBuf, sizeof distBuf, "DIST: %dm", distM);
                        draw_list->AddText(ImGui::GetFont(), 13.0f,
                                           {bx + 8.0f, by + 7.0f},
                                           IM_COL32(255, 255, 255, 255), distBuf);

                        const float barX0 = bx + 6.0f, barY0 = by + 27.0f;
                        const float barW  = bw - 12.0f, barH  = 8.0f;
                        float hpFrac = (float)hp / (float)maxHP;
                        draw_list->AddRectFilled({barX0, barY0},
                                                 {barX0 + barW, barY0 + barH},
                                                 IM_COL32(45, 45, 45, 220), 4.0f);
                        draw_list->AddRectFilled({barX0, barY0},
                                                 {barX0 + barW * hpFrac, barY0 + barH},
                                                 IM_COL32(200, 40, 40, 230), 4.0f);

                        char hpBuf[32];
                        snprintf(hpBuf, sizeof hpBuf, "HP: %d/%d", hp, maxHP);
                        draw_list->AddText(ImGui::GetFont(), 13.0f,
                                           {bx + 8.0f, by + 39.0f},
                                           IM_COL32(255, 255, 255, 255), hpBuf);
                    }
                }
            }
            if (Vars.OOF)
            {
                if ((pos_3.x < 0 || pos_3.x > disp.width) || (pos_3.y < 0 || pos_3.y > disp.height) || !w2sc)
                {
                    constexpr int maxpixels = 150;
                    int pixels = maxpixels;
                    if (w2sc)
                    {
                        if (pos_3.x < 0)
                            pixels = clamp((int)-pos_3.x, 0, (int)maxpixels);
                        if (pos_3.y < 0)
                            pixels = clamp((int)-pos_3.y, 0, (int)maxpixels);

                        if (pos_3.x > disp.width)
                            pixels = clamp((int)pos_3.x - (int)disp.width, 0, (int)maxpixels);
                        if (pos_3.y > disp.height)
                            pixels = clamp((int)pos_3.y - (int)disp.height, 0, (int)maxpixels);
                    }

                    float opacity = (float)pixels / (float)maxpixels;

                    float size = 3.5f;
                    Vector3 viewdir = game_sdk->GetForward(game_sdk->Component_GetTransform(game_sdk->get_camera()));
                    Vector3 targetdir = Vector3::Normalized(pos - viewpos);

                    float viewangle = atan2(viewdir.z, viewdir.x) * Rad2Deg;
                    float targetangle = atan2(targetdir.z, targetdir.x) * Rad2Deg;

                    if (viewangle < 0)
                        viewangle += 360;
                    if (targetangle < 0)
                        targetangle += 360;

                    float angle = targetangle - viewangle;

                    while (angle < 0)
                        angle += 360;
                    while (angle > 360)
                        angle -= 360;

                    angle = 360 - angle;
                    angle -= 90;
                    OtFovV1(ImGui::GetIO().DisplaySize.x / 2, ImGui::GetIO().DisplaySize.y / 2, 90 + distance * 2,
                            angle - size,
                            angle + size,
                            ImColor(1.f, 1.f, 1.f, 1.f * opacity), 1);
                }
            }
        }

        // ── กล่องสีม่วง: ศัตรูที่ยังไม่โผล่ (not visible) ───────────────────
        if (Vars.Box) {
            for (int u = 0; u < players->getSize(); u++) {
                void *enemy = players->getValues()[u];
                if (!enemy) continue;
                if (enemy == local_player) continue;
                if (!game_sdk->get_MaxHP(enemy)) continue;
                if (!game_sdk->Component_GetTransform(enemy)) continue;
                if (game_sdk->get_isLocalTeam(enemy)) continue;
                if (game_sdk->get_IsDieing(enemy)) continue;
                if (tanghinh::isVisible(enemy)) continue; // ถ้าเห็นแล้วไม่ต้องวาดอีก

                Vector3 pos  = getPosition(enemy);
                Vector3 pos2 = getPosition(local_player);
                float dist   = Vector3::Distance(pos, pos2);
                if (dist > 200.0f) continue;

                bool w2sc;
                ImVec2 top_pos = Camera$$WorldToScreen::Regular(pos + Vector3(0, 1.6f, 0));
                ImVec2 bot_pos = Camera$$WorldToScreen::Regular(pos);
                Camera$$WorldToScreen::Checker(pos + Vector3(0, 0.75f, 0), w2sc);
                if (!w2sc) continue;

                auto pmtXtop    = top_pos.x;
                auto pmtXbottom = bot_pos.x;
                if (top_pos.x > bot_pos.x) { pmtXtop = bot_pos.x; pmtXbottom = top_pos.x; }
                float cp = fabs((top_pos.y - bot_pos.y) * (0.0092f / 0.019f) / 2);

                ImRect r(ImVec2(pmtXtop - cp, top_pos.y), ImVec2(pmtXbottom + cp, bot_pos.y));
                // กล่องสีม่วง + outline ดำ
                draw_list->AddRect(ImVec2(r.Min.x - 1, r.Min.y - 1), ImVec2(r.Max.x + 1, r.Max.y + 1), ImColor(0, 0, 0, 180));
                draw_list->AddRect(r.Min, r.Max, ImColor(180, 0, 255, 255));
            }
        }

        // ── แสดง ENEMIES: X (Knocked: Y) กลางบนจอ + กล่องแดง ───────────────
        if (Vars.ESPCount) {
            char ecBuf[64];
            snprintf(ecBuf, sizeof ecBuf, "ENEMIES: %d (Knocked: %d)", g_EnemyCount, g_KnockedCount);
            ImVec2 dispSz = ImGui::GetIO().DisplaySize;
            ImVec2 textSz = ImGui::GetFont()->CalcTextSizeA(16.0f, FLT_MAX, 0, ecBuf);
            float ex  = dispSz.x * 0.5f - textSz.x * 0.5f;
            float ey  = 52.0f;
            float pad = 5.0f;
            // กล่องแดงพื้นหลัง
            draw_list->AddRectFilled(
                ImVec2(ex - pad, ey - pad),
                ImVec2(ex + textSz.x + pad, ey + 16.0f + pad),
                ImColor(180, 0, 0, 200), 4.0f);
            // ขอบขาว
            draw_list->AddRect(
                ImVec2(ex - pad, ey - pad),
                ImVec2(ex + textSz.x + pad, ey + 16.0f + pad),
                ImColor(255, 255, 255, 220), 4.0f);
            // เงาดำ
            draw_list->AddText(ImGui::GetFont(), 16.0f,
                               ImVec2(ex + 1.0f, ey + 1.0f),
                               IM_COL32(0, 0, 0, 220), ecBuf);
            // ข้อความขาว
            draw_list->AddText(ImGui::GetFont(), 16.0f,
                               ImVec2(ex, ey),
                               IM_COL32(255, 255, 255, 255), ecBuf);
        }
    }
    catch (...)
    {
        return;
    }
}


// Offsets ทั้งหมด ob53
//   set_AmmoInClip                 = 0x61C8308
//   set_ReloadSpeed                = 0x61C82F8
//   set_OnceAmmo                   = 0x61C82E8
//   RenderSettings.set_ambientLight= 0x8503F7C
//   RenderSettings.set_fogColor    = 0x85038E8
//   RenderSettings.set_fog         = 0x850363C
//   RenderSettings.set_fogDensity  = 0x85039E0
//   GarenaMSDK_ResetGuest (extern) = 0x5DFCBF8

struct UnityColor { float r, g, b, a; };

static Vector3 g_MarkPos        = Vector3::zero();
static bool    g_HasMark        = false;
static double  g_LastAutoTPTime = 0.0;

static void Player_TeleportTo(const Vector3& pos) {
    void* match = game_sdk->Curent_Match();
    if (!match) return;
    void* local = game_sdk->GetLocalPlayer(match);
    if (!local) return;
    void* tf = game_sdk->Component_GetTransform(local);
    if (!tf) return;
    Transform_INTERNAL_SetPosition(tf, Vvector3(pos.x, pos.y, pos.z));
}

// ── Set Mark — บันทึก position ปัจจุบัน
static void SetMarkAtCurrentPos() {
    void* match = game_sdk->Curent_Match();
    if (!match) return;
    void* local = game_sdk->GetLocalPlayer(match);
    if (!local) return;
    void* tf = game_sdk->Component_GetTransform(local);
    if (!tf) return;
    g_MarkPos = game_sdk->get_position(tf);
    g_HasMark = true;
}

// ── Mark Teleport — teleport กลับไปยัง mark ที่บันทึกไว้
static void RunMarkTeleport() {
    if (!g_HasMark) return;
    Player_TeleportTo(g_MarkPos);
}

// ── Auto Teleport — teleport ไปข้างศัตรูใกล้สุดทุก ~0.5 วิ
extern void* GetClosestEnemy();   // forward decl (defined later in this file)
extern Vector3 GetHeadPosition(void* player);
static void RunAutoTeleport() {
    using namespace std::chrono;
    double now = duration<double>(steady_clock::now().time_since_epoch()).count();
    if (now - g_LastAutoTPTime < 0.5) return;   // throttle 2 ครั้ง/วินาที
    g_LastAutoTPTime = now;
    void* enemy = GetClosestEnemy();
    if (!enemy) return;
    Vector3 head = GetHeadPosition(enemy);
    Player_TeleportTo(Vector3(head.x + 1.5f, head.y - 1.0f, head.z + 1.5f));
}

// ── Weapon_StartFiring — บังคับให้อาวุธเริ่มยิงทันที ──
// RVA: 0x4EA8A54  private void StartFiring()
static void Weapon_StartFiring(void* weapon) {
    if (!weapon) return;
    ((void (*)(void*))getRealOffset(0x4EA8A54))(weapon);
}

// ── Ammo Speed Fast — reload เร็ว + clip เต็มทุกเฟรม + StartFiring ──
static void RunAmmoSpeedFast() {
    void* match = game_sdk->Curent_Match();
    if (!match) return;
    void* local = game_sdk->GetLocalPlayer(match);
    if (!local) return;
    void* weapon = GetWeaponOnHand1(local);
    if (!weapon) return;

    typedef void (*set_int_t)(void*, int);
    typedef void (*set_float_t)(void*, float);
    static set_float_t _set_ReloadSpeed = (set_float_t)getRealOffset(0x61C82F8);
    static set_int_t   _set_AmmoInClip  = (set_int_t)  getRealOffset(0x61C8308);
    static set_int_t   _set_OnceAmmo    = (set_int_t)  getRealOffset(0x61C82E8);

    if (_set_ReloadSpeed) _set_ReloadSpeed(weapon, 100.0f);   // reload โคตรเร็ว
    if (_set_AmmoInClip)  _set_AmmoInClip (weapon, 999);      // clip เต็มตลอด
    if (_set_OnceAmmo)    _set_OnceAmmo   (weapon, 999);      // ammo ต่อนัดเยอะ
    Weapon_StartFiring(weapon);                                // บังคับยิงทันที
}

// ── No Reload — clip เต็มตลอด ไม่ต้องเติมกระสุน ──────────────────────────
// ต่างจาก AmmoSpeedFast: ไม่บังคับยิง + ไม่เปลี่ยน ReloadSpeed
static void RunNoReload() {
    void* match = game_sdk->Curent_Match();
    if (!match) return;
    void* local = game_sdk->GetLocalPlayer(match);
    if (!local) return;
    void* weapon = GetWeaponOnHand1(local);
    if (!weapon) return;

    typedef void (*set_int_t)(void*, int);
    typedef void (*set_float_t)(void*, float);
    set_float_t _set_ReloadSpeed = (set_float_t)getRealOffset(0x61C82F8);  // dump OB53 verified
    set_int_t   _set_AmmoInClip  = (set_int_t)  getRealOffset(0x61C8308);  // dump OB53 verified
    set_int_t   _set_OnceAmmo    = (set_int_t)  getRealOffset(0x61C82E8);  // dump OB53 verified

    if (_set_ReloadSpeed) _set_ReloadSpeed(weapon, 999.0f); // reload จบแทบทันที
    if (_set_AmmoInClip)  _set_AmmoInClip (weapon, 9999);   // clip เต็มตลอด
    if (_set_OnceAmmo)    _set_OnceAmmo   (weapon, 9999);   // ammo ต่อนัดเยอะ
}

// ── Fast Switch — สับปืนเร็วมาก (SwitchTime → 0) ─────────────────────────
// dump OB53: set_SwitchWeaponTime=0x61C83E8 / set_PreSwitchWeaponTime=0x61C83F8 / set_PostSwitchWeaponTime=0x61C8408
static void RunFastSwitch() {
    void* match = game_sdk->Curent_Match();
    if (!match) return;
    void* local = game_sdk->GetLocalPlayer(match);
    if (!local) return;
    void* weapon = GetWeaponOnHand1(local);
    if (!weapon) return;

    typedef void (*set_float_t)(void*, float);
    set_float_t _set_SwitchTime     = (set_float_t)getRealOffset(0x61C83E8);
    set_float_t _set_PreSwitchTime  = (set_float_t)getRealOffset(0x61C83F8);
    set_float_t _set_PostSwitchTime = (set_float_t)getRealOffset(0x61C8408);

    if (_set_SwitchTime)     _set_SwitchTime    (weapon, 0.01f);  // สับปืนแทบทันที
    if (_set_PreSwitchTime)  _set_PreSwitchTime (weapon, 0.01f);
    if (_set_PostSwitchTime) _set_PostSwitchTime(weapon, 0.01f);
}

// ── Dash Forward — พุ่งไปข้างหน้าตามทิศกล้อง ~100 เมตร ทันที ──────────────
static void RunDashForward(float distance = 100.0f) {
    void* match = game_sdk->Curent_Match();
    if (!match) return;
    void* local = game_sdk->GetLocalPlayer(match);
    if (!local) return;
    void* cam = game_sdk->get_camera();
    if (!cam) return;
    void* pTF = game_sdk->Component_GetTransform(local);
    void* cTF = game_sdk->Component_GetTransform(cam);
    if (!pTF || !cTF) return;

    Vector3 cur = game_sdk->get_position(pTF);
    Vector3 fwd = game_sdk->GetForward(cTF);

    // normalize แนวราบ (ไม่พุ่งขึ้น/ลงตามมุมกล้อง)
    float len = sqrtf(fwd.x * fwd.x + fwd.z * fwd.z);
    if (len < 0.001f) return;
    float nx = fwd.x / len;
    float nz = fwd.z / len;

    cur.x += nx * distance;
    cur.z += nz * distance;
    Transform_INTERNAL_SetPosition(pTF, Vvector3(cur.x, cur.y, cur.z));
}

// ── Blue Map — tint ambient + fog เป็นสีน้ำเงิน
static void RunBlueMap() {
    typedef void (*set_color_t)(UnityColor);
    typedef void (*set_bool_t)(bool);
    typedef void (*set_float_t)(float);
    static set_color_t _set_ambientLight = (set_color_t)getRealOffset(0x8503F7C);
    static set_color_t _set_fogColor     = (set_color_t)getRealOffset(0x85038E8);
    static set_bool_t  _set_fog          = (set_bool_t) getRealOffset(0x850363C);
    static set_float_t _set_fogDensity   = (set_float_t)getRealOffset(0x85039E0);

    // ── สีน้ำเงินเข้มจัด คลุมทั้งฉาก + พื้นผิวที่ผู้เล่นยืน ──
    // fogColor    = สีหมอกที่ห่อหุ้มทุกอย่างในฉาก (ทำให้บรรยากาศเป็นน้ำเงิน)
    // ambientLight= แสงสะท้อนรอบทิศบนพื้นผิวทุกชิ้น (เปลี่ยนสีพื้นที่เรายืน)
    // fogDensity  = ความหนาแน่น ยิ่งสูงยิ่งเข้มและคลุมระยะใกล้
    UnityColor deepBlueFog = { 0.00f, 0.04f, 0.30f, 1.0f };  // น้ำเงินเข้มมาก
    UnityColor deepBlueAmb = { 0.00f, 0.06f, 0.45f, 1.0f };  // แสง ambient น้ำเงินเข้ม

    if (_set_ambientLight) _set_ambientLight(deepBlueAmb);
    if (_set_fog)          _set_fog(true);
    if (_set_fogColor)     _set_fogColor(deepBlueFog);
    if (_set_fogDensity)   _set_fogDensity(0.10f);  // เพิ่มจาก 0.015 → 0.10 (เข้มจัด)
}

// ── Reset Account — เรียก GarenaMSDK_ResetGuest ──
// RVA: 0x5DFCBF8  GarenaMSDK_ResetGuest (void, no args)
static void DoResetAccount() {
    typedef void (*reset_guest_t)();
    static reset_guest_t _GarenaMSDK_ResetGuest =
        (reset_guest_t)getRealOffset(0x5DFCBF8);
    if (_GarenaMSDK_ResetGuest) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _GarenaMSDK_ResetGuest();
        });
    }
}

void (*_AutoFire)(void *_this, int32_t pFireStatus, int32_t pFireMode);

void old_AutoFire(void *_this, int32_t pFireStatus, int32_t pFireMode) 
{
    // ✅ ใช้ steady_clock (ความละเอียดระดับ nanosecond)
    // แทน clock() ที่บน iOS มี granularity ~10ms ทำให้ FireDelay ต่ำกว่า 10ms ไร้ผล
    using namespace std::chrono;
    static auto lastTime = steady_clock::now();
    static bool fireState = false;

    if (_this != NULL && Vars.AutoFire) 
    {
        void* enemy = GetClosestEnemy();

        if (enemy != NULL && tanghinh::isVisible(enemy)) 
        {
            auto now = steady_clock::now();
            double elapsed = duration<double>(now - lastTime).count();

            // ✅ toggle ทุก FireDelay/2 → 1 นัดเต็มใช้เวลา = FireDelay
            // เดิม toggle ทุก FireDelay → 1 นัดเต็มใช้ 2*FireDelay (ช้าครึ่งนึง)
            // ถ้า FireDelay = 0 (FastFire) → toggle ทุกเฟรม
            // → semi-auto (DEagle/Sniper) ได้ pulse FIRING→NONE→FIRING ทุก ~16ms
            // → engine ของปืนจะ throttle ตาม RPM ของอาวุธเอง (ไม่โดน hook block)
            float halfDelay = FireDelay * 0.0001f;
            if (elapsed >= halfDelay)
            {
                fireState = !fireState;
                lastTime = now;
            }

            pFireStatus = fireState ? FireStatus::FIRING : FireStatus::NONE;
            pFireMode = FireMode::AUTO;
        }
        else
        {
            // ❌ ไม่เห็นศัตรู → ไม่ยิง + reset เพื่อพร้อมยิงทันทีเมื่อเจอเป้าใหม่
            pFireStatus = FireStatus::NONE;
            fireState = false;
        }
    }

    return _AutoFire(_this, pFireStatus, pFireMode);
}

void aimbot()
{
    ImVec2 center = ImVec2(ImGui::GetIO().DisplaySize.x / 2, ImGui::GetIO().DisplaySize.y / 2);
    if (!Vars.Aimbot)
        return;
    ImDrawList *draw_list = ImGui::GetBackgroundDrawList();
    if (!draw_list)
        return;
    void *Match = game_sdk->Curent_Match();
    if (!Match)
        return;
    if (Vars.isAimFov)
    {
        if (Vars.fovaimglow)
            drawcircleglow(draw_list, center, Vars.AimFov, ImColor(Vars.fovLineColor[0], Vars.fovLineColor[1], Vars.fovLineColor[2], Vars.fovLineColor[3]), 999, 1, 12);
        else
            draw_list->AddCircle(center, Vars.AimFov, ImColor(Vars.fovLineColor[0], Vars.fovLineColor[1], Vars.fovLineColor[2], Vars.fovLineColor[3]), 100);
    }
    void *LocalPlayer = game_sdk->GetLocalPlayer(Match);
    if (!LocalPlayer)
        return;
    void *playertarget = GetClosestEnemy();
    if (!playertarget)
        return;
    ImVec2 EnemyLocation = Camera$$WorldToScreen::Regular(GetHeadPosition(playertarget));
    drawlineglow(draw_list, ImVec2(center.x, center.y), EnemyLocation, ImColor(255, 255, 255), 1, 3);
}
void draw_watermark()
{
    std::string claw = oxorany("");
    ImVec2 text_size = verdana_smol->calc_size(1, claw);
    ImVec2 text_pos(
        10, // Left margin
        ImGui::GetIO().DisplaySize.y - text_size.y - 10); // Bottom margin
    AddText(verdana_smol, 16, false, false, text_pos + ImVec2(1, 1), ImColor(0, 0, 0, 150), claw);
    static float hue = 0.0f;
    hue += ImGui::GetIO().DeltaTime * 0.1f;
    if (hue > 1.0f)
        hue = 0.0f;
    ImColor rainbow = ImColor::HSV(hue, 0.8f, 0.8f);
    AddText(verdana_smol, 16, false, false, text_pos, rainbow, claw);
    ImDrawList *draw_list = ImGui::GetBackgroundDrawList();
    draw_list->AddLine(
        ImVec2(text_pos.x, text_pos.y + text_size.y + 2),
        ImVec2(text_pos.x + text_size.x, text_pos.y + text_size.y + 2),
        rainbow,
        2.0f);

    // ===== Center floating text - always // ===== Center floating text - always std::string center_text = oxorany("Fluck all right reverse");
    // ===== Center floating text - always visible =====
    std::string center_text = "2K COMMUNITY/monalisa";
    ImVec2 ctext_size = verdana_smol->CalcTextSizeA(24, FLT_MAX, 0, center_text.c_str());
    ImVec2 cpos(
        (ImGui::GetIO().DisplaySize.x - ctext_size.x) * 0.5f,
        30
    );
    // Shadow for readability
    AddText(verdana_smol, 24, false, false, ImVec2(cpos.x + 1, cpos.y + 1), ImColor(0, 0, 0, 200), center_text);
    AddText(verdana_smol, 24, false, false, ImVec2(cpos.x + 2, cpos.y + 2), ImColor(0, 0, 0, 120), center_text);
    // Bold black text (drawn twice with 1px offset to fake bold)
    AddText(verdana_smol, 24, false, false, cpos,                            ImColor(0, 0, 0, 255), center_text);
    AddText(verdana_smol, 24, false, false, ImVec2(cpos.x + 1, cpos.y),     ImColor(0, 0, 0, 200), center_text);
   }
