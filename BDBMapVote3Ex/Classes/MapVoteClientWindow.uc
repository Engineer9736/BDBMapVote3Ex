class MapVoteClientWindow expands UWindowPageWindow;

var MapVoteListBox MapListBox;
var UWindowSmallButton CloseButton;
var UWindowSmallButton VoteButton;
var MapStatusListBox lstMapStatus;
var UWindowCheckBox   cbLoadScreenShot;
var UMenuLabelControl lblStatusTitles;
var UMenuLabelControl lblMapCount;
var UWindowEditControl txtFind;
var UWindowSmallButton SendButton;
var UWindowEditControl txtMessage;
var UMenuLabelControl lblMode;

// Gerco: vars voor insta/nw vote knopjes en statuslabels
var UWindowSmallButton  btnInstaVote;
var UWindowSmallButton  btnNWVote;
var UMenuLabelControl   lblInstaNumVotes;
var UMenuLabelControl   lblNWNumVotes;

// vars voor kick/ban/unban controls 
var UWindowComboControl cmbPlayers;
var UWindowSmallButton  btnKick;
var UWindowSmallButton  btnBan;
var UWindowLabelControl lblHours;
var UWindowEditControl  txtHours;
var UWindowComboControl cmbBanned;
var UWindowSmallButton  btnUnban;

var color   TextColor;
var Texture Screenshot;
var string  MapTitle;
var string  MapAuthor;
var string  IdealPlayerCount;
var float   LastVoteTime;
var float   SelectionTime;
var bool    bAdmin;

function Created()
{
   local PlayerReplicationInfo PRI;
   local int i;
   local string s;
   
   TextColor.R = 255;
   TextColor.G = 255;
   TextColor.B = 255;

   //MapCount = 1;

   Super.Created();

   MapListBox = MapVoteListBox(CreateControl(class'MapVoteListBox',10,10,130,110));
   MapListBox.Items.Clear();

   VoteButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton',50,120,40,20));
   VoteButton.DownSound = sound 'UnrealShare.BeltSnd';
   VoteButton.Text= "Vote";
   VoteButton.bDisabled = false;

   lstMapStatus = MapStatusListBox(CreateControl(class'MapStatusListBox',10,150,200,130));
   lstMapStatus.bAcceptsFocus = False;
   lstMapStatus.Items.Clear();

   cbLoadScreenShot = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 230, 120, 70, 20));
   cbLoadScreenShot.SetText("ScreenShot");
   cbLoadScreenShot.Align = TA_Right;
   cbLoadScreenShot.SetFont(F_Normal);
   cbLoadScreenShot.SetTextColor(TextColor);
   cbLoadScreenShot.bChecked = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bLoadScreenShot;

   lblStatusTitles = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 10, 140, 390, 10));
   lblStatusTitles.SetText("Rank Map Name                              Votes");
   lblStatusTitles.SetFont(F_Normal);
   lblStatusTitles.SetTextColor(TextColor);

   lblMapCount = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 95, 120, 70, 10));
   lblMapCount.SetText("");
   lblMapCount.SetFont(F_Normal);
   lblMapCount.SetTextColor(TextColor);

   txtFind = UWindowEditControl(CreateControl(class'UWindowEditControl', -30, 120, 80, 10));
   txtFind.SetNumericOnly(false);
   txtFind.SetText("");

   txtMessage = UWindowEditControl(CreateControl(class'UWindowEditControl', -150, 285, 320, 10));
   txtMessage.SetText("");
   txtMessage.SetNumericOnly(false);
   txtMessage.SetHistory(true);
   txtMessage.SetMaxLength(150);

   SendButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 170, 285, 30, 10));
   SendButton.Text= "Send";
   SendButton.bDisabled = false;

   lblMode = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 210, 290, 100, 20));
   lblMode.SetText("Mode:");
   lblMode.SetFont(F_Normal);
   lblMode.SetTextColor(TextColor);

   CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton',360,285,40,20));
   CloseButton.DownSound = sound 'UnrealShare.WeaponPickup';
   CloseButton.Text= "Close";
   CloseButton.bDisabled = false;
   
   // Gerco: Buttons en labels voor de Insta en NW vote maken.   
   // Instagib votebutton (maakt Shockrifle schiet geluidje)
   btnInstaVote = UWindowSmallButton(CreateControl(class'UWindowSmallButton',230,200,100,20));
   btnInstaVote.DownSound = sound 'UnrealShare.TazerFire';
   btnInstaVote.Text= "Instagib";
   btnInstaVote.bDisabled = false;
   
   // Instagib statuslabel
   lblInstaNumVotes = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 335, 200, 60, 20));
   lblInstaNumVotes.SetText("0 votes");
   lblInstaNumVotes.SetFont(F_Normal);
   lblInstaNumVotes.SetTextColor(TextColor);
   
   // Normal votebutton (maakt raket-laad geluidje)
   btnNWVote = UWindowSmallButton(CreateControl(class'UWindowSmallButton',230,230,100,20));
   btnNWVote.DownSound = sound 'UnrealShare.Loading';
   btnNWVote.Text= "Normal Weapons";
   btnNWVote.bDisabled = false;
   
   // NW statuslabel
   lblNWNumVotes = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 335, 230, 60, 20));
   lblNWNumVotes.SetText("0 votes");
   lblNWNumVotes.SetFont(F_Normal);
   lblNWNumVotes.SetTextColor(TextColor);
}

