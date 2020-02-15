// Adds map-specific response rules.

printl("Plan B map 1 response rule script initializing.");


IncludeScript("response_testbed_fixed", this);

deafaultParams <- RGroupParams({permitrepeats = true, sequential = false, norepeat = false})

PlanB1Rules <-
[
	
	
	{
		name = "PlanB1AfterStormBlank",
		criteria = 
		[
			[ "concept", "PlanB1AfterStorm" ],
			//[ "Who", "Any" ],
		],
		responses = 
		[
			// List of multiple possible responses.
			{ 
				scenename = "scenes/namvet/blank.vcd"//"scenes/NamVet/blank.vcd",
				followup = RThen("NamVet", "PlanB1AfterStormNamVet", null, 0)
				//func = @(_,__) printl("PlanB1AfterStorm 1")
			}
			{ 
				scenename = "scenes/namvet/blank.vcd"
				followup = RThen("Manager", "PlanB1AfterStormManager", null, 0)
				//func = @(_,__) printl("PlanB1AfterStorm 2")
			}
			{ 
				scenename = "scenes/namvet/blank.vcd"
				followup = RThen("Biker", "PlanB1AfterStormBiker", null, 0)
				//func = @(_,__) printl("PlanB1AfterStorm 3")
			}
		],
		group_params =  RGroupParams({permitrepeats = true, sequential = false, norepeat = true})
	},
	
	{
		name = "PlanB1AfterStormNamVet1",
		criteria = 
		[
			[ "concept", "PlanB1AfterStormNamVet" ],
			[ "Coughing", 0 ],
			[ "Who", "NamVet" ],
		],
		responses = 
		[
			{ 
				scenename = "scenes/namvet/c6dlc3communitylines03.vcd",
				followup = RThen("Manager", "PlanB1AfterStormNamvet1Spoken", null, 0.5)
			}
			{
				scenename = "scenes/namvet/c6dlc3communitylines05.vcd",	
			}
		],
		group_params = deafaultParams
	},
		
	{
		name = "PlanB1AfterStormManager1",
		criteria = 
		[
			[ "concept", "PlanB1AfterStormManager" ],
			[ "Coughing", 0 ],
			[ "Who", "Manager" ],
		],
		responses = 
		[
			{ 
				scenename = "scenes/manager/dlc1_communityl4d101.vcd",
				followup = RThen("TeenGirl", "PlanB1AfterStormManager1Spoken", null, 0.5)

			}
		],
		group_params = deafaultParams
	},
	
		{
		name = "PlanB1AfterStormBiker1",
		criteria = 
		[
			[ "concept", "PlanB1AfterStormBiker" ],
			[ "Coughing", 0 ],
			[ "Who", "Biker" ],
		],
		responses = 
		[
			{ 
				scenename = "scenes/biker/dlc1_communityl4d104.vcd",
				followup = RThen("NamVet", "PlanB1AfterStormBiker1Spoken", null, 0.5)
			}
		],
		group_params = deafaultParams
	},
	
	{
		name = "PlanB1AfterStormManagerResp1",
		criteria = 
		[
			[ "concept", "PlanB1AfterStormNamvet1Spoken" ],
			[ "Coughing", 0 ],
			[ "Who", "Manager" ],

		],
		responses = 
		[
			{ 
				scenename = "scenes/manager/dlc1_communityl4d102.vcd",
				//scenename = "scenes/manager/dlc1_communityl4d103.vcd",
				//followup = RThen("Manager", "PlanB1AfterStormManagerResp1Spoken", null, 0.5) 
			}
		],
		group_params = deafaultParams
	},
	
	{
		name = "PlanB1AfterStormNamVetResp1",
		criteria = 
		[
			[ "concept", "PlanB1AfterStormBiker1Spoken" ],
			[ "Coughing", 0 ],
			[ "Who", "NamVet" ],

		],
		responses = 
		[
			{ 
				scenename = "scenes/namvet/c6dlc3communitylines04.vcd",
			}
		],
		group_params = deafaultParams
	},
	
	{
		name = "PlanB1AfterStormTeenGirlResp1",
		criteria = 
		[
			[ "concept", "PlanB1AfterStormManager1Spoken" ],
			[ "Coughing", 0 ],
			[ "Who", "TeenGirl" ],

		],
		responses = 
		[
			{ 
				scenename = "scenes/teengirl/dlc1_communityl4d103.vcd",
				followup = RThen("NamVet", "PlanB1AfterStormTeenGirlResp1Spoken", null, 0.5)
			}
		],
		group_params = deafaultParams
	},
	
	{
		name = "PlanB1AfterStormNamVetResp2",
		criteria = 
		[
			[ "concept", "PlanB1AfterStormTeenGirlResp1Spoken" ],
			[ "Coughing", 0 ],
			[ "Who", "NamVet" ],

		],
		responses = 
		[
			{ 
				scenename = "scenes/namvet/c6dlc3communitylines02.vcd",
			}
		],
		group_params = deafaultParams
	},
	
]



rr_ProcessRules(PlanB1Rules);

