#include maps\mp\gametypes\_gamelogic;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\_movie;

init()
{
	level thread MiscConnect();

	// Common precache, do not remove !!!
	PrecacheModel("defaultactor");
	PrecacheModel("projectile_rpg7");
	PrecacheModel("projectile_semtex_grenade_bombsquad");
	PrecacheMPAnim("pb_stand_alert");
	PrecacheMPAnim("pb_stand_death_chest_blowback");
	precacheItem("lightstick_mp");
}

MiscConnect()
{
	for (;;)
	{
		level waittill("connected", player);

		// LOD tweaks
		setDvar("r_lodBiasRigid", "-1000");
		setDvar("r_lodBiasSkinned", "-1000");

		setDvar("ui_gametype", "war");
		setDvar("sv_hostname", "^3Sass' Cinematic Mod ^7- Ported to MW3 by ^3Forgive");
		setDvar("g_TeamName_Allies", "allies");
		setDvar("g_TeamName_Axis", "axis");
		setDvar("jump_slowdownEnable", "0");

		setObjectiveText(game["attackers"], "^3Sass' Cinematic Mod ^7- Ported to MW3 by ^3Forgive");
		setObjectiveText(game["defenders"], "^3Sass' Cinematic Mod ^7- Ported to MW3 by ^3Forgive");
		setObjectiveHintText("allies", " ");
		setObjectiveHintText("axis", " ");
		game["strings"]["change_class"] = " ";

		player thread MiscSpawn();
	}
}

MiscSpawn()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		// No fall damage and unlimited sprint.
		self givePerk("specialty_falldamage");
		self givePerk("specialty_marathon");

		// Misc
		thread SetPlayerScore();
		thread GivePlayerKillstreak();
		thread GivePlayerWeapon();
		thread MsgAbout();
		thread MsgWelcome();
		thread WeaponChangeClass();
		thread WeaponSecondaryCamo();
		thread CreateClone();
		thread ClearBodies();
		thread LoadPos();
		thread FakeNoclip();

		// Random useless stuff
		thread VerifyModel();
	}
}

SetPlayerScore()
{
    self endon("death");
	self endon("disconnect");
	
	setDvar("mvm_score", "Change score per kill");
	for (;;)
	{
		if(getDvar("mvm_score") != "Change score per kill")
        {
		    maps\mp\gametypes\_rank::registerScoreInfo( "kill",  int(getDvarInt("mvm_score")));

		    if ( isSubStr(getDvar("mvm_score"), "Change") || getDvarInt("mvm_score") >= 50 )
		    {
		    	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "execution", 100 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "defender", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 25 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "double", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "triple", 75 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "multi", 100 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 100 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 100 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 100 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 100 );
		    }
		    else 
		    {
		    	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "execution", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "defender", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "double", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "triple", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "multi", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 0 );
		    }
            setDvar("mvm_score", "Change score per kill");
        }
        wait 0.1;
	}
}

GivePlayerKillstreak()
{
    self endon("death");
	self endon("disconnect");

	setDvar("mvm_killstreak", "Give yourself a killstreak");
	for (;;)
	{
        if(getDvar("mvm_killstreak") != "Give yourself a killstreak")
        {
		    self maps\mp\killstreaks\_killstreaks::giveKillstreak(getDvar("mvm_killstreak"), false);
            setDvar("mvm_killstreak", "Give yourself a killstreak");
        }
        wait 0.1;
    }
}

GivePlayerWeapon()
{
    self endon("death");
	self endon("disconnect");

	setDvar("mvm_give", "Give yourself a weapon");
	for (;;)
	{
		if(getDvar("mvm_give") != "Give yourself a weapon")
        {
		    argumentstring = getDvar("mvm_give");
		    arguments = StrTok(argumentstring, " ,");

		    if ( isEquipment(arguments[0]) )
		    {
		    	if ( isSecOffhand(arguments[0]))
		    	{
		    		self iPrintLn("Changing tactical to ^8" + arguments[0] + "^7...");
		    		self takeAllSecOffhands();
		    		wait 0.1; // An artifical delay is necessary for the new equipment to register. Same happens with primaries. Why? Idk.
		    		self setOffhandSecondaryClass( getOffhandName(arguments[0]) );
		    	}
		    	else 
		    	{
		    		self iPrintLn("Changing lethal to ^8" + arguments[0] + "^7...");
		    		self takeAllPrimOffhands();
		    		wait 1; 
		    		self SetOffhandPrimaryClass( getOffhandName(arguments[0]) );
		    	}
		    	self givePerk(getOffhandName(arguments[0]));
		    	self giveWeapon(arguments[0]);
		    }
		    else
		    {
		    	self takeweapon(self getCurrentWeapon());
		    	self switchToWeapon(self getCurrentWeapon());
		    	wait .1;
		    	if (isSubStr(arguments[0], "akimbo"))
		    		self giveWeapon(arguments[0], GetCamoInt(arguments[1]), true);
		    	else self giveWeapon(arguments[0], GetCamoInt(arguments[1]), false);
				wait .1;
		    	self switchToWeapon(arguments[0], GetCamoInt(arguments[1]), true);
		    }
            setDvar("mvm_give", "Give yourself a weapon");
        }
        wait 0.1;
	}
}

