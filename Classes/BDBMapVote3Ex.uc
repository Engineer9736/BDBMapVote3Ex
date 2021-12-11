//-----------------------------------------------------------
// MapVote Mutator
// By BDB (Bruce Bickar)
// BDB@PlanetUnreal.com
// or BBickar@carolina.rr.com
//-----------------------------------------------------------
class BDBMapVote3Ex expands Mutator config;

var bool   bInitialized;
var string MapList[1024];       // list of all the maps available on the server
var int    PlayerIDList[32];    // list of player IDs, used for looking up the players index number   
var int    PlayerVote[32];      // index of the map that the player has voted for
var int    MapCount;            // total number of maps on server
var string MapStatusText[100];
var float  EndGameTime;
var bool   bMidGameVote;
var int    CurrentID;
var string CurGameMode;

// Gerco: of de speler insta(1), nw(2) of niets(-1) gevote heeft
var int PlayerModeVote[32];
var int InstaNumVotes,NWNumVotes;

// Engineer: Other gamemode config
var config int OtherGamemodesbEnabled[10];
var config string OtherGamemodesMapPrefix[10];
var config string OtherGamemodesPackageGameClass[10];

var config bool bAutoDetect;
var config bool bDM;
var config bool bLMS;
var config bool bTDM;
var config bool bDOM;
var config bool bCTF;
var config bool bAS;
var config bool bOther;
var config int MsgTimeOut;
var config string OtherClass;
var config int VoteTimeLimit;
var config bool bUseMapList;
var config int ScoreBoardDelay;
var config bool bAutoOpen;
var config bool bTOTieGameFix;
var config bool bCheckOtherGameTie;
var config int RepeatLimit;
var config bool bLoadScreenShot;
var config string ServerInfoURL;    //www.planetunreal.com:80/BDBUnreal/ServerInfo.htm
var config string MapInfoURL;       //www.planetunreal.com:80/BDBUnreal/MapInfo/
var config int MidGameVotePercent;
var config string Mode;
var config int MinMapCount;
var config string MapPreFixOverRide;
var config string AccName[32];   // use for Accumulation mode
var config int    AccVotes[32];    // use for Accumulation mode
var config string HasStartWindow;  // Yes,No,Auto - Does the game have a start menu
var config bool bEntryWindows;     // false = Dont open Welcome window or Keybinder when player enters
var config string ExtraMutators;   // Extra mutators to add to ServerTravelString
var config bool   bShowVoterNames; // Wether to show who voted for what
var config bool   bAllowEarlySwitch; // Allow early mapswitch when more than 50% of the players voted

var int TimeLeft,ScoreBoardTime,ServerTravelTime;
var class<GameInfo> OtherGameClass;

var config string DMGameType;
var config string LMSGameType;
var config string TDMGameType;
var config string DOMGameType;
var config string CTFGameType;
var config string ASGameType;
var class<GameInfo> DMGameClass;
var class<GameInfo> LMSGameClass;
var class<GameInfo> TDMGameClass;
var class<GameInfo> DOMGameClass;
var class<GameInfo> CTFGameClass;
var class<GameInfo> ASGameClass;

var bool bLevelSwitchPending;
var string ServerTravelString;

