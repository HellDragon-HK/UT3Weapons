/******************************************************************************
UT3Pickup

Creation date: 2008-07-20 11:48
Last change: $Id$
Copyright (c) 2008, 2013 Wormbo, GreatEmerald
******************************************************************************/

class UT3Pickup extends TournamentPickup notplaceable;


//=============================================================================
// Properties
//=============================================================================

var() Sound RespawnSound;
var() Sound SpawnedAmbientSound;


//=============================================================================
// Variables
//=============================================================================

var TexPannerTriggered RespawnBuildGlow;
var bool bWasHidden;


simulated function PostBeginPlay()
{
	local UT3MaterialManager MaterialManager;
	local int i;
	
	Super.PostBeginPlay();
	
	if (Level.NetMode != NM_DedicatedServer) {
		MaterialManager = class'UT3MaterialManager'.static.GetMaterialManager(Level);
		RespawnBuildGlow = MaterialManager.GetSpawnEffectPanner(1.6 / GetSoundDuration(RespawnSound));
		for (i = 0; i < Skins.Length; ++i) {
			switch (Skins[i]) {
			case FinalBlend'PickupSkins.Shaders.FinalHealthGlass':
				Skins[i] = MaterialManager.GetSpawnEffectGlass(RespawnBuildGlow);
				break;
			case Shader'XGameTextures.SuperPickups.MHInnerS':
				Skins[i] = MaterialManager.GetSpawnEffectBubbles(RespawnBuildGlow);
				break;
			case FinalBlend'PickupSkins.Shaders.FinalHealthCore':
				Skins[i] = MaterialManager.GetSpawnEffectHealth(RespawnBuildGlow);
				break;
			case FinalBlend'PickupSkins.Shaders.ShieldFinal':
				Skins[i] = MaterialManager.GetSpawnEffectShield(RespawnBuildGlow);
				break;
			case FinalBlend'PickupSkins.Shaders.FinalDamShader':
				Skins[i] = MaterialManager.GetSpawnEffectUDamage(RespawnBuildGlow);
				break;
			default:
				if (Texture(Skins[i]) != None) {
					Skins[i] = MaterialManager.GetSpawnEffectTexture(RespawnBuildGlow, Texture(Skins[i]));
				}
			}
		}
		
		PostNetReceive();
	}
}


simulated function Destroyed()
{
	local UT3MaterialManager MaterialManager;
	local int i;
	
	if (Level.NetMode != NM_DedicatedServer) {
		MaterialManager = class'UT3MaterialManager'.static.GetMaterialManager(Level);
		for (i = 0; i < Skins.Length; ++i) {
			MaterialManager.ReleaseSpawnEffect(Skins[i]);
		}
		MaterialManager.ReleaseSpawnEffect(RespawnBuildGlow);
	}
	Super.Destroyed();
}


function RespawnEffect()
{
	PlaySound(RespawnSound);
}


simulated function PostNetReceive()
{
	if (!bHidden && bWasHidden) {
		RespawnBuildGlow.Trigger(Self, None);
	}
	bWasHidden = bHidden;
}


auto state Pickup
{
    function BeginState()
    {
        Super.BeginState();
        if (UT3PickupFactory(PickUpBase) != None)
            UT3PickupFactory(PickUpBase).StartPulse(true);
    }

Begin:
	CheckTouching();
	AmbientSound = SpawnedAmbientSound;
}


state Sleeping
{
    function BeginState()
    {
        AmbientSound = None;
        Super.BeginState();
        if (Level.NetMode != NM_DedicatedServer)
            PostNetReceive();
        if (UT3PickupFactory(PickUpBase) != None)
        {
            log(self@"Sleeping: Entered BeginState");
            UT3PickupFactory(PickUpBase).StartPulse(false);
        }
    }

    function EndState()
    {
        Super.EndState();
        if (Level.NetMode != NM_DedicatedServer)
            PostNetReceive();
    }

DelayedSpawn:
Begin:
    if (UT3PickupFactory(PickUpBase) != None)
    {
        Sleep(GetReSpawnTime() - UT3PickupFactory(PickUpBase).PulseThreshold);
        log(self@"Sleeping: Should start pulsing now");
        UT3PickupFactory(PickUpBase).StartPulse(true);
        Sleep(UT3PickupFactory(PickUpBase).PulseThreshold);
    }
    else
        Sleep(GetReSpawnTime() - RespawnEffectTime);
Respawn:
	RespawnEffect();
	Sleep(RespawnEffectTime);
	if (PickUpBase != None)
		PickUpBase.TurnOn();
	GotoState('Pickup');
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	bNetNotify = True
	CollisionRadius = 40.0
	CollisionHeight = 44.0
	
	TransientSoundVolume = 1.0
	TransientSoundRadius = 1000.0
	SoundVolume = 200
	SoundRadius = 500.0
	
	bWasHidden = True
	RespawnEffectTime = 0.0
	DrawType = DT_StaticMesh
}
