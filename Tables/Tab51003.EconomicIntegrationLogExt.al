tableextension 51003 "Economic Integration Log Ext" extends "Integration Log"
{
    fields
    {
        field(51000; "Request Type"; Enum "Economic Request Type")
        {
            Caption = 'Request Type';
            DataClassification = CustomerContent;
        }

        field(51001; "API Endpoint"; Text[250])
        {
            Caption = 'API Endpoint';
            DataClassification = CustomerContent;
        }

        field(51002; "HTTP Method"; Text[10])
        {
            Caption = 'HTTP Method';
            DataClassification = CustomerContent;
        }

        field(51003; "Request Body"; Blob)
        {
            Caption = 'Request Body';
            DataClassification = CustomerContent;
        }

        field(51004; "Response Body"; Blob)
        {
            Caption = 'Response Body';
            DataClassification = CustomerContent;
        }
    }
}