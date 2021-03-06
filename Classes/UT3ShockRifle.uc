//==============================================================================
// UT3ShockRifle.uc
// Shocking.
// 2008, 2013, 2014 GreatEmerald
//==============================================================================

class UT3ShockRifle extends ShockRifle;

var Material UDamageOverlay, FallbackSkin;
var() Sound PutDownSound;

/*var const Material RedSkin, BlueSkin;

simulated function ApplySkin()
{
    local Controller Contra;
    local UT3ShockRifleAttachment Tach;

    if (Instigator.Controller != None)
        Contra = Instigator.Controller;
    else
        return;

    Tach = UT3ShockRifleAttachment(ThirdPersonActor);
    if ( (Contra != None) && (Contra.PlayerReplicationInfo != None)&& (Contra.PlayerReplicationInfo.Team != None) )
    {
        if ( Contra.PlayerReplicationInfo.Team.TeamIndex == 0 )
        {
            Skins[0] = RedSkin;
            if (Tach != None)
                Tach.Skins[0] = RedSkin;
        }
        else if ( Contra.PlayerReplicationInfo.Team.TeamIndex == 1 )
        {
            Skins[0] = BlueSkin;
            if (Tach != None)
                Tach.Skins[0] = BlueSkin;
        }
        //log("UT3ShockRifle: Tach skin is"@Tach.Skins[0]);
    }
}

function AttachToPawn(Pawn P)
{
    Super.AttachToPawn(P);
    ApplySkin(); //GE: Applying skin here instead of PostBeginPlay() since we don't have the Instigator nor attachment there yet... We get Instigator on GiveTo, Attachment here.
}*/

function byte BestMode()
{
    local float EnemyDist, MaxDist;
    local bot B;

    bWaitForCombo = false;
    B = Bot(Instigator.Controller);
    if ( (B == None) || (B.Enemy == None) )
        return 0;

    if (B.IsShootingObjective())
        return 0;

    if ( !B.EnemyVisible() )
    {
        if ( (ComboTarget != None) && !ComboTarget.bDeleteMe && B.CanCombo() )
        {
            bWaitForCombo = true;
            return 0;
        }
        ComboTarget = None;
        if ( B.CanCombo() && B.ProficientWithWeapon() )
        {
            bRegisterTarget = true;
            return 1;
        }
        return 0;
    }

    EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
    if ( B.Skill > 5 )
        MaxDist = 4 * class'UT3ShockBall'.default.Speed; //GE: Added just to change this. It doesn't really matter since it's the same as in ShockProjectile.
    else
        MaxDist = 3 * class'UT3ShockBall'.default.Speed;

    if ( (EnemyDist > MaxDist) || (EnemyDist < 150) )
    {
        ComboTarget = None;
        return 0;
    }

    if ( (ComboTarget != None) && !ComboTarget.bDeleteMe && B.CanCombo() )
    {
        bWaitForCombo = true;
        return 0;
    }

    ComboTarget = None;

    if ( (EnemyDist > 2500) && (FRand() < 0.5) )
        return 0;

    if ( B.CanCombo() && B.ProficientWithWeapon() )
    {
        bRegisterTarget = true;
        return 1;
    }
    if ( FRand() < 0.7 )
        return 0;
    return 1;
}

function SetOverlayMaterial(Material mat, float time, bool bOverride)
{
    Super.SetOverlayMaterial(mat, time, bOverride);
    if (OverlayMaterial == class'xPawn'.default.UDamageWeaponMaterial)
        OverlayMaterial = UDamageOverlay;
    // GEm: Single-player UDamage fallback
    if (mat == None || time <= 0.0)
    {
        Skins = default.Skins;
    }
    else
        Skins[0] = FallbackSkin;
}

simulated function PostNetReceive()
{
    Super.PostNetReceive();
    // GEm: Client-side UDamage fallback
    if (OverlayMaterial == UDamageOverlay)
        Skins[0] = FallbackSkin;
    else
        Skins = default.Skins;
}

// GEm: Put down sound code below
simulated function BringUp(optional Weapon PrevWeapon)
{
   local int Mode;

    if ( ClientState == WS_Hidden )
    {
        PlayOwnedSound(SelectSound,,,,,, false);
                ClientPlayForceFeedback(SelectForce);  // jdf

        if ( Instigator.IsLocallyControlled() )
        {
            if ( (Mesh!=None) && HasAnim(SelectAnim) )
                PlayAnim(SelectAnim, SelectAnimRate, 0.0);
        }

        ClientState = WS_BringUp;
        SetTimer(BringUpTime, false);
    }
    for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
        {
                FireMode[Mode].bIsFiring = false;
                FireMode[Mode].HoldTime = 0.0;
                FireMode[Mode].bServerDelayStartFire = false;
                FireMode[Mode].bServerDelayStopFire = false;
                FireMode[Mode].bInstantStop = false;
        }
           if ( (PrevWeapon != None) && PrevWeapon.HasAmmo() && !PrevWeapon.bNoVoluntarySwitch )
                OldWeapon = PrevWeapon;
        else
                OldWeapon = None;

}

