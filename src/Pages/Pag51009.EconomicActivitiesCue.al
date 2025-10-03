page 51009 "Economic Activities Cue"
{
    PageType = CardPart;
    ApplicationArea = All;
    Caption = 'Activities';
    SourceTable = "Economic Activities Cue";

    layout
    {
        area(content)
        {
            cuegroup(Synchronization)
            {
                Caption = 'Synchronization';
                field(CustomersToSync; Rec.CustomersToSync)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Mapping';
                    DrillDownPageId = "Economic Customer Mapping";
                    ToolTip = 'Shows the number of customers that need to be synchronized.';
                }
                field(VendorsToSync; Rec.VendorsToSync)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Mapping';
                    DrillDownPageId = "Economic Vendor Mapping";
                    ToolTip = 'Shows the number of vendors that need to be synchronized.';
                }
                field(CountryMappings; Rec.CountryMappings)
                {
                    ApplicationArea = All;
                    Caption = 'Country Mappings';
                    DrillDownPageId = "Economic Country Mapping";
                    ToolTip = 'Shows the number of country mappings defined.';
                }
            }
            cuegroup("Last 24 Hours")
            {
                Caption = 'Last 24 Hours';
                field(CustomersModified; Rec.CustomersModified)
                {
                    ApplicationArea = All;
                    Caption = 'Customers Modified';
                    DrillDownPageId = "Economic Customer Mapping";
                    ToolTip = 'Shows the number of customers modified in the last 24 hours.';
                }
                field(VendorsModified; Rec.VendorsModified)
                {
                    ApplicationArea = All;
                    Caption = 'Vendors Modified';
                    DrillDownPageId = "Economic Vendor Mapping";
                    ToolTip = 'Shows the number of vendors modified in the last 24 hours.';
                }
                field(IntegrationLogs; Rec.IntegrationLogs)
                {
                    ApplicationArea = All;
                    Caption = 'Integration Logs';
                    DrillDownPageId = "Economic Integration Log";
                    ToolTip = 'Shows the number of integration log entries from the last 24 hours.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('DEFAULT') then begin
            Rec.InitRecord();
            Rec.Insert();
        end;
        Rec.RefreshData();
    end;
}