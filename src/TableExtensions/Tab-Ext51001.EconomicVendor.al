tableextension 51001 "Economic Vendor" extends Vendor
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