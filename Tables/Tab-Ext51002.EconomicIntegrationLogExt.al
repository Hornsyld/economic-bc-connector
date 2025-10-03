tableextension 51002 "Economic Integration Log Ext" extends "Economic Integration Log"
{
    fields
    {
        field(51000; "Request Type"; Enum "Economic Request Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Request Type';
        }
        field(51001; "API Endpoint"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'API Endpoint';
        }
        field(51002; "Request Method"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Method';
            OptionMembers = GET,POST,PUT,PATCH,DELETE;
            OptionCaption = 'GET,POST,PUT,PATCH,DELETE';
        }
    }
}