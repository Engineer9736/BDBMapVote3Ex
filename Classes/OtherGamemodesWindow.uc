class OtherGamemodesWindow expands UWindowPageWindow;

var UWindowCheckBox cbEnabled[10];
var UWindowEditControl txtMapPrefix[10];
var UWindowEditControl txtPackageGameClass[10];
var UWindowEditControl txtGamemodeDescription[10];

var UWindowSmallButton RemoteSaveButton;
var UWindowSmallButton CloseButton;

var UWindowEditControl txtMapPreFixOverRide;
var UWindowHSliderControl sldVoteTimeLimit;
var UMenuLabelControl lblVoteTimeLimit;
var UWindowEditControl txtMinMapCount;
var UWindowHSliderControl sldMidGameVotePercent;
var UWindowComboControl cboMode;



var UWindowCheckBox       cbUseMapList;
var UWindowCheckBox       cbAutoOpen;
var UWindowEditControl    txtExtraMuts;
var UWindowHSliderControl sldScoreBoardDelay;
var UMenuLabelControl     lblScoreBoardDelay;


var UMenuLabelControl lblTableHeader;

function Created()
{
	local int i, pos;
	
    Super.Created();

//    DesiredWidth = 400;
//    DesiredHeight = 450;

    lblTableHeader = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 10, 10, WinWidth-20, 20));
    lblTableHeader.SetText("Enabled     Map PreFix    Package.GameClass                 Description");

	// Make 10 Other Gamemode rows in the GUI.
	for (i=0;i<10;i++) {
	
		// Calculate the Y position for the current row. 30 offset, and 20 pixels per row.
		pos = 30 + (i * 20);
		
		// Gamemode enabled checkbox
		cbEnabled[i] = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 20, pos+2, 20, 20));
		cbEnabled[i].bAcceptsFocus = False;
		
		// Map prefix textbox
		txtMapPrefix[i] = UWindowEditControl(CreateControl(class'UWindowEditControl', 60, pos, 50, 20));
		txtMapPrefix[i].SetNumericOnly(false);
		txtMapPrefix[i].EditBoxWidth = 50;
		
		// Package & Gameclass textbox
		txtPackageGameClass[i] = UWindowEditControl(CreateControl(class'UWindowEditControl', 120, pos, 130, 20));
		txtPackageGameClass[i].SetNumericOnly(false);
		txtPackageGameClass[i].EditBoxWidth = 130;
		
		// Package & Gameclass textbox
		txtGamemodeDescription[i] = UWindowEditControl(CreateControl(class'UWindowEditControl', 260, pos, 140, 20));
		txtGamemodeDescription[i].SetNumericOnly(false);
		txtGamemodeDescription[i].EditBoxWidth = 140;
	}

	// Save button
    RemoteSaveButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 340, 270, 40, 20));
    RemoteSaveButton.Text= "Save";

	// Close button
    CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 340, 290, 40, 20));
    CloseButton.Text= "Close";
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
               SaveOtherGamemodesConfig();
               GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE RELOADMAPS");
               break;
          }
          break;
     }
}

// Called from the Notify function above.
function SaveOtherGamemodesConfig() {

	local int i;
	
	for (i=0;i<10;i++) {
		if (cbEnabled[i].bChecked) {
			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote4.BDBMapVote4 OtherGamemodesbEnabled " $ i $ " 1");
		}
		else {
			GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote4.BDBMapVote4 OtherGamemodesbEnabled " $ i $ " 0");
		}
		
		GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote4.BDBMapVote4 OtherGamemodesMapPrefix " $ i $ " " $ txtMapPrefix[i].getValue());
		GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote4.BDBMapVote4 OtherGamemodesPackageGameClass " $ i $ " " $ txtPackageGameClass[i].getValue());
		GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote4.BDBMapVote4 OtherGamemodesDescription " $ i $ " " $ txtGamemodeDescription[i].getValue());
	}
}

function Paint(Canvas C, float MouseX, float MouseY)
{
     Super.Paint(C,MouseX,MouseY);

     C.DrawColor.r = 0;
     C.DrawColor.g = 0;
     C.DrawColor.b = 0;
     DrawStretchedTexture(C, 10, 23, WinWidth-20, 2, Texture'UWindow.WhiteTexture'); // Bovenste lijn onder de tabelheader. was 380
}

defaultproperties
{
}
