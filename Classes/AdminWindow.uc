class AdminWindow expands UWindowPageWindow;

var UWindowCheckBox   cbLoadDM;  // Death Match
var UWindowCheckBox   cbLoadLMS; // Last Man Standing
var UWindowCheckBox   cbLoadTDM; // Team Death Match
var UWindowCheckBox   cbLoadAS;  // Assault
var UWindowCheckBox   cbLoadDOM; // Domination
var UWindowCheckBox   cbLoadCTF; // Capture The Flag
var UWindowCheckBox   cbLoadOther; // Other Custom Game Type
var UWindowCheckBox   cbAutoDetect; // Automatically sets the game type
var UWindowCheckBox   cbCheckOtherGameTie;
var UWindowSmallButton RemoteSaveButton;
var UWindowSmallButton CloseButton;
var UWindowEditControl txtOtherClass;
var UWindowEditControl txtMapPreFixOverRide;
var UWindowHSliderControl sldVoteTimeLimit;
var UMenuLabelControl lblVoteTimeLimit;
var UWindowEditControl txtMinMapCount;
var UWindowHSliderControl sldMidGameVotePercent;
var UWindowComboControl cboMode;

var UMenuLabelControl lblMidGameVotePercent;
var UMenuLabelControl lblGameTypeSection;
var UMenuLabelControl lblMiscSection;
var UMenuLabelControl lblOtherClass;
var UMenuLabelControl lblLimitsLabel;
var UMenuLabelControl lblMapPreFixOverRide;
var UMenuLabelControl lblMinMapCount;

var UWindowCheckBox       cbUseMapList;
var UWindowCheckBox       cbAutoOpen;
var UWindowEditControl    txtExtraMuts;
var UWindowHSliderControl sldScoreBoardDelay;
var UMenuLabelControl     lblScoreBoardDelay;

