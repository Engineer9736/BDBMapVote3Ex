class MapVoteWRI expands WRI;

var BDBMapVote4 MapVoteMutator;
var string MapList1[257];
var string MapList2[257];
var string MapList3[257];
var string MapList4[257];
var int MapCount;
var string MapVoteResults[100];
var int InstaNumVotes;
var int NWNumVotes;
var struct BanRecord {
	var string IP;
	var string Nick;
} BannedList[50];

//var bool bDM;          *
//var bool bLMS;         |*
//var bool bTDM;         ||*
//var bool bAS;          |||*
//var bool bDOM;         ||||*
//var bool bCTF;         |||||*
//var bool bOther;       ||||||*
var string GameTypes;  //0000000
var string OtherClass;
var int VoteTimeLimit;
var bool bUseMapList;
var bool bAutoOpen;
var int  ScoreBoardDelay;
var bool bAutoDetect;
var bool bCheckOtherGameTie;
var string Mode;
var int RepeatLimit;
var string MapVoteHistoryType;
var int MidGameVotePercent;
var int MinMapCount;
var string MapPreFixOverRide;
var string ExtraMutators;
var bool bIsAdmin;
var string CurrentMapName;

var int OtherGamemodesbEnabled[10];
var string OtherGamemodesMapPrefix[10];
var string OtherGamemodesPackageGameClass[10];

replication
{
   // Variables the server should send to the client.
   reliable if( Role==ROLE_Authority )
      MapList1,MapList2,MapList3,MapList4,
      MapCount,
      MapVoteResults,
      InstaNumVotes,
      NWNumVotes,
      BannedList,
      UpdateMapVoteResults,
      UpdateModeVoteResults,    
      GameTypes,
      OtherClass,
      VoteTimeLimit,
      bUseMapList,
      bAutoOpen,
      ScoreBoardDelay,
      bAutoDetect,
      bCheckOtherGameTie,
      Mode,
      RepeatLimit,
      MidGameVotePercent,
      MinMapCount,
      MapPreFixOverRide,
      ExtraMutators,
	  bIsAdmin,
	  OtherGamemodesbEnabled,
	  OtherGamemodesMapPrefix,
	  OtherGamemodesPackageGameClass,
	  CurrentMapName;
}

simulated function bool SetupWindow ()
{	
   // Increase the length of time messages stay on screen
   class'SayMessagePlus'.default.Lifetime     = class'BDBMapVote4.BDBMapVote4'.default.MsgTimeOut;
   class'CriticalStringPlus'.default.Lifetime = class'BDBMapVote4.BDBMapVote4'.default.MsgTimeOut;
   class'RedSayMessagePlus'.default.Lifetime  = class'BDBMapVote4.BDBMapVote4'.default.MsgTimeOut;
   class'TeamSayMessagePlus'.default.Lifetime = class'BDBMapVote4.BDBMapVote4'.default.MsgTimeOut;
   class'StringMessagePlus'.default.Lifetime  = class'BDBMapVote4.BDBMapVote4'.default.MsgTimeOut;
   class'DeathMessagePlus'.default.Lifetime  = class'BDBMapVote4.BDBMapVote4'.default.MsgTimeOut;   
   
   //log("WRI SetupWindow");
   if ( Super.SetupWindow() )
   {
      settimer(1,false);
   }
   else
      log("Super.SetupWindow() = false");
	  
	// Give a handle to this WRI from the Mapvote window, so that it can give the instruction to reload the maplist with a filter on it.
	MapVoteTabWindow(TheWindow).MapWindow.WRI = self;

	return true;
}

