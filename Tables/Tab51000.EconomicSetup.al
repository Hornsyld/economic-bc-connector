table 51000 "Economic Setup"
{
    Caption = 'Economic Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "API Secret Token"; Text[100])
        {
            Caption = 'API Secret Token';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(3; "Agreement Grant Token"; Text[100])
        {
            Caption = 'Agreement Grant Token';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(4; "Default Journal Template"; Code[10])
        {
            Caption = 'Default Journal Template';
            TableRelation = "Gen. Journal Template";
            DataClassification = CustomerContent;
        }
        field(5; "Default Journal Batch"; Code[10])
        {
            Caption = 'Default Journal Batch';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Default Journal Template"));
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}