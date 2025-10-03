tableextension 51000 "Economic Customer" extends Customer
{
    fields
    {
        field(51000; "Economic Sync Status"; Enum "Economic Sync Status")
        {
            Caption = 'e-conomic Sync Status';
            DataClassification = CustomerContent;
        }
    }
}