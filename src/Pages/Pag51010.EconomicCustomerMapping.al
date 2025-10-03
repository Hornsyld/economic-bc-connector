page 51010 "Economic Customer Mapping"
{
    ApplicationArea = All;
    Caption = 'Economic Customer Mapping';
    PageType = List;
    SourceTable = "Economic Customer Mapping";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central customer number.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("Economic Customer Id"; Rec."Economic Customer Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer ID in e-conomic.';
                }
                field("Economic Customer Number"; Rec."Economic Customer Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number in e-conomic.';
                }
                field("Last Sync DateTime"; Rec."Last Sync DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the customer was last synchronized with e-conomic.';
                }
                field("Sync Status"; Rec."Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the synchronization status of the customer.';
                    StyleExpr = StatusStyleExpr;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetCustomers)
            {
                ApplicationArea = All;
                Caption = 'Get Customers';
                Image = GetEntries;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Retrieves customers from e-conomic.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.GetCustomers();
                end;
            }
            action(SyncCustomer)
            {
                ApplicationArea = All;
                Caption = 'Sync Customer';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Synchronizes the selected customer with e-conomic.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.SyncCustomer(Rec."Customer No.");
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