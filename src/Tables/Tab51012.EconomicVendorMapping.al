table 51012 "Economic Vendor Mapping"
{
    Caption = 'Economic Vendor Mapping';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(2; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            DataClassification = CustomerContent;
        }
        field(5; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Sync Status"; Enum "Economic Sync Status")
        {
            Caption = 'Sync Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        // Contact Information
        field(10; "Email"; Text[250])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(11; "Phone"; Text[30])
        {
            Caption = 'Phone';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        // Address Information
        field(20; "Address"; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(21; "City"; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(22; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(23; "Country"; Text[50])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        // Financial Information
        field(30; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(31; "Bank Account"; Text[50])
        {
            Caption = 'Bank Account';
            DataClassification = CustomerContent;
        }
        field(32; "Payment Terms Number"; Integer)
        {
            Caption = 'Payment Terms Number';
            DataClassification = CustomerContent;
        }
        field(33; "VAT Zone Number"; Integer)
        {
            Caption = 'VAT Zone Number';
            DataClassification = CustomerContent;
        }
        field(34; "Supplier Group Number"; Integer)
        {
            Caption = 'Supplier Group Number';
            DataClassification = CustomerContent;
        }
        field(35; "Corporate ID Number"; Text[40])
        {
            Caption = 'Corporate ID Number';
            DataClassification = CustomerContent;
        }
        // Business Information
        field(40; "Default Invoice Text"; Text[100])
        {
            Caption = 'Default Invoice Text';
            DataClassification = CustomerContent;
        }
        field(41; "Barred"; Boolean)
        {
            Caption = 'Barred';
            DataClassification = CustomerContent;
        }
        field(42; "Layout Number"; Integer)
        {
            Caption = 'Layout Number';
            DataClassification = CustomerContent;
        }
        // Contact References
        field(50; "Attention Contact Number"; Integer)
        {
            Caption = 'Attention Contact Number';
            DataClassification = CustomerContent;
        }
        field(51; "Supplier Contact Number"; Integer)
        {
            Caption = 'Supplier Contact Number';
            DataClassification = CustomerContent;
        }
        field(52; "Sales Person Employee Number"; Integer)
        {
            Caption = 'Sales Person Employee Number';
            DataClassification = CustomerContent;
        }
        field(53; "Cost Account Number"; Integer)
        {
            Caption = 'Cost Account Number';
            DataClassification = CustomerContent;
        }
        // Payment Information
        field(60; "Payment Type Number"; Integer)
        {
            Caption = 'Payment Type Number';
            DataClassification = CustomerContent;
        }
        field(61; "Creditor ID"; Text[50])
        {
            Caption = 'Creditor ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Vendor No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Vendor No.", "Vendor Name", "Email", "City")
        {
        }
        fieldgroup(Brick; "Vendor No.", "Vendor Name", "Currency Code", "Last Sync DateTime")
        {
        }
    }

    trigger OnInsert()
    begin
        "Last Sync DateTime" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last Sync DateTime" := CurrentDateTime;
    end;
}