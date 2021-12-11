class OtherGamemodesWindow expands UWindowPageWindow;

var UWindowCheckBox cbEnabled[10];
var UWindowEditControl txtPackageGameClass[10];
var UWindowEditControl txtMapPrefix[10];

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
    local color c;
	local int i, pos;
	
    Super.Created();

//    DesiredWidth = 400;
//    DesiredHeight = 450;

    lblTableHeader = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 10, 10, WinWidth-20, 20));
    lblTableHeader.SetText("Enabled     Map PreFix    Package.GameClass");

	for (i=0;i<10;i++) {
		pos = 30 + (i * 20);
		
		// Other Gamemode row
		cbEnabled[i] = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 20, pos+2, 20, 20));
		cbEnabled[i].bAcceptsFocus = False;
		
		txtMapPrefix[i] = UWindowEditControl(CreateControl(class'UWindowEditControl', 60, pos, 50, 20));
		txtMapPrefix[i].SetNumericOnly(false);
		txtMapPrefix[i].EditBoxWidth = 50;
		
		
		txtPackageGameClass[i] = UWindowEditControl(CreateControl(class'UWindowEditControl', 120, pos, 200, 20));
		txtPackageGameClass[i].SetNumericOnly(false);
		txtPackageGameClass[i].EditBoxWidth = 200;
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
               //GetPlayerOwner().ConsoleCommand("ADMIN SET BDBMapVote3Ex.BDBMapVote3Ex bDM "$ string(cbLoadDM.bChecked));
               GetPlayerOwner().ConsoleCommand("MUTATE BDBMAPVOTE RELOADMAPS");
               break;
            case cbEnabled[0]:
               if(cbEnabled[0].bChecked)
                  //cbAutoDetect.bChecked = false; todo
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
     DrawStretchedTexture(C, 10, 23, WinWidth-20, 2, Texture'UWindow.WhiteTexture'); // Bovenste lijn onder de tabelheader. was 380
}

defaultproperties
{
}
