/*
 *    Sass' Cinematic Mod
 *  Ported to IW5 by Forgive
 *  --  [_extras.gsc]   --
 *  Includes Extra Features
 */


#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
    level thread ExtraConnect();
    setDvar("developer_script", "0");
}

ExtraConnect()
{
    level waittill("connected", player);
    player thread ExtraSpawn();
}

ExtraSpawn()
{
    self endon("disconnect");

    for(;;)
    {
        self waittill("spawned_player");

        thread whatsMyWeapon();
        thread setPlayerViewmodel();

        //Useless bs
		thread dirt();
		thread thermal();
		thread watermark();
    }
}

whatsMyWeapon()
{
    self endon("death");
    self endon("disconnect");

    setDvar("whatsMyWeapon", "Prints your current weapon");
    for(;;)
    {
        if(getDvar("whatsMyWeapon") != "Prints your current weapon")
        {
            weapon = self getCurrentWeapon();
            self iPrintLn("Current weapon: ^1" + weapon);
            setDvar("whatsMyWeapon", "Prints your current weapon");
        }
        wait 0.1;
    }
}

setPlayerViewmodel()
{
    self endon("disconnect");

    setDvar("mvm_viewmodel", "Give yourself a viewmodel");
    for(;;)
    {
        if(getDvar("mvm_viewmodel") != "Give yourself a viewmodel")
        {
            newViewmodel = getDvar("mvm_viewmodel", "");
            self setViewmodel(newViewmodel);
            setDvar("mvm_viewmodel", "Give yourself a viewmodel");
        }
        wait 0.1;
    }
}

dirt()
{
	self endon("disconnect");

	setDvar("test_dirt", "Test command");
	for (;;)
	{
		if(getDvar("test_dirt") != "Test command")
        {
            self thread maps\mp\gametypes\_shellshock::dirtEffect(self.origin);
            setDvar("test_dirt", "Test command");
        }
        wait 0.5;
    }
}

thermal()
{
	self endon("disconnect");

	setDvar("test_thermal", "Test command");
	for (;;)
	{
        if(getDvar("test_thermal") != "Test command")
        {
		    if (!isDefined(self.thermalOn) || self.thermalOn == 0) {
		    	self visionSetThermalForPlayer( "thermal_mp", 1 );
		    	self ThermalVisionOn();
		    	self.thermalOn = 1;
		    }
		    else if (self.thermalOn == 1) {
		    	self visionSetThermalForPlayer( "missilecam", 1 );
		    	self.thermalOn = 2;
		    }
		    else if (self.thermalOn == 2) {
		    	self ThermalVisionOff();
		    	self.thermalOn = 0;
		    }
            setDvar("test_thermal", "Test command");
        }
        wait 0.5;
	}
}

watermark()
{
	self endon("disconnect");
	setDvar("test_watermark", "Test command");
    for(;;)
    {
	    if(getDvar("test_watermark") != "Test command")
        {
	        watermark = newClientHudElem(self);
	        watermark.horzAlign ="left";
	        watermark.vertAlign ="top";
	        watermark.x = 10;
	        watermark.y = 110;
	        watermark.font = "Objective";
	        watermark.fontscale = 0.84;
	        watermark.alpha = 0.8;
	        watermark.hideWhenInMenu = true;
	        watermark setText("^3Sass' Cinematic Mod \n^7Ported to MW3 by ^3Forgive");
            setDvar("test_watermark", "Test command");
        }
        wait 0.5;
    }
}