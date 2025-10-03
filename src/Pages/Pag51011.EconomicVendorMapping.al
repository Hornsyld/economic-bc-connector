page 51011 "Economic Vendor Mapping"
{
    ApplicationArea = All;
    Caption = 'Economic Vendor Mapping';
    PageType = List;
    SourceTable = "Economic Vendor Mapping";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central vendor number.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the vendor.';
                }
                field("Economic Vendor Id"; Rec."Economic Vendor Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor ID in e-conomic.';
                }
                field("Economic Vendor Number"; Rec."Economic Vendor Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor number in e-conomic.';
                }
                field("Last Sync DateTime"; Rec."Last Sync DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the vendor was last synchronized with e-conomic.';
                }
                field("Sync Status"; Rec."Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the synchronization status of the vendor.';
                    StyleExpr = StatusStyleExpr;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetVendors)
            {
                ApplicationArea = All;
                Caption = 'Get Vendors';
                Image = GetEntries;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Retrieves vendors from e-conomic.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.GetVendors();
                end;
            }
            action(SyncVendor)
            {
                ApplicationArea = All;
                Caption = 'Sync Vendor';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Synchronizes the selected vendor with e-conomic.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.SyncVendor(Rec."Vendor No.");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;

    var
        StatusStyleExpr: Text;

    local procedure SetStatusStyle()
    begin
        case Rec."Sync Status" of
            Rec."Sync Status"::New:
                StatusStyleExpr := 'Attention';
            Rec."Sync Status"::Modified:
                StatusStyleExpr := 'Ambiguous';
            Rec."Sync Status"::Error:
                StatusStyleExpr := 'Unfavorable';
            else
                StatusStyleExpr := 'Favorable';
        end;
    end;
}