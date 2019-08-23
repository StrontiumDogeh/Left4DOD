/**
 * =============================================================================
 * SourceMod Left4DoD for Day of Defeat Source
 * (C)2009 - 2010 Dog - www.theville.org
 *
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Ammo restock adapted from DoDS Restock by Feuersturm
 * Particles Effects routine by L.Duke
 * Damage routine by pimpinjuice
 * Basechatx by MMX
 * Fast Respawn routine by Andersso
 */


#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <morecolors>

//See also line 879
#undef REQUIRE_EXTENSIONS
#include <dodhooks>

#define PLUGIN_VERSION "5.3.200"

#define DEBUG 0

#define MAXWEAPONS 45

//Used for versus
#define MINIMUMALLIES 7

#define AXIS 3
#define ALLIES 2
#define BOTS 1
#define SPECTATOR 1
#define UNASSIGNED 0

#define RIFLEMAN 0
#define ASSAULT 1
#define SUPPORT 2
#define SNIPER 3
#define MG 4
#define ROCKET 5

#define WAYPOINTREACHED 8.0
#define MOVE_SEEK 250.0
#define MOVE_ATTACK 350.0
#define MOVE_FORWARD 220.0
#define UNG_FORWARD 150.0
#define GRAVITY -450.0

#define MAXHEALTH 100
#define WRAITH_HEALTH 140
#define UNG_HEALTH 500
#define SKELETON_HEALTH 180
#define GREYDUDE_HEALTH 190
#define INFECTEDONE_HEALTH 170
#define WITCH_HEALTH 130
#define ANARCHIST_HEALTH 190
#define GASMAN_HEALTH 190
#define EMO_HEALTH 200
#define HELLSPAWN_HEALTH 300
#define ZOMBIE_HEALTH 100

#define WITCHSPEED 1.5
#define ZOMBIESPEED 1.0
#define SKELETONSPEED 1.07
#define INFECTEDSPEED 1.01
#define UNGSPEED 0.80

#define GASBOMB 80.0
#define SUCK 5.0
#define HEAL 40.0
#define MINES 9

#define HOOCH_SPEED 1.8

#define TW 10
#define TK 5

#define PI 3.1415926535897932384626433832795

#define ZOMBIETYPES 10
#define WITCH 0
#define GREYDUDE 1
#define GASMAN 2
#define INFECTEDONE 3
#define EMO 4
#define ANARCHIST 5
#define UNG 6
#define WRAITH 7
#define SKELETON 8
#define HELLSPAWN 9
#define ZOMBIE -1

//Begin attacking from this point
#define MINIMUM_ATTACK_DISTANCE 180.0
#define MINIMUM_RUN_DISTANCE 66.0

//4=COLLISION_GROUP_INTERACTIVE
#define DROP_COLLISION   4
//28
#define DROP_SOLID_FLAGS 156
#define DROP_SOLID 6
#define DROP_RANGE 80.0

#define COLLISION_GROUP_DEBRIS 1
#define COLLISION_GROUP_INTERACTIVE 8

#define STOREDISTANCE 150.0

#define FLAMELENGTH 500.0

#define FIRE_SMALL_LOOP2  "ambient/fire/fire_small_loop2.wav"

#define DMG_GENERIC			0
#define DMG_CRUSH			(1 << 0)
#define DMG_SLASH			(1 << 2)
#define DMG_BURN			(1 << 3)
#define DMG_FALL			(1 << 5)
#define DMG_ENERGYBEAM 	(1 << 10)
#define DMG_POISON		(1 << 17)
#define DMG_ACID			(1 << 20)

#define FFADE_IN            0x0001        // Just here so we don't pass 0 into the function
#define FFADE_OUT           0x0002        // Fade out (not in)
#define FFADE_MODULATE      0x0004        // Modulate (don't blend)
#define FFADE_STAYOUT       0x0008        // ignores the duration, stays faded out until new ScreenFade message received
#define FFADE_PURGE         0x0010        // Purges all other fades, replacing them with this one

//Damagetype types
#define MELEE			4224

//Data Handles
new Handle:hTeleportData[MAXPLAYERS+1];
new Handle:hSkullData[MAXPLAYERS+1];
new Handle:hFireballData[MAXPLAYERS+1];

//CVAR Handles
new Handle:hL4DOn;
new Handle:hL4DSetup;
new Handle:hL4DSpawnProtection;
new Handle:hL4DGameType;
new Handle:hL4DAI;
new Handle:hL4DFright;
new Handle:hL4DSI;
new Handle:hL4DDrops;
new Handle:hL4DTickets;
new Handle:hL4DSpawnDistance = INVALID_HANDLE;
new Handle:hFF = INVALID_HANDLE;
//new Handle:hAT = INVALID_HANDLE;

//Timer Handles
new Handle:hAmbientTimer = INVALID_HANDLE;
new Handle:hSpawnCheckTimer = INVALID_HANDLE;
new Handle:hZombieSoundsTimer = INVALID_HANDLE;
new Handle:hTeamCheck = INVALID_HANDLE;
new Handle:hOneSecond = INVALID_HANDLE;
new Handle:hTenSecond = INVALID_HANDLE;
new Handle:hTenthSecond = INVALID_HANDLE;
new Handle:hFlagTimer = INVALID_HANDLE;
new Handle:hAFKUpdateViewTimer = INVALID_HANDLE;
new Handle:hAFKCheckPlayersTimer = INVALID_HANDLE;
new Handle:g_hSearch_Timer[MAXPLAYERS+1];
new Handle:hFireTimer[MAXPLAYERS+1];
new Handle:hShieldTimer[MAXPLAYERS+1];
new Handle:hAngleTimer[MAXPLAYERS+1];

