page 51004 "Economic Country Mapping"
{
    ApplicationArea = All;
    Caption = 'Economic Country Mapping';
    PageType = List;
    SourceTable = "Economic Country Mapping";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Economic Country Name"; Rec."Economic Country Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country name as it appears in e-conomic.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central country/region code to map to.';
                }
                field("Country/Region Name"; Rec."Country/Region Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Business Central country/region.';
                }
                field("Customer Count"; Rec."Customer Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many customers use this country code.';
                }
                field("Vendor Count"; Rec."Vendor Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many vendors use this country code.';
                }
                field("Auto-Created"; Rec."Auto-Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this mapping was automatically created during synchronization.';
                }
                field("Last Used Date"; Rec."Last Used Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this mapping was last used.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SuggestMappings)
            {
                ApplicationArea = All;
                Caption = 'Suggest Mappings';
                Image = Suggest;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Suggests country mappings based on similar names.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.SuggestCountryMappings();
                end;
            }
            action(ApplyToCustomers)
            {
                ApplicationArea = All;
                Caption = 'Apply to Customers';
                Image = ApplyEntries;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Applies the selected country mapping to matching customers.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.ApplyCountryMappingToCustomers(Rec."Economic Country Name");
                end;
            }
            action(ApplyToVendors)
            {
                ApplicationArea = All;
                Caption = 'Apply to Vendors';
                Image = ApplyEntries;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Applies the selected country mapping to matching vendors.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.ApplyCountryMappingToVendors(Rec."Economic Country Name");
                end;
            }
        }
    }
}