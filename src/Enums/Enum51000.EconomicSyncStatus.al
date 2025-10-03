enum 51000 "Economic Sync Status"
{
    Extensible = true;

    value(0; New)
    {
        Caption = 'New';
    }
    value(1; Synced)
    {
        Caption = 'Synced';
    }
    value(2; Modified)
    {
        Caption = 'Modified';
    }
    value(3; Error)
    {
        Caption = 'Error';
    }
}