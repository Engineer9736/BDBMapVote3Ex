class MapVoteWRI expands WRI;

var BDBMapVote3Ex MapVoteMutator;
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
	  OtherGamemodesPackageGameClass;
}

simulated function bool SetupWindow ()
{
   local int i;

   // Increase the length of time messages stay on screen
   class'SayMessagePlus'.default.Lifetime     = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;
   class'CriticalStringPlus'.default.Lifetime = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;
   class'RedSayMessagePlus'.default.Lifetime  = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;
   class'TeamSayMessagePlus'.default.Lifetime = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;
   class'StringMessagePlus'.default.Lifetime  = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;
   class'DeathMessagePlus'.default.Lifetime  = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;   
   
   //log("WRI SetupWindow");
   if ( Super.SetupWindow() )
   {
      settimer(1,false);
   }
   else
      log("Super.SetupWindow() = false");
}

simulated function timer()
{
   local int i,MyCount,MyPlayerCount;

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
      settimer(1,false);
      return;
   }

   log("Total Maps Received = "$ MyCount);

   if(MapCount > 0)
   {
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
      MapVoteTabWindow(TheWindow).MapWindow.lblMode.SetText("Mode: " $ Mode);
   }
}

function GetServerConfig() // executes on server
{
   if(class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bDM)
      GameTypes = "1";
   else
      GameTypes = "0";
   if(class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bLMS)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   if(class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bTDM)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   if(class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bAS)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   if(class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bDOM)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   if(class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bCTF)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   if(class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bOther)
      GameTypes = GameTypes $ "1";
   else
      GameTypes = GameTypes $ "0";
   OtherClass = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.OtherClass;
   VoteTimeLimit = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.VoteTimeLimit;
   bUseMapList = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bUseMapList;
   bAutoOpen = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bAutoOpen;
   ScoreBoardDelay = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.ScoreBoardDelay;
   bAutoDetect = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bAutoDetect;
   bCheckOtherGameTie = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bCheckOtherGameTie;
   Mode = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.Mode;
   RepeatLimit = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.RepeatLimit;
   MidGameVotePercent = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MidGameVotePercent;
   MinMapCount = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MinMapCount;
   MapPreFixOverRide = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MapPreFixOverRide;
   ExtraMutators = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.ExtraMutators;
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
     WindowClass=Class'BDBMapVote3Ex.MapVoteTabWindow'
     WinLeft=50
     WinTop=30
     WinWidth=410
     WinHeight=330
}