MsgAbout()
{
    self endon("death");
	self endon("disconnect");

	setDvar("about", "About the mod...");
	for (;;)
	{
		if(getDvar("about") != "About the mod...")
        {
			setDvar("about", "About the mod...");
		    self IPrintLnBold("^3Sass' Cinematic Mod");
		    wait 1.5;
		    self IPrintLnBold("Ported to MW3 by ^3Forgive");
		    wait 1.5;
		    self IPrintLnBold("Thanks for downloading !");
		    self IPrintLn("^1Thanks to / Credits :");
		    self IPrintLn("- case, ozzie and ODJ for their coolness");
		    self IPrintLn("- luckyy, zura and the CoDTVMM team for base code");
		    self IPrintLn("- LASKO & simon for the menus");
		    self IPrintLn("- You and everybody who supported the project!");
		    wait 1.5;
		    self IPrintLnBold("Discord server link : discord.gg/wgRJDJJ");
            
        }
        wait 0.1;
    }
}

MsgWelcome()
{
    self endon("death");
	self endon("disconnect");
	{
		if (!isDefined(self.donefirst) && self.pers["isBot"] == false)
		{
			thread matchStartTimer("waiting_for_teams", 0);
			thread matchStartTimer("match_starting_in", 0 );
			level.prematchPeriodEnd = -1;
			wait 6;
			//self thread teamPlayerCardSplash("one_from_defcon", self, self.pers["team"]);
			self IPrintLn("Welcome to ^3Sass' Cinematic Mod");
            self IPrintLn("Ported to MW3 by ^3Forgive");
			self IPrintLn("Type ^3/about 1 ^7for more info");
			self.donefirst = 1;
		}
	}
}

WeaponChangeClass()
{
    self endon("death");
	self endon("disconnect");

	oldclass = self.pers["class"];
	for(;;)
	{
		if(self.pers["class"] != oldclass)
		{
			self maps\mp\gametypes\_class::giveloadout(self.pers["team"],self.pers["class"]);
			oldclass = self.pers["class"];
			self givePerk("specialty_falldamage");
			self givePerk("specialty_marathon");
			self thread WeaponSecondaryCamo();
		}
		wait .05;
	}
}

WeaponSecondaryCamo()
{
    sec = self.secondaryWeapon;
	self takeweapon(sec);

	if (isSubStr(sec, "akimbo"))
		self _giveWeapon(sec, self.loadoutPrimaryCamo, true);
	else self _giveWeapon(sec, self.loadoutPrimaryCamo, false);
}

CreateClone()
{
    self endon("disconnect");
	self endon("death");

	setDvar("clone", "Spawn a clone of yourself");
	for (;;)
	{
        if(getDvar("clone") != "Spawn a clone of yourself")
        {
		    if ( getDvar("clone") == "1") {
		    	self PrepareInHandModel();
		    	wait .1;
		    	self ClonePlayer(1);
		    }
		    else {
		    	self.weaptoattach delete();
		    	self ClonePlayer(1);
		    }
            setDvar("clone", "Spawn a clone of yourself");
        }
		wait 0.1;
	}
}

Clearbodies()
{
    self endon("disconnect");
	self endon("death");

	setDvar("clearbodies", "Clear all dead bodies");
	for (;;)
	{
		if(getDvar("clearbodies") != "Clear all dead bodies")
        {
			setDvar("clearbodies", "Clear all dead bodies");
		    self iPrintLn("Cleaning up...");
		    for (i = 0; i < 15; i++)
		    {
		    	clone = self ClonePlayer(1);
		    	clone delete();
		    	wait .1;
		    }
        }
        wait 0.1;
	}
}

LoadPos()
{
    self freezecontrols(true);
	wait .05;
	self setPlayerAngles(self.spawn_angles);
	self setOrigin(self.spawn_origin);
	wait .05;
	self freezecontrols(false);
}

