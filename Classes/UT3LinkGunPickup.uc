/******************************************************************************
UT3LinkGunPickup

Creation date: 2008-07-17 11:16
Last change: $Id$
Copyright (c) 2008, 2013, 2014 Wormbo, GreatEmerald
******************************************************************************/

class UT3LinkGunPickup extends LinkGunPickup;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
    InventoryType = class'UT3LinkGun'
    PickupSound=Sound'UT3PickupSounds.LinkGunPickup'
    Skins(0)=Shader'UT3WeaponSkins.LinkGun.LinkGunSkin'
    PickupMessage="Link Gun"
    MessageClass=class'UT3PickupMessage'
    StaticMesh=StaticMesh'UT3WPStatics.UT3LinkGunPickup'
    PrePivot=(Y=24)
    DrawScale=1.1
    Standup=(X=0.25,Y=0.0,Z=0.25) // GEm: This is actually a rotator in tau radians
    AmbientGlow=77
}