//Cookie handles
new Handle:hEquipCookie;
new Handle:hHelpCookie;
new Handle:hOverlayCookie;
new Handle:hPrimaryCookie;
new Handle:hSecondaryCookie;
new Handle:hGrenadeCookie;
new Handle:hZombieClassCookie;

//RESPAWN HOOKS
//new Handle:hGameConfig;
//new Handle:hPlayerRespawn;

//Database handle
new Handle:hDatabase = INVALID_HANDLE;

new String:g_szMapName[64];
new String:g_szPlayerWeapon[MAXPLAYERS+1][32];
new String:g_szPlayerSecondaryWeapon[MAXPLAYERS+1][32];
new String:g_szPlayerGrenadeWeapon[MAXPLAYERS+1][32];

new String:g_szLogFileName[PLATFORM_MAX_PATH];

new bool:g_bIsSupporter[MAXPLAYERS+1];
new g_IsMember[MAXPLAYERS+1];

new g_iUserID[MAXPLAYERS+1];

//Weather -1 = clear 0 = rain 1 = fastsnow 2 = ash 3 = snow
new g_iWeather = -1;

//Offsets
new g_oAmmo;
new g_oEntityOrigin;
new g_offsetClip1;
new g_oWeaponParent;

new g_iCurrentRound;
new g_iWaitCount;

//Drops
new g_AmmoBoxNumber;
new g_HealthPackNumber;
new g_MineNumber;
new g_ZombieBloodNumber;
new g_BoxNadesNumber;
new g_SkullNumber;
new g_FireballNumber;
new g_iGasBombNumber;
new g_HoochNumber;
new g_AdrenalineNumber;
new g_PillsNumber;
new g_AntiGasNumber;
new g_TNTNumber;
new g_RadioNumber;
new g_ShieldNumber;
new g_SpringNumber;
new g_BombletNumber;

//Gasbombs
new g_iGasBombEntity[MAXPLAYERS+1];
new Float:g_vecLastGasBombLoc[MAXPLAYERS+1][3];
new g_iNumGasBombs[MAXPLAYERS+1];

//TNT
new g_iDroppedTNT[MAXPLAYERS+1];

//Sticky Nades
new g_iDroppedMine[MAXPLAYERS+1][10];
new g_numMines[MAXPLAYERS+1];
new Float:g_fLastMineLength[2048];
new g_iMineData[2048];

//Scoring
new g_Allies;
new g_AlliedWins;
new g_AxisWins;
new g_botnumber;
new g_NumberAlliedTickets;

//Sprite models
new g_AlliedSpriteModel;
new g_AlliedSpriteModel50;
new g_AlliedSpriteModel75;
new g_AlliedSpriteModel200;
new g_AlliedSpriteModel400;
new g_AxisHumanSpriteModel;
new g_AxisSpriteModel[10];
new BeamSprite;
new HaloSprite;
new GunSmokeSprite;
new BallSprite;

//g_mapType = 0 standard map; g_mapType = 1 Allied defend map
new g_mapType;

//Team Balance
new g_Checking = 0;

//Health
new g_Health[MAXPLAYERS+1];
new Float:g_fDamageScale[MAXPLAYERS+1];
new g_HealthMax[MAXPLAYERS+1];
new g_HealthAdded[MAXPLAYERS+1];

new g_Bomblet[MAXPLAYERS+1];
new g_Molotov[MAXPLAYERS+1];
new g_Parachute[MAXPLAYERS+1];

new g_Sprite[MAXPLAYERS+1];
new g_SpriteEntity[MAXPLAYERS+1];

new g_iSwapped[MAXPLAYERS+1];

new g_numSkull[MAXPLAYERS+1];
new g_numFireball[MAXPLAYERS+1];
new g_numMaster[MAXPLAYERS+1];
new g_numTP[MAXPLAYERS+1];

new g_numDroppedHealth[MAXPLAYERS+1];

new g_iSuckCount[MAXPLAYERS+1];

//Zombie Type: Witch:0 GreyDude:1 Gasman:2 Traitor:3 Emo:4 Anarchist:5 UNG:6 Wraith:7 Skeleton:8
new g_ZombieType[MAXPLAYERS+1];

new g_ScoreWitch[MAXPLAYERS+1];
new g_ScoreEmo[MAXPLAYERS+1];
new g_ScoreGreyDude[MAXPLAYERS+1];
new g_ScoreGasMan[MAXPLAYERS+1];
new g_ScoreTraitor[MAXPLAYERS+1];
new g_ScoreZombies[MAXPLAYERS+1];
new g_ScoreHumans[MAXPLAYERS+1];
new g_ScoreAnarchist[MAXPLAYERS+1];
new g_ScoreUNG[MAXPLAYERS+1];
new g_ScoreWraith[MAXPLAYERS+1];
new g_ScoreSkeleton[MAXPLAYERS+1];
new g_ScoreHellSpawn[MAXPLAYERS+1];

new g_minAlpha[MAXPLAYERS+1];
new g_wasTP[MAXPLAYERS+1];

