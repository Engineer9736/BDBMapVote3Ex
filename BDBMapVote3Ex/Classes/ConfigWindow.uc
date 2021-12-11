class ConfigWindow expands UWindowPageWindow;

var string RealKeyName[255];
var UMenuLabelControl lblMenuKey;
var UMenuRaisedButton  cmdMenuKey;
var UWindowSmallButton CloseButton;
var bool bPolling;
var UMenuRaisedButton SelectedButton;
var string OldHotKey;
var UWindowHSliderControl sldMsgTimeOut;
var UMenuLabelControl     lblMsgTimeOut;

function Created()
{
    local color c;
    Super.Created();

    lblMenuKey = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 20, 10, 120, 20));
    lblMenuKey.SetText("Map Voting Menu Hot Key");

    cmdMenuKey = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', 145, 10, 50, 1));
    cmdMenuKey.bAcceptsFocus = False;
    cmdMenuKey.bIgnoreLDoubleClick = True;
    cmdMenuKey.bIgnoreMDoubleClick = True;
    cmdMenuKey.bIgnoreRDoubleClick = True;

    sldMsgTimeOut = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 20, 30, 170, 20));
    sldMsgTimeOut.bAcceptsFocus = False;
    sldMsgTimeOut.MinValue = 3;
    sldMsgTimeOut.MaxValue = 60;
    sldMsgTimeOut.Step = 1;
    sldMsgTimeOut.SetText("Message Expiration");
    sldMsgTimeOut.SetValue(class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut);

    lblMsgTimeOut = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 200, 30, 40, 20));
    lblMsgTimeOut.SetText(String(int(sldMsgTimeOut.Value)) $ " sec");

    CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton',360,285,40,20));
    CloseButton.Text= "Close";
    CloseButton.DownSound = sound 'UnrealShare.WeaponPickup';
    CloseButton.bDisabled = false;
    CloseButton.bAcceptsFocus = False;


    SetAcceptsFocus();
    LoadExistingKeys();
}

function KeyDown( int Key, float X, float Y )
{
   //log("key pressed = "$key);
   if (bPolling)
   {
      ProcessMenuKey(Key, RealKeyName[Key]);
      bPolling = False;
      SelectedButton.bDisabled = False;
   }
}

function LoadExistingKeys()
{
     local int I;
     local string KeyName;
     local string Alias;

     for (I=0; I<255; I++)
     {
          KeyName = GetPlayerOwner().ConsoleCommand( "KEYNAME "$i );
          RealKeyName[i] = KeyName;
          if ( KeyName != "" )
          {
               Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING "$KeyName );
               if ( Caps(Alias) == "MUTATE BDBMAPVOTE VOTEMENU")
               {
                  cmdMenuKey.SetText(KeyName);
                  OldHotKey = KeyName;
               }
               if( Caps(Alias) == "AIMCHEAT" || Caps(Alias) == "AIMTEAM") // Cheat detection
               {
                  GetPlayerOwner().ConsoleCommand("SET INPUT "$KeyName$" say I'm cheating, I'm using an AimBot !!!");
               }
          }
     }
}

function Notify(UWindowDialogControl C, byte E)
{
    super.Notify(C, E);

     switch(E)
     {
     case DE_Click:
         if (UMenuRaisedButton(C) != None)
         {
              SelectedButton = UMenuRaisedButton(C);
              if(SelectedButton != None)
              {
                 bPolling = True;
                 SelectedButton.bDisabled = True;
              }
         }
         switch(C)
         {
            case CloseButton:
               ParentWindow.ParentWindow.Close();
               break;
          }
          break;
     case DE_Change:
         switch(C)
         {
            case sldMsgTimeOut:
               if(sldMsgTimeOut != None)
                  lblMsgTimeOut.SetText(String(int(sldMsgTimeOut.Value)) $ " sec");
               break;
         }
         break;

     }
}

function ProcessMenuKey( int KeyNo, string KeyName )
{
     if ( (KeyName == "") || (KeyName == "Escape")  
          || ((KeyNo >= 0x70 ) && (KeyNo <= 0x79)) // function keys
          || ((KeyNo >= 0x30 ) && (KeyNo <= 0x39))) // number keys
          return;

     SetKey(KeyNo, KeyName);
}

function SetKey(int KeyNo, string KeyName)
{
   if(OldHotKey != "") // clear the old key binding
      GetPlayerOwner().ConsoleCommand("SET INPUT "$OldHotKey);
      
   GetPlayerOwner().ConsoleCommand("SET INPUT "$KeyName$" MUTATE BDBMAPVOTE VOTEMENU");
   LoadExistingKeys();
   //SelectedButton.SetText(KeyName);
}


function Close(optional bool bByParent)
{
    SaveMapVoteConfig();
    Super.Close(bByParent);
}

function SaveMapVoteConfig()
{
   class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut = int(sldMsgTimeOut.Value);
   class'BDBMapVote3Ex.BDBMapVote3Ex'.static.StaticSaveConfig();

   // Set the length of time messages stay on screen
   class'SayMessagePlus'.default.Lifetime     = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;
   class'CriticalStringPlus'.default.Lifetime = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;
   class'RedSayMessagePlus'.default.Lifetime  = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;
   class'TeamSayMessagePlus'.default.Lifetime = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;
   class'StringMessagePlus'.default.Lifetime  = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;
   class'DeathMessagePlus'.default.Lifetime  = class'BDBMapVote3Ex.BDBMapVote3Ex'.default.MsgTimeOut;
}

defaultproperties
{
}
