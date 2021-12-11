// ====================================================================
//  Class:  BDBMapVote3Ex.DynIPInfo
//  Parent: Engine.ReplicationInfo
//
//  <Enter a description here>
// ====================================================================

class DynIPInfo extends ReplicationInfo	config;

var config string Until;

replication {	
	// Things the server should send to the client
	reliable if( Role == Role_Authority )
		CheckBan,
		SetBan;		
}

simulated function CheckBan(int Month, int Day, int Hour) {
  local int u_Month;
  local int u_Day;
  local int u_Hour;

  log("MV: DIPI.CheckBan");
  
  // Execute only on the client
  if( Role == ROLE_Authority ) 
  	return;
	
  // Until not set or Owner == none, so return
  if( Until=="" || Owner==none ) return;
  
  log("MV: DIPI.CheckBan: Extract Info");
	
  // Extract info
  u_Month = int(Left(Until,2));
  u_Day   = int(Mid(Until,3,2));
  u_Hour  = int(Right(Until,2));  

  log("MV: DIPI.CheckBan: Check unban, Until="$Until);
  
  // Unban?
  if(( Month >  u_Month ) ||
    (( Month == u_Month ) && ( Day >  u_Day )) ||
    (( Month == u_Month ) && ( Day == u_Day ) && ( Hour > u_Hour ))) {
	
    log("MV: DIPI.CheckBan: Unban");

	class'BDBMapVote3Ex.DynIPInfo'.default.Until = "";
	class'BDBMapVote3Ex.DynIPInfo'.static.StaticSaveConfig();	
	return;	// Player's ban has expired, allow him to play
  }	
  
  log("MV: DIPI.CheckBan: Still banned, destroy playerpawn");

  // Don't unban, destroy the PlayerPawn
  Owner.Destroy();
  Destroy(); // Destroy myself
  
  log("MV: DIPI.CheckBan: END");
}

simulated function SetBan(int Month, int Day, int Hour) {
  log("MV: DIPI.SetBan");

  // Execute only on the client
  if( Role == ROLE_Authority ) 
  	return;

  log("MV: Setting Until to"@Month@Day@Hour);
  class'BDBMapVote3Ex.DynIPInfo'.default.Until = Month@Day@Hour;
  class'BDBMapVote3Ex.DynIPInfo'.static.StaticSaveConfig();	
  
  log("MV: DIPI.SetBan: END");
}

defaultproperties
{
}