new g_FireParticle[MAXPLAYERS+1];
new g_TNTentity[MAXPLAYERS+1];
new g_preHealth[MAXPLAYERS+1];

new g_iTimeAtSpawn[MAXPLAYERS+1];
new Float:g_vecSpawn[MAXPLAYERS+1][3];

new bool:g_OnFire[MAXPLAYERS+1];
new bool:g_isIgnored[MAXPLAYERS+1];
new bool:g_bCanMakeNoise[MAXPLAYERS+1];
new bool:g_canTP[MAXPLAYERS+1];
new bool:g_canDet[MAXPLAYERS+1];
new bool:g_canGas[MAXPLAYERS+1];
new bool:g_canSkull[MAXPLAYERS+1];
new bool:g_canFireball[MAXPLAYERS+1];
new bool:g_canSuck[MAXPLAYERS+1];
new bool:g_canMine[MAXPLAYERS+1];

new bool:g_bCanGasBomb[MAXPLAYERS+1];
new bool:g_canVanish[MAXPLAYERS+1];
new bool:g_Invisible[MAXPLAYERS+1];
new bool:g_canAppear[MAXPLAYERS+1];
new bool:g_hasHooch[MAXPLAYERS+1];
new bool:g_hasAntiGas[MAXPLAYERS+1];
new bool:g_hasShotgun[MAXPLAYERS+1];
new bool:g_canMaster[MAXPLAYERS+1];
new bool:g_switchSpec[MAXPLAYERS+1];
new bool:g_hasBoxNades[MAXPLAYERS+1];
new bool:g_ShowSprite[MAXPLAYERS+1];
new bool:g_canUseWeapon[MAXPLAYERS+1];
new bool:g_HasMolotov[MAXPLAYERS+1];
new bool:g_ShieldDeployed[MAXPLAYERS+1];
new bool:g_checkWeapons[MAXPLAYERS+1];
new bool:g_hasParachute[MAXPLAYERS+1];
new bool:g_canSmoke[MAXPLAYERS+1];
new bool:g_hasAdrenaline[MAXPLAYERS+1];
new bool:g_hasSprings[MAXPLAYERS+1];
new bool:g_showOverlay[MAXPLAYERS+1];
new bool:g_isInfected[MAXPLAYERS+1];

new bool:g_getIntro[MAXPLAYERS+1];

new bool:g_plantedTNT[MAXPLAYERS+1];
new bool:g_primedTNT[MAXPLAYERS+1];
new bool:g_airstrike[MAXPLAYERS+1];
new bool:g_Shield[MAXPLAYERS+1];

new bool:g_useEquip[MAXPLAYERS+1];
new bool:g_useFL[MAXPLAYERS+1];
new bool:g_found[MAXPLAYERS+1];
new bool:g_bGasBombExploded[MAXPLAYERS+1];
new bool:g_bPlayerDead[MAXPLAYERS+1];
new bool:g_CanRightClick[MAXPLAYERS+1];
new bool:g_bZoomed[MAXPLAYERS+1];
new bool:g_invZB[MAXPLAYERS+1];
new bool:g_noFire[MAXPLAYERS+1];
new bool:g_PauseMovement[MAXPLAYERS+1];

// Zombie classes
new g_PlayEmo;
new g_PlayUNG;
new g_PlaySkeleton;
new g_PlayGreyDude;
new g_PlayWitch;
new g_PlayGasman;
new g_PlayWraith;
new g_PlayAnarchist;
new g_PlayInfectedOne;
new g_PlayHellSpawn;

//Cookies
new bool:g_Hints[MAXPLAYERS+1];
new bool:g_ShowOverlays[MAXPLAYERS+1];
new g_ZombieClass[MAXPLAYERS+1];

new bool:g_bCanRespawn[MAXPLAYERS+1];

new bool:g_bRoundOver = false;
new bool:g_inProgress = false;
new bool:g_bRoundActive = false;

//Bot properties
new g_iBotsTarget[MAXPLAYERS+1];
new g_iBotsDirection[MAXPLAYERS+1];
new g_iBotsTime[MAXPLAYERS+1];
new g_iBotsStuck[MAXPLAYERS+1];
new g_iBotsLostTarget[MAXPLAYERS+1];
new g_iHasSpawned[MAXPLAYERS+1];
new g_iBotJumped[MAXPLAYERS+1];
new Float:g_vecBotVel[MAXPLAYERS+1][3];
new bool:g_bCanTarget[MAXPLAYERS+1];
new bool:g_bAtFlag[MAXPLAYERS+1];
new bool:g_bIsWaiting[MAXPLAYERS+1];

//Waypoints
new Float:g_vecAlliesWaypointSet[15][150][3];
new Float:g_vecAxisWaypointSet[15][150][3];
new Float:g_vecWayPoint[MAXPLAYERS+1][150][3];
new Float:g_vecLastPosition[MAXPLAYERS+1][3];
new g_WayPoint[MAXPLAYERS+1];
new g_WayPointSet[MAXPLAYERS+1];
new g_WayPointCheck[MAXPLAYERS+1];
new g_iAlliesKeys[15];
new g_iAxisKeys[15];
new String:g_szWayPointCreator[32];
new String:g_szWayPointDate[16];

