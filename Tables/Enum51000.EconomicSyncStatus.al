enum 51000 "Economic Sync Status"
{
    Caption = 'Economic Sync Status';
    Extensible = true;

    value(0; "Not Synced")
    {
        Caption = 'Not Synced';
    }
    value(1; "Pending")
    {
        Caption = 'Pending';
    }
    value(2; "Synced")
    {
        Caption = 'Synced';
    }
    value(3; "Failed")
    {
        Caption = 'Failed';
    }
}