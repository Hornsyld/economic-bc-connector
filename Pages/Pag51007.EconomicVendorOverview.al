page 51007 "Economic Vendor Overview"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Vendor;
    Caption = 'Economic Vendor Overview';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor number.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor name.';
                }
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posting group for the vendor.';
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
            part(VendorStatistics; "Vendor Statistics FactBox")
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
                ToolTip = 'Synchronize the selected vendor with e-conomic.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.SyncVendor(Rec."No.");
                end;
            }
            action(SyncAll)
            {
                ApplicationArea = All;
                Caption = 'Sync All';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Synchronize all vendors with e-conomic.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    if Confirm('Do you want to synchronize all vendors with e-conomic?') then
                        EconomicMgt.GetVendors();
                end;
            }
            action(UpdatePostingGroups)
            {
                ApplicationArea = All;
                Caption = 'Update Posting Groups';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Update posting groups for the selected vendor based on setup.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.UpdateVendorPostingGroups(Rec."No.");
                end;
            }
        }
    }
}