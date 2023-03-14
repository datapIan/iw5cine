#include maps\mp\gametypes\_hud_message;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
    level thread MovieConnect();

	level._effect["cash"] = loadfx("props/cash_player_drop");
	level._effect["blood"] = loadfx("impacts/flesh_hit_body_fatal_exit");
	game["dialog"]["gametype"] = undefined;
}

MovieConnect()
{
	for (;;)
	{
		level waittill("connected", player);
		player thread MovieSpawn();
	}
}

MovieSpawn()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		// Grenade cam reset
		setDvar("camera_thirdperson", "0");
		self show();

		// Regeneration	
		thread RegenAmmo();
		thread RegenEquip();
		thread RegenSpec();

		// Bots
		thread BotSpawn();
		thread BotSetup();
		thread BotStare();
		thread BotAim();
		thread BotModel();

		// Explosive Bullets
		thread EBClose();
		thread EBMagic();

		// "Kill" command
		thread BotKill();
		thread EnableLink();

		// Environement
		thread SpawnProps();
		thread SpawnEffects();
		thread TweakFog();
		thread SetVisions();

	}
}

RegenAmmo()
{
	for (;;)
	{
		self waittill("reload");
		wait 1;
		currentWeapon = self getCurrentWeapon();
		self giveMaxAmmo(currentWeapon);
	}
}

RegenEquip()
{
	for (;;)
	{
		if(self fragButtonPressed())
		{
			currentOffhand = self GetCurrentOffhand();
			self.pers["equSpec1"] = currentOffhand;
			wait 2;
			self setWeaponAmmoClip(self.pers["equSpec1"], 9999);
			self GiveMaxAmmo(self.pers["equSpec1"]);
		}
		wait 0.1;
	}
}

RegenSpec()
{
	for (;;)
	{
		if(self secondaryOffhandButtonPressed())
		{
			currentOffhand = self GetCurrentOffhand();
			self.pers["equSpec"] = currentOffhand;
			wait 2;
			self giveWeapon(self.pers["equSpec"]);
			self giveMaxAmmo(currentOffhand);
			self setWeaponAmmoClip(currentOffhand, 9999);
		}
		wait 0.1;
	}
}

BotSpawn()
{
    self endon("disconnect");
	self endon("death");

	setDvar("mvm_bot_add", "Spawn a bot - ^9[class team]");
	for (;;)
	{
		if(getDvar("mvm_bot_add") != "Spawn a bot - ^9[class team]")
        {
		    newTestClient = addTestClient();
		    newTestClient.pers["isBot"] = true;
		    newTestClient.isStaring = false;
		    newTestClient thread BotsLevel();
		    newTestClient thread BotDoSpawn(self); 
			setDvar("mvm_bot_add", "Spawn a bot - ^9[class team]"); 
        }
        wait 0.1;
	}
}

BotDoSpawn(owner)
{
	self endon("disconnect");

	argumentstring = getDvar("mvm_bot_add");
	arguments = StrTok(argumentstring, " ,");

	while (!isdefined(self.pers["team"])) wait .05;
	self.isUsingCustomLoadout = false;

	// Picking team
	if ( ( arguments[1] == "allies" || arguments[1] == "axis" ) && isDefined(arguments[1]) )
		self notify("menuresponse", game["menu_team"], arguments[1]);
	else 
	{
		kick(self getEntityNumber());
		owner iPrintLn("[^1ERROR^7] Team name needs to be either ^8allies ^7or ^8axis^7!");
		return;
	}
	wait .1;

	// Picking class
	if (arguments[0] == "ar")
		self notify("menuresponse", "changeclass", "class" + 0);
	else if (arguments[0] == "smg")
		self notify("menuresponse", "changeclass", "class" + 1);
	else if (arguments[0] == "lmg")
		self notify("menuresponse", "changeclass", "class" + 2);
	else if (arguments[0] == "shotgun")
		self notify("menuresponse", "changeclass", "class" + 4);
	else if (arguments[0] == "sniper")
		self notify("menuresponse", "changeclass", "class" + 3);
	else 
	{
		kick(self getEntityNumber());
		owner iPrintLn("[^3WARNING^7] ^8'"+ arguments[0] +"' ^7isn't a valid class." );
	}

	self waittill("spawned_player");

	self setOrigin(BulletTrace(owner getTagOrigin("tag_eye"), anglestoforward(owner getPlayerAngles()) * 100000, true, owner)["position"]);
	self setPlayerAngles(owner.angles + (0, 180, 0));
	self thread SaveSpawn();
}