FakeNoclip()
{
    self endon("disconnect");
	self endon("death");
	self endon("killnoclip");
	setDvar("noclip2", "Useless noclip");
	maps\mp\gametypes\_spectating::setSpectatePermissions();
	for (;;)
	{
		if(getDvarInt("noclip2") == 1)
		{
			self allowSpectateTeam("freelook", true);
			self.sessionstate = "spectator";
		}
		else if(getDvarInt("noclip2") == 0)
		{
			self allowSpectateTeam("freelook", false);
			self.sessionstate = "playing";
		}
		wait 0.1;
	}
}

VerifyModel()
{
    self endon("disconnect");
	if (isDefined(self.modelalready))
	{
		self detachAll();
		self[[game[self.lteam + "_model"][self.lmodel]]]();
	}
}

takeAllSecOffhands()
{
	self takeweapon( "smoke_grenade_mp" );
	self takeweapon( "flash_grenade_mp" );
	self takeweapon( "concussion_grenade_mp" );
}

takeAllPrimOffhands()
{
	self takeweapon( "flare_mp" );
	self takeweapon( "throwingknife_mp" );
	self takeweapon( "c4_mp" );
	self takeweapon( "claymore_mp" );
	self takeweapon( "semtex_mp" );
	self takeweapon( "frag_grenade_mp" );
}

getOffhandName(item)
{
	switch(item)
	{
		case "flash_grenade_mp":
			return "flash";
		case "smoke_grenade_mp":
			return "smoke";
		case "concussion_grenade_mp":
			return "concussion_grenade_mp";
		case "flare_mp":
			return "flare";
		case "c4_mp":
			return "c4_mp";
		case "claymore_mp":
			return "claymore_mp";
		case "semtex_mp":
			return "semtex_mp";
		case "frag_grenade_mp":
			return "frag_grenade_mp";
		case "throwingknife_mp":
			return "throwingknife_mp";
		case "lightstick_mp":
			return "lightstick_mp";
		default:
			return "other";
	}
}

isSecOffhand(item)
{
	switch(item)
	{
		case "flash_grenade_mp":
		case "smoke_grenade_mp":
		case "concussion_grenade_mp":
			return true;
		default:
			return false;
	}
}

isEquipment(item)
{
	switch(item)
	{
		case "flash_grenade_mp":
		case "concussiongrenade_mp":
		case "scrambler_mp":
		case "claymore_mp":
		case "semtex_mp":
		case "frag_grenade_mp":
		case "flash_grenade_mp":
		case "smoke_grenade_mp":
		case "concussion_grenade_mp":
		case "lightstick_mp":
			return true;
		default:
			return false;
	}
}

checkIfWeirdWeapon(weapon, camo)
{
	if(isSubStr( weapon, "magpul_masada" ) && isDefined(camo) && isValidCamoAlias(camo) ) 
		return "weapon_magpul_masada";
	if(isSubStr( weapon, "steyr" ) && isDefined(camo) && isValidCamoAlias(camo) ) 
		return "weapon_steyr";
	if(isSubStr( weapon, "aa12" ) && isDefined(camo) && isValidCamoAlias(camo) ) 
		return "weapon_aa12_2";
	if(isSubStr( weapon, "famas" ) && isDefined(camo) && isValidCamoAlias(camo) ) 
		return "weapon_famas_f1";
	if(isSubStr( weapon, "m14ebr" ) && isDefined(camo) && isValidCamoAlias(camo) ) 
		return "weapon_m14ebr";
	else return weapon;
}

checkIfCamoAvailable(weapon, camo)
{
	weaponName = StrTok(weapon, "_");
	ref = weaponName[0];
	switch( weaponName[0] )
	{
		case "fmg9":
		case "mp9":
		case "skorpion":
		case "glock":
		case "usp45":
		case "p99":
		case "mp412":
		case "44magnum":
		case "fiveseven":
		case "deserteagle":
		case "smaw":
		case "javelin":
		case "stinger":
        case "xm25":
        case "m320glm":
        case "rpg7":
			return "";
		default:
			return GetCamoName(camo);
	}
}

isValidCamoAlias(camo)
{
	switch(camo)
	{
		case "classic":
		case "snow":
		case "multi":
		case "d_urban":
		case "hex":
		case "choco":
		case "snake":
		case "blue":
        case "red":
        case "autumn":
        case "gold":
        case "marine":
        case "winter":
			return true;
		default:
			return false;
	}
}