//************************************************************************************************
//function EndGameHandler()
function bool HandleEndGame()
{
   local Pawn aPawn;
   local bool bReturn;

   bReturn = false;

   if(!bAutoOpen || CheckForTie()) // Don't open voting windows for tied game or if disabled
   {
      if(bOther &&
         OtherGameClass != None &&
         OtherClass ~= "s_SWAT.s_SWATGame" &&
         bTOTieGameFix  &&
         Level.Game.MapPrefix ~= OtherGameClass.default.MapPreFix)
      {
         // Fixes the Tactical Ops tie game problem where it restarts without ending the game properly
         // Note: If this problem is fixed in the next release of TO then you can disable this fix
         //       by setting bTOTieGameFix=False in the UnrealTournament.ini file
         TOFixSetEndCams("Tie Game");
         bReturn = true;
      }
      else
         return false;
   }

   // Do not mess with Assult games in mid game
   if(Level.Game.IsA('Assault'))
   {
      //log("Playing Assault, Check bDefense");
      if( !Assault(Level.Game).bDefenseSet )
      {
         //log("bDefenseSet == False, Ending game normally.(First half end)");
         return false;
      }
      else
      {
         //log("bDefense == True, calling ResetGame.(Second half end)");
         Assault(Level.Game).ResetGame();  // resets assault ini settings so next game starts on first half of game instead of second
      }
   }

   // Setting bDontRestart will give players time to vote
   DeathMatchPlus(Level.Game).bDontRestart = true;

   // Start voting count-down timer
   TimeLeft = VoteTimeLimit;
   ScoreBoardTime = ScoreBoardDelay;
   settimer(1,true);

   return bReturn;
}
//************************************************************************************************
event timer()
{
   local pawn aPawn;
   local int VoterNum,NoVoteCount;
   local MapVoteWRI A;
   local Pawn P;

   if(bLevelSwitchPending)
   {
      if(Level.TimeSeconds > ServerTravelTime + 3) // Give a little extra time for windows to close
         Level.ServerTravel(ServerTravelString, false);    // change the map
      return;
   }

   if(ScoreBoardTime > 0)
   {
      ScoreBoardTime--;
      if(ScoreBoardTime == 0)
      {
         EndGameTime = Level.TimeSeconds;

         // force all players voting window open
         for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
         {
            if(PlayerPawn(aPawn) != none && aPawn.bIsPlayer)
            {
               VoterNum = FindPlayerIndex(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID);
               if(PlayerVote[VoterNum] == 0) // if this player has not voted
                  OpenVoteWindow(PlayerPawn(aPawn));
            }
         }

         BroadcastMessage(String(TimeLeft) $" seconds left to vote.", true);
      }
      return;
   }
   TimeLeft--;

   //log(TimeLeft);
   if(TimeLeft == 60)  // play announcer voice for 1 minute warning
   {
      BroadcastMessage("1 Minute left to vote.", true);
      for( P = Level.PawnList; P!=None; P=P.nextPawn )
         if( P.IsA('TournamentPlayer') )
           TournamentPlayer(P).TimeMessage(12);
   }

   if(TimeLeft == 10)
      BroadcastMessage("10 seconds left to vote.", true);

   if(TimeLeft < 11 && TimeLeft > 0 )  // play announcer voice Count Down
   {
      for( P = Level.PawnList; P!=None; P=P.nextPawn )
         if( P.IsA('TournamentPlayer') )
            TournamentPlayer(P).TimeMessage(TimeLeft);
   }

   CleanUpPlayerIDs();

   if(TimeLeft % 20 == 0 && TimeLeft > 0)
   {
      NoVoteCount = 0;
      // force all players voting windows open if they have not voted
      for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
      {
         if(aPawn.bIsPlayer && PlayerPawn(aPawn) != none)
         {
            VoterNum = FindPlayerIndex(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID);
            if(PlayerVote[VoterNum] == 0) // if this player has not voted
            {
               NoVoteCount++;
               //OpenVoteWindow(PlayerPawn(aPawn));
            }
         }
      }
      if(NoVoteCount == 0) // this should fix a problem cause by players leaving the game
         TallyVotes(true && bAllowEarlySwitch); // all players have voted, so force a map change
   }

   if(TimeLeft == 0)  // force level switch if time limit is up
   {
     TallyVotes(true);   // if no-one has voted a random map will be choosen
   }
}
//************************************************************************************************
function tick(float DeltaTime)
{
   local string PlayerName,PID;
   local int    TeamID;
   local Pawn   Other;

   Super.tick(DeltaTime);

   if(Level.Game.CurrentID > CurrentID) // at least one new player has joined
   {
      // Find the new player
      for( Other=Level.PawnList; Other!=None; Other=Other.NextPawn )
         if(Other.PlayerReplicationInfo.PlayerID == CurrentID)
            break;

	  // Check if this player needs to be removed from the game (dyn ip ban)
	  if(PlayerPawn(Other)!=None) {
	    log("MV: Checking ban for"@PlayerPawn(Other).GetHumanName());
	    CheckDynIPBan(PlayerPawn(Other));
	  }
	  if(Other==None) return;
			
      CurrentID++;

      // Ignore Bots and other none playerpawns
      if(Other == None || !Other.bIsPlayer || !Other.IsA('PlayerPawn'))
         return;

      if(bEntryWindows && !Other.IsA('Spectator'))
      {
         if(Level.Game.IsA('Assault') && Assault(Level.Game).bDefenseSet)  // dont open for second half of Assault game
            return;
         if(Level.Game.bGameEnded)
         {
            if(bAutoOpen)
               OpenVoteWindow(PlayerPawn(Other));   // open the voting window
         }
      }
   }
}
//************************************************************************************************
function bool CheckForTie()
{
  local TeamInfo Best;
  local int i;
  local pawn P, BestP;
  local PlayerPawn Player;

  if(Level.Game.IsA('Assault'))  //cant have ties in Assault, I think ?
     return false;

  if(Level.Game.IsA('Domination'))  //cant have ties in Domination, I think ?
     return false;

  // No ties in RocketArena, StrikeForce, etc.
  if(bOther &&
     !bCheckOtherGameTie &&
     Level.Game.MapPrefix ~= OtherGameClass.default.MapPreFix &&
     !(OtherClass ~= "s_SWAT.s_SWATGame"))
     return false;

  if(Level.Game.IsA('TeamGamePlus'))  // check for a team game tie
  {
     // find best team
     for( i=0; i<TeamGamePlus(Level.Game).MaxTeams; i++ )
       if( (Best == None) || (Best.Score < TeamGamePlus(Level.Game).Teams[i].Score) )
          Best = TeamGamePlus(Level.Game).Teams[i];

     for( i=0; i<TeamGamePlus(Level.Game).MaxTeams; i++ )
          if( (Best.TeamIndex != i) && (Best.Score == TeamGamePlus(Level.Game).Teams[i].Score) )
             return true;  // teams tied
  }
  else   // check for death match tie
  {
     // find individual winner
     for( P=Level.PawnList; P!=None; P=P.nextPawn )
        if( P.bIsPlayer && ((BestP == None) || (P.PlayerReplicationInfo.Score > BestP.PlayerReplicationInfo.Score)) )
           BestP = P;
     // check for tie
     for ( P=Level.PawnList; P!=None; P=P.nextPawn )
          if ( P.bIsPlayer && (BestP != P) && (P.PlayerReplicationInfo.Score == BestP.PlayerReplicationInfo.Score) )
               return true; // tied
  }
  return false;  // No tie
}
//************************************************************************************************
function SubmitVote(string MapName, Actor Voter)
{
   local int PlayerIndex,x,MapIndex;

   if(bLevelSwitchPending) 
      return;

   //log(PlayerPawn(Voter).PlayerReplicationInfo.PlayerName $ " has voted for " $ MapName);

   if(Voter.IsA('Spectator') && !bLMS)
      return; // spectators can not vote in modes other than LMS

   CleanUpPlayerIDs();

   PlayerIndex = FindPlayerIndex(PlayerPawn(Voter).PlayerReplicationInfo.PlayerID);

   //look up map index
   for(x=1; x<=MapCount; x++)
   {
      if(MapList[x] == MapName)
      {
         MapIndex = x;
         break;
      }
   }

   if(MapIndex == 0) // if map not found stop
      return;

   if(PlayerVote[PlayerIndex] == MapIndex) // voted for same map don't tally.
      return;

   PlayerVote[PlayerIndex] = MapIndex;
   if(bShowVoterNames) 
   {
	   if(Mode == "Accumulation")
    	  BroadcastMessage(PlayerPawn(Voter).PlayerReplicationInfo.PlayerName $ " has placed " $ GetAccVote(PlayerIndex) $ " votes for " $ MapName, true);
	   else
    	  if(Mode == "Score")
	         BroadcastMessage(PlayerPawn(Voter).PlayerReplicationInfo.PlayerName $ " has placed " $ GetPlayerScore(PlayerIndex) $ " votes for " $ MapName, true);
    	  else
	         BroadcastMessage(PlayerPawn(Voter).PlayerReplicationInfo.PlayerName $ " voted for " $ MapName, true);
   }
   else
   {
	   if(Mode == "Accumulation")
	      BroadcastMessage(GetAccVote(PlayerIndex) $ " votes were placed for " $ MapName, true);
	   else
	      if(Mode == "Score")
	         BroadcastMessage(GetPlayerScore(PlayerIndex) $ " votes were placed for " $ MapName, true);
	      else
	         BroadcastMessage("1 vote was placed for " $ MapName, true);
   }

   TallyVotes(false);
}
//******************************************************************************
// Gerco: Submit functie voor gamemode votes
function SubmitModeVote(string GameMode, Actor Voter)
{
   local int PlayerIndex,x,modenum;
   local string modename;
   
   modenum  = -1;
   modename = "<ERROR: Unable to determine gamemode>";
   if(GameMode=="Insta") 
   {
      modenum  = 1;
      modename = "Instagib";
   }
   if(GameMode=="Normal")
   {
      modenum  = 2;
      modename = "Normal Weapons";
   }

   if(Voter.IsA('Spectator') && !bLMS)
      return; // spectators can not vote in other games than LMS

   CleanUpPlayerIDs(); // Remove votes for players that leave.

   PlayerIndex = FindPlayerIndex(PlayerPawn(Voter).PlayerReplicationInfo.PlayerID);

   if(PlayerModeVote[PlayerIndex] == modenum) // voted for same mode don't tally.
      return;

   PlayerModeVote[PlayerIndex] = modenum;
   if(bShowVoterNames)
   {
     BroadcastMessage(PlayerPawn(Voter).PlayerReplicationInfo.PlayerName $ " voted for " $ modename, true);
   }
   else
   {
     BroadcastMessage("1 vote for " $ modename, true);
   }

   InstaNumVotes = 0; // Reset Instagib votes
   NWNumVotes    = 0; // Reset NW votes

   // Tally votes
   for(x=0;x<32;x++) // for each player
   {
      if(PlayerModeVote[x] > 0) // if this player has voted
      {
         // increment the votecount for his/her chosen mode
         if(PlayerModeVote[x] == 1) InstaNumVotes++;
         if(PlayerModeVote[x] == 2) NWNumVotes++;         
      }
   }
   
   UpdateOpenWRI();    
}
//************************************************************************************************
simulated function PreBeginPlay()
{
   local int x;

   if(!bInitialized)
   {
      //log("PreBeginPlay...");
      // initialize PlayerIDList
      for(x=0;x<32;x++)
      {
         PlayerIDList[x] = -1;
         PlayerModeVote[x] = -1;
      }

      LoadMaps();    // load all the map names in the maplist array
      SortMapList(); // sort the maplist in alphabetic order

      bInitialized = true;
   }

   Super.PostBeginPlay();
}
//************************************************************************************************
function KickPlayer(int PlayerID, string AdminName, string AdminIP)
{
  local Pawn aPawn;
  local MapVoteWRI MVWRI;
  local BanListInfo bl;

  //log("PlayerID = " $ PlayerID);
  
  for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
  {
     //if(aPawn.bIsPlayer) log("Player: " $ PlayerPawn(aPawn).PlayerReplicationInfo.PlayerName $ ", " $ PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID);
     
     if(aPawn.bIsPlayer &&
        aPawn.PlayerReplicationInfo.PlayerID == PlayerID &&
//	    !aPawn.PlayerReplicationInfo.bAdmin && // Cannot kick an admin
        (PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None )
       )
     {
        //close his/her voting window if open
        foreach AllActors(class'BDBMapVote3Ex.MapVoteWRI',MVWRI) // check all existing WRIs
        {
           if(aPawn == MVWRI.Owner)
           {
              MVWRI.CloseWindow();
              MVWRI.Destroy();
              break;
           }
        }
	
		// Find BanListInfo actor and have it kick the player
		foreach AllActors(class'BDBMapVote3Ex.BanListInfo', bl) break;
	    if(bl == none) log( "MV: BanListInfo not found!" );
		else if(bl.bIsAdmin(AdminIP)) bl.blKickPlayer(PlayerID, AdminName); 
	    
    	CleanupPlayerIDs();
        return;
     }
  }
}
//************************************************************************************************
function BanPlayer(int PlayerID, string AdminName, int Hours, string AdminIP)
{
  local Pawn aPawn;
  local MapVoteWRI MVWRI;
  local string IP;
  local int j;
  local BanListInfo bl;  
  
  for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
  {
     if(aPawn.bIsPlayer &&
        aPawn.PlayerReplicationInfo.PlayerID == PlayerID &&
//       !aPawn.PlayerReplicationInfo.bAdmin && // Cannot ban an admin
        (PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None )
       )
     {
        //close his/her voting window if open
        foreach AllActors(class'BDBMapVote3Ex.MapVoteWRI',MVWRI) // check all existing WRIs
        {
           if(aPawn == MVWRI.Owner)
           {
              MVWRI.CloseWindow();
              MVWRI.Destroy();
              break;
           }
        }

		SetDynIPBan(PlayerPawn(aPawn));		

		// Find BanListInfo actor and have it ban the player
		foreach AllActors(class'BDBMapVote3Ex.BanListInfo', bl) break;
	    if(bl == none) log( "MV: BanListInfo not found!" );
		else if(bl.bIsAdmin(AdminIP)) bl.blBanPlayer(PlayerID, AdminName, Hours);
	 
		CleanupPlayerIDs();
        return;
     }
  }
}
//************************************************************************************
function UnBanIP(int Index, string AdminName, string AdminIP) {
  local BanListInfo bl;
  
  // Find BanListInfo actor and have it unban the IP
  foreach AllActors(class'BDBMapVote3Ex.BanListInfo', bl) break;
  if(bl == none) log( "MV: BanListInfo not found!" );
  else if(bl.bIsAdmin(AdminIP)) bl.blUnbanIndex(Index, AdminName); 
}
//************************************************************************************************
function Mutate(string MutateString, PlayerPawn Sender)
{
   local string MapName;
   local string PlayerName;
   local string Tmp;
   local int PlayerID,pos,seq;
   local int ObjectCount;
   local int sppos;
   local string IP;
   local MapVoteWRI MVWRI;

   IP = Sender.GetPlayerNetworkAddress();
   IP = Left(IP,Instr(IP,":"));
     
   Super.Mutate(MutateString, Sender);
   //log(">"$MutateString$"<");
   //       012345678901234567890
   //MUTATE BDBMAPVOTE VOTEMENU
   if(left(Caps(MutateString),10) == "BDBMAPVOTE")
   {
      if(Mid(Caps(MutateString),11,8) == "VOTEMENU")
      {
         if(Level.TimeSeconds > 20 || Level.Netmode == NM_Standalone || Sender.bAdmin)  // make sure they cant vote before other players have joined server
         {
            if(!Sender.IsA('Spectator') || bLMS )
            {
               CleanUpPlayerIDs();
               OpenVoteWindow(Sender);
            }
         }
         else
         {
            Sender.ClientMessage("Please Wait 20 seconds to vote");
         }
      }
      //---------------------------------------------
      if(Mid(Caps(MutateString),11,3) == "MAP")
      {
         MapName = mid(MutateString,15);
         SubmitVote(MapName,Sender);
      }
      //---------------------------------------------
      // Gerco: Submit voor insta en nw votes
      if(Mid(Caps(MutateString),11,8) == "INSTAGIB")
      {
         SubmitModeVote("Insta", Sender);
      }
      if(Mid(Caps(MutateString),11,13) == "NORMALWEAPONS")
      {
         SubmitModeVote("Normal", Sender);
      }
      //---------------------------------------------
      if(Mid(Caps(MutateString),11,10) == "KICKPLAYER")
      {
         KickPlayer(int(Mid(MutateString,22)), Sender.GetHumanName(), IP);
      }
      //----------------------------------------------
      if(Mid(Caps(MutateString),11,9) == "BANPLAYER")
      {
	    tmp = Mid(MutateString,21);
        BanPlayer(int( Left( tmp, Instr( tmp, " " ))),	                 
	              Sender.GetHumanName(),
			      int( Right( tmp, Len( tmp ) - Instr( tmp ," " ) - 1 )),
				  IP);
      }
      //----------------------------------------------
      if(Mid(Caps(MutateString),11,5) == "UNBAN")
      {
	    UnBanIP(int(Mid(MutateString,17)), Sender.GetHumanName(), IP);
      }
      //----------------------------------------------
      if(Mid(Caps(MutateString),11,10) == "RELOADMAPS")
      {
         if(Sender.bAdmin)
         {
            LoadMaps();
            SortMapList();
            BroadcastMessage("MapVote configuration has been changed, Re-Open Voting window for updates.", true);
         }
      }
      //---------------------------------------------
      if(Mid(Caps(MutateString),11,6) == "STATUS")
      {
         Sender.ClientMessage("Total Map Count is " $ MapCount);

         // count MapVoteWRIs
         ObjectCount = 0;
         foreach AllActors(class'BDBMapVote3Ex.MapVoteWRI',MVWRI)
            ObjectCount++;
         Sender.ClientMessage("Active MapVoteWRI count is " $ ObjectCount);
      }
   }
}
//************************************************************************************************
function CheckDynIPBan(PlayerPawn Victim)
{
	local DynIPInfo DIPI;
	
	log("MV: CheckDynIPBan");
	
	if( Victim==none ) return;
	
	log("Spawning DynIPInfo on PlayerPawn");
	DIPI = Spawn(class'BDBMapVote3Ex.DynIPInfo',Victim,,Victim.Location);
	if(DIPI==None) {
	  log("MV: ERROR! Could not spawn DynIPInfo on"@Victim.GetHumanName());
	  return;
	}
	
	log("Call DIPI.CheckBan");
	DIPI.CheckBan(Level.Month, Level.Day, Level.Hour);
}
//************************************************************************************************
function SetDynIPBan(PlayerPawn Victim) 
{
	local DynIPInfo DIPI;
	
	if( Victim == none ) return;
	
	DIPI = Spawn(class'BDBMapVote3Ex.DynIPInfo',Victim,,Victim.Location);
	if(DIPI==None) {
	  log("MV: ERROR! Could not spawn DynIPInfo on"@Victim.GetHumanName());
	  return;
	}
	
	DIPI.SetBan(Level.Month, Level.Day, Level.Hour);
}
//************************************************************************************************
function OpenVoteWindow(PlayerPawn Sender)
{
   local MapVoteWRI MVWRI;
   local int x,playercount,y,i;
   local pawn p;
   local MapVoteWRI A;
   local int TeamID;
   local string PID;
   local BanListInfo bl;
   local string IP;

   if(Sender.IsA('Spectator') && !bLMS)
      return; // don't open voting window for spectators in non-LMS

   // check if window already open
   foreach AllActors(class'BDBMapVote3Ex.MapVoteWRI',A) // check all existing WRIs
   {
      if(Sender == A.Owner)
         return;            // dont open if already open
   }

   MVWRI = Spawn(class'BDBMapVote3Ex.MapVoteWRI',Sender,,Sender.Location);
   if(MVWRI==None)
   {
      Log("#### -- PostLogin :: Fail:: Could not spawn WRI");
      return;
   }
   
   // transfer map list to the WRI
   MVWRI.MapCount = MapCount;
   //for(x=1;x<=MapCount;x++)
   //   MVWRI.MapList[x] = MapList[x];

   //  Map Number  List
   //  ----------- ----------
   //  1   - 255   MapList1
   //  256 - 510   MapList2
   //  511 - 765   MapList3
   //  766 - 1020  MapList4

   for(i=1;i<=MapCount;i++)
   {
      if(i < 256)
         MVWRI.MapList1[i] = MapList[i];
      if(i >= 256 && i < 511)
         MVWRI.MapList2[i - 255] = MapList[i];
      if(i >= 511 && i < 766)
         MVWRI.MapList3[i - 510] = MapList[i];
      if(i >= 766)
         MVWRI.MapList4[i - 765] = MapList[i];
   }
   MVWRI.MapVoteMutator = self;

   // transfer Map Voting Status to status page window
   x=0;
   while(MapStatusText[x] != "" && x<99)
   {
      MVWRI.MapVoteResults[x] = MapStatusText[x];
      x++;
   }
   MVWRI.MapVoteResults[x]="";

   // Gerco: Transfer ModeVote status to the status page window
   MVWRI.InstaNumVotes = InstaNumVotes;
   MVWRI.NWNumVotes = NWNumVotes;
 
   // find the BanListInfo actor
   foreach AllActors(class'BDBMapVote3Ex.BanListInfo', bl) break;
   
   // Gerco: Transfer Bannedlist to the window
   IP = Sender.GetPlayerNetworkAddress();
   IP = Left(IP,Instr(IP,":"));
   if(bl.bIsAdmin(IP)) {
   	 MVWRI.bIsAdmin = True;
     for(i=0; i<50; i++) {
       if( bl.blGetBan(i).Used ) 
         MVWRI.SetBan(i, bl.blGetBan(i).IP, bl.blGetBan(i).Nick);
     }
   }
   
   for(i=0;i<10;i++) {
	   MVWRI.OtherGamemodesbEnabled[i] = OtherGamemodesbEnabled[i];
	   MVWRI.OtherGamemodesMapPrefix[i] = OtherGamemodesMapPrefix[i];
	   MVWRI.OtherGamemodesPackageGameClass[i] = OtherGamemodesPackageGameClass[i];
   }
   
   MVWRI.GetServerConfig();
}
//************************************************************************************************
function int FindPlayerIndex(int PlayerID)
{
   // this funtion maintains the list of players
   // uses the PlayerID which should be unique for every player
   local int x;

   // find the PlayerID in PlayerIDList array if it exists
   for(x=0;x<32;x++)
   {
      if(PlayerIDList[x] == PlayerID)
         return x;
   }

   // not found, so add to bottom of array
   for(x=0;x<32;x++)
   {
      if(PlayerIDList[x]==-1)
      {
         PlayerIDList[x]=PlayerID;
         return x;
      }
   }
}
//************************************************************************************************
function CleanUpPlayerIDs()
{
   // This function removes the player vote info that belongs to players
   // that have left the game
   local Pawn aPawn;
   local int x;
   local bool bFound;

   for(x=0;x<32;x++)
   {
      //log("x = " $ x $ " , PlayerIDList[x] = " $ PlayerIDList[x]);
      if(PlayerIDList[x]>-1)
      {
         bFound = false;
         for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
         {
            if(aPawn.bIsPlayer && aPawn.IsA('PlayerPawn') && PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID == PlayerIDList[x])
            {
               bFound = true;
               break;
            }
         }
         if(!bFound)
         {
            PlayerVote[PlayerIDList[x]]=0;
            PlayerIDList[x] = -1;
            
            // Gerco: modevote entry verwijderen
            PlayerModeVote[x] = 0;
         }
      }
   }
}
//************************************************************************************************
function string GetPlayerName(int PlayerID)
{
   local pawn aPawn;
   local string PlayerName;

   PlayerName="unknown";
   for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
   {
      if(aPawn.bIsPlayer && PlayerPawn(aPawn) != None)
      {
         if(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID == PlayerID)
         {
            PlayerName = right("000" $ PlayerID,3) $ aPawn.PlayerReplicationInfo.PlayerName;
            break;
         }
      }
   }
   return PlayerName;
}
//******************************************************************************
function float GetPlayerScore(int PlayerIndex)
{
   local pawn aPawn;
   local float PlayerScore;

   for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
   {
      if(aPawn.bIsPlayer && PlayerPawn(aPawn) != None)
      {
         if(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID == PlayerIDList[PlayerIndex])
         {
            PlayerScore = PlayerPawn(aPawn).PlayerReplicationInfo.Score;
            break;
         }
      }
   }
   if(PlayerScore < 1)
      PlayerScore = 1;

   return PlayerScore;
}
//******************************************************************************
function int GetAccVote(int PlayerIndex)
{
   local pawn aPawn;
   local int x,PlayerAccVotes;
   local string PlayerName;

   // Find the Players Name
   for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
   {
      if(aPawn.bIsPlayer && PlayerPawn(aPawn) != None)
      {
         if(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID == PlayerIDList[PlayerIndex])
         {
            PlayerName = PlayerPawn(aPawn).PlayerReplicationInfo.PlayerName;
            break;
         }
      }
   }

   if(PlayerName == "")
      return(0);

   // Find the players name in the saved accumulated votes
   for(x=0;x<32;x++)
   {
      if(AccName[x] == PlayerName)
      {
         PlayerAccVotes = AccVotes[x];
         break;
      }
   }

   if(PlayerAccVotes > 0)
      return(PlayerAccVotes); // if found return the saved vote count

   // Not found, so find an empty slot and save it
   for(x=0;x<32;x++)
   {
      if(AccName[x] == "")
      {
         AccName[x] = PlayerName;
         AccVotes[x] = 1;
         break;
      }
   }
   return(1);
}
//******************************************************************************
function SaveAccVotes(int WinningMapIndex)
{
   local pawn aPawn;
   local int x;
   local bool bFound;

   for(x=0;x<32;x++)
   {
      if(AccName[x] != "")
      {
         bFound = false;
         for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
         {
            if(aPawn.bIsPlayer && PlayerPawn(aPawn) != None)
            {
               if(AccName[x] == PlayerPawn(aPawn).PlayerReplicationInfo.PlayerName)
               {
                  if(PlayerVote[FindPlayerIndex(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerID)] != WinningMapIndex)
                  {
                     bFound = true;
                     AccVotes[x]++;
                  }
                  break;
               }
            }
         }
         if(!bFound)  // If this player is not here anymore remove his/her votes
         {
            AccName[x] = "";
            AccVotes[x] = 0;
         }
      }
   }
   // save votes to ini file
   for(x=0;x<32;x++)
   {
      class'BDBMapVote3Ex.BDBMapVote3Ex'.default.AccName[x] = AccName[x];
      class'BDBMapVote3Ex.BDBMapVote3Ex'.default.AccVotes[x] = AccVotes[x];
   }
   class'BDBMapVote3Ex.BDBMapVote3Ex'.static.StaticSaveConfig();
}
//******************************************************************************
function TallyVotes(bool bForceMapSwitch)
{
   local string MapName;
   local string RealMapName;
   local Actor  A;
   local int    index,x,y,topmap;
   local int    VoteCount[1024];
   local int    Ranking[32];
   local int    PlayersThatVoted;
   local int    TieCount;
   local string GameType,CurrentMap;
   local int i,textline;

   // Gerco: var voor de mode
   local string extra;
   local int GameMode;

   PlayersThatVoted = 0;
   for(x=0;x<32;x++) // for each player
   {
      if(PlayerVote[x] != 0) // if this player has voted
      {
         PlayersThatVoted++;

         if(Mode == "Score")
         {
            VoteCount[PlayerVote[x]] = VoteCount[PlayerVote[x]] + int(GetPlayerScore(x));
         }

         if(Mode == "Accumulation")
         {
            VoteCount[PlayerVote[x]] = VoteCount[PlayerVote[x]] + GetAccVote(x);
         }

         if(Mode == "Elimination" || Mode == "Majority")
         {
            VoteCount[PlayerVote[x]]++; // increment the votecount for this map
            if(float(VoteCount[PlayerVote[x]]) / float(Level.Game.NumPlayers) > 0.5 && Level.Game.bGameEnded && bAllowEarlySwitch)
               bForceMapSwitch = true;
         }
      }
   }

   if(!Level.Game.bGameEnded && !bMidGameVote && (float(PlayersThatVoted) / float(Level.Game.NumPlayers)) * 100 >= MidGameVotePercent) // Mid game vote initiated
   {
      BroadCastMessage("Mid-Game Map Voting has been initiated !!!!");
      bMidGameVote = true;
      // Start voting count-down timer
      TimeLeft = VoteTimeLimit;
      ScoreBoardTime = 1;
      settimer(1,true);
   }
     
   index = 0;
   for(x=1;x<=MapCount;x++) // for each map
   {
      if(VoteCount[x] > 0)
      {
         Ranking[index++] = x; // copy all map indexes to the ranking list if someone has voted for it.
      }
   }

   // bubble sort ranking list by vote count
   for(x=0; x<index-1; x++)
   {
      for(y=x+1; y<index; y++)
      {
         if(VoteCount[Ranking[x]] < VoteCount[Ranking[y]])
         {
            topmap = Ranking[x];
            Ranking[x] = Ranking[y];
            Ranking[y] = topmap;
         }
      }
   }
   
   //Update Status Page
   for(x=0;x<index;x++)
   {
      MapStatusText[x] = MapList[Ranking[x]] $ "," $ VoteCount[Ranking[x]];
   }
   MapStatusText[index] = "";

   UpdateOpenWRI();

   //Check for a tie
   if(VoteCount[Ranking[0]] == VoteCount[Ranking[1]] && VoteCount[Ranking[0]] != 0)
   {
      TieCount = 1;
      for(x=1; x<index; x++)
      {
        if(VoteCount[Ranking[0]] == VoteCount[Ranking[x]])
           TieCount++;
      }
      //reminder ---> int Rand( int Max ); Returns a random number from 0 to Max-1.
      topmap = Ranking[Rand(TieCount)];

      // Don't allow same map to be choosen
      CurrentMap = GetURLMap();
      if(CurrentMap != "" && !(Right(CurrentMap,4) ~= ".unr"))
         CurrentMap = CurrentMap$".unr";

      x = 0;
      while(MapList[topmap] ~= CurrentMap)
      {
         topmap = Ranking[Rand(TieCount)];
         x++;
         if(x>20)
            break;  // just incase, don't want to waste alot of time choosing a random map
      }
   }
   else 
   {
      topmap = Ranking[0];
   }

   // check if all players have voted
   //log("Players - " $ level.game.NumPlayers);
   //log("Voted - " $ PlayersThatVoted);

   //return; // testing

   if(bForceMapSwitch)  // forces a map change even if everyone has not voted
      if(PlayersThatVoted == 0) // if noone has voted choose a map at random
         topmap = Rand(MapCount) + 1;

   if(bForceMapSwitch || ( Level.Game.NumPlayers == PlayersThatVoted && bAllowEarlySwitch))  // if everyone has voted go ahead and change map
   {             
      if(MapList[topmap] == "")
         return;

	  // Kies random map indien random map gevote
      if(MapList[topmap] == "--Random Map--") {
	     MapList[topmap] = MapList[rand(MapCount-1) + 1];
      }
	 
	 // This variable determines which Package.Gameclass gets assigned to the next game.
      GameType = SetupGameMap(MapList[topmap]);

      // Gerco: bepaal Insta of NW

      // Fix bugje als er niet gemodevote was, kreeg je altijd NW
      if( ( InstaNumVotes == 0 ) && ( NWNumVotes == 0 ) ) {
	InstaNumVotes = 1; 
	NWNumVotes = 1;
      }

      if( InstaNumVotes > NWNumVotes )
        GameMode = 1;
      else
        GameMode = 2;

      if( InstaNumVotes == NWNumVotes ) {
         if( CurGameMode ~= "NW" )      GameMode = 1;
         else if( CurGameMode ~= "IG" ) GameMode = 2;
      }

      if( GameMode == 1 )
         extra = " (Instagib "; 
      else if( GameMode == 2 )
         extra = " (Normal Weapons ";
      else
         extra = " (";
      
      if(GameType ~= DMGameType)
      	extra = extra $ "Deathmatch)";
      else if(GameType ~= LMSGameType)
        extra = extra $ "Last man standing)";
      else if(GameType ~= TDMGameType)
        extra = extra $ "Team Deathmatch)";
      else if(GameType ~= ASGameType)
        extra = extra $ "Assault)";
      else if(GameType ~= DOMGameType)
        extra = extra $ "Domination)";
      else if(GameType ~= CTFGameType)
        extra = extra $ "Capture the Flag)";
      else if(GameType ~= "FragBall.FragGame") {
      	extra = "(Frag*Ball)";
		GameMode = 2;
      }
      else
        extra = "";
		
      RealMapName = TranslateMapName(MapList[topmap]);     
      BroadcastMessage("Next map will be " $ MapList[topmap] $ extra, true);
      CloseAllVoteWindows();
      bLevelSwitchPending = true;
      ServerTravelString = RealMapName$".unr?game="$GameType;
      if(GameMode == 1) ServerTravelString = ServerTravelString $ "?mutator=BotPack.InstaGibDM,BDBMapVote3Ex.BDBMapVote3Ex";
      else if(GameMode == 2) ServerTravelString = ServerTravelString $ "?mutator=BotPack.NoRedeemer,BDBMapVote3Ex.BDBMapVote3Ex";
      if(ExtraMutators != "") ServerTravelString = ServerTravelString $ "," $ ExtraMutators;
      ServerTravelTime = Level.TimeSeconds;
      // enable timer for mid game voting
      if(!Level.Game.bGameEnded)
         settimer(1,true);
      //Level.ServerTravel(MapList[topmap]$"?game="$GameType, false);    // change the map
      // this is for a later version -> $"?mutator="$Mutators()

      if(Mode == "Elimination")
      {
         RepeatLimit++;
         class'BDBMapVote3Ex.BDBMapVote3Ex'.default.RepeatLimit = RepeatLimit;
         class'BDBMapVote3Ex.BDBMapVote3Ex'.static.StaticSaveConfig();
      }

      if(Mode == "Accumulation")
      {
         SaveAccVotes(topmap);
      }
      //**********Log
      //MVLog = spawn(class'BDBMapVote3Ex.MapVoteLog');
      //MVLog.OpenLog();
      //MVLog.FileLog(MVLog.GetTimeStamp() $ "-" $ MapList[topmap] $ Chr(13));
      //MVLog.FileFlush();
      //MVLog.CloseLog();
      //MVLog.Destroy();
      //MVLog.FileFlush();
   }
}    
//************************************************************************************************
function string TranslateMapName(string MapName) 
{
   local string PreFix;
   
   Prefix = Left(MapName,3);
   If(Prefix ~= "TDM" || Prefix ~= "LMS")
   {
      // Zet prefix op DM en return waarde
      return "DM" $ Right(MapName, Len(MapName) - 3);
   } 
   
   return MapName;
}
//************************************************************************************************
function UpdateOpenWRI()
{
   local MapVoteWRI MVWRI;
   local int x,y;

   foreach AllActors(class'BDBMapVote3Ex.MapVoteWRI',MVWRI)
   {
      // transfer Map Voting Status to status page window
      x=0;
      MVWRI.UpdateMapVoteResults("Clear",x);
      while(MapStatusText[x] != "" && x<99)
      {
         MVWRI.UpdateMapVoteResults(MapStatusText[x],x);
         x++;
      }
      MVWRI.UpdateMapVoteResults("",x); // Mark the end
      y=0;
      
      // Gerco: update modevotestatus
      MVWRI.UpdateModeVoteResults(InstaNumVotes, NWNumVotes);
   }
}
//************************************************************************************************
function SortMapList()
{
   local int a,b;
   local string TempMapName;

   // bubble sort the map list
   for(a=1;a<=MapCount-1;a++)
   {
      for(b=a+1;b<=MapCount;b++)
      {
         if(Caps(MapList[a]) > Caps(MapList[b]))
         {
            TempMapName = MapList[a];
            MapList[a] = MapList[b];
            MapList[b] = TempMapName;
         }
      }
   }
}
//************************************************************************************************
function CloseAllVoteWindows()
{
   local MapVoteWRI MVWRI;

   foreach AllActors(class'BDBMapVote3Ex.MapVoteWRI',MVWRI)
   {
      MVWRI.CloseWindow();
      MVWRI.Destroy();
   }
}
//************************************************************************************************
function string SetupGameMap(string MapName)
{
   local string GameType, PreFix;
   local MapList myList;
   local int i;

   if(OtherGameClass != None && left(Caps(MapName),len(OtherGameClass.default.MapPreFix)) == OtherGameClass.default.MapPreFix)
   {
      GameType = OtherClass;
      return GameType;
   }
   
   // Check if the chosen map is one of the gamemodes on the OtherGamemodes admin tab.
   for (i=0;i<10;i++) {
		// Do the prefix check including the - character. For example Badlands has BL and BLC prefixes.
		// If the - is not taken into account then BL could end up with the BLC gametype.
		if(OtherGamemodesbEnabled[i] == 1 && left(Caps(MapName),len(OtherGamemodesMapPrefix[i])+1) == (Caps(OtherGamemodesMapPrefix[i]) $ "-")) {
			return OtherGamemodesPackageGameClass[i];
		}
   }

   if(Left(Caps(MapName),2) == "DM")
         GameType = DMGameType;

   if(Left(Caps(MapName),3) == "TDM")
         GameType = TDMGameType;

   if(Left(Caps(MapName),3) == "LMS")
         GameType = LMSGameType;
	 
   if(Left(Caps(MapName),3) == "DOM")
      GameType = DOMGameType;

   if(Left(Caps(MapName),3) == "CTF") 
      GameType = CTFGameType;

   if(Left(Caps(MapName),2) == "AS")
   {
      GameType = ASGameType;
      // if playing assault in second half and switching to a different assault map
      if(Level.Game.IsA('Assault') &&  Assault(Level.Game).bDefenseSet)
      {
         Assault(Level.Game).ResetGame();  // resets assault ini settings so next game starts on first half of game instead of second
      }
      else
      {
         // this should make sure that we start in the first half
         class'Assault'.default.bDefenseSet = false;
         class'Assault'.static.StaticSaveConfig();
      }
   }

   return GameType;
}
//************************************************************************************************
function LoadMaps()
{
   local int pos;
   local string GamePackage;
   local Mutator M;
	local int i;
	
   MapCount = 0;

   if(bAutoDetect)
   {
      log("Detected GameType = "$string(Level.Game.Class));
      bAS=False;
      bCTF=False;
      bDM=False;
      bLMS=False;
      bTDM=False;
      bDOM=False;
      bOther=False;
      if(string(Level.Game.Class) ~= ASGameType)
         bAS=True;
      else if(string(Level.Game.Class) ~= CTFGameType)
         bCTF=True;
      else if(string(Level.Game.Class) ~= DMGameType)
         bDM=True;
      else if(string(Level.Game.Class) ~= LMSGameType)
         bLMS=True;
      else if(string(Level.Game.Class) ~= TDMGameType)
         bTDM=True;
      else if(string(Level.Game.Class) ~= DOMGameType)
         bDOM=True;
      else
      {
         bOther=True;
         OtherClass=string(Level.Game.Class);
      }
   }

   // Gerco: Detect Insta/NW
   CurGameMode = "NW";
   for (M = Level.Game.BaseMutator.NextMutator; M != None; M = M.NextMutator) {
      if( string( M.Class ) ~= "BotPack.InstaGibDM" ) {
         CurGameMode = "IG";
         break;
      }	
   }

   if( CurGameMode ~= "NW" )
      log("Detected mode = Normal Weapons");
   if( CurGameMode ~= "IG" )
      log("Detected mode = Instagib");

   if(bOther)
      OtherGameClass = class<GameInfo>(DynamicLoadObject(OtherClass, class'Class'));

   MapCount = 0;
   MapList[++MapCount] = "--Random Map--";	  
	
   // Load game classes	
   ASGameClass = class<GameInfo>(DynamicLoadObject(ASGameType, class'Class'));
   CTFGameClass = class<GameInfo>(DynamicLoadObject(CTFGameType, class'Class'));
   DMGameClass = class<GameInfo>(DynamicLoadObject(DMGameType, class'Class'));   
   DOMGameClass = class<GameInfo>(DynamicLoadObject(DOMGameType, class'Class'));   
   TDMGameClass = class<GameInfo>(DynamicLoadObject(TDMGameType, class'Class'));   
   LMSGameClass = class<GameInfo>(DynamicLoadObject(LMSGameType, class'Class'));   
	  
   if(bAS)
   {
      if(bUseMapList)
         LoadMapCycleList(ASGameClass.default.MapListType);
      else
         LoadMapTypes("AS");
   }
   
   if(bCTF) // Load Capture The Flag Maps
   {
      if(bUseMapList)
         LoadMapCycleList(CTFGameClass.default.MapListType);
      else
         LoadMapTypes("CTF");
   }

   if(bDM) // Load DeathMatch Maps
   {
      if(bUseMapList)
         LoadMapCycleList(DMGameClass.default.MapListType);
      else
         LoadMapTypes("DM");
   }

   if(bDOM) // Load Domination Maps
   {
      if(bUseMapList)
         LoadMapCycleList(DOMGameClass.default.MapListType);
      else
         LoadMapTypes("DOM");
   }

   if(bTDM) // Load TeamDeathMatch Maps
   {
      if(bUseMapList)
         LoadMapCycleList(TDMGameClass.default.MapListType);
      else
         LoadMapTypes("TDM");
   }

   if(bLMS) // Load LastManStanding Maps
   {
      if(bUseMapList)
         LoadMapCycleList(LMSGameClass.default.MapListType);
      else
         LoadMapTypes("LMS");
   }

   if(bOther && OtherGameClass != None) // Load Other Maps
   {
      if(bUseMapList)
         LoadMapCycleList(OtherGameClass.default.MapListType);
      else
      {
         if(MapPreFixOverRide == "")
            LoadMapTypes(OtherGameClass.default.MapPreFix);
         else
            LoadMapTypes(MapPreFixOverRide);
      }
      if(HasStartWindow == "Auto")
      {
         GamePackage = Caps(string(Level.Game.Class));
         pos = InStr(GamePackage,".");
         if(pos > 0)
            GamePackage = left(GamePackage,pos);

         if(GamePackage=="S_SWAT" || GamePackage =="WFCODE" || GamePackage =="ROCKETARENA")
            HasStartWindow = "Yes"; // these Mods have start windows
         else
            HasStartWindow = "No";
      }
   }

   if(Mode == "Elimination")
   {
      if(MapCount < MinMapCount || (MapCount == 0 && RepeatLimit > 0))
      {
         RepeatLimit = 0;
         LoadMaps();
         return;
      }
   }
   
   // Load the gamemodes from the Other Gamemodes admin tab
   for (i=0;i<10;i++) {
		if (OtherGamemodesbEnabled[i] == 1) {
			LoadMapTypes(OtherGamemodesMapPrefix[i]);
		}
   }
   
   log("Total Maps = "$ MapCount);
}
//*******************************************************************************
function LoadMapTypes(string PreFix)
{
   local string FirstMap,NextMap,MapName,TestMap,ListPrefix;

   // De listprefix zetten
   ListPrefix = Prefix;
   if(PreFix ~= "TDM") {
   	ListPrefix = "TDM";
	Prefix = "DM";
   }
   if(PreFix ~= "LMS") {
        ListPrefix = "LMS";
	Prefix = "DM";
   }	
   
   FirstMap = Level.GetMapName(PreFix, "", 0);
   NextMap = FirstMap;
   while(!(FirstMap ~= TestMap))
   {
      MapName = Left(NextMap,len(NextMap) - 4);
      if(!(Left(NextMap, Len(NextMap) - 4) ~= (PreFix $ "-tutorial")) )
      {
	 // Map prefix eraf slopen
	 MapName = Right(MapName, Len(MapName) - Instr(MapName,"-"));
	   
	 // Map in de list zetten met goede listprefix
         MapList[++MapCount] = ListPrefix $ MapName;
      }
      NextMap = Level.GetMapName(PreFix, NextMap, 1);
      TestMap = NextMap;
      if(MapCount > 1020)
         break;
   }
}
//*******************************************************************************
function LoadMapCycleList(class<MapList> MapListType)
{
   local MapList MapCycleList;
   local string MapName;
   local int x,z;

   MapCycleList = spawn(MapListType);
   if(MapCycleList != none)
   {
      x = 0;
      While(x<32 && MapCycleList.Maps[x]!="")
      {
         MapName = MapCycleList.Maps[x++];
         z = InStr(Caps(MapName), ".UNR");
         if(z != -1)
            MapName = Left(MapName, z);

         MapList[++MapCount] = MapName;
      }
      MapCycleList.Destroy();
   }
   else
      Log("MapList Spawn Failed");
}

