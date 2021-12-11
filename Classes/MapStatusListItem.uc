class MapStatusListItem expands UWindowListBoxItem;

var int    Rank;
var string MapName;
var int    VoteCount;

function int Compare(UWindowList T, UWindowList B)
{
     if(Caps(MapStatusListItem(T).MapName) < Caps(MapStatusListItem(B).MapName))
          return -1;
     return 1;
}

defaultproperties
{
}