BotSetup()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_setup", "Move bot to x-hair - ^9[name]");
	for (;;)
	{
		if(getDvar("mvm_bot_setup") != "Move bot to x-hair - ^9[name]")
		{
			foreach(player in level.players)
			{
				if (isSubStr(player.name, getDvar("mvm_bot_setup"))) 
				{
					player setOrigin(BulletTrace(self getTagOrigin("tag_eye"), anglestoforward(self getPlayerAngles()) * 100000, true, self)["position"]);
					player thread SaveSpawn();
				}
			}
			setDvar("mvm_bot_setup", "Move bot to x-hair - ^9[name]");
		}
		wait 0.1;
	}
}

BotStare()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_stare", "Bot stare at clostest enemy - ^9[name]");
	for (;;)
	{
		if(getDvar("mvm_bot_stare") != "Bot stare at clostest enemy - ^9[name]")
		{
			foreach(player in level.players)
			{
				if (isSubStr(player.name, getDvar("mvm_bot_stare")))
				{
					if (player.isStaring == false) 
					{
						player thread BotDoAim();
						player.isStaring = true;
					}
					else if (player.isStaring == true) 
					{
						player notify("stopaim");
						player.isStaring = false;
					}
					player thread SaveSpawn();
				}
			}
			setDvar("mvm_bot_stare", "Bot stare at clostest enemy - ^9[name]");
		}
		wait 0.1;
	}
}

BotAim()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_aim", "Bot aim at clostest enemy - ^9[name]");
	for (;;)
	{
		if(getDvar("mvm_bot_aim") != "Bot aim at clostest enemy - ^9[name]")
		{
			foreach(player in level.players)
			{
				if (isSubStr(player.name, getDvar("mvm_bot_aim")))
				{
					player thread BotDoAim();
					wait .4;
					player notify("stopaim");
					player thread SaveSpawn();
				}
			}
			setDvar("mvm_bot_aim", "Bot aim at clostest enemy - ^9[name]");
		}
		wait 0.1;
	}
}

BotDoAim()
{
	self endon("disconnect");
	self endon("stopaim");

	for (;;)
	{
		wait .01;
		aimAt = undefined;
		foreach(player in level.players)
		{
			if ((player == self) || (level.teamBased && self.pers["team"] == player.pers["team"]) || (!isAlive(player)))
				continue;
			if (isDefined(aimAt))
			{
				if (closer(self getTagOrigin("j_head"), player getTagOrigin("j_head"), aimAt getTagOrigin("j_head")))
					aimAt = player;
			}
			else
				aimAt = player;
		}
		if (isDefined(aimAt))
		{
			self setplayerangles(VectorToAngles((aimAt getTagOrigin("j_head")) - (self getTagOrigin("j_head"))));
		}
	}
}

BotModel()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_model", "Change bot model - ^9[name MODEL team]");
	for (;;)
	{
		if(getDvar("mvm_bot_model") != "Change bot model - ^9[name MODEL team]")
		{
			argumentstring = getDvar("mvm_bot_model");
			arguments = StrTok(argumentstring, " ,");

			foreach(player in level.players)
			{
				 if (isSubStr(player.name, arguments[0]))
                {
                    player.lteam = arguments[2];
                    player.lmodel = arguments[1];
                    if(arguments[1] == "SNIPER" || arguments[1] == "LMG" || arguments[1] == "ASSAULT" || arguments[1] == "SHOTGUN" || arguments[1] == "SMG" || arguments[1] == "RIOT" || arguments[1] == "JUGGERNAUT" || arguments[1] == "GHILLIE")
                    {
                        if(arguments[2] == "allies" || arguments[2] == "axis")
                        {
                            player.lteam = arguments[2];
                            player.lmodel = arguments[1];
                            player detachAll();
                            player[[game[player.lteam + "_model"][player.lmodel]]]();
                            player.modelalready = true;
                        }
                        else
                        {
                            self iPrintLn("^1ERROR! ^7TEAM MUST = allies, axis");
							self iprintLn("Set to default: ASSAULT allies");
							player detachAll();
							player[[game["allies_model"]["ASSAULT"]]]();
							player.modelalready = true;
                        }
                    }
                    else
                    {
                        self iPrintLn("^1ERROR! ^7CLASS MUST = SNIPER, LMG, ASSAULT, SHOTGUN, SMG, RIOT, JUGGERNAUT, GHILLIE");
						self iprintLn("Set to default: ASSAULT allies");
						player detachAll();
						player[[game["allies_model"]["ASSAULT"]]]();
						player.modelalready = true;
					}
                }
			}
			setDvar("mvm_bot_model", "Change bot model - ^9[name MODEL team]");
		}
		wait .1;
	}
}

EBClose()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_eb_close", "Toggle 'close' explosive bullets");
	for (;;)
	{
		if(getDvar("mvm_eb_close") != "Toggle 'close' explosive bullets")
		{
			if (!isDefined(self.ebclose) || self.ebclose == false)
			{
				self thread ebCloseScript();
				self iPrintLn("Close explosive bullets - ^2ON");
				self.ebclose = true;
			}
			else if (self.ebclose == true)
			{
				self notify("eb1off");
				self iPrintLn("Close explosive bullets - ^1OFF");
				self.ebclose = false;
			}
			setDvar("mvm_eb_close", "Toggle 'close' explosive bullets");
		}
		wait 0.1;
	}
}

