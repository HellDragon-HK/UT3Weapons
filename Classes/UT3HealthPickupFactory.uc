//=============================================================================
// UT3HealthPickupFactory.uc
// The glowy health pickup base
// Copyright © 2013 GreatEmerald
//=============================================================================

class UT3HealthPickupFactory extends UT3PickupFactory
    abstract;

defaultproperties
{
    PowerUp = class'UT3HealthPickupMedium'
    StaticMesh = StaticMesh'UT3PICKUPS_Mesh.Health_Large.S_Pickups_Base_Health_Large'
    DrawScale = 0.8
    PrePivot = (Z=5.0)
    BaseBrightSkins(0) = Material'UT3Pickups.Health_Large.M_Pickups_Base_Health_Large'
    BaseDimSkins(0) = Material'UT3Pickups.Health_Large.M_Pickups_Base_Health_Large_Dim'
    SpawnHeight = +44.0
    GlowStaticMesh = StaticMesh'UT3PICKUPS_Mesh.Health_Large.S_Pickups_Base_HealthGlow01'
    GlowBrightSkins(0) = Material'UT3Pickups.Health_Large.M_Pickups_Base_Health_Glow'
    GlowDimSkins(0) = Material'UT3Pickups.Health_Large.M_Pickups_Base_Health_Glow_Dim'
    GlowColour = (R=16,G=255,B=170)
}
