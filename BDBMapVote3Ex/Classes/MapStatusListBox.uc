class MapStatusListBox expands UWindowListBox;

function Created()
{
     Super.Created();
     VertSB.Close();
     VertSB = UWindowVScrollbar(CreateWindow(class'PlainVScrollBar', WinWidth-12, 0, 12, WinHeight));
}

// |---------------------------------------------|
// |1 | CTF-DarkForest                       |5  |
// |--|--------------------------------------|---|
// |2 | DOM-Shrunk                           |3  |
// |--|--------------------------------------|---|
// |  |                                      |   |
function Paint(Canvas C, float MouseX, float MouseY)
{
   C.DrawColor.r = 255;
   C.DrawColor.g = 255;
   C.DrawColor.b = 255;
   // top outer line
   DrawStretchedTexture(C, 0, 0, WinWidth, 1, Texture'UWindow.WhiteTexture');
   // left outer line
   DrawStretchedTexture(C, 0, 0, 1, WinHeight-1, Texture'UWindow.WhiteTexture');
   // rank divider line
   DrawStretchedTexture(C, 20, 0, 1, WinHeight-1, Texture'UWindow.WhiteTexture');
   // MapName divider line
   DrawStretchedTexture(C, 160, 0, 1, WinHeight-1, Texture'UWindow.WhiteTexture');
   // bottom
   DrawStretchedTexture(C, 0,WinHeight-1, WinWidth, 1, Texture'UWindow.WhiteTexture');

   Super.Paint(C,MouseX,MouseY);
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
     if(MapStatusListItem(Item).bSelected)
     {
          //draw blue background
          C.DrawColor.r = 0;
          C.DrawColor.g = 0;
          C.DrawColor.b = 128;
          DrawStretchedTexture(C, X, Y+1, W, H-2, Texture'UWindow.WhiteTexture');

          //draw white outer bouder lines
          C.DrawColor.r = 255;
          C.DrawColor.g = 255;
          C.DrawColor.b = 255;
          // bottom line
          DrawStretchedTexture(C, X, Y+H-1, W, 1, Texture'UWindow.WhiteTexture');
          // rank divider line
          DrawStretchedTexture(C, 20, Y, 1, H, Texture'UWindow.WhiteTexture');
          // left line
          DrawStretchedTexture(C, 0, Y, 1, H, Texture'UWindow.WhiteTexture');
          // MapName divider line
          DrawStretchedTexture(C, 160, Y, 1, H, Texture'UWindow.WhiteTexture');
     }
     else
     {
          C.DrawColor.r = 255;
          C.DrawColor.g = 255;
          C.DrawColor.b = 255;
          DrawStretchedTexture(C, X, Y+H-1, W, 1, Texture'UWindow.WhiteTexture');
          //DrawStretchedTexture(C, 95, Y, 1, H-1, Texture'UWindow.WhiteTexture');
          //DrawStretchedTexture(C, 0, Y, 1, H, Texture'UWindow.WhiteTexture');
          //DrawStretchedTexture(C, W, Y, 1, H, Texture'UWindow.WhiteTexture');
     }

     C.Font = Root.Fonts[F_Normal];

     ClipText(C, X+5, Y, MapStatusListItem(Item).Rank);
     ClipText(C, X+25, Y, MapStatusListItem(Item).MapName);
     ClipText(C, X+165, Y, MapStatusListItem(Item).VoteCount);
}

function SelectMap(string MapName)
{
   local MapStatusListItem MapItem;

   for(MapItem=MapStatusListItem(Items); MapItem!=None; MapItem=MapStatusListItem(MapItem.Next) )
   {
      if(MapName ~= MapItem.MapName)
      {
         SetSelectedItem(MapItem);
         MakeSelectedVisible();
         break;
      }
   }
}

function DoubleClickItem(UWindowListBoxItem I)
{
   UWindowDialogClientWindow(ParentWindow).Notify(self,DE_DoubleClick);
}

defaultproperties
{
     ItemHeight=13.000000
     ListClass=Class'BDBMapVote3Ex.MapStatusListItem'
}