EBMagic()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_eb_magic", "Toggle 'magic' explosive bullets");
	for (;;)
	{
		if(getDvar("mvm_eb_magic") != "Toggle 'magic' explosive bullets")
		{
			if (!isDefined(self.ebmagic) || self.ebmagic == false)
			{
				self thread ebMagicScript();
				self iPrintLn("Magic explosive bullets - ^2ON");
				self.ebmagic = true;
			}
			else if (self.ebmagic == true)
			{
				self notify("eb2off");
				self iPrintLn("Magic explosive bullets - ^1OFF");
				self.ebmagic = false;
			}
			setDvar("mvm_eb_magic", "Toggle 'magic' explosive bullets");
		}
		wait 0.1;
	}
}

ebCloseScript()
{
	self endon("eb1off");
	self endon("disconnect");

	range = 150; // make this a client adjustable variable
	for(;;)
	{
		wait .01;
		aimAt = undefined;
		destination = bulletTrace( self getEye(), anglesToForward( self getPlayerAngles() ) * 1000000, true, self )["position"];
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if (player == self)
				continue;
			if (!isAlive(player))
				continue;
			if (level.teamBased && self.pers["team"] == player.pers["team"])
				continue;
			if ( distance( destination, player getOrigin() ) > range )
                continue;
			if (isDefined(aimAt))
			{
				if (closer(self getTagOrigin("j_head"), player getTagOrigin("j_head"), aimAt getTagOrigin("j_head")))
					aimAt = player;
			}
			else aimAt = player;
		}
		if (isDefined(aimAt))
		{
			self waittill("weapon_fired");
			aimAt thread[[level.callbackPlayerDamage]](self, self, aimAt.health, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "HEAD", 0);
		}
	}
}

ebMagicScript()
{
	self endon("disconnect");
	self endon("eb2off");

	for(;;)
	{
		wait 0.1;
		aimAt = undefined;
		for (i = 0; i < level.players.size; i++)
		{
			player = level.players[i];
			if (player == self || !isAlive(player) || (level.teamBased && self.pers["team"] == player.pers["team"]))
				continue;
			if (isDefined(aimAt))
			{
				if (closer(self getTagOrigin("j_head"), player getTagOrigin("j_head"), aimAt getTagOrigin("j_head")))
					aimAt = player;
			}
			else aimAt = player;
		}
		if (isDefined(aimAt))
		{
			self waittill("weapon_fired");
			aimAt thread[[level.callbackPlayerDamage]](self, self, aimAt.health, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "HEAD", 0);
		}
	}
}

BotKill()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_kill", "Kill a bot - ^9[name mode]");
	for (;;)
	{
		if(getDvar("mvm_bot_kill") != "Kill a bot - ^9[name mode]")
		{
			argumentstring = getDvar("mvm_bot_kill", "");
			arguments = StrTok(argumentstring, " ,");

			foreach(player in level.players)
			{
				if (isSubStr(player.name, arguments[0]))
				{
					if (isDefined(self.linke))
					{
						player PrepareInHandModel();
						player takeweapon(player getCurrentWeapon());
						wait .05;
					}
					player thread BotDoKill(arguments[1], self);
				}
			}
			setDvar("mvm_bot_kill", "Kill a bot - ^9[name mode]");
		}
		wait 0.1;
	}
}

BotDoKill(mode, attacker)
{
	self endon("disconnect");
	self endon("death");

	{
		if (mode == "head")
		{
			playFx(level._effect["blood"], self getTagOrigin("j_head"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "head", 0);
		}
		else if (mode == "body")
		{
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "body", 0);
		}
		else if (mode == "shotgun")
		{
			vec = anglestoforward(self.angles);
			end = (vec[0] * (-300), vec[1] * (-300), vec[2] * (-300));
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", "spas12_mp", self.origin + end, self.origin, "left_foot", 0);
		}
		else if (mode == "cash")
		{
			playFx(level._effect["cash"], self getTagOrigin("j_spine4"));
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "body", 0);
		}
	}
}

EnableLink()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_holdgun", "Toggle bots holding their gun when dying");
	for (;;)
	{
		if(getDvar("mvm_bot_holdgun") != "Toggle bots holding their gun when dying")
		{
			if (!isDefined(self.linke))
			{
				foreach(player in level.players)
				{
					player iPrintLn("Bots hold weapon on mvm_bot_kill : ^2TRUE");
 					setDvar("mvm_throwgun", "0");
					self.linke = true;
				}
			}
			else if (self.linke == true)
			{
				foreach(player in level.players)
				{
					player iPrintLn("Bots hold weapon on mvm_bot_kill : ^1FALSE");
					self.linke = undefined;
				}
			}
			setDvar("mvm_bot_holdgun", "Toggle bots holding their gun when dying");
		}
		wait 0.1;
	}
}

