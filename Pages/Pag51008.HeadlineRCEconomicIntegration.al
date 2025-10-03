page 51008 "Headline RC Economic Integration"
{
    PageType = HeadlinePart;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field(FirstHeadline; FirstHeadlineText)
            {
                ApplicationArea = All;
                Caption = 'Headline 1';
                Editable = false;
                trigger OnDrillDown()
                begin
                    RefreshHeadlines();
                end;
            }
            field(SecondHeadline; SecondHeadlineText)
            {
                ApplicationArea = All;
                Caption = 'Headline 2';
                Editable = false;
                trigger OnDrillDown()
                begin
                    RefreshHeadlines();
                end;
            }
        }
    }

    var
        FirstHeadlineText: Text;
        SecondHeadlineText: Text;

    trigger OnOpenPage()
    begin
        RefreshHeadlines();
    end;

    local procedure RefreshHeadlines()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Setup: Record "Economic Setup";
        CustomersToSync: Integer;
        VendorsToSync: Integer;
    begin
        if not Setup.Get() then begin
            FirstHeadlineText := 'Welcome to e-conomic Integration';
            SecondHeadlineText := 'Start by setting up your e-conomic credentials';
            exit;
        end;

        // Count customers and vendors that need syncing
        Customer.SetRange("Country/Region Code", '');
        CustomersToSync := Customer.Count;

        Vendor.SetRange("Country/Region Code", '');
        VendorsToSync := Vendor.Count;

        if (CustomersToSync > 0) or (VendorsToSync > 0) then begin
            FirstHeadlineText := StrSubstNo('You have %1 customers and %2 vendors that need attention',
                                          CustomersToSync, VendorsToSync);
            SecondHeadlineText := 'Click to refresh status';
        end else begin
            FirstHeadlineText := 'Everything is up to date';
            SecondHeadlineText := Format(CurrentDateTime, 0, '<Hours24>:<Minutes,2> <Month Text,3> <Day>');
        end;
    end;
}