simulated function loadMapList() {
	local int i;
	
	// Clear the maplist.
	MapVoteTabWindow(TheWindow).ClearMapList();
	
	// fill Map List-Box with map names
	//  Map Number  List
	//  ----------- ----------
	//  1   - 255   MapList1
	//  256 - 510   MapList2
	//  511 - 765   MapList3
	//  766 - 1020  MapList4
	
	for(i=1; i<=MapCount; i++)
      {
         if(i < 256)
           MapVoteTabWindow(TheWindow).AddMapName(MapList1[i]);
         if(i >= 256 && i < 511)
           MapVoteTabWindow(TheWindow).AddMapName(MapList2[i - 255]);
         if(i >= 511 && i < 766)
           MapVoteTabWindow(TheWindow).AddMapName(MapList3[i - 510]);
         if(i >= 766)
           MapVoteTabWindow(TheWindow).AddMapName(MapList4[i - 765]);
      }
}

simulated function timer()
{
   local int i, MyCount;

   //count maps that have replicated
   MyCount = 0;
   i = 1;
   While(MapList1[i] != "" && i < 256)
   {
     MyCount++;
     i++;
   }
   i = 1;
   While(MapList2[i] != "" && i < 256)
   {
     MyCount++;
     i++;
   }
   i = 1;
   While(MapList3[i] != "" && i < 256)
   {
     MyCount++;
     i++;
   }
   i = 1;
   While(MapList4[i] != "" && i < 256)
   {
     MyCount++;
     i++;
   }

   if(MyCount < MapCount)
   {
      //log("settimer");
      settimer(0.1,false);
      return;
   }

   log("Total Maps Received = "$ MyCount);

   if(MapCount > 0)
   {	  
		MapVoteTabWindow(TheWindow).CurrentMapName = CurrentMapName;
		// Test if any of the default 6 gamemodes (inc other) is checked, if so, add it.
		if (Mid(GameTypes,3,1) == "1") MapVoteTabWindow(TheWindow).AddGamemode("AS");
		if (Mid(GameTypes,5,1) == "1") MapVoteTabWindow(TheWindow).AddGamemode("CTF");
		if (Mid(GameTypes,0,1) == "1") MapVoteTabWindow(TheWindow).AddGamemode("DM");
		if (Mid(GameTypes,4,1) == "1") MapVoteTabWindow(TheWindow).AddGamemode("DOM");
		if (Mid(GameTypes,1,1) == "1") MapVoteTabWindow(TheWindow).AddGamemode("LMS");
		if (Mid(GameTypes,2,1) == "1") MapVoteTabWindow(TheWindow).AddGamemode("TDM");
		if (Mid(GameTypes,6,1) == "1") MapVoteTabWindow(TheWindow).AddGamemode(MapPreFixOverRide);
		
		LoadMapList();
		
		// Loop through the 10 Othergamemodes, and if enabled, add the prefix to the Gamemodes list.
		for (i=0;i<10;i++) {
			if (OtherGamemodesbEnabled[i] == 1) {
				MapVoteTabWindow(TheWindow).AddGamemode(OtherGamemodesMapPrefix[i]);
			}
		}
		
      MapVoteTabWindow(TheWindow).UpdateAdmin(GameTypes,
                                              OtherClass,
                                              VoteTimeLimit,                                              
                                              ScoreBoardDelay,
                                              bUseMapList,
                                              bAutoOpen,
                                              bAutoDetect,
                                              bCheckOtherGameTie,
                                              RepeatLimit,
                                              MapVoteHistoryType,
                                              MidGameVotePercent,
                                              Mode,
                                              MinMapCount,
                                              MapPreFixOverRide,
                                              ExtraMutators);

      i=0;
      while(MapVoteResults[i] != "" && i<99)
      {
         //MapVoteTabWindow(TheWindow).MapVoteResults[i] = MapVoteResults[i];
         UpdateMapVoteResults(MapVoteResults[i],i);
         i++;
      }
      // Gerco: update modevote results
      UpdateModeVoteResults(InstaNumVotes,NWNumVotes);     
      
      // Gerco: update bannedlist
      if(bIsAdmin) {
		 MapVoteTabWindow(TheWindow).MapWindow.SetAdmin(bIsAdmin);
		 
         MapVoteTabWindow(TheWindow).MapWindow.cmbBanned.Clear();
	     for(i=0; i<50; i++) {
	        if( BannedList[i].IP != "" )
	           MapVoteTabWindow(TheWindow).MapWindow.cmbBanned.AddItem(BannedList[i].Nick @ "(" $ BannedList[i].IP $ ")",""$i);
	     }		 
      }

	for(i=0;i<10;i++) {
		MapVoteTabWindow(TheWindow).UpdateAdminOtherGamemode(i, OtherGamemodesbEnabled[i]==1, OtherGamemodesMapPrefix[i], OtherGamemodesPackageGameClass[i]);
	}
      MapVoteTabWindow(TheWindow).MapWindow.lblMapCount.SetText(MapCount $ " Maps");
      //MapVoteTabWindow(TheWindow).MapWindow.lblMode.SetText("Mode: " $ Mode);
   }
}

