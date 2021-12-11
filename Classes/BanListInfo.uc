// ====================================================================
//  Class:  BDBMapVote3Ex.BanList
//  Parent: Core.Object
//
//  <Enter a description here>
// ====================================================================

// This one is an 'interface' for a BanList (like Nickserv.BanList)		

class BanListInfo extends Info;

var config struct BanRecord {
	var bool   Used;
	var string IP;
	var string Nick;
	var string UnbanAt;
	var bool   Permban;
	var string Admin;
} Bans[50];

replication 
{
  // Don't replicate anything to the client
  // config vars (like the banlist) won't replicate anyway :(
    
  // Replicate the function calls to the server
  reliable if( Role < ROLE_Authority )
    blKickPlayer,
    blBanPlayer,
    blUnBanIndex,
    blSetBan,
    blGetBan,
	bIsAdmin;
}

function blKickPlayer(int PlayerID, string AdminName)
{
}

function blBanPlayer(int PlayerID, string AdminName, int Hours) 
{
}

function blUnBanIndex(int Index, string AdminName)
{
}

function blSetBan(int i, string IP, string Nick, string UnbanAt, bool Permban, string Admin) 
{
}

function BanRecord blGetBan(int i) 
{
}

function bool bIsAdmin(String IP)
{
}
		

defaultproperties
{
}
