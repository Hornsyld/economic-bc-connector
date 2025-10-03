page 51006 "Economic Customer Overview"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Customer;
    Caption = 'Economic Customer Overview';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posting group for the customer.';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the general business posting group.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the VAT business posting group.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country/region code.';
                }
                field(County; Rec.County)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the county/state.';
                }
            }
        }
        area(FactBoxes)
        {
            part(CustomerStatistics; "Customer Statistics FactBox")
            {
                ApplicationArea = All;
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncSelected)
            {
                ApplicationArea = All;
                Caption = 'Sync Selected';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Synchronize the selected customer with e-conomic.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.SyncCustomer(Rec."No.");
                end;
            }
            action(SyncAll)
            {
                ApplicationArea = All;
                Caption = 'Sync All';
                Image = RefreshAll;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Synchronize all customers with e-conomic.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    if Confirm('Do you want to synchronize all customers with e-conomic?') then
                        EconomicMgt.GetCustomers();
                end;
            }
            action(UpdatePostingGroups)
            {
                ApplicationArea = All;
                Caption = 'Update Posting Groups';
                Image = PostingSetup;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Update posting groups for the selected customer based on setup.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.UpdateCustomerPostingGroups(Rec."No.");
                end;
            }
        }
    }
}