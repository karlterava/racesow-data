/**
 * Racesow Position Model
 *
 * @package Racesow
 * @version 1.1.0
 */
class RS_Position
{
	/**
	 * The player associated
	 */
	RS_Player @player;

	/**
	 * Whether a position has been saved
	 * @var bool
	 */
	bool saved;

	/**
	 * Location of the player
	 * @var Vec3
	 */
	Vec3 origin;

	/**
	 * Facing of the player
	 * @var Vec3
	 */
	Vec3 angles;

	/**
	 * Weapons the player posseses
	 * @var bool[]
	 */
	bool[] weapons;

	/**
	 * Ammunition count for each weapon
	 * @var int[]
	 */
	int[] ammo;

	/**
	 * The currently loaded weapon
	 * @var uint
	 */
	int weapon;

	/**
	 * Speed the player has
	 * @var uint
	 */
	float speed;

	/**
	 * Constructor
	 */
	RS_Position( RS_Player @player )
	{
		@this.player = player;
		saved = false;
		ammo.resize( WEAP_TOTAL );
		weapons.resize( WEAP_TOTAL );
	}

	/**
	 * Save the player's position, facing, and weapon loadout
	 * @return bool True if succesful
	 */
	bool save()
	{
		Entity @ent = @player.client.getEnt();
		if( @ent is null )
			return false;

		this.origin = ent.origin;
		this.angles = ent.angles;

		for( int i = WEAP_NONE + 1; i < WEAP_TOTAL; i++ )
		{
			weapons[i] = player.client.canSelectWeapon( i );
			ammo[i] = player.client.inventoryCount( G_GetItem( i ).ammoTag );
		}

		if( ent.moveType == MOVETYPE_NOCLIP )
			weapon = player.noclipWeapon;
		else
			weapon = player.client.weapon;
		weapon = weapon == 0 ? 1 : weapon;

		saved = true;
		return true;
	}

	/**
	 * Load the player's position, facing, velocity, and weapon loadout
     * @param floodProtect Set to true to flood check the load call
	 * @return bool True if succesful
	 */
	bool load()
	{
		Entity @ent = @player.client.getEnt();
		if( !saved || @ent is null )
			return false;

		// teleport the player
		player.teleport( origin, angles, false, false, false );

		// set the weapon loadout
		for( int i = WEAP_NONE + 1; i < WEAP_TOTAL; i++ )
		{
			if( weapons[i] || i == WEAP_GUNBLADE )
				player.client.inventorySetCount( i, 1 );
			player.client.inventorySetCount( G_GetItem( i ).ammoTag, ammo[i] );
		}
		player.client.selectWeapon( weapon );

		// set the players speed
		Vec3 a, b, c;
		angles.angleVectors(a, b, c);
		a.z = 0;
		a.normalize();
		a *= speed;
		if( ent.moveType != MOVETYPE_NOCLIP )
			ent.set_velocity( a );

		return true;
	}

	/**
	 * Save the player's speed
	 * @param String args The argstring passed to position command
	 * @return bool True if succesful
	 */
	bool saveSpeed( String newSpeed )
	{
		if( newSpeed.locate( "+", 0 ) == 0 )
			speed = player.getSpeed() + newSpeed.substr( 1 ).toFloat();

		else if( newSpeed.locate( "-", 0 ) == 0 )
			speed = player.getSpeed() - newSpeed.substr( 1 ).toFloat();

		else
			speed = newSpeed.toFloat();

		return true;
	}

	/**
	 * Clear the currently saved position
	 */
	void clear()
	{
		saved = false;
	}
}
