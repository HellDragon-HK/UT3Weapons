//=============================================================================
// UT3RocketLauncherPickup.uc
// Got it.
// 2008, GreatEmerald
//=============================================================================

class UT3RocketLauncherPickup extends RocketLauncherPickup;

#exec OBJ LOAD FILE=UT3WeaponSkins.utx
#exec OBJ LOAD FILE=UT3WPStatics.usx

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Shader'UT3WeaponSkins.RocketLauncher.RocketLauncherSkin');
    L.AddPrecacheStaticMesh(StaticMesh'UT3WPStatics.UT3RocketLauncherPickup');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Shader'UT3WeaponSkins.RocketLauncher.RocketLauncherSkin');

    super.UpdatePrecacheMaterials();
}

defaultproperties
{
    InventoryType=class'UT3RocketLauncher'

    PickupMessage="Rocket Launcher"
    PickupSound=Sound'UT3PickupSounds.Generic.RocketLauncherPickup'
    TransientSoundVolume=0.6
    StaticMesh=StaticMesh'UT3WPStatics.UT3RocketLauncherPickup'
    PrePivot=(Y=18,Z=5)
    DrawScale=1.5
    Skins(0)=Shader'UT3WeaponSkins.RocketLauncher.RocketLauncherSkin'
    StandUp=(X=0.0,Y=0.0,Z=0.25)
}
