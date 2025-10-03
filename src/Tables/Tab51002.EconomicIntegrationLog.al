table 51002 "Economic Integration Log"
{
    DataClassification = CustomerContent;
    Caption = 'Economic Integration Log';
    LookupPageId = "Economic Integration Log";
    DrillDownPageId = "Economic Integration Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Log Timestamp"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Timestamp';
        }
        field(3; "Event Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Event Type';
            OptionMembers = Information,Warning,Error;
            OptionCaption = 'Information,Warning,Error';
        }
        field(4; "Record Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Record Type';
            OptionMembers = Customer,Vendor,Item,GLAccount;
            OptionCaption = 'Customer,Vendor,Item,G/L Account';
        }
        field(5; "Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Record ID';
        }
        field(6; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(7; "Error Message"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
        }
        field(8; "User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User ID';
        }
        field(9; "Operation"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Operation';
        }
        field(10; "Status Code"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Status Code';
        }
        field(11; "Request URL"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Request URL';
        }
        field(12; "Response Data"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Response Data';
        }
        field(13; "Request Type"; Enum "Economic Request Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Request Type';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(K2; "Log Timestamp")
        {
        }
        key(K3; "Event Type")
        {
        }
        key(K4; "Record Type", "Record ID")
        {
        }
        key(K5; "Operation")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Log Timestamp" = 0DT then
            "Log Timestamp" := CurrentDateTime;
        
        "User ID" := CopyStr(UserId, 1, MaxStrLen("User ID"));
    end;
}