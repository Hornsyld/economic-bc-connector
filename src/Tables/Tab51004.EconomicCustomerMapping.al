table 51004 "Economic Customer Mapping"
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
        field(7; "Create BC Customer"; Boolean)
        {
            Caption = 'Create BC Customer';
            DataClassification = CustomerContent;
        }
        field(10; "Economic Customer Name"; Text[100])
        {
            Caption = 'Economic Customer Name';
            DataClassification = CustomerContent;
        }
        field(11; "Economic Address"; Text[100])
        {
            Caption = 'Economic Address';
            DataClassification = CustomerContent;
        }
        field(12; "Economic City"; Text[30])
        {
            Caption = 'Economic City';
            DataClassification = CustomerContent;
        }
        field(13; "Economic Post Code"; Code[20])
        {
            Caption = 'Economic Post Code';
            DataClassification = CustomerContent;
        }
        field(14; "Economic Country"; Text[30])
        {
            Caption = 'Economic Country';
            DataClassification = CustomerContent;
        }
        field(15; "Economic Email"; Text[80])
        {
            Caption = 'Economic Email';
            DataClassification = CustomerContent;
        }
        field(16; "Economic Phone"; Text[30])
        {
            Caption = 'Economic Phone';
            DataClassification = CustomerContent;
        }
        field(17; "Economic Mobile Phone"; Text[30])
        {
            Caption = 'Economic Mobile Phone';
            DataClassification = CustomerContent;
        }
        field(18; "Economic Telephone Fax"; Text[30])
        {
            Caption = 'Economic Telephone Fax';
            DataClassification = CustomerContent;
        }
        field(19; "Economic VAT Number"; Text[20])
        {
            Caption = 'Economic VAT Number';
            DataClassification = CustomerContent;
        }
        field(20; "Economic Corporate ID"; Text[20])
        {
            Caption = 'Economic Corporate ID';
            DataClassification = CustomerContent;
        }
        field(21; "Economic Customer Group"; Text[50])
        {
            Caption = 'Economic Customer Group';
            DataClassification = CustomerContent;
        }
        field(22; "Economic Currency Code"; Code[10])
        {
            Caption = 'Economic Currency Code';
            DataClassification = CustomerContent;
        }
        field(23; "Economic Payment Terms"; Text[50])
        {
            Caption = 'Economic Payment Terms';
            DataClassification = CustomerContent;
        }
        field(24; "Economic Payment Terms No."; Integer)
        {
            Caption = 'Economic Payment Terms No.';
            DataClassification = CustomerContent;
        }
        field(25; "Economic Credit Limit"; Decimal)
        {
            Caption = 'Economic Credit Limit';
            DataClassification = CustomerContent;
        }
        field(26; "Economic Blocked"; Boolean)
        {
            Caption = 'Economic Blocked';
            DataClassification = CustomerContent;
        }
        field(27; "Economic Barred"; Boolean)
        {
            Caption = 'Economic Barred';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Economic Customer Id")
        {
            Clustered = true;
        }
        key(Customer; "Customer No.")
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
        Validate("Sync Status", Enum::"Economic Sync Status"::New);
    end;

    trigger OnModify()
    begin
        if xRec."Customer No." <> "Customer No." then
            Validate("Sync Status", Enum::"Economic Sync Status"::Modified);
    end;

    procedure SuggestCustomerNo(): Code[20]
    var
        Customer: Record Customer;
        SuggestedNo: Code[20];
        Counter: Integer;
    begin
        // Try using economic customer number first
        if "Economic Customer Number" <> '' then begin
            SuggestedNo := CopyStr("Economic Customer Number", 1, 20);
            if not Customer.Get(SuggestedNo) then
                exit(SuggestedNo);
        end;

        // Try using economic customer name
        if "Economic Customer Name" <> '' then begin
            SuggestedNo := CopyStr("Economic Customer Name", 1, 20);
            if not Customer.Get(SuggestedNo) then
                exit(SuggestedNo);
        end;

        // Generate numbered suggestions
        SuggestedNo := CopyStr(StrSubstNo('ECON%1', "Economic Customer Id"), 1, 20);
        Counter := 1;
        while Customer.Get(SuggestedNo) do begin
            Counter += 1;
            SuggestedNo := CopyStr(StrSubstNo('ECON%1-%2', "Economic Customer Id", Counter), 1, 20);
        end;
        
        exit(SuggestedNo);
    end;
}