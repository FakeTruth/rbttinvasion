class Antlion extends RBTTMonster placeable;


simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local vector ApplyImpulse, ShotDir;
	local TraceHitInfo HitInfo;
	local PlayerController PC;
	local bool bPlayersRagdoll;
	local class<UTDamageType> UTDamageType;
	local class<UTEmitCameraEffect> CameraEffect;
	local name HeadShotSocketName;
	local SkeletalMeshSocket SMS;

	if ( DarkMatchLight != None )
	{
		DarkMatchLight.SetEnabled(false);
		DarkMatchLight = None;
	}

	bCanTeleport = false;
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;
	bForcedFeignDeath = false;
	bPlayingFeignDeathRecovery = false;

	HitDamageType = DamageType; // these are replicated to other clients
	TakeHitLocation = HitLoc;

	// make sure I don't have an active weaponattachment
	CurrentWeaponAttachmentClass = None;
	WeaponAttachmentChanged();

	if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
 		UTDamageType = class<UTDamageType>(DamageType);
		// tell clients whether to gib
		bTearOffGibs = (UTDamageType != None && ShouldGib(UTDamageType));
		bGibbed = bGibbed || bTearOffGibs;
		GotoState('Dying');
		return;
	}

	// Is this the local player's ragdoll?
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if( pc.ViewTarget == self )
		{
			if ( UTHud(pc.MyHud)!=none )
				UTHud(pc.MyHud).DisplayHit(HitLoc, 100, DamageType);
			bPlayersRagdoll = true;
			break;
		}
	}
	if ( (WorldInfo.TimeSeconds - LastRenderTime > 3) && !bPlayersRagdoll )
	{
		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.IsRecordingDemo())
		{
			if (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumSpectators < 2 && !WorldInfo.IsRecordingDemo())
			{
				Destroy();
				return;
			}
			bHideOnListenServer = true;

			// check if should gib (for clients)
			UTDamageType = class<UTDamageType>(DamageType);
			if (UTDamageType != None && ShouldGib(UTDamageType))
			{
				bTearOffGibs = true;
				bGibbed = true;
			}
			TurnOffPawn();
			return;
		}
		else
		{
			// if we were not just controlling this pawn,
			// and it has not been rendered in 3 seconds, just destroy it.
			Destroy();
			return;
		}
	}

	UTDamageType = class<UTDamageType>(DamageType);
	if (UTDamageType != None && !class'GameInfo'.static.UseLowGore(WorldInfo) && ShouldGib(UTDamageType))
	{
		SpawnGibs(UTDamageType, HitLoc);
	}
	else
	{
		CheckHitInfo( HitInfo, Mesh, Normal(TearOffMomentum), TakeHitLocation );

		// check to see if we should do a CustomDamage Effect
		if( UTDamageType != None )
		{
			if( UTDamageType.default.bUseDamageBasedDeathEffects )
			{
				UTDamageType.static.DoCustomDamageEffects(self, UTDamageType, HitInfo, TakeHitLocation);
			}

			if( UTPlayerController(PC) != none )
			{
				CameraEffect = UTDamageType.static.GetDeathCameraEffectVictim(self);
				if (CameraEffect != None)
				{
					UTPlayerController(PC).ClientSpawnCameraEffect(CameraEffect);
				}
			}
		}

		bBlendOutTakeHitPhysics = false;

		// Turn off hand IK when dead.
		SetHandIKEnabled(false);

		// if we had some other rigid body thing going on, cancel it
		if (Physics == PHYS_RigidBody)
		{
			//@note: Falling instead of None so Velocity/Acceleration don't get cleared
			setPhysics(PHYS_Falling);
		}

		PreRagdollCollisionComponent = CollisionComponent;
		CollisionComponent = Mesh;

		Mesh.MinDistFactorForKinematicUpdate = 0.f;

		// If we had stopped updating kinematic bodies on this character due to distance from camera, force an update of bones now.
		if( Mesh.bNotUpdatingKinematicDueToDistance )
		{
			Mesh.ForceSkelUpdate();
			Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
		}

		Mesh.PhysicsWeight = 1.0;


		SetPhysics(PHYS_RigidBody);
		Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
		SetPawnRBChannels(TRUE);
		
		if( TearOffMomentum != vect(0,0,0) )
		{
			ShotDir = normal(TearOffMomentum);
			ApplyImpulse = ShotDir * DamageType.default.KDamageImpulse;
			
			// If not moving downwards - give extra upward kick
			if ( Velocity.Z > -10 )
			{
				ApplyImpulse += Vect(0,0,1)*DamageType.default.KDeathUpKick;
			}
			Mesh.AddImpulse(ApplyImpulse, TakeHitLocation, HitInfo.BoneName, true);
		}

		GotoState('Dying');

		if (WorldInfo.NetMode != NM_DedicatedServer && UTDamageType != None && UTDamageType.default.bSeversHead && !bDeleteMe)
		{
			SpawnHeadGib(UTDamageType, HitLoc);

			if ( !class'GameInfo'.Static.UseLowGore(WorldInfo) )
			{
				HeadShotSocketName = GetFamilyInfo().default.HeadShotGoreSocketName;
				SMS = Mesh.GetSocketByName( HeadShotSocketName );
				if( SMS != none )
				{
					HeadshotNeckAttachment = new(self) class'StaticMeshComponent';
					HeadshotNeckAttachment.SetActorCollision( FALSE, FALSE );
					HeadshotNeckAttachment.SetBlockRigidBody( FALSE );
					HeadshotNeckAttachment.SetScale(0.5);

					Mesh.AttachComponentToSocket( HeadshotNeckAttachment, HeadShotSocketName );
					HeadshotNeckAttachment.SetStaticMesh( GetFamilyInfo().default.HeadShotNeckGoreAttachment );
					HeadshotNeckAttachment.SetLightEnvironment( LightEnvironment );
				}
			}
		}
	}
}

