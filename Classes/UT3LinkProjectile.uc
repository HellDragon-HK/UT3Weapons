//==============================================================================
// UT3LinkProjectile.uc
// Just for the nice sound.
// 2008, GreatEmerald
//==============================================================================

class UT3LinkProjectile extends LinkProjectile;

simulated function Explode(vector HitLocation, vector HitNormal)
{
    if ( EffectIsRelevant(Location,false) )
    {
        if (Links == 0)
            Spawn(class'LinkProjSparks',,, HitLocation, rotator(HitNormal));
        else
            Spawn(class'LinkProjSparksYellow',,, HitLocation, rotator(HitNormal));
    }
    PlaySound(Sound'UT3Style.LinkGunFireImpact');
    Destroy();
}

defaultproperties
{
   Damage=26
   Speed=1400.000000
   MaxSpeed=5000.000000
   TransientSoundVolume=0.5
   MyDamageType=class'DamTypeUT3LinkProj'
     DrawScale=0.400000
}
