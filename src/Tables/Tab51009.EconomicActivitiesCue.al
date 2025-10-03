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
            CalcFormula = count(Customer where("Economic Sync Status" = const(Modified)));
        }
        field(3; VendorsToSync; Integer)
        {
            Caption = 'Vendors to Sync';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(Vendor where("Economic Sync Status" = const(Modified)));
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
            CalcFormula = count(Customer where("Economic Sync Status" = const(New)));
        }
        field(6; VendorsModified; Integer)
        {
            Caption = 'Vendors Modified';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(Vendor where("Economic Sync Status" = const(New)));
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
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }

    procedure RefreshData()
    begin
        LastDateTimeValue := CreateDateTime(Today, 0T) - 1;
        CalcFields(
            CustomersToSync,
            VendorsToSync,
            CountryMappings,
            CustomersModified,
            VendorsModified,
            IntegrationLogs);
        Modify();
    end;

    procedure InitRecord()
    begin
        PrimaryKey := 'DEFAULT';
        LastDateTimeValue := CreateDateTime(Today, 0T) - 1;
    end;
}