function Created()
{
    Super.Created();

//    DesiredWidth = 400;
//    DesiredHeight = 450;

    lblGameTypeSection = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 10, 10, 90, 20));
    lblGameTypeSection.SetText("Game Type");

    cbAutoDetect = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 30, 60, 20));
    cbAutoDetect.SetText("Auto Detect");
    cbAutoDetect.SetFont(F_Normal);
    cbAutoDetect.Align = TA_Left;
    cbAutoDetect.SetSize(70, 1);
    cbAutoDetect.bAcceptsFocus = False;

    cbLoadDM = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 90, 30, 60, 20));
    cbLoadDM.SetText("DM");
    cbLoadDM.SetFont(F_Normal);
    cbLoadDM.Align = TA_Left;
    cbLoadDM.SetSize(60, 1);

    cbLoadLMS = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 90, 50, 60, 20));
    cbLoadLMS.SetText("LMS");
    cbLoadLMS.SetFont(F_Normal);
    cbLoadLMS.Align = TA_Left;
    cbLoadLMS.SetSize(60, 1);

    cbLoadTDM = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 90, 70, 60, 20));
    cbLoadTDM.SetText("Team DM");
    cbLoadTDM.SetFont(F_Normal);
    cbLoadTDM.Align = TA_Left;
    cbLoadTDM.SetSize(60, 1);

    cbLoadAS = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 30, 60, 20));
    cbLoadAS.SetText("AS");
    cbLoadAS.SetFont(F_Normal);
    cbLoadAS.Align = TA_Left;
    cbLoadAS.SetSize(45, 1);

    cbLoadDOM = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 50, 60, 20));
    cbLoadDOM.SetText("DOM");
    cbLoadDOM.SetFont(F_Normal);
    cbLoadDOM.Align = TA_Left;
    cbLoadDOM.SetSize(45, 1);

    cbLoadCTF = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 70, 60, 20));
    cbLoadCTF.SetText("CTF");
    cbLoadCTF.SetFont(F_Normal);
    cbLoadCTF.Align = TA_Left;
    cbLoadCTF.SetSize(45, 1);

    cbLoadOther = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 230, 30, 80, 20));
    cbLoadOther.SetText("Other (MODs)");
    cbLoadOther.SetFont(F_Normal);
    cbLoadOther.Align = TA_Left;
    cbLoadOther.SetSize(90, 1);

    txtMapPreFixOverRide = UWindowEditControl(CreateControl(class'UWindowEditControl', 230, 50, 140, 20));
    txtMapPreFixOverRide.SetNumericOnly(false);
    txtMapPreFixOverRide.SetText("Map PreFix OverRide");
    txtMapPreFixOverRide.EditBoxWidth = 40;

    lblOtherClass = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 230, 75, 150, 20));
    lblOtherClass.SetText("Other Game Package.GameClass ");

    txtOtherClass = UWindowEditControl(CreateControl(class'UWindowEditControl', 230, 90, 150, 20));
    txtOtherClass.SetNumericOnly(false);
    txtOtherClass.EditBoxWidth = 150;

    lblLimitsLabel = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 10, 110, 50, 20));
    lblLimitsLabel.SetText("Limits");

    sldVoteTimeLimit = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 10, 130, 170, 20));
    sldVoteTimeLimit.bAcceptsFocus = False;
    sldVoteTimeLimit.MinValue = 20;
    sldVoteTimeLimit.MaxValue = 180;
    sldVoteTimeLimit.Step = 10;
    sldVoteTimeLimit.SetText("Voting Time Limit");

    lblVoteTimeLimit = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 190, 130, 40, 20));
    lblVoteTimeLimit.SetText(String(int(sldVoteTimeLimit.Value)) $ " sec");

    sldScoreBoardDelay = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 10, 170, 180, 20));
    sldScoreBoardDelay.MinValue = 1;
    sldScoreBoardDelay.MaxValue = 30;
    sldScoreBoardDelay.Step = 1;
    sldScoreBoardDelay.SetText("ScoreBoard Delay");

    lblScoreBoardDelay = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 190, 170, 40, 20));
    lblScoreBoardDelay.SetText(String(int(sldScoreBoardDelay.Value)) $ " sec");

    sldMidGameVotePercent = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 10, 190, 185, 20));
    sldMidGameVotePercent.MinValue = 1;
    sldMidGameVotePercent.MaxValue = 100;
    sldMidGameVotePercent.Step = 1;
    sldMidGameVotePercent.SetText("Mid-Game Voter Req.");

    lblMidGameVotePercent = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 195, 190, 40, 20));
    lblMidGameVotePercent.SetText(String(int(sldMidGameVotePercent.Value)) $ " %");

    txtMinMapCount = UWindowEditControl(CreateControl(class'UWindowEditControl', 230, 150, 120, 20));
    txtMinMapCount.SetNumericOnly(true);
    txtMinMapCount.SetText("Reload Map List when");
    txtMinMapCount.EditBoxWidth = 20;

    lblMinMapCount = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 230, 165, 200, 20));
    lblMinMapCount.SetText("maps remain. (Elimiation Mode only)");

    lblMiscSection = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 10, 210, 50, 20));
    lblMiscSection.SetText("Misc.");

    cbUseMapList = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 230, 300, 20));
    cbUseMapList.SetText("Use the Map Cycle List instead of all maps");
    cbUseMapList.SetFont(F_Normal);
    cbUseMapList.Align = TA_Right;
    cbUseMapList.SetSize(200, 1);

    cbAutoOpen = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 250, 300, 20));
    cbAutoOpen.SetText("Open Voting Window at Game End");
    cbAutoOpen.SetFont(F_Normal);
    cbAutoOpen.Align = TA_Right;
    cbAutoOpen.SetSize(200, 1);
		
	txtExtraMuts = UWindowEditControl(CreateControl(class'UWindowEditControl', 10, 270, 250, 20));
    txtExtraMuts.SetNumericOnly(false);
	txtExtraMuts.SetText("Extra Mutator(s):");
    txtExtraMuts.EditBoxWidth = 170;
	
    cbCheckOtherGameTie = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 290, 300, 20));
    cbCheckOtherGameTie.SetText("Check Sudden Death OverTime");
    cbCheckOtherGameTie.SetFont(F_Normal);
    cbCheckOtherGameTie.Align = TA_Right;
    cbCheckOtherGameTie.SetSize(200, 1);

    RemoteSaveButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 340, 270, 40, 20));
    RemoteSaveButton.Text= "Save";

    CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 340, 290, 40, 20));
    CloseButton.Text= "Close";

    cboMode = UWindowComboControl(CreateControl(class'UWindowComboControl', 230, 230, 120, 1));
    cboMode.SetText("Mode");
    cboMode.SetEditable(False);
    cboMode.EditBoxWidth = 90;
    cboMode.AddItem("Majority");
    cboMode.AddItem("Elimination");
    cboMode.AddItem("Score");
    cboMode.AddItem("Accumulation");
}

