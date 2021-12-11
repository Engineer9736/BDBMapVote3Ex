class AdminTabWindow expands UWindowScrollingDialogClient;

function Created()
{
     ClientClass = class'AdminWindow';
     FixedAreaClass = none;
     Super.Created();
}

defaultproperties
{
}