//*******************************************************************************
function TOFixSetEndCams(string Reason)
{
     local pawn P, Best;
     local PlayerPawn player;

     // find individual winner
     for ( P=Level.PawnList; P!=None; P=P.nextPawn )
          if ( P.bIsPlayer && ((Best == None) || (P.PlayerReplicationInfo.Score > Best.PlayerReplicationInfo.Score)) )
               Best = P;

     Level.Game.GameReplicationInfo.GameEndedComments = DeathMatchPlus(Level.Game).GameEndedMessage;

     DeathMatchPlus(Level.Game).EndTime = Level.TimeSeconds + 3.0;
     for ( P=Level.PawnList; P!=None; P=P.nextPawn )
     {
          player = PlayerPawn(P);
          if ( Player != None )
          {
               DeathMatchPlus(Level.Game).PlayWinMessage(Player, true);
               player.bBehindView = true;
               if ( Player == Best )
                    Player.ViewTarget = None;
               else
                    Player.ViewTarget = Best;
               player.ClientGameEnded();
          }
          P.GotoState('GameEnded');
     }
     DeathMatchPlus(Level.Game).CalcEndStats();
     return;
}

//************************************************************************************************

defaultproperties
{
     bAutoDetect=True
     MsgTimeOut=10
     VoteTimeLimit=70
     ScoreBoardDelay=10
     bAutoOpen=True
     bTOTieGameFix=True
     RepeatLimit=4
     bLoadScreenShot=True
     MidGameVotePercent=90
     Mode="Majority"
     MinMapCount=2
     HasStartWindow="Auto"
     bEntryWindows=True
     bShowVoterNames=True
     DMGameType="Botpack.DeathMatchPlus"
     LMSGameType="Botpack.LastManStanding"
     TDMGameType="BotPack.TeamGamePlus"
     DOMGameType="BotPack.Domination"
     CTFGameType="Botpack.CTFGame"
     ASGameType="Botpack.Assault"
}