//Spawn points
new Float:g_vecAlliesSpawnAngle[8][3];
new Float:g_vecAxisSpawnAngle[8][3];
new Float:g_vecAlliesSpawn[8][3];
new Float:g_vecAxisSpawn[8][3];
new Float:g_vecFlagVector[8][3];
new Float:g_vecZFlagVector[8][3];

// Teamkill variables
new g_tkAmount[MAXPLAYERS+1];
new g_twAmount[MAXPLAYERS+1];
new g_actualtkAmount[MAXPLAYERS+1];
new g_tkfromtw[MAXPLAYERS+1];
new g_tkClient[MAXPLAYERS+1];
new bool:g_tkDelayedKill[MAXPLAYERS+1];

//Flag cap variables
new g_iObjectiveResource;
new g_iDoDCaptureArea[9];
//new g_iDoDCcontrolPoint[9];

new g_flagAlliedDefCaps[9];
new g_flagAxisDefCaps[9];
new g_oOwner;
new g_oAlliesTime;
new g_oAxisTime;
new g_oAlliesCaps;
new g_oAxisCaps;
new g_iFlagNumber;
new g_atFlag[9][MAXPLAYERS+1];
new g_AlliedFlagStatus;
new g_AxisFlagStatus;
new bool:g_bFlagData = false;
new bool:g_bSpawnData = false;
new bool:g_bZSpawnData = false;
new Float:g_fNumberAlliesAtFlag[9];
new g_NumberAxisAtFlag[9];
new Float:g_fAlliedCapTime = 5.0;
new Float:g_fAxisCapTime = 5.0;

//Spawn checks
new Float:g_fAlliedSpawnVectors[25][3];
new Float:g_fAxisSpawnVectors[25][3];
new g_NumberofAlliedSpawnPoints;
new g_NumberofAxisSpawnPoints;

//AFK
new Float:g_fPosition[MAXPLAYERS+1][3];
new g_iTimeAFK[MAXPLAYERS+1];
new bool:g_iSuspendAFK[MAXPLAYERS+1];

new g_AxisColour[4] = {255, 51, 51, 255};
new g_AxisColourFeed[4] = {255, 255, 255, 255};
new g_AlliesColour[4] = {124, 200, 0, 255};
new g_WhiteColour[4] = {255, 255, 255, 255};

//Double Jump
//greydude witch gasman infected emo anarchist ung wraith skeleton
new g_iLastFlags[MAXPLAYERS+1];
new g_iLastButtons[MAXPLAYERS+1];
new g_iJumps[MAXPLAYERS+1];
new g_iJumpMax[ZOMBIETYPES] = {1, 2, 3, 1, 1, 1, 1, 1, 3, 1};
new Float:g_fJumpAmount[ZOMBIETYPES] = {300.0, 450.0, 200.0, 300.0, 150.0, 300.0, 50.0, 300.0, 450.0, 300.0};

//Store
new g_iMoney[MAXPLAYERS+1];
new g_iDonateTarget[MAXPLAYERS+1];
new bool:g_AllowedMG[MAXPLAYERS+1];
new bool:g_AllowedRocket[MAXPLAYERS+1];
new bool:g_AllowedSniper[MAXPLAYERS+1];
new bool:g_StoreEnabled = false;

new String:g_Weapon[MAXWEAPONS][] =
{
	"weapon_amerknife", "weapon_spade", "weapon_colt", "weapon_p38", "weapon_m1carbine", "weapon_c96",
	"weapon_garand", "weapon_k98", "weapon_thompson", "weapon_mp40", "weapon_bar", "weapon_mp44",
	"weapon_spring", "weapon_k98_scoped", "weapon_30cal", "weapon_mg42", "weapon_bazooka", "weapon_pschreck",
	"weapon_riflegren_us", "weapon_riflegren_ger", "weapon_frag_us", "weapon_frag_ger", "weapon_smoke_us", "weapon_smoke_ger",
	"basic", "kevlar", "pills", "health", "radio", "shield", "boxnades",
	"hooch", "antigas", "invzb", "nofire", "emo", "ung", "tnt",
	"parachute", "skeleton", "adrenaline", "zombiejump", "flamethrower", "fuel", "tk"
};

new g_szWeaponCost[MAXWEAPONS] =
{
	0, 0, 0, 0, 0, 0,
	2, 2, 2, 2, 2, 2,
	40, 40, 200, 250, 35, 35,
	10, 10, 10, 10, 10, 10,
	20, 50, 90, 10, 100, 80, 80,
	50, 100, 5, 5, 0, 0, 30,
	50, 0, 10, 200, 100, 10, 500
};

new g_AmmoOffs[MAXWEAPONS] =
{
	0, 0, 4, 8, 24, 12,
	16, 20, 32, 32, 36, 32,
	28, 20, 40, 44, 48, 48,
	84, 88, 52, 56, 68, 72,
	0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0
};

new g_AmmoMax[MAXWEAPONS] =
{
	0, 0, 14, 16, 30, 40,
	80, 60, 180, 180, 240, 180,
	15, 15, 150, 180, 4, 4,
	1, 1, 2, 2, 0, 0,
	0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0
};

new g_ClipSize[MAXWEAPONS] =
{
	-1, -1, -1, -1, -1, -1,
	8, 5, 30, 30, 20, 30,
	5, 5, 150, 180, -1, -1,
	-1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1
};