function Notify(UWindowDialogControl C, byte E)
{
    super.Notify(C, E);
     switch(E)
     {
     case DE_Click:
         switch(C)
         {
            case CloseButton:
               ParentWindow.ParentWindow.ParentWindow.Close();
               break;
            case RemoteSaveButton:
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bDM "$ string(cbLoadDM.bChecked));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bLMS "$ string(cbLoadLMS.bChecked));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bTDM "$ string(cbLoadTDM.bChecked));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bAS "$ string(cbLoadAS.bChecked));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bDOM "$ string(cbLoadDOM.bChecked));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bCTF "$ string(cbLoadCTF.bChecked));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bOther "$ string(cbLoadOther.bChecked));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex OtherClass "$ txtOtherClass.GetValue());
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex VoteTimeLimit "$ string(int(sldVoteTimeLimit.Value)));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bUseMapList "$ string(cbUseMapList.bChecked));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bAutoOpen "$ string(cbAutoOpen.bChecked));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex ScoreBoardDelay "$ string(int(sldScoreBoardDelay.Value)));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bAutoDetect "$ string(cbAutoDetect.bChecked));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bCheckOtherGameTie "$ string(cbCheckOtherGameTie.bChecked));
               // New options for v3
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex MidGameVotePercent "$ string(int(sldMidGameVotePercent.Value)));
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex Mode "$ cboMode.GetValue());
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex MinMapCount "$ txtMinMapCount.GetValue());
               GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex MapPreFixOverRide "$ txtMapPreFixOverRide.GetValue());
			   // New option for ut.tweakers.net
			   GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex ExtraMutators "$ txtExtraMuts.GetValue());
			   
               GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE RELOADMAPS");
               break;
            case cbLoadDM:
               if(cbLoadDM.bChecked)
                  cbAutoDetect.bChecked = false;
               break;
            case cbLoadLMS:
               if(cbLoadLMS.bChecked)
                  cbAutoDetect.bChecked = false;
               break;
            case cbLoadTDM:
               if(cbLoadTDM.bChecked)
                  cbAutoDetect.bChecked = false;
               break;
            case cbLoadAS:
               if(cbLoadAS.bChecked)
                  cbAutoDetect.bChecked = false;
               break;
            case cbLoadCTF:
               if(cbLoadCTF.bChecked)
                  cbAutoDetect.bChecked = false;
               break;
            case cbLoadDOM:
               if(cbLoadDOM.bChecked)
                  cbAutoDetect.bChecked = false;
               break;
            case cbLoadOther:
               if(cbLoadOther.bChecked)
                  cbAutoDetect.bChecked = false;
               break;
            case cbAutoDetect:
               if(cbAutoDetect.bChecked)
               {
                  cbLoadDM.bChecked=false;
                  cbLoadLMS.bChecked=false;
                  cbLoadTDM.bChecked=false;
                  cbLoadAS.bChecked=false;
                  cbLoadCTF.bChecked=false;
                  cbLoadDOM.bChecked=false;
                  cbLoadOther.bChecked=false;
               }
               break;
          }
          break;
     case DE_Change:
         switch(C)
         {
            case sldVoteTimeLimit:
               lblVoteTimeLimit.SetText(String(int(sldVoteTimeLimit.Value)) $ " sec");
               break;
            case sldScoreBoardDelay:
               lblScoreBoardDelay.SetText(String(int(sldScoreBoardDelay.Value)) $ " sec");
               break;
            case sldMidGameVotePercent:
               lblMidGameVotePercent.SetText(String(int(sldMidGameVotePercent.Value)) $ " %");
               break;
         }
         break;
     }
}

function Paint(Canvas C, float MouseX, float MouseY)
{
     Super.Paint(C,MouseX,MouseY);

     C.DrawColor.r = 0;
     C.DrawColor.g = 0;
     C.DrawColor.b = 0;
     DrawStretchedTexture(C, 10, 20, 380, 2, Texture'UWindow.WhiteTexture');
     DrawStretchedTexture(C, 10, 120, 380, 2, Texture'UWindow.WhiteTexture');
     DrawStretchedTexture(C, 10, 220, 380, 2, Texture'UWindow.WhiteTexture');
     DrawStretchedTexture(C, 10, 320, 380, 2, Texture'UWindow.WhiteTexture');
}

defaultproperties
{
}
