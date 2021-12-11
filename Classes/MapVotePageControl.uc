class MapVotePageControl expands UMenuPageControl;

function KeyDown( int Key, float X, float Y )
{
   super.KeyDown(Key,X,Y);
   ParentWindow.KeyDown(Key,X,Y);
}

defaultproperties
{
}
