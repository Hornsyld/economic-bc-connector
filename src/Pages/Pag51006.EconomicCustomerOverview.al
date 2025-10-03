page 51006 "Economic Customer Overview"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Economic Customer Mapping";
    Caption = 'Economic Customer Overview';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
                }
                field("Economic Customer Number"; Rec."Economic Customer Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the e-conomic customer number.';
                }
                field("Sync Status"; Rec."Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the synchronization status.';
                }
                field("Last Sync DateTime"; Rec."Last Sync DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the customer was last synchronized.';
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
                begin
                    // TODO: Implement SyncCustomer method in Economic Management codeunit
                    Message('Sync Customer functionality not yet implemented.');
                end;
            }
            action(SyncAll)
            {
                ApplicationArea = All;
                Caption = 'Sync All';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Synchronize all customers with e-conomic.';

                trigger OnAction()
                begin
                    // TODO: Implement GetCustomers method in Economic Management codeunit
                    if Confirm('Do you want to synchronize all customers with e-conomic?') then
                        Message('Get Customers functionality not yet implemented.');
                end;
            }
            action(UpdatePostingGroups)
            {
                ApplicationArea = All;
                Caption = 'Update Posting Groups';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Update posting groups for the selected customer based on setup.';

                trigger OnAction()
                begin
                    // TODO: Implement UpdateCustomerPostingGroups method in Economic Management codeunit
                    Message('Update Customer Posting Groups functionality not yet implemented.');
                end;
            }
        }
    }
}