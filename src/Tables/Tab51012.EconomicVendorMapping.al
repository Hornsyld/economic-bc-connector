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
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(3; "Economic Vendor Id"; Integer)
        {
            Caption = 'Economic Vendor Id';
            DataClassification = CustomerContent;
        }
        field(4; "Economic Vendor Number"; Text[50])
        {
            Caption = 'Economic Vendor Number';
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
        key(PK; "Vendor No.")
        {
            Clustered = true;
        }
        key(Economic; "Economic Vendor Id")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Vendor No.", "Vendor Name", "Economic Vendor Number", "Last Sync DateTime")
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

    procedure SuggestVendorNo(): Code[20]
    var
        Vendor: Record Vendor;
        SuggestedNo: Code[20];
        Counter: Integer;
    begin
        // Try using economic vendor number first
        if "Economic Vendor Number" <> '' then begin
            SuggestedNo := CopyStr("Economic Vendor Number", 1, 20);
            if not Vendor.Get(SuggestedNo) then
                exit(SuggestedNo);
        end;

        // Generate numbered suggestions
        SuggestedNo := CopyStr(StrSubstNo('VEND%1', "Economic Vendor Id"), 1, 20);
        Counter := 1;
        while Vendor.Get(SuggestedNo) do begin
            Counter += 1;
            SuggestedNo := CopyStr(StrSubstNo('VEND%1-%2', "Economic Vendor Id", Counter), 1, 20);
        end;
        
        exit(SuggestedNo);
    end;
}