new g_AmmoRefill[MAXWEAPONS] =
{
	0, 0, 0, 0, 0, 0,
	3, 2, 10, 10, 7, 10,
	3, 3, 20, 20, 1, 1,
	1, 1, 1, 1, 0, 0,
	0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0
};

new String:g_WitchSounds[6][] =
{
	"left4dod/witch/witch001.mp3", "left4dod/witch/witch002.mp3", "left4dod/witch/witch003.mp3", "left4dod/witch/witch004.mp3",
	"left4dod/witch/witch005.mp3", "left4dod/witch/witch006.mp3"
};

new String:g_ZombieSounds[27][] =
{
	"left4dod/zombie/zombie001.mp3", "left4dod/zombie/zombie002.mp3", "left4dod/zombie/zombie003.mp3", "left4dod/zombie/zombie004.mp3",
	"left4dod/zombie/zombie005.mp3", "left4dod/zombie/zombie006.mp3", "left4dod/zombie/zombie007.mp3", "left4dod/zombie/zombie008.mp3",
	"left4dod/zombie/zombie009.mp3", "left4dod/zombie/zombie010.mp3", "left4dod/zombie/zombie011.mp3", "left4dod/zombie/zombie012.mp3",
	"left4dod/zombie/zombie013.mp3", "left4dod/zombie/zombie014.mp3", "left4dod/zombie/zombie015.mp3", "left4dod/zombie/zombie016.mp3",
	"left4dod/zombie/zombie017.mp3", "left4dod/zombie/zombie018.mp3", "left4dod/zombie/zombie019.mp3", "left4dod/zombie/zombie020.mp3",
	"left4dod/zombie/zombie021.mp3", "left4dod/zombie/zombie022.mp3", "left4dod/zombie/zombie023.mp3", "left4dod/zombie/zombie024.mp3",
	"npc/zombie/zombie_alert1.wav",  "npc/zombie/zombie_alert2.wav",  "npc/zombie/zombie_alert3.wav"
};

new String:g_ZombieDeathSounds[3][] =
{
	"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"
};

new String:g_ZombieIdleSounds[14][] =
{
	"npc/zombie/zombie_voice_idle1.wav", "npc/zombie/zombie_voice_idle2.wav", "npc/zombie/zombie_voice_idle3.wav",
	"npc/zombie/zombie_voice_idle4.wav", "npc/zombie/zombie_voice_idle5.wav", "npc/zombie/zombie_voice_idle6.wav",
	"npc/zombie/zombie_voice_idle7.wav", "npc/zombie/zombie_voice_idle8.wav", "npc/zombie/zombie_voice_idle9.wav",
	"npc/zombie/zombie_voice_idle10.wav", "npc/zombie/zombie_voice_idle11.wav", "npc/zombie/zombie_voice_idle12.wav",
	"npc/zombie/zombie_voice_idle13.wav", "npc/zombie/zombie_voice_idle14.wav"
};

new String:g_ZombiePainSounds[6][] =
{
	"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"
};

new String:g_EndSounds[4][] =
{
	"left4dod/end001.mp3", "left4dod/end002.mp3", "left4dod/end003.mp3", "left4dod/zombie_win.mp3"
};

new String:g_Zaps[6][] =
{
	"ambient/energy/spark1.wav", "ambient/energy/spark2.wav", "ambient/energy/spark3.wav",
	"ambient/energy/spark4.wav", "ambient/energy/spark5.wav", "ambient/energy/spark6.wav"
};

new String:g_FlagStates[5][] =
{
	"Single Cap", "Default Cap", "Increased Cap (2)", "Increased Cap (3)", "Capping blocked"
};

new String:g_AlliedSprites[8][] =
{
	"materials/sprites/player_icons/american01.vmt", "materials/sprites/player_icons/american02.vmt", "materials/sprites/player_icons/american03.vmt",
	"materials/sprites/player_icons/american04.vmt", "materials/sprites/player_icons/american05.vmt", "materials/sprites/player_icons/american06.vmt",
	"materials/sprites/player_icons/american07.vmt", "materials/sprites/player_icons/american08.vmt"
};

#include "left4dod/display.sp"
#include "left4dod/menus.sp"
#include "left4dod/client.sp"
#include "left4dod/mines.sp"
#include "left4dod/store.sp"
#include "left4dod/sdkdamage.sp"
#include "left4dod/sdkcreate.sp"
#include "left4dod/map.sp"
#include "left4dod/event_round.sp"
#include "left4dod/event_spawn.sp"
#include "left4dod/event_death.sp"
#include "left4dod/event_hurt.sp"
#include "left4dod/event_roundwin.sp"
#include "left4dod/event_team.sp"
#include "left4dod/event_say.sp"
#include "left4dod/waypoints.sp"
#include "left4dod/weapons.sp"
#include "left4dod/skulls.sp"
#include "left4dod/detonate.sp"
#include "left4dod/invisible.sp"
#include "left4dod/teleport.sp"
#include "left4dod/fire.sp"
#include "left4dod/commands.sp"
#include "left4dod/locate.sp"
#include "left4dod/drops.sp"
#include "left4dod/timers.sp"
#include "left4dod/sound.sp"
#include "left4dod/overlay.sp"
#include "left4dod/particles.sp"
#include "left4dod/runcmd.sp"
#include "left4dod/helper.sp"
#include "left4dod/airstrike.sp"
#include "left4dod/spawnzombies.sp"
#include "left4dod/targeting.sp"
#include "left4dod/flags.sp"
#include "left4dod/gasbomb.sp"
#include "left4dod/afk.sp"
#include "left4dod/health.sp"
#include "left4dod/shield.sp"
#include "left4dod/sprites.sp"
#include "left4dod/carpet.sp"
#include "left4dod/fireball.sp"


