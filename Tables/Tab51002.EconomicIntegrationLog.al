table 51002 "Economic Integration Log"
{
    Caption = 'Economic Integration Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Date Time"; DateTime)
        {
            Caption = 'Date Time';
        }
        field(3; "Operation"; Text[50])
        {
            Caption = 'Operation';
        }
        field(4; "Status Code"; Integer)
        {
            Caption = 'Status Code';
        }
        field(5; "Status Text"; Text[250])
        {
            Caption = 'Status Text';
        }
        field(6; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
        }
        field(7; "Request URL"; Text[2048])
        {
            Caption = 'Request URL';
        }
        field(8; "Response Data"; Blob)
        {
            Caption = 'Response Data';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}