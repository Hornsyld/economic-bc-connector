table 51003 "Economic Customer Mapping"
{
    Caption = 'Economic Customer Mapping';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(2; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(3; "Economic Customer Id"; Integer)
        {
            Caption = 'Economic Customer Id';
            DataClassification = CustomerContent;
        }
        field(4; "Economic Customer Number"; Text[50])
        {
            Caption = 'Economic Customer Number';
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
    }

    keys
    {
        key(PK; "Customer No.")
        {
            Clustered = true;
        }
        key(Economic; "Economic Customer Id")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Customer No.", "Customer Name", "Economic Customer Number", "Last Sync DateTime")
        {
        }
    }

    trigger OnInsert()
    begin
        Validate("Sync Status", "Sync Status"::New);
    end;

    trigger OnModify()
    begin
        if xRec."Customer No." <> "Customer No." then
            Validate("Sync Status", "Sync Status"::Modified);
    end;
}