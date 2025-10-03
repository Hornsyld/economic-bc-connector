tableextension 51003 "Economic Integration Log Ext" extends "Economic Integration Log"
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
        field(51003; "Request Body"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Body';
        }
        field(51004; "Response Body"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Response Body';
        }
        field(51005; "HTTP Status Code"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'HTTP Status Code';
        }
    }
}