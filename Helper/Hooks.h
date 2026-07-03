#import "vinhtran.hpp"
#import "loading.hxx"
#include <fstream>
#define FMT_HEADER_ONLY
#include "fmt/core.h"


struct Vars_t
  {
      bool Enable      = {};
      bool ESPCount    = {};
      // ── ESP ────────────────────────────────────────
      bool lines       = {};
      bool Box         = {};
      bool Outline     = {};
      bool Name        = {};
      bool Health      = {};
      bool Distance    = {};
      bool fovaimglow  = {};
      bool circlepos   = {};
      bool skeleton    = {};
      bool OOF         = {};
      bool enemycount  = {};
      float fovLineColor[4] = {1.0f, 1.0f, 1.0f, 1.0f};
      ImVec4 boxColor  = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
      bool IgnoreKnocked = true;
      // ── Movement Hacks ─────────────────────────────
      bool FlyAlt      = false;   // บินขึ้นเรื่อยๆ
      float FlyAltSpeed = 8.0f;
      bool FlyUntra    = false;   // บินทะลุทุกอย่าง (noclip)
      float FlyUntraSpeed = 12.0f;
      bool SpeedHolizon = false;  // เดินช้ามากๆ
      float SpeedHolizonMult = 0.08f; // 0.0=หยุด, 1.0=ปกติ
      bool StopMove    = false;   // แช่แข็งตำแหน่ง
      bool UnderKill   = false;   // มุดดิน
      float UnderKillDepth = 3.0f; // ลึก (เมตร)
      bool XMove       = false;   // ดาเมจสูง
      float XMoveMult  = 8.0f;
      // ── Player Manipulation ────────────────────────
      bool UpPlayer    = false;   // ดึงศัตรูขึ้นฟ้า
      float UpPlayerSpeed = 20.0f;

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

void game_sdk_t::init()
  {
      // ── OB54 Updated RVAs ─────────────────────────────────────────
      this->GetHp = (int (*)(void *))getRealOffset(oxo("0x543592C")); 
    this->Curent_Match = (void *(*)())getRealOffset(oxo("0x55C4DA4")); 
    this->GetLocalPlayer = (void *(*)(void *))getRealOffset(oxo("0x2FFE494")); 
    this->GetHeadPositions = (void *(*)(void *))getRealOffset(oxo("0x54547E0")); 
    this->get_position = (Vector3(*)(void *))getRealOffset(oxo("0x91CA56C")); 
    this->Component_GetTransform = (void *(*)(void *))getRealOffset(oxo("0x91B82E4")); 
    this->get_camera = (void *(*)())getRealOffset(oxo("0x915E9E4")); 
    this->WorldToViewpoint = (Vector3(*)(void*, Vector3, int))getRealOffset(oxo("0x915E364")); 
    this->get_isVisible = (bool (*)(void *))getRealOffset(oxo("0x53C8894")); 
    this->get_isLocalTeam = (bool (*)(void *))getRealOffset(oxo("0x53E20C4")); 
    this->get_IsDieing = (bool (*)(void *))getRealOffset(oxo("0x53AA18C")); 
    this->get_MaxHP = (int (*)(void *))getRealOffset(oxo("0x5435A3C")); 
    this->GetForward = (Vector3(*)(void *))getRealOffset(oxo("0x91CAF64")); 
    this->set_aim = (void (*)(void *, Quaternion))getRealOffset(oxo("0x53C4534")); 
    this->get_IsSighting = (bool (*)(void *))getRealOffset(oxo("0x53B769C")); 
    this->get_IsFiring = (bool (*)(void *))getRealOffset(oxo("0x53ACC9C")); 
    this->name = (monoString * (*)(void *player)) getRealOffset(oxo("0x53BE8E0")); 
 
    this->_GetHeadPositions = (void *(*)(void *))getRealOffset(oxo("0x54547E0")); 
    this->_newHipMods = (void *(*)(void *))getRealOffset(oxo("0x5454990")); 
    this->_GetLeftAnkleTF = (void *(*)(void *))getRealOffset(oxo("0x5454DE0")); 
    this->_GetRightAnkleTF = (void *(*)(void *))getRealOffset(oxo("0x5454EEC")); 
    this->_GetLeftToeTF = (void *(*)(void *))getRealOffset(oxo("0x5454FF8")); 
    this->_GetRightToeTF = (void *(*)(void *))getRealOffset(oxo("0x5455104")); 
    this->_getLeftHandTF = (void *(*)(void *))getRealOffset(oxo("0x53C3608")); 
    this->_getRightHandTF = (void *(*)(void *))getRealOffset(oxo("0x53C370C")); 
    this->_getLeftForeArmTF = (void *(*)(void *))getRealOffset(oxo("0x53C3810")); 
    this->_getRightForeArmTF = (void *(*)(void *))getRealOffset(oxo("0x53C3914")); 
}


void *get_gameObject(void *Pthis)
{
    return ((void* (*)(void *))getRealOffset(0x1610CC8))(Pthis);
}

static void *GetWeaponOnHand1(void *local) {
    void *(*_GetWeaponOnHand1)(void *local) = (void *(*)(void *))getRealOffset(0x53BE110); // OB54
    return _GetWeaponOnHand1(local);
}


static Vector3 Transform_INTERNAL_GetPosition(void *player) {
    Vector3 out = Vector3::zero();
    void (*_Transform_INTERNAL_GetPosition)(void *transform, Vector3 * out) = (void (*)(void *, Vector3 *))getRealOffset(ENCRYPTOFFSET("0x8552C10"));
    _Transform_INTERNAL_GetPosition(player, &out);
    return out;
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






  // ── Position Helpers ────────────────────────────────────────────────────────
  static inline void SetEntityTransformPosition(void *tf, Vector3 pos)
  {
      if (!tf) return;
      void (*_set_pos)(void *, Vector3 *) = (void (*)(void *, Vector3 *))getRealOffset(ENCRYPTOFFSET("0x91CA6A8"));
      _set_pos(tf, &pos);
  }
  static inline void SetEntityPosition(void *entity, Vector3 pos)
  {
      void *tf = game_sdk->Component_GetTransform(entity);
      SetEntityTransformPosition(tf, pos);
  }
  // ────────────────────────────────────────────────────────────────────────────
  
  // ── FLY / STOP MOVE helpers ───────────────────────────────────────────
  static inline void SetPlayerPosition(void *player, Vector3 newPos)
  {
      void *tf = game_sdk->Component_GetTransform(player);
      if (!tf) return;
      void (*_set_pos)(void *, Vector3 *) = (void (*)(void *, Vector3 *))getRealOffset(ENCRYPTOFFSET("0x91CA6A8"));
      _set_pos(tf, &newPos);
  }

  // ── Sakura ESP helpers ────────────────────────────────────────────────
  static inline void DrawRoseGlowLine(ImDrawList* dl, ImVec2 a, ImVec2 b, float thick = 1.5f)
  {
      dl->AddLine(a, b, ImColor(1.0f,0.40f,0.65f,0.10f), thick+8.0f);
      dl->AddLine(a, b, ImColor(1.0f,0.55f,0.72f,0.22f), thick+5.0f);
      dl->AddLine(a, b, ImColor(1.0f,0.70f,0.80f,0.40f), thick+3.0f);
      dl->AddLine(a, b, ImColor(1.0f,0.80f,0.87f,0.65f), thick+1.2f);
      dl->AddLine(a, b, ImColor(1.0f,1.00f,1.00f,0.90f), thick*0.5f);
  }

  static void DrawRosePetalFOV(ImDrawList* dl, ImVec2 c, float r, ImColor col, float thick=1.5f)
  {
      const int seg = 240;
      ImVec2 prev = {0,0};
      for (int i = 0; i <= seg; i++) {
          float t = i * 6.28318f / seg;
          float ro = r * fabsf(cosf(5.0f * t));
          ImVec2 cur(c.x + ro*cosf(t), c.y + ro*sinf(t));
          if (i > 0) {
              dl->AddLine(prev, cur, ImColor(1.0f,0.45f,0.65f,0.18f), thick+4.0f);
              dl->AddLine(prev, cur, ImColor(1.0f,0.60f,0.75f,0.35f), thick+2.0f);
              dl->AddLine(prev, cur, col, thick);
          }
          prev = cur;
      }
  }
  // ─────────────────────────────────────────────────────────────────────

  
void get_players()
{
    ImDrawList *draw_list = ImGui::GetBackgroundDrawList();
    if (!draw_list)
        return;
    if (!Vars.Enable)
        return;

    try
    {

          // ─── Get local player ────────────────────────────────────────────
          {
              void *_match = game_sdk->Curent_Match();
              void *_lp    = _match ? game_sdk->GetLocalPlayer(_match) : nullptr;
              float _dt    = ImGui::GetIO().DeltaTime;

              if (_lp && game_sdk->Component_GetTransform(_lp))
              {
                  void *_lptf = game_sdk->Component_GetTransform(_lp);
                  Vector3 _lppos = game_sdk->get_position(_lptf);

                  // ── STOP MOVE: แช่แข็งตำแหน่ง ────────────────────────────────
                  static Vector3 s_frozenPos = {};
                  static bool    s_wasFrozen = false;
                  if (Vars.StopMove) {
                      if (!s_wasFrozen) { s_frozenPos = _lppos; s_wasFrozen = true; }
                      SetEntityTransformPosition(_lptf, s_frozenPos);
                      _lppos = s_frozenPos;
                  } else { s_wasFrozen = false; }

                  // ── FLY ALT: บินขึ้น ─────────────────────────────────────────
                  if (Vars.FlyAlt) {
                      _lppos.y += Vars.FlyAltSpeed * _dt;
                      SetEntityTransformPosition(_lptf, _lppos);
                  }

                  // ── FLY UNTRA: บินทะลุทุกอย่าง (noclip) ─────────────────────
                  // ใช้ set_position_Injected ผ่าน transform ตรง → bypass collision
                  if (Vars.FlyUntra) {
                      _lppos.y += Vars.FlyUntraSpeed * _dt;
                      SetEntityTransformPosition(_lptf, _lppos);
                      // Zero-out downward velocity so gravity ไม่ดึงลง
                      void (*_SV)(void *, Vector3) = (void (*)(void *, Vector3))getRealOffset(ENCRYPTOFFSET("0x6454914"));
                      _SV(_lp, Vector3(0.0f, 0.1f, 0.0f));
                  }

                  // ── SPEED HOLIZON: เดินช้ามากๆ ──────────────────────────────
                  // Track delta XZ แล้วลดให้เหลือ mult*delta เท่านั้น
                  static Vector3 s_prevPos  = {};
                  static bool    s_spFirstFrame = true;
                  if (Vars.SpeedHolizon) {
                      if (s_spFirstFrame) { s_prevPos = _lppos; s_spFirstFrame = false; }
                      Vector3 delta = _lppos - s_prevPos;
                      Vector3 slowPos(
                          s_prevPos.x + delta.x * Vars.SpeedHolizonMult,
                          _lppos.y,   // คง Y (กระโดด/gravity ทำงานปกติ)
                          s_prevPos.z + delta.z * Vars.SpeedHolizonMult);
                      SetEntityTransformPosition(_lptf, slowPos);
                      s_prevPos = slowPos;
                  } else {
                      s_prevPos = _lppos;
                      s_spFirstFrame = true;
                  }

                  // ── UNDERKILL: มุดดิน ──────────────────────────────────────
                  static bool  s_underActive = false;
                  static float s_underY      = 0.0f;
                  if (Vars.UnderKill) {
                      if (!s_underActive) { s_underY = _lppos.y; s_underActive = true; }
                      Vector3 underPos(_lppos.x, s_underY - Vars.UnderKillDepth, _lppos.z);
                      SetEntityTransformPosition(_lptf, underPos);
                  } else { s_underActive = false; }

                  // ── XMOVE: ดาเมจสูง ────────────────────────────────────────
                  if (Vars.XMove && game_sdk->get_IsFiring(_lp)) {
                      void *xEnemy = GetClosestEnemysilent();
                      if (xEnemy) {
                          Vector3 enPos = GetHeadPosition(xEnemy);
                          Vector3 midPos(((_lppos.x+enPos.x)*0.5f), enPos.y, ((_lppos.z+enPos.z)*0.5f));
                          for (int xi = 0; xi < (int)Vars.XMoveMult; xi++)
                              SetEntityTransformPosition(_lptf, midPos);
                          SetEntityTransformPosition(_lptf, _lppos);
                      }
                  }

                  // ── UPPLAYER: ดึงศัตรูขึ้นฟ้า ────────────────────────────────
                  if (Vars.UpPlayer) {
                      void *upEnemy = GetClosestEnemysilent();
                      if (upEnemy) {
                          void *etf = game_sdk->Component_GetTransform(upEnemy);
                          if (etf) {
                              Vector3 epos = game_sdk->get_position(etf);
                              epos.y += Vars.UpPlayerSpeed * _dt;
                              SetEntityTransformPosition(etf, epos);
                          }
                      }
                  }

              }
          }
          // ────────────────────────────────────────────────────────────────────

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
            if (game_sdk->get_IsDieing(closestEnemy))
                continue;
            if (!game_sdk->get_isVisible(closestEnemy))
                continue;
            if (game_sdk->get_isLocalTeam(closestEnemy))
                continue;

            Vector3 pos = getPosition(closestEnemy);
            Vector3 pos2 = getPosition(local_player);
            float distance = Vector3::Distance(pos, pos2);
            if (distance > 200.0f)
                continue;
            ImColor line_color = ImColor(255, 140, 200, 230); // sakura pink
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
                        draw_list->AddLine(ImVec2(ImGui::GetIO().DisplaySize.x / 2, 0), ImVec2(rect.GetCenter().x, rect.Min.y), ImColor(255,80,80,200), 2.0f);
                    }
                    else
                    {
                        DrawRoseGlowLine(draw_list, ImVec2(ImGui::GetIO().DisplaySize.x / 2, 0), ImVec2(rect.GetCenter().x, rect.Min.y), 1.5f);
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
                        draw_list->AddRect(rect.Min - ImVec2(1, 1), rect.Max + ImVec2(1, 1), ImColor(0, 0, 0), 0.65, 0, 1);
                        draw_list->AddRect(rect.Min + ImVec2(1, 1), rect.Max - ImVec2(1, 1), ImColor(0, 0, 0), 0.65, 0, 1);
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
    }
    catch (...)
    {
        return;
    }
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
}