public Plugin:myinfo =
{
	name = "Left4DoD for DoDS",
	author = "Dog",
	description = "Day of Defeat Source and Zombies",
	version = PLUGIN_VERSION,
	url = "https://www.theville.org"
};

public OnPluginStart()
{
	CreateConVar("left4dod", PLUGIN_VERSION, " Left4DoD Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	hL4DOn    					= CreateConVar("l4dod_enabled", "1", " Turn on/off Left4DoD", FCVAR_PLUGIN);
	hL4DSetup 				= CreateConVar("l4dod_setup", "0", " Allows an Admin to set up waypoints", FCVAR_PLUGIN);
	hL4DGameType				= CreateConVar("l4dod_gametype", "0", " 0=Versus 1=Coop 2=Tournament", FCVAR_PLUGIN);
	hL4DAI						= CreateConVar("l4dod_ai", "0", " Unbalances teams", FCVAR_PLUGIN);
	hL4DFright				= CreateConVar("left4dod_fright", "0", " Set ambience <0|1>", FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY);
	hL4DSpawnProtection	= CreateConVar("l4dod_sp", "4", " Spawn protection", FCVAR_PLUGIN);
	hL4DSpawnDistance		= CreateConVar("l4dod_distance", "400.0", " Distance from spawn within which dmg occurs", FCVAR_PLUGIN);
	hL4DSI						= CreateConVar("l4dod_si", "1", " Allow special infected", FCVAR_PLUGIN);
	hL4DDrops					= CreateConVar("l4dod_drops", "1", " Allow drops", FCVAR_PLUGIN);
	hL4DTickets				= CreateConVar("l4dod_tickets", "50", " Number of tickets", FCVAR_PLUGIN);

	RegAdminCmd("sm_waypoint", Command_Waypoint, ADMFLAG_CONVARS, " sm_waypoint <add|show> <# waypoint set>");
	RegAdminCmd("sm_where", Command_Location, ADMFLAG_CONVARS, " sm_where ");
	RegAdminCmd("sm_give", Command_SetMoney, ADMFLAG_BAN, " sm_give <player> <amount> ");

	RegConsoleCmd("equip", Command_Equip, " to select a weapon");
	RegConsoleCmd("drophealth", Command_DropHealth, " drop a health kit");
	RegConsoleCmd("dh", Command_DropHealth, " drop a health kit");

	RegAdminCmd("jointeam", Command_JoinTeam, 0);

	//Stops AFK counter
	RegAdminCmd("record", Command_RecordingDemo, 0);
	RegAdminCmd("stop", Command_StopRecordingDemo, 0);

	RegAdminCmd("cls_k98", Command_JoinClass, 0);
	RegAdminCmd("cls_mp40", Command_JoinClass, 0);
	RegAdminCmd("cls_mp44", Command_JoinClass, 0);
	RegAdminCmd("cls_pschreck", Command_JoinClass, 0);
	RegAdminCmd("cls_k98s", Command_JoinClass, 0);
	RegAdminCmd("cls_mg42", Command_JoinClass, 0);
	RegAdminCmd("joinclass", Command_JoinClass, 0);

	RegAdminCmd("kill", Command_Kill, 0);

	RegAdminCmd("drop", Command_Drop, 0);

	hEquipCookie 		= RegClientCookie("l4dod_use_equip", "Bring up the equip menu every time you spawn", CookieAccess_Public);
	hHelpCookie	 		= RegClientCookie("l4dod_no_hints", "Get hints each time you die", CookieAccess_Public);
	hOverlayCookie 		= RegClientCookie("l4dod_no_overlays", "Remove Allied overlays", CookieAccess_Public);
	hPrimaryCookie 		= RegClientCookie("l4dod_primary", "Primary Weapon", CookieAccess_Public);
	hSecondaryCookie 	= RegClientCookie("l4dod_secondary", "Secondary Weapon", CookieAccess_Public);
	hGrenadeCookie 		= RegClientCookie("l4dod_grenade", "Grenade Weapon", CookieAccess_Public);
	hZombieClassCookie 	= RegClientCookie("l4dod_zombie_class", "Class chosen when a Zombie", CookieAccess_Public);

	//Include these to override any medic or restock commands
	RegConsoleCmd("restock", Command_Equip);
	RegConsoleCmd("menu", Command_Equip);
	RegConsoleCmd("medic", Command_Medic);
	RegConsoleCmd("ammo", Command_Ammo);
	RegConsoleCmd("faq", Command_Help);
	RegConsoleCmd("l4dod_status", Command_Status);
	RegConsoleCmd("l4dod_botstatus", Command_BotStatus);
	RegConsoleCmd("radio", Command_Radio);
	RegConsoleCmd("off", Command_RadioOff);

	AddCommandListener(Command_VoiceMenu, "voice_areaclear");
	AddCommandListener(Command_VoiceMenu, "voice_attack");
	AddCommandListener(Command_VoiceMenu, "voice_backup");
	AddCommandListener(Command_VoiceMenu, "voice_bazookaspotted");
	AddCommandListener(Command_VoiceMenu, "voice_ceasefire");
	AddCommandListener(Command_VoiceMenu, "voice_cover");
	AddCommandListener(Command_VoiceMenu, "voice_coverflanks");
	AddCommandListener(Command_VoiceMenu, "voice_displace");
	AddCommandListener(Command_VoiceMenu, "voice_dropweapons");
	AddCommandListener(Command_VoiceMenu, "voice_enemyahead");
	AddCommandListener(Command_VoiceMenu, "voice_enemybehind");
	AddCommandListener(Command_VoiceMenu, "voice_gogogo");
	AddCommandListener(Command_VoiceMenu, "voice_grenade");
	AddCommandListener(Command_VoiceMenu, "voice_fallback");
	AddCommandListener(Command_VoiceMenu, "voice_fireleft");
	AddCommandListener(Command_VoiceMenu, "voice_fireinhole");
	AddCommandListener(Command_VoiceMenu, "voice_fireright");
	AddCommandListener(Command_VoiceMenu, "voice_hold");
	AddCommandListener(Command_VoiceMenu, "voice_left");
	AddCommandListener(Command_VoiceMenu, "voice_medic");
	AddCommandListener(Command_VoiceMenu, "voice_mgahead");
	AddCommandListener(Command_VoiceMenu, "voice_moveupmg");
	AddCommandListener(Command_VoiceMenu, "voice_needammo");
	AddCommandListener(Command_VoiceMenu, "voice_negative");
	AddCommandListener(Command_VoiceMenu, "voice_niceshot");
	AddCommandListener(Command_VoiceMenu, "voice_right");
	AddCommandListener(Command_VoiceMenu, "voice_sniper");
	AddCommandListener(Command_VoiceMenu, "voice_sticktogether");
	AddCommandListener(Command_VoiceMenu, "voice_takeammo");
	AddCommandListener(Command_VoiceMenu, "voice_thanks");
	AddCommandListener(Command_VoiceMenu, "voice_usebazooka");
	AddCommandListener(Command_VoiceMenu, "voice_usegrens");
	AddCommandListener(Command_VoiceMenu, "voice_usesmoke");
	AddCommandListener(Command_VoiceMenu, "voice_wegothim");
	AddCommandListener(Command_VoiceMenu, "voice_wtf");
	AddCommandListener(Command_VoiceMenu, "voice_yessir");

	HookEvent("player_death", PlayerDeathEvent, EventHookMode_Pre);
	HookEvent("player_spawn", SpawnEvent);
	HookEvent("player_hurt", HurtEvent, EventHookMode_Pre);
	HookEvent("player_team", TeamEvent, EventHookMode_Pre);
	HookEvent("player_changeclass", ChangeClassEvent, EventHookMode_Pre);
	HookEvent("dod_round_start", RoundStartEvent);
	HookEvent("dod_round_active", RoundActiveEvent);
	HookEvent("dod_round_win", RoundWinEvent);
	HookEvent("dod_stats_weapon_attack", WeaponEvent);
	HookEvent("player_changename", NameChangeEvent, EventHookMode_Pre);
	HookEvent("dod_game_over", GameOverEvent);
	HookEvent("dod_broadcast_audio", BroadcastAudioEvent, EventHookMode_Pre);
	HookEvent("player_say", PlayerSayEvent);
	HookEvent("dod_point_captured", FlagCapturedEvent);
	HookEvent("player_disconnect", PlayerDisconnectEvent);

	HookConVarChange(hL4DSetup, Cvar_Setup);

	hFF = FindConVar("mp_friendlyfire");
	//hAT = FindConVar("sv_alltalk");

	LoadTranslations("common.phrases");

	AddNormalSoundHook(NormalSHook:NormalSoundHook);

	//Turn off notification for Cheats
	//Most players never get on before the bots anyway, but it's a safeguard
	new Handle:sv_cheats = FindConVar("sv_cheats");
	new cvarCheatsflags = GetConVarFlags(sv_cheats);
	cvarCheatsflags &= ~FCVAR_NOTIFY;
	SetConVarFlags(sv_cheats, cvarCheatsflags);

	//OFFSETS
	g_oAmmo = FindSendPropOffs("CDODPlayer", "m_iAmmo");
	g_offsetClip1 = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	g_oEntityOrigin = FindSendPropOffs("CDODPlayer", "m_vecOrigin");
	g_oOwner = FindSendPropOffs("CDODObjectiveResource", "m_iOwner");
	g_oAlliesTime = FindSendPropOffs("CDODObjectiveResource", "m_flAlliesCapTime");
	g_oAxisTime = FindSendPropOffs("CDODObjectiveResource", "m_flAxisCapTime");
	g_oAlliesCaps = FindSendPropOffs("CDODObjectiveResource", "m_iAlliesReqCappers");
	g_oAxisCaps = FindSendPropOffs("CDODObjectiveResource", "m_iAxisReqCappers");
	g_oWeaponParent = FindSendPropOffs("CBaseCombatWeapon", "m_hOwnerEntity");

	decl String:logpath[PLATFORM_MAX_PATH];
	FormatTime(logpath, sizeof(logpath), "logs/l4dod%Y%m%d.log");
	BuildPath(Path_SM, g_szLogFileName, PLATFORM_MAX_PATH, logpath);

	//Hook Damage messages in console
	HookUserMessage(GetUserMessageId("TextMsg"), TextMsg, true);

	if (hDatabase == INVALID_HANDLE)
	{
		SQL_TConnect(StartUpConnect, "l4dod");
	}

	//################################################################################################EMERGENCY RESPAWN PLAY ROUTINE

	//hGameConfig = LoadGameConfigFile("plugin.left4dod");
	//if (hGameConfig == INVALID_HANDLE)
	//{
	//	SetFailState("Fatal Error: Missing File \"plugin.left4dod\"!");
	//}

	if (GetExtensionFileStatus("dodhooks.ext") < 1)
	{
		PrintToServer("UNABLE TO LOAD DODHOOKS - BYPASSING - ERROR:%i", GetExtensionFileStatus("dodhooks.ext"));

		//StartPrepSDKCall(SDKCall_Player);
		//PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Virtual, "Respawn");
		//PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
		//hPlayerRespawn = EndPrepSDKCall();

		//if (hPlayerRespawn == INVALID_HANDLE)
		//{
		//	SetFailState("Fatal Error: Unable to find offsets for \"CDODPlayer::ForceRespawn(void)\"!");
		//}
	}
}

public OnConfigsExecuted()
{
	//Connect to Stats Database
	if (hDatabase == INVALID_HANDLE)
	{
		SQL_TConnect(DBConnect, "l4dod");
	}
}

public StartUpConnect(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		SetFailState("Oops. Something went wrong somewhere. Report ERROR:x01 to Dog.");
		return;
	}

	hDatabase = hndl;
	LogToFileEx(g_szLogFileName, "  ");
	LogToFileEx(g_szLogFileName, "=====================================================");
	LogToFileEx(g_szLogFileName, "[L4DOD] LEFT4DOD SERVER STARTED");

	new String:address[64], ip, String:port[16], String:ServerIp[16];

	ip = GetConVarInt(FindConVar("hostip"));
	Format(ServerIp, sizeof(ServerIp), "%i.%i.%i.%i", (ip >> 24) & 0x000000FF,(ip >> 16) & 0x000000FF,(ip >> 8) & 0x000000FF, ip & 0x000000FF);

	GetConVarString(FindConVar("hostport"), port, sizeof(port));
	Format(address, sizeof(address), "%s:%s", ServerIp, port);
	LogToFileEx(g_szLogFileName,"[L4DOD] SERVER IP: %s", address);
	LogToFileEx(g_szLogFileName, "=====================================================");

	new String:query[1024];
	Format(query, sizeof(query), "SELECT * FROM auth WHERE ip = '%s';", address);
	SQL_TQuery(hDatabase, CheckServer, query, _, DBPrio_High);
}

