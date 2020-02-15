

if(!("vsScriptLoaded" in g_MapScript))
{
	g_MapScript.vsScriptLoaded <- true;
	Msg("Plan B versus script initialized.\n");

	IncludeScript("vscript_hint_recreate", g_MapScript);

	//Actually enable the callbacks outside Scripted mode.
	__CollectGameEventCallbacks(g_MapScript);
}