SpawnProps()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_env_prop", "Spawn a prop - ^9[prop]");
	for (;;)
	{
		if(getDvar("mvm_env_prop") != "Spawn a prop - ^9[prop]")
		{
			prop = spawn("script_model", self.origin);
			prop.angles = self.angles;
			prop setModel(getDvar("mvm_env_prop", ""));
			self IPrintLn("^7" + getDvar("mvm_env_prop", "") + " ^3spawned ! ");
			setDvar("mvm_env_prop", "Spawn a prop - ^9[prop]");
		}
		wait 0.1;
	}
}

SpawnEffects()
{
	self endon("disconnect");

	setDvar("mvm_env_fx", "Spawn an effect - ^9[fx]");
	for (;;)
	{
		if(getDvar("mvm_env_fx") != "Spawn an effect - ^9[fx]")
		{
			start = self getTagOrigin("tag_eye");
			end = anglestoforward(self getPlayerAngles()) * 1000000;
			fxpos = BulletTrace(start, end, true, self)["position"];
			level._effect[getDvar("mvm_env_fx")] = loadfx((getDvar("mvm_env_fx")));
			playFX(level._effect[getDvar("mvm_env_fx")], fxpos);
			setDvar("mvm_env_fx", "Spawn an effect - ^9[fx]");
		}
		wait 0.1;
	}
}

TweakFog()
{

}

SetVisions()
{
	self endon("disconnect");
	self endon("death");

	setDvar("mvm_env_colors", "Change vision - ^9[vision]");
	for (;;)
	{
		if(getDvar("mvm_env_colors") != "Change vision - ^9[vision]")
		{
			VisionSetNaked(getDvar("mvm_env_colors", "visname"));
			self IPrintLn("Vision changed to : " + getDvar("mvm_env_colors"));
			setDvar("mvm_env_colors", "Change vision - ^9[vision]");
		}
		wait 0.1;
	}
}

GetCamoInt(tracker)
{
	switch (tracker)
	{
		case "classic":
            return 01;
		case "snow":
            return 02;
		case "multi":
            return 03;
		case "d_urban":
            return 04;
		case "hex":
            return 05;
		case "choco":
            return 06;
		case "snake":
            return 07;
		case "blue":
            return 08;
        case "red":
            return 09;
        case "autumn":
            return 10;
        case "gold":
            return 11;
        case "marine":
            return 12;
        case "winter":
            return 13;
		default:
			return 0;
	}
}

GetCamoName(tracker)
{
	switch (tracker)
	{
		case "classic":
			return 1;
		case "_snow":
			return 2;
		case "_multi":
			return 3;
		case "_d_urban":
			return 4;
		case "_hex":
			return 5;
		case "_choco":
			return 6;
		case "_snake":
			return 7;
		case "_blue":
			return 8;
		case "_red":
			return 9;
		case "_autumn":
			return 10;
		case "_gold":
			return 11;
		case "_marine":
			return 12;
		case "_winter":
			return 13;
		default:
			return "";
	}
}

GetCamoNameFromInt(tracker)
{
	switch (tracker)
	{
        case 1:
            return "_classic";
		case 2:
			return "_snow";
		case 3:
			return "_multi";
		case 4:
			return "_d_urban";
		case 5:
			return "_hex";
		case 6:
			return "_choco";
		case 7:
			return "_snake";
		case 8:
			return "_blue";
		case 9:
			return "_red";
        case 10:
			return "_autumn";
        case 11:
            return "_gold";
        case 12:
            return "_marine";
        case 13:
            return "_winter";
		default:
			return "";
	}
}

SaveSpawn()
{
	self.spawn_origin = self.origin;
	self.spawn_angles = self getPlayerAngles();
}

BotsLevel()
{
	self setPlayerData("prestige", RandomInt(11));
	self setPlayerData("experience", 2400000);
}

PrepareInHandModel()
{
	currentWeapon = self getCurrentWeapon();

	if (isDefined(self.weaptoattach))
		self.weaptoattach delete();

	self.weaptoattach = getWeaponModel(currentWeapon, self.loadoutPrimaryCamo);
	self attach(self.weaptoattach, "tag_weapon_right", true);
	//hideTagList = GetWeaponHideTags(currentWeapon);

	//for (i = 0; i < hideTagList.size; i++)
		//self HidePart(hideTagList[i], self.weaptoattach);

	self.weaptoattach thread maps\mp\gametypes\_weapons::deleteWeaponAfterAWhile();
}