function SetAdmin(bool bIsAdmin)
{
   local int i;
   local PlayerReplicationInfo PRI;
   local string s;

   bAdmin = bIsAdmin;
	
   // Kick/ban/unban spul 
   if(bAdmin)
   {           
      cmbPlayers = UWindowComboControl(CreateControl(class'UWindowComboControl', 145, 10, 250, 1));
      cmbPlayers.SetText("");
      cmbPlayers.SetFont(F_Normal);
      cmbPlayers.SetEditable(False);
      for(i=0; i<32; i++) {
        PRI = GetPlayerOwner().GameReplicationInfo.PRIArray[i];
        if( PRI != none && Caps(PRI.PlayerName) != "PLAYER") {
	      s = PRI.PlayerName;
	  
 	      if(PRI.bAdmin)
	        s = s $ " (admin)";
	      else if(PRI.bIsSpectator)
	        s = s $ " (spec)";
	     
	      if( !PRI.bIsABot )
		    cmbPlayers.AddItem(s,Right("000" $ PRI.PlayerID, 3));
        }
      }
      
      btnKick = UWindowSmallButton(CreateControl(class'UWindowSmallButton',270,30,45,20));
      btnKick.Text= "Kick";
      btnKick.bDisabled = false;
            
      btnBan = UWindowSmallButton(CreateControl(class'UWindowSmallButton',270,50,45,20));
      btnBan.Text= "Ban";
      btnBan.bDisabled = false;   
      
      txtHours = UWindowEditControl(CreateControl(class'UWindowEditControl',300,50,50,20));
      txtHours.SetNumericOnly(true);
      txtHours.SetHistory(false);
      txtHours.SetMaxLength(4);
      txtHours.SetText("");
      txtHours.SetValue("24");
      
      lblHours = UWindowLabelControl(CreateControl(class'UWindowLabelControl',360,53,100,20));
      lblHours.SetText("Hours");
      lblHours.SetFont(F_Normal);
      lblHours.SetTextColor(TextColor);      
         
      cmbBanned = UWindowComboControl(CreateControl(class'UWindowComboControl',145,80,250,1));
      cmbBanned.SetText("");
      cmbBanned.SetFont(F_Normal);
      cmbBanned.SetEditable(False);
      
      btnUnBan = UWindowSmallButton(CreateControl(class'UWindowSmallButton',270,100,45,20));
      btnUnBan.Text= "UnBan";
      btnUnBan.bDisabled = false;   
   }      	
}