defaultproperties
{
	health=400

	bMeleeMonster = True;
	bInvisibleWeapon = True;

	TorsoBoneName="Spine"
	HeadBone="Antlion.Head_Bone"
	bEnableFootPlacement=False
	LeftFootControlName="LeftFrontFootControl"
	RightFootControlName="RightFrontFootControl"
	MonsterName = "Antlion"
	MonsterSkill=5
	LightEnvironment=MyLightEnvironment
	BioBurnAway=GooDeath
	ArmsMesh(0)=FirstPersonArms
	ArmsMesh(1)=FirstPersonArms2
	PawnAmbientSound=AmbientSoundComponent
	WeaponAmbientSound=AmbientSoundComponent2
	GroundSpeed=400.000000
   OverlayMesh=OverlayMeshComponent0
   DefaultFamily=Class'AntLionFamilyInfo'
   
   DefaultMesh=SkeletalMesh'AntlionContent.antlion'
   
   WalkableFloorZ=0.300000
   
   ControllerClass=Class'RBTTMonsterControllerMelee'
   InventoryManagerClass=class'RBTTInventoryManager'
  
   Begin Object Name=WPawnSkeletalMeshComponent ObjName=WPawnSkeletalMeshComponent Archetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
      Scale3D=(X=1.5,Y=1.5,Z=1.5)
      Rotation=(Yaw=49149) //(65535 = 360 degrees) (16383 = 90 degrees) | Yaw, Roll, Pitch
      SkeletalMesh=SkeletalMesh'AntlionContent.antlion'
      AnimTreeTemplate=AnimTree'AntlionContent.antlionAnimTree'
      AnimSets(0)=AnimSet'AntlionContent.antlion_animation'
      bHasPhysicsAssetInstance=True
      PhysicsAsset=PhysicsAsset'AntlionContent.antlion_Physics'
      Name="WPawnSkeletalMeshComponent"
	  ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTPawn:WPawnSkeletalMeshComponent'
   End Object
   Mesh=WPawnSkeletalMeshComponent
   
   DefaultHeight = 50.0000
   DefaultRadius = 50.0000

   Begin Object Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
      CollisionHeight=50.000000
      CollisionRadius=50.000000
      ObjectArchetype=CylinderComponent'UTGame.Default__UTPawn:CollisionCylinder'
   End Object
   CylinderComponent=CollisionCylinder
   
   Components(0)=CollisionCylinder
   
   Begin Object Name=Arrow ObjName=Arrow Archetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
      ObjectArchetype=ArrowComponent'UTGame.Default__UTPawn:Arrow'
   End Object
   
   
   Components(1)=Arrow
   Components(2)=MyLightEnvironment
   Components(3)=WPawnSkeletalMeshComponent
   Components(4)=AmbientSoundComponent
   Components(5)=AmbientSoundComponent2
   Components(6)=MyLightEnvironment
   Components(8)=CollisionCylinder
   CollisionComponent=CollisionCylinder
   Name="Default__Antlion"
   ObjectArchetype=UTPawn'UTGame.Default__UTPawn'
   
	// default bone names
	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	bNeedWeapon = false
}
