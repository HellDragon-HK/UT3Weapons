//=============================================================================
// UT3RedeemerFire.uc
// Oh I'm on fire!
// 2008, GreatEmerald
//=============================================================================

class UT3RedeemerFire extends RedeemerFire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    p = Super(ProjectileFire).SpawnProjectile(Start,Dir);
    if ( p == None )
        p = Super(ProjectileFire).SpawnProjectile(Instigator.Location,Dir);
    if ( p == None )
    {
        Weapon.Spawn(class'SmallRedeemerExplosion');
        Weapon.HurtRadius(500, 400, class'DamTypeUT3Redeemer', 100000, Instigator.Location);
    }
    return p;
}

defaultproperties
{
    //AmmoClass=class'UT3RedeemerAmmo'
    ProjectileClass=class'UT3RedeemerProjectile'
    FireSound=Sound'UT3Weapons2.Redeemer.RedeemerFire'
     FireAnim="WeaponFire"
}