function Notify(UWindowDialogControl C, byte E)
{
   Super.Notify(C,E);

   switch(E)
   {
      case DE_Change:
         switch(C)
         {
            case txtFind:
               MapListBox.Find(txtFind.GetValue());
               break;
         }
         break;

      case DE_DoubleClick:
         switch(C)
         {
            case MapListBox:
               //log("DoubleClick MapListBox");
               if(GetPlayerOwner().Level.TimeSeconds > LastVoteTime + 5) // prevent spamming
               {
                  GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE MAP "$UMenuMapVoteList(MapListBox.SelectedItem).MapName);
                  LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
               }
               SelectionTime = GetPlayerOwner().Level.TimeSeconds; // delays the selection to prevent laggy scolling due to screenshot loading
               break;

            case lstMapStatus:
               //log("DoubleClick lstMapStatus");
               MapListBox.SelectMap(MapStatusListItem(lstMapStatus.SelectedItem).MapName);
               if(GetPlayerOwner().Level.TimeSeconds > LastVoteTime + 5) // prevent spamming
               {
                  GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE MAP "$UMenuMapVoteList(MapListBox.SelectedItem).MapName);
                  LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
               }
               SelectionTime = GetPlayerOwner().Level.TimeSeconds;
               break;
         }
         break;

      case DE_Click:
         switch(C)
         {
            case SendButton:
               if(txtMessage.GetValue() != "")
               {
                  GetPlayerOwner().ConsoleCommand("SAY "$ txtMessage.GetValue());
                  txtMessage.SetValue("");
               }
               break;

            case VoteButton:
               if(GetPlayerOwner().Level.TimeSeconds > LastVoteTime + 5) // prevent spamming
               {
                  if(UMenuMapVoteList(MapListBox.SelectedItem).MapName != "")
                     GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE MAP "$UMenuMapVoteList(MapListBox.SelectedItem).MapName);
                  LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
               }
               break;
               
            // Gerco: Handler voor Insta votebutton
            case btnInstaVote:
               if(GetPlayerOwner().Level.TimeSeconds > LastVoteTime + 3) // prevent spamming
               {
                  GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE INSTAGIB");
                  LastVoteTime = GetPlayerOwner().Level.TimeSeconds;                  
               } 
               break;
            
            // Gerco: Handler voor NW votebutton
            case btnNWVote:     
               if(GetPlayerOwner().Level.TimeSeconds > LastVoteTime + 3) // prevent spamming
               {
                  GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE NORMALWEAPONS");
                  LastVoteTime = GetPlayerOwner().Level.TimeSeconds;                  
               } 
               break;
	    
	    // Gerco: Handler voor Kickbutton
	    case btnKick:
	       if(bAdmin) {	          
	          GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE KICKPLAYER " $ cmbPlayers.GetValue2());
               }
	       break;               	       
            
	    // Gerco: Handler voor Banbutton
	    case btnBan:
	       if(bAdmin) {	          
	          GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE BANPLAYER " $ cmbPlayers.GetValue2() $ " " $ txtHours.GetValue());
               }
	       break;
	       
	    // Gerco: Handler voor UnBan button
            case btnUnBan:
	       if(bAdmin) {
	          GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE UNBAN " $ cmbBanned.GetValue2());
	       }
	       break;
	       	                       
            case CloseButton:
               ParentWindow.ParentWindow.Close();
               break;

            case MapListBox:
               SelectionTime = GetPlayerOwner().Level.TimeSeconds; // delays the selection to prevent laggy scolling due to screenshot loading
               break;

            case lstMapStatus:
               MapListBox.SelectMap(MapStatusListItem(lstMapStatus.SelectedItem).MapName);
               SelectionTime = GetPlayerOwner().Level.TimeSeconds;
               break;

         }
         break;

      case DE_EnterPressed:
         if(txtMessage.GetValue() != "")
         {
            GetPlayerOwner().ConsoleCommand("SAY "$ txtMessage.GetValue());
            txtMessage.SetValue("");
            txtMessage.FocusOtherWindow(SendButton);
         }
         break;
   }
}

