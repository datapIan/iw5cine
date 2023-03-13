# *IW5Cine*
<img src="" alt="screenshot" height="250px" align="right"/>

**A Port of [Sass' Cinematic Mod](https://github.com/sortileges/iw4cine) to Modern Warfare 3**

<p align="left">
  <a href="#about">About</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#issues">Issues</a> •
  <a href="#credits">Credits</a>
</p>

<div align="left">
<a href="https://github.com/datapIan/iw5cine/releases"><img src="https://img.shields.io/github/v/release/datapIan/iw5cine?label=Latest%20Release&style=flat-square"></a>
  <a href="https://github.com/datapIan/iw5cine/releases""><img src="https://img.shields.io/github/downloads/datapIan/iw5cine/total?style=flat-square"></a>

## About

 - Sass' mod changed the editing game, and it's what we've all used for cinematics for as long as we can remember. I believed the same level of personalization should be in every other game. So I did it.

 - 99% of the code was written by Sass, I take no credit for the work he has done, I just changed a few things to make it work on MW3.

## Installation

There's two types of installations for this mod. One for the *Plutonium* client, and one for the *Steam* client.

#### [Plutonium IW5](https://plutonium.pw) (Recommended)

* Download the mod from [here](), extract and drag the "iw5cine" folder into your mods folder.
```text
C:/
└── %localappdata%/
    └── plutonium
        └── storage
            └── iw5
                └── mods
                    └── iw5cine
```


#### MW3 Steam

* Download the mod from [here](), extract and drag the "iw5cine" folder into your mods folder.
```text
C:/
└── .../
    └── MW3/
        └── mods/
            └── iw5cine
```

## Usage

* Most commands in-game function the same way as they did in MW2, except for the toggling type commands: `about, actorback, clone, clearbodies, mvm_eb_close, mvm_eb_magic, mvm_bot_holdgun, etc...`

  └── These commands are required to be typed as `command` followed by a 1. Example: `clearbodies 1`
* BotSpawn command arguments are `class = ar, smg, lmg, shotgun, sniper`, `team = allies, axis`
* BotModel command arguments are `CLASS = ASSAULT, SMG, LMG, SHOTGUN, SNIPER, GHILLIE, RIOT, JUGGERNAUT`, `team = allies, axis`
* BotWeapon command arugments are `weapon = weapon name (iw5_msr_mp_msrscope)`, `camo = classic, snow, multi, d_urban, hex, choco, snake, blue, red, autumn, gold, marine, winter`
* BotKill command arguments are `mode = head, body, shotgun, cash` // Currently not working
* EnvColors command arguments are the name of any zone, example: `mvm_env_colors mp_hardhat`
* EnvProp command arguments are models in the current map, common_mp, or a custom fastfile. If from a custom fastfile or another map, it must be precached!

  └── A list of common_mp xmodels can be found [here](https://pastebin.com/ssKspwD4)
* EnvFx command arguments are fx in the current map, common_mp, or a custom fastile. If from a custom fastfile or another map, it must be precached!
  
  └── Additionally, the arguments must be typed as `folder/filename`, example: `dust/bouncing_betty_swirl`
       └── A list of common_mp fx's can be found [here](https://pastebin.com/zeHWZNSC).

## Issues
* ***BotKill*** - Currently the command doesn't kill bots.
* ***Expect bugs all around, this mod will be further developed.***

### To report bugs or feature requests, please do so through [this](https://github.com/datapIan/iw5cine/issues) link.

## Credits

* [Antiga](https://github.com/mprust) - Helped with .gsc related questions.
* [Expert](https://github.com/soexperttt) - Told me I should start coding, althought I didn't technically code anything for this.
* [ReeaL](https://github.com/reaalx) - Helped with .menu related questions.
* [Sass](https://github.com/sortileges) - Wrote the original MW2 Cinematic Mod.
* [yoyo1love](https://github.com/yoyothebest) - Helped with .gsc and .menu related questions.
