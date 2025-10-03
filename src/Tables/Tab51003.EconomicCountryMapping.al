table 51003 "Economic Country Mapping"
{
    Caption = 'Economic Country Mapping';
    DataClassification = CustomerContent;
    LookupPageId = "Economic Country Mapping";
    DrillDownPageId = "Economic Country Mapping";

    fields
    {
        field(1; "Economic Country Name"; Text[100])
        {
            Caption = 'Economic Country Name';
            DataClassification = CustomerContent;
        }
        field(2; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";

            trigger OnValidate()
            var
                CountryRegion: Record "Country/Region";
            begin
                if "Country/Region Code" <> '' then begin
                    CountryRegion.Get("Country/Region Code");
                    "Country/Region Name" := CountryRegion.Name;
                end else
                    "Country/Region Name" := '';
            end;
        }
        field(3; "Country/Region Name"; Text[100])
        {
            Caption = 'Country/Region Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Country/Region".Name where(Code = field("Country/Region Code")));
            Editable = false;
        }
        field(4; "Auto-Created"; Boolean)
        {
            Caption = 'Auto-Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Customer Count"; Integer)
        {
            Caption = 'Customer Count';
            FieldClass = FlowField;
            CalcFormula = count(Customer where("Country/Region Code" = field("Country/Region Code")));
            Editable = false;
        }
        field(6; "Vendor Count"; Integer)
        {
            Caption = 'Vendor Count';
            FieldClass = FlowField;
            CalcFormula = count(Vendor where("Country/Region Code" = field("Country/Region Code")));
            Editable = false;
        }
        field(7; "Last Used Date"; Date)
        {
            Caption = 'Last Used Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Economic Country Name")
        {
            Clustered = true;
        }
        key(CountryCode; "Country/Region Code")
        {
        }
    }
}