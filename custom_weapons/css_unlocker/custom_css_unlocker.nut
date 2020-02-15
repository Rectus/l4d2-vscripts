/* 
 * NetProp based CS:S weapon unlocker. 
 * 
 *
 * Copyright (c) 2017 Rectus
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */


// Store the model index for each weapon, so we can change the weapon_spawn model.
modelIndices <- {}

function PrecacheWeapons()
{
	local weapons = ["weapon_rifle_sg552", "weapon_smg_mp5", "weapon_sniper_awp", "weapon_sniper_scout"]
	local keyvalues = {origin = Vector(-100000, -100000, -100000)}

	foreach(weapon in weapons)
	{
		keyvalues.classname <- weapon
		PrecacheEntityFromTable(keyvalues)
		local entity = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
		modelIndices[weapon] <- NetProps.GetPropInt(entity, "m_nModelIndex")
		entity.Kill()
	}
	printl("CS:S Weapons Precached")
}



 /* 
Netprop m_weaponID weapon mappings
1 = pistol
2 = smg
3 = shotgun
4 = autoshotgun
5 = rifle
6 = hunting_rifle
7 = smg_silenced
8 = shotgun_chrome
9 = rifle_desert
10 = sniper_military
11 = shotgun_spas
12 = medkit
13 = molotov
14 = pipebomb
15 = pain_pills
16 = gascan
17 = propane_tank
18 = oxygen
19
20 = chainsaw
21 = grenadelauncher
22
23 = adrenaline
24 = defib
25 = boomer_bile
26 = rifle_ak47
27 = gnome
28 = cola
29 = fireworks
30 = incendiary
31 = explosive
32 = pistol_magnum
33 = smg_mp5
34 = rifle_ssg552
35 = sniper_awp
36 = sniper_scout
37 = rifle_m60
*/


function Replace()
{
	local weaponReplacements = 
	[
		{
			spawnSet = ["weapon_rifle", "weapon_rifle_ak47", "weapon_rifle_desert"], 
			replacementSet = ["weapon_rifle_sg552"]
		},
		{
			spawnSet = ["weapon_smg", "weapon_smg_silenced"], 
			replacementSet = ["weapon_smg_mp5"]
		},
		{
			spawnSet = ["weapon_sniper_military", "weapon_hunting_rifle"], 
			replacementSet = ["weapon_sniper_awp", "weapon_sniper_scout"]
		}
	]
	
	local idTable =
	{
		weapon_smg = 2
		weapon_smg_silenced = 7
		weapon_smg_mp5 = 33
		weapon_rifle = 5
		weapon_rifle_ak47 = 26
		weapon_rifle_desert = 9
		weapon_rifle_sg552 = 34
		weapon_sniper_military = 10
		weapon_hunting_rifle = 6
		weapon_sniper_awp = 35
		weapon_sniper_scout = 36
	}
	
	local entity = null
	while(entity = Entities.FindByClassname(entity, "weapon_spawn"))
	{
		local origID = NetProps.GetPropInt(entity, "m_weaponID")
		foreach(name, id in idTable)
		{
			if(id == origID)
			{
				foreach(category in weaponReplacements)
				{
					local spawnSet = category.spawnSet
					local replacementSet = category.replacementSet
					
					if(spawnSet.find(name) != null)
					{
						local maxIdx = spawnSet.len() + replacementSet.len() - 1
						local random = RandomInt(0, maxIdx)
						if(random < replacementSet.len())
						{
							NetProps.SetPropInt(entity, "m_weaponID", idTable[replacementSet[random]])
							NetProps.SetPropInt(entity, "m_nModelIndex", modelIndices[replacementSet[random]])
							
						}
						break
					}
				}
			}
		}
	}
	printl("CS:S Weapons Replaced")
}
