table 51009 "Economic Activities Cue"
{
    DataClassification = CustomerContent;
    Caption = 'Economic Activities Cue';

    fields
    {
        field(1; PrimaryKey; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(2; CustomersToSync; Integer)
        {
            Caption = 'Customers to Sync';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic Customer Mapping" where("Sync Status" = filter(<> Synced)));
        }
        field(3; VendorsToSync; Integer)
        {
            Caption = 'Vendors to Sync';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic Vendor Mapping" where("Sync Status" = filter(<> Synced)));
        }
        field(4; CountryMappings; Integer)
        {
            Caption = 'Country Mappings';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic Country Mapping");
        }
        field(5; CustomersModified; Integer)
        {
            Caption = 'Customers Modified';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic Customer Mapping" where("Sync Status" = const(Modified)));
        }
        field(6; VendorsModified; Integer)
        {
            Caption = 'Vendors Modified';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic Vendor Mapping" where("Sync Status" = const(Modified)));
        }
        field(7; IntegrationLogs; Integer)
        {
            Caption = 'Integration Logs';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic Integration Log");
        }
        field(8; LastDateTimeValue; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last DateTime Value';
        }
        
        // Entries Processing Cues
        field(10; "Entries Landing Count"; Integer)
        {
            Caption = 'Entries in Landing';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic Entries Landing");
        }
        field(11; "Entries Processing Count"; Integer)
        {
            Caption = 'Entries in Processing';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic Entry Processing");
        }
        field(12; "Entries Not Validated"; Integer)
        {
            Caption = 'Entries Not Validated';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic Entry Processing" where("Validation Status" = const("Not Validated")));
        }
        field(13; "Entries Validation Errors"; Integer)
        {
            Caption = 'Entries with Errors';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic Entry Processing" where("Validation Status" = const("Validation Error")));
        }
        field(14; "Entries Validated"; Integer)
        {
            Caption = 'Entries Validated';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic Entry Processing" where("Validation Status" = const(Validated)));
        }
        field(15; "GL Account Mappings"; Integer)
        {
            Caption = 'GL Account Mappings';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Economic GL Account Mapping");
        }
        field(16; "Period Config Valid"; Boolean)
        {
            Caption = 'Period Config Valid';
            Editable = false;
            FieldClass = Normal;
        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }

    procedure RefreshData()
    var
        EconomicSetup: Record "Economic Setup";
    begin
        LastDateTimeValue := CreateDateTime(Today, 0T) - 1;
        
        // Validate period configuration
        if EconomicSetup.Get() then
            "Period Config Valid" := EconomicSetup.ValidatePeriodConfiguration()
        else
            "Period Config Valid" := false;
            
        CalcFields(
            CustomersToSync,
            VendorsToSync,
            CountryMappings,
            CustomersModified,
            VendorsModified,
            IntegrationLogs,
            "Entries Landing Count",
            "Entries Processing Count",
            "Entries Not Validated",
            "Entries Validation Errors",
            "Entries Validated",
            "GL Account Mappings");
        Modify();
    end;

    procedure InitRecord()
    begin
        PrimaryKey := 'DEFAULT';
        LastDateTimeValue := CreateDateTime(Today, 0T) - 1;
    end;
}