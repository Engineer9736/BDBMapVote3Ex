class PlainVScrollBar extends UWindowVScrollBar;

//function Created()
//{
//     Super.Super.Created();
//     UpButton = UWindowSBUpButton(CreateWindow(class'UWindowSBUpButton', 0, 0, 12, 10));
//     DownButton = UWindowSBDownButton(CreateWindow(class'UWindowSBDownButton', 0, WinHeight-10, 12, 10));
//}

//function BeforePaint(Canvas C, float X, float Y)
//{
//     UpButton.WinTop = 0;
//     UpButton.WinLeft = 0;
//     UpButton.WinWidth = LookAndFeel.Size_ScrollbarWidth;
//     UpButton.WinHeight = LookAndFeel.Size_ScrollbarButtonHeight;
//
//     DownButton.WinTop = WinHeight - LookAndFeel.Size_ScrollbarButtonHeight;
//     DownButton.WinLeft = 0;
//     DownButton.WinWidth = LookAndFeel.Size_ScrollbarWidth;
//     DownButton.WinHeight = LookAndFeel.Size_ScrollbarButtonHeight;
//
//     CheckRange();
//}

function Paint(Canvas C, float X, float Y) 
{
   //LookAndFeel.SB_VDraw(Self, C);
   //local Region R;
   //local Texture T;

   //T = GetLookAndFeelTexture();

   //R = SBBackground;
   //SBBackground=(X=4,Y=79,W=1,H=1)
   C.DrawColor.r = 255;
   C.DrawColor.g = 255;
   C.DrawColor.b = 255;

   //left line
   DrawStretchedTexture( C, 0, 0, 1, WinHeight, Texture'UWindow.WhiteTexture');
   //right line
   DrawStretchedTexture( C, WinWidth-1, 0, 1, WinHeight, Texture'UWindow.WhiteTexture');

     
   if(!bDisabled)
   {
     DrawUpBevel( C, 0, ThumbStart, 12, ThumbHeight, Texture'UWindow.WhiteTexture');
   }
}

defaultproperties
{
}
