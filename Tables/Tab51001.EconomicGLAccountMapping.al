table 51001 "Economic GL Account Mapping"
{
    Caption = 'Economic GL Account Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "Economic GL Account Mapping";
    LookupPageId = "Economic GL Account Mapping";

    fields
    {
        field(1; "Economic Account No."; Code[20])
        {
            Caption = 'Account No.';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Economic Account Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "BC Account No."; Code[20])
        {
            Caption = 'Mapped To Account No.';
            DataClassification = CustomerContent;
        }
        field(4; "BC Account Name"; Text[100])
        {
            Caption = 'Mapped Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Entry Count"; Integer)
        {
            Caption = 'Entries';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Migration Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = "Not Started","In Progress","Completed","Error";
            OptionCaption = 'Not Started,In Progress,Completed,Error';
            DataClassification = CustomerContent;
        }
        field(7; "Account Type"; Option)
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionMembers = " ",profitAndLoss,status,totalFrom,heading,headingStart,sumInterval,sumAlpha;
            OptionCaption = ' ,Profit/Loss,Status,Total,Heading,Heading Start,Sum Interval,Sum Alpha';
        }
        field(13; "Indentation"; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Total From Account"; Code[20])
        {
            Caption = 'Total From Account';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Economic GL Account Mapping"."Economic Account No." where("Account Type" = const(totalFrom));
        }
        field(8; Balance; Decimal)
        {
            Caption = 'Balance';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Block Direct Entries"; Boolean)
        {
            Caption = 'Block Direct Entries';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Debit Credit"; Code[10])
        {
            Caption = 'Debit Credit';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "VAT Code"; Code[20])
        {
            Caption = 'VAT Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Last Synced"; DateTime)
        {
            Caption = 'Last Synced';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Economic Account No.")
        {
            Clustered = true;
        }
        key(Key2; "BC Account No.") { }
    }
}