simulated function bool PutDown()
{
    local int Mode;

    if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
    {
        if ( (Instigator.PendingWeapon != None) && !Instigator.PendingWeapon.bForceSwitch )
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if ( FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring )
                    return false;
                if ( FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].FireRate*(1.f - MinReloadPct))
                                        DownDelay = FMax(DownDelay, FireMode[Mode].NextFireTime - Level.TimeSeconds - FireMode[Mode].FireRate*(1.f - MinReloadPct));
            }
        }

        PlayOwnedSound(PutDownSound,,,,,, false);

        if (Instigator.IsLocallyControlled())
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if ( FireMode[Mode].bIsFiring )
                    ClientStopFire(Mode);
            }

            if (  DownDelay <= 0 )
            {
                                if ( ClientState == WS_BringUp )
                                        TweenAnim(SelectAnim,PutDownTime);
                                else if ( HasAnim(PutDownAnim) )
                                        PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
                        }
        }
        ClientState = WS_PutDown;
        if ( Level.GRI.bFastWeaponSwitching )
                        DownDelay = 0;
        if ( DownDelay > 0 )
                        SetTimer(DownDelay, false);
                else
                        SetTimer(PutDownTime, false);
    }
    for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
    {
                FireMode[Mode].bServerDelayStartFire = false;
                FireMode[Mode].bServerDelayStopFire = false;
        }
    Instigator.AmbientSound = None;
    OldWeapon = None;
    return true; // return false if preventing weapon switch
}

defaultproperties
{
    ItemName="UT3 Shock Rifle"
    Description="The ASMD Shock Rifle has changed little since its first incorporation into the Liandri Tournament. The ASMD sports two firing modes: a thin photon beam, and a sphere of unstable plasma energy. These modes are each deadly in their own right, but used together they can neutralize opponents in a devastating shockwave. The energy spheres can be detonated with the photon beam, releasing the explosive energy of the anti-photons in the plasma's EM containment field."

    FireModeClass(0)=UT3ShockFire
    FireModeClass(1)=UT3ShockAltFire

    PickupClass=class'UT3ShockRiflePickup'
    AttachmentClass=class'UT3ShockRifleAttachment'

    SelectSound=Sound'UT3Weapons.ShockRifle.ShockRifleTakeOut'
    TransientSoundVolume=1.0

    CustomCrosshairTextureName="UT3HUD.Crosshairs.UT3CrosshairShockRifle"
    CustomCrosshairColor=(B=255,G=0,R=160,A=255)
    HudColor=(B=255,G=0,R=160,A=255)
    CustomCrosshairScale=1.00

    IconMaterial=Material'UT3HUD.Icons.UT3IconsScaled'
    IconCoords=(X1=363,Y1=190,X2=445,Y2=213)
    bSniping=True

    Priority=4.200000
    AIRating=0.650000

    IdleAnim="WeaponIdle"
    RestAnim="WeaponIdle"
    AimAnim="WeaponIdle"
    RunAnim="WeaponIdle"
    SelectAnim="WeaponEquip"
    PutDownAnim="WeaponPutDown"
    PlayerViewPivot=(Pitch=0,Yaw=-15884,Roll=500)
    PlayerViewOffset=(X=16.0,Y=7.7,Z=-6.2)
    SmallViewOffset=(X=24,Y=11.5,Z=-9.5)
    Mesh=SkeletalMesh'UT3WeaponAnims.SK_WP_ShockRifle_1P'
    BringUpTime=0.367
    PutDownTime=0.367
    HighDetailOverlay=None
    OldMesh=None
    Skins(0)=Shader'UT3WeaponSkins.ShockRifle.ShockRifleSkin'
    UDamageOverlay=Material'UT3Pickups.Udamage.M_UDamage_Overlay_S'
    FallbackSkin=Material'UT3WeaponSkins.ShockRifle.T_WP_ShockRifle_D'
    PutDownSound=Sound'UT3Weapons2.ShockRifle.A_Weapon_SR_Lower01'
}