public CheckServer(Handle:owner, Handle:hQuery, const String:error[], any:client)
{
	if(hQuery != INVALID_HANDLE)
	{
		if(SQL_GetRowCount(hQuery) == 0)
		{
			//Auth error
			SetFailState("Oops. Something went wrong somewhere. Report ERROR:x02 to Dog.");
		}
		else
		{
			PrintToServer("Connection to Left4DoD server successful.");
		}
		CloseHandle(hQuery);
	}
}

public DBConnect(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("[L4DoD] Unable to connect to database");
		return;
	}

	hDatabase = hndl;
}

//Clean up
public OnEventShutdown()
{
	UnhookEvent("player_death", PlayerDeathEvent);
	UnhookEvent("player_spawn", SpawnEvent);
	UnhookEvent("player_hurt", HurtEvent);
	UnhookEvent("player_team", TeamEvent);
	UnhookEvent("player_changeclass", ChangeClassEvent);
	UnhookEvent("dod_round_start", RoundStartEvent);
	UnhookEvent("dod_round_active", RoundActiveEvent);
	UnhookEvent("dod_stats_weapon_attack", WeaponEvent);
	UnhookEvent("player_changename", NameChangeEvent);
	UnhookEvent("dod_round_win", RoundWinEvent);
	UnhookEvent("dod_game_over", GameOverEvent);
	UnhookEvent("dod_broadcast_audio", BroadcastAudioEvent);
	UnhookEvent("dod_point_captured", FlagCapturedEvent);
	UnhookEvent("player_disconnect", PlayerDisconnectEvent);

	RemoveNormalSoundHook(NormalSoundHook);
}

//####RESPAWN ROUTINE ##################################################################################################
public Action:TimerRespawnPlayer(Handle:hTimer, any:client)
{
	if (client > 0 && IsClientInGame(client) && g_inProgress && GetClientTeam(client) == AXIS)
	{
		if (GetEntProp(client, Prop_Send, "m_iPlayerClass") != -1)
		{
				//If DoDHooks not working.....
				//Respawn and change class of bot
				if (GetExtensionFileStatus("dodhooks.ext") < 1)
				{
					//SDKCall(hPlayerRespawn, client, true);

					//if (IsFakeClient(client))
					//{
					//	FakeClientCommand(client, "cls_mp40");
					//	FakeClientCommand(client, "cls_k98");
					//}
				}
				else
				{
					RespawnPlayer(client, true);
				}
		}
	}

	return Plugin_Handled;
}


// ################################### CONVARS ##################################################################################
public Cvar_Setup(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (StrEqual(newValue, "1"))
	{
		SetConVarInt(hL4DOn, 0);
	}
	else
	{
		SetConVarInt(hL4DOn, 1);
	}
}