function GetServerConfig() // executes on server
{
   if(class'BDBMapVote4.BDBMapVote4'.default.bDM)
      GameTypes = "1";
   else
      GameTypes = "0";
   if(class'BDBMapVote4.BDBMapVote4'.default.bLMS)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   if(class'BDBMapVote4.BDBMapVote4'.default.bTDM)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   if(class'BDBMapVote4.BDBMapVote4'.default.bAS)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   if(class'BDBMapVote4.BDBMapVote4'.default.bDOM)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   if(class'BDBMapVote4.BDBMapVote4'.default.bCTF)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   if(class'BDBMapVote4.BDBMapVote4'.default.bOther)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   OtherClass = class'BDBMapVote4.BDBMapVote4'.default.OtherClass;
   VoteTimeLimit = class'BDBMapVote4.BDBMapVote4'.default.VoteTimeLimit;
   bUseMapList = class'BDBMapVote4.BDBMapVote4'.default.bUseMapList;
   bAutoOpen = class'BDBMapVote4.BDBMapVote4'.default.bAutoOpen;
   ScoreBoardDelay = class'BDBMapVote4.BDBMapVote4'.default.ScoreBoardDelay;
   bAutoDetect = class'BDBMapVote4.BDBMapVote4'.default.bAutoDetect;
   bCheckOtherGameTie = class'BDBMapVote4.BDBMapVote4'.default.bCheckOtherGameTie;
   Mode = class'BDBMapVote4.BDBMapVote4'.default.Mode;
   RepeatLimit = class'BDBMapVote4.BDBMapVote4'.default.RepeatLimit;
   MidGameVotePercent = class'BDBMapVote4.BDBMapVote4'.default.MidGameVotePercent;
   MinMapCount = class'BDBMapVote4.BDBMapVote4'.default.MinMapCount;
   MapPreFixOverRide = class'BDBMapVote4.BDBMapVote4'.default.MapPreFixOverRide;
   ExtraMutators = class'BDBMapVote4.BDBMapVote4'.default.ExtraMutators;
}
//-------------------------------------------------------------------
simulated function UpdateMapVoteResults(string Text,int i)
{
   MapVoteTabWindow(TheWindow).UpdateMapVoteResults(Text, i);
}
//-------------------------------------------------------------------
// Gerco: passthru functie voor updaten van modevoteresults
simulated function UpdateModeVoteResults(int insta, int nw)
{
   InstanumVotes = insta;
   NWNumVotes = nw;
   MapVoteTabWindow(TheWindow).UpdateModeVoteResults(insta, nw);
}
//-------------------------------------------------------------------
function SetBan(int i, string IP, string Nick) {
   BannedList[i].IP   = IP;
   BannedList[i].Nick = Nick;
}
//-------------------------------------------------------------------

defaultproperties
{
     WindowClass=Class'BDBMapVote4.MapVoteTabWindow'
     WinLeft=50
     WinTop=30
     WinWidth=410
     WinHeight=330
}