function tick(float DeltaTime)
{
   if(SelectionTime != 0 && GetPlayerOwner().Level.TimeSeconds  > SelectionTime + 1)
   {
      SetMap(UMenuMapVoteList(MapListBox.SelectedItem).MapName);
      SelectionTime = 0;
   }
   super.tick(DeltaTime);
}

function SetMap(string MapName)
{
     local int i;
     local LevelSummary L;

     if(!cbLoadScreenShot.bChecked)
        return;

     i = InStr(Caps(MapName), ".UNR");
     if(i != -1)
          MapName = Left(MapName, i);
	  
     // Even de map omnamen naar DM als het TDM of LMS is.
     MapName = TranslateMapName(MapName);    

     Screenshot = Texture(DynamicLoadObject(MapName$".Screenshot", class'Texture'));
     L = LevelSummary(DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary'));
     if(L != None)
     {
          MapTitle = L.Title;
          MapAuthor = L.Author;
          IdealPlayerCount = L.IdealPlayerCount;
     }
     else
     {
          MapTitle = "DownLoad";
          MapAuthor = "Required";
          IdealPlayerCount = "";
     }
}

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

function Paint(Canvas C, float MouseX, float MouseY)
{
     local int i,p1,p2,pos;
     local string TempText,TextLine,WarningText;
     local float X, Y, W, H;

     Super.Paint(C,MouseX,MouseY);

     //DrawStretchedTexture(C, 145, 10, 120, 110, Texture'BlackTexture');

     DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');

     if(Screenshot != None)
     {
          W = Min(100, Screenshot.USize);
          H = Min(100, Screenshot.VSize);
          if(W > H)
               W = H;
          if(H > W)
               H = W;
          C.DrawColor.R = 255;
          C.DrawColor.G = 255;
          C.DrawColor.B = 255;

          DrawStretchedTexture(C, 145, 10, 120, 110, Screenshot);
     }

     C.Font = Root.Fonts[F_Normal];

     if(IdealPlayerCount != "")
     {
        TextSize(C, IdealPlayerCount $ " Players", W, H);
        ClipText(C, 155, 110, IdealPlayerCount $ " Players");
     }

     if(MapAuthor != "")
     {
        TextSize(C, MapAuthor, W, H);
        ClipText(C, 155, 40, MapAuthor);
     }
          
     if(MapTitle != "")
     {
        TextSize(C, MapTitle, W, H);
        ClipText(C, 155, 20, MapTitle);
     }

   if(!bAdmin)
   {          
     // Gerco: Print changelog
     H = printText("Changes in this version:     " , 270, 10,           C);
     H = printText("- 'Random map' option added  " , 270, 10 + (1 * H), C);
     H = printText("                             " , 270, 10 + (2 * H), C);
     H = printText("Changes in last version:     " , 270, 10 + (3 * H), C);
     H = printText("- Ban/Unban by name          " , 270, 10 + (4 * H), C);
     H = printText("                             " , 270, 10 + (5 * H), C);
     H = printText("                             " , 270, 10 + (6 * H), C);
     H = printText("For info or questions, mail  " , 270, 10 + (7 * H), C);
     H = printText("me at gerco@gdries.com       " , 270, 10 + (8 * H), C);
   }
     // Draw Status text
     C.DrawColor.R = 0;
     C.DrawColor.G = 0;
     C.DrawColor.B = 0;
     C.Font = Root.Fonts[F_Normal];
}

function float printText(string Text, float X, float Y, Canvas C)
{
     local float W,H;

     TextSize(C, Text, W, H);
     ClipText(C, X, Y, Text);        

     return H;
}

function KeyDown( int Key, float X, float Y )
{
   ParentWindow.KeyDown(Key,X,Y);
}


function Close(optional bool bByParent)
{
    local int w, Mode;

    class'BDBMapVote3Ex.BDBMapVote3Ex'.default.bLoadScreenShot = cbLoadScreenShot.bChecked;
    class'BDBMapVote3Ex.BDBMapVote3Ex'.static.StaticSaveConfig();
    Super.Close(bByParent);
}

defaultproperties
{
}
