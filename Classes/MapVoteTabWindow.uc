class MapVoteTabWindow expands UWindowDialogClientWindow;

var UMenuPageControl Pages;
var MapVoteClientWindow MapWindow;
var ConfigWindow ConfigWindow;
//var AboutMapVoteWindow AboutWindow;
var AdminTabWindow AdminWindow;
var OtherGamemodesTabWindow OtherGamemodesWindow;
var string PrevSelectedMap;
var int MapCount;

function Created()
{
   local UWindowPageControlPage PageControl;
   WinLeft = (Root.WinWidth - WinWidth) / 2;
   WinTop = (Root.WinHeight - WinHeight) / 2;

   Pages = UMenuPageControl(CreateWindow(class'MapVotePageControl', 0, 0, WinWidth, WinHeight));
   Pages.SetMultiLine(false);

   // Add the Map Client Window
   PageControl = Pages.AddPage( "Maps", class'MapVoteClientWindow');
   MapWindow = MapVoteClientWindow(PageControl.Page);

   // Add the config window
   PageControl = Pages.AddPage( "Config", class'ConfigWindow');
   ConfigWindow = ConfigWindow(PageControl.Page);

   // Add the About window
   //PageControl = Pages.AddPage( "About", class'AboutMapVoteWindow');
   //AboutWindow = AboutMapVoteWindow(PageControl.Page);

   if(GetPlayerOwner().PlayerReplicationInfo.bAdmin) // only show this tab to the Admin
   {
      // Add the Admin window
      PageControl = Pages.AddPage( "Admin", class'AdminTabWindow');
      AdminWindow = AdminTabWindow(PageControl.Page);
	  

   }
   
   	  // Add the Other Games window
      PageControl = Pages.AddPage( "Other Gamemodes", class'OtherGamemodesTabWindow');
      OtherGamemodesWindow = OtherGamemodesTabWindow(PageControl.Page);

   Super.Created();
}

// Called from MapVoteWRI
function AddMapName(String MapName)
{
   local UMenuMapVoteList I;

   //log("Adding " $ MapName);
   I = UMenuMapVoteList(MapWindow.MapListBox.Items.Append(class'UMenuMapVoteList'));
   I.MapName = MapName;
   //MapWindow.MapList[MapWindow.MapCount++] = MapName;
}

// Called from MapVoteWRI
function UpdateAdminOtherGamemode(int index, bool cbEnabled, string txtPackageGameClass, string txtMapPrefix) {

	local OtherGamemodesWindow Window;
	local int i;

	if(OtherGamemodesWindow != None) {
		Window = OtherGamemodesWindow(OtherGamemodesWindow.ClientArea);
		Window.cbEnabled[index].bChecked = cbEnabled;
		Window.txtPackageGameClass[index].SetValue(txtPackageGameClass);
		Window.txtMapPrefix[index].SetValue(txtMapPrefix);
	}

}

// Called from MapVoteWRI
function UpdateAdmin(string p_GameTypes,
                     string p_OtherClass,
                     int p_VoteTimeLimit,                     
                     int p_ScoreBoardDelay,
                     bool p_bUseMapList,
                     bool p_bAutoOpen,
                     bool p_bAutoDetect,
                     bool p_bCheckOtherGameTie,
                     int p_RepeatLimit,
                     string p_MapVoteHistoryType,
                     int p_MidGameVotePercent,
                     string p_Mode,
                     int p_MinMapCount,
                     string p_MapPreFixOverRide,
					 string p_ExtraMutators)
{
   local AdminWindow Window;

   if(AdminWindow!=None)
   {
      Window = AdminWindow(AdminWindow.ClientArea);

      Window.cbLoadDM.bChecked = bool(Mid(p_GameTypes,0,1));
      Window.cbLoadLMS.bChecked = bool(Mid(p_GameTypes,1,1));
      Window.cbLoadTDM.bChecked = bool(Mid(p_GameTypes,2,1));
      Window.cbLoadAS.bChecked = bool(Mid(p_GameTypes,3,1));
      Window.cbLoadDOM.bChecked = bool(Mid(p_GameTypes,4,1));
      Window.cbLoadCTF.bChecked = bool(Mid(p_GameTypes,5,1));
      Window.cbLoadOther.bChecked = bool(Mid(p_GameTypes,6,1));
      Window.txtOtherClass.SetValue(p_OtherClass);

      Window.sldVoteTimeLimit.SetValue(p_VoteTimeLimit);
      Window.sldScoreBoardDelay.SetValue(p_ScoreBoardDelay);
      Window.cbUseMapList.bChecked = p_bUseMapList;
      Window.cbAutoOpen.bChecked = p_bAutoOpen;
      Window.cbAutoDetect.bChecked = p_bAutoDetect;
      Window.cbCheckOtherGameTie.bChecked = p_bCheckOtherGameTie;

      Window.sldMidGameVotePercent.SetValue(p_MidGameVotePercent);
      Window.cboMode.SetValue(p_Mode);
      Window.txtMinMapCount.SetValue(string(p_MinMapCount));
      Window.txtMapPreFixOverRide.SetValue(p_MapPreFixOverRide);
	  
	  Window.txtExtraMuts.SetValue(p_ExtraMutators);
   }
}

simulated function UpdateMapVoteResults(string Text, int i)
{
   local UWindowList Item;
   local string MapName;
   local int c,pos;

   if(Text == "Clear")
   {
      if(MapWindow.lstMapStatus.SelectedItem != None)
         PrevSelectedMap = MapStatusListItem(MapWindow.lstMapStatus.SelectedItem).MapName;
      MapWindow.lstMapStatus.Items.Clear();
      return;
   }

   pos = Instr(Text,",");
   if(pos > 0)
   {
      MapName = left(Text,pos);
      c = int(Mid(Text,pos+1));
   }

   // check to see if MapName is already in the list
   for(Item=MapWindow.lstMapStatus.Items;Item!=None;Item=Item.Next)
   {
      if(MapStatusListItem(Item).MapName == MapName)
      {
         MapStatusListItem(Item).Rank = i + 1;
         MapStatusListItem(Item).VoteCount = c;
         return;
      }
   }

   // Add it to the list
   Item = MapStatusListItem(MapWindow.lstMapStatus.Items.Append(class'MapStatusListItem'));
   MapStatusListItem(Item).Rank = i + 1;
   MapStatusListItem(Item).MapName = MapName;
   MapStatusListItem(Item).VoteCount = c;
   if(PrevSelectedMap == MapName) // re-select previously selected map
      MapWindow.lstMapStatus.SelectMap(PrevSelectedMap);
}

// Gerco: functie om het aantal insta/nw votes bij te werken
simulated function UpdateModeVoteResults(int insta, int nw)
{
   MapWindow.lblInstaNumVotes.SetText(insta $ " votes");
   MapWindow.lblNWNumVotes.SetText(nw $ " votes");
}

defaultproperties
{
}
