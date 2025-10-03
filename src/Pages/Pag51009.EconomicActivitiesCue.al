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
            cuegroup("Entries Processing")
            {
                Caption = 'Entries Processing';
                field("Entries Landing Count"; Rec."Entries Landing Count")
                {
                    ApplicationArea = All;
                    Caption = 'Entries in Landing';
                    ToolTip = 'Shows the number of entries stored in the landing table from e-conomic API.';

                    trigger OnDrillDown()
                    var
                        EconomicEntriesLanding: Record "Economic Entries Landing";
                    begin
                        Page.Run(Page::"Economic Entries Landing List", EconomicEntriesLanding);
                    end;
                }
                field("Entries Processing Count"; Rec."Entries Processing Count")
                {
                    ApplicationArea = All;
                    Caption = 'Entries in Processing';
                    ToolTip = 'Shows the number of entries being processed for Business Central integration.';

                    trigger OnDrillDown()
                    var
                        EconomicEntryProcessing: Record "Economic Entry Processing";
                    begin
                        Page.Run(Page::"Economic Entry Processing List", EconomicEntryProcessing);
                    end;
                }
                field("GL Account Mappings"; Rec."GL Account Mappings")
                {
                    ApplicationArea = All;
                    Caption = 'GL Account Mappings';
                    DrillDownPageId = "Economic GL Account Mapping";
                    ToolTip = 'Shows the number of G/L account mappings configured.';
                }
            }
            cuegroup("Entries Validation")
            {
                Caption = 'Entries Validation Status';
                field("Entries Validated"; Rec."Entries Validated")
                {
                    ApplicationArea = All;
                    Caption = 'Validated Entries';
                    ToolTip = 'Shows the number of entries that have passed validation and are ready for journal creation.';
                    Style = Favorable;

                    trigger OnDrillDown()
                    var
                        EconomicEntryProcessing: Record "Economic Entry Processing";
                    begin
                        EconomicEntryProcessing.SetRange("Validation Status", EconomicEntryProcessing."Validation Status"::Validated);
                        Page.Run(Page::"Economic Entry Processing List", EconomicEntryProcessing);
                    end;
                }
                field("Entries Not Validated"; Rec."Entries Not Validated")
                {
                    ApplicationArea = All;
                    Caption = 'Not Validated';
                    ToolTip = 'Shows the number of entries that have not been validated yet.';
                    Style = Attention;

                    trigger OnDrillDown()
                    var
                        EconomicEntryProcessing: Record "Economic Entry Processing";
                    begin
                        EconomicEntryProcessing.SetRange("Validation Status", EconomicEntryProcessing."Validation Status"::"Not Validated");
                        Page.Run(Page::"Economic Entry Processing List", EconomicEntryProcessing);
                    end;
                }
                field("Entries Validation Errors"; Rec."Entries Validation Errors")
                {
                    ApplicationArea = All;
                    Caption = 'Validation Errors';
                    ToolTip = 'Shows the number of entries with validation errors that need attention.';
                    Style = Unfavorable;

                    trigger OnDrillDown()
                    var
                        EconomicEntryProcessing: Record "Economic Entry Processing";
                    begin
                        EconomicEntryProcessing.SetRange("Validation Status", EconomicEntryProcessing."Validation Status"::"Validation Error");
                        Page.Run(Page::"Economic Entry Processing List", EconomicEntryProcessing);
                    end;
                }
            }
            cuegroup("Configuration")
            {
                Caption = 'Configuration Status';
                field("Period Config Valid"; Rec."Period Config Valid")
                {
                    ApplicationArea = All;
                    Caption = 'Period Config';
                    ToolTip = 'Shows whether the entries period configuration is valid. Click to open setup.';
                    Style = Favorable;
                    StyleExpr = Rec."Period Config Valid";

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Economic Setup");
                    end;
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