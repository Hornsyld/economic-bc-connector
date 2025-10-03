page 51005 "Economic Role Center"
{
    PageType = RoleCenter;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Economic Integration Role Center';
    AccessByPermission = tabledata "Economic Setup" = R;
    AdditionalSearchTerms = 'economic,integration,e-conomic,role center';

    layout
    {
        area(RoleCenter)
        {
            part(Headline; "Headline RC Economic")
            {
                ApplicationArea = All;
            }
            part(Activities; "Economic Activities Cue")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action(EconomicSetup)
            {
                ApplicationArea = All;
                Caption = 'Setup';
                Image = Setup;
                RunObject = Page "Economic Setup";
                ToolTip = 'Set up the e-conomic integration.';
            }
            action(Customers)
            {
                ApplicationArea = All;
                Caption = 'Customers';
                Image = Customer;
                RunObject = Page "Economic Customer Overview";
                ToolTip = 'View and manage e-conomic customers.';
            }
            action(Vendors)
            {
                ApplicationArea = All;
                Caption = 'Vendors';
                Image = Vendor;
                RunObject = Page "Economic Vendor Overview";
                ToolTip = 'View and manage e-conomic vendors.';
            }
            action(CountryMapping)
            {
                ApplicationArea = All;
                Caption = 'Country Mapping';
                Image = CountryRegion;
                RunObject = Page "Economic Country Mapping";
                ToolTip = 'Map e-conomic country names to Business Central country codes.';
            }
            action(IntegrationLog)
            {
                ApplicationArea = All;
                Caption = 'Integration Log';
                Image = Log;
                RunObject = Page "Economic Integration Log";
                ToolTip = 'View the integration log.';
            }
        }
        area(Sections)
        {
            group(EconomicConfiguration)
            {
                Caption = 'Setup';
                Image = Setup;
                action(GeneralSetup)
                {
                    ApplicationArea = All;
                    Caption = 'General Setup';
                    Image = Setup;
                    RunObject = Page "Economic Setup";
                    ToolTip = 'Set up the e-conomic integration.';
                }
                action(PostingSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Posting Setup';
                    Image = Setup;
                    RunObject = Page "Economic Setup";
                    ToolTip = 'Set up posting groups for e-conomic integration.';
                }
            }
            group(History)
            {
                Caption = 'History';
                action(ViewLog)
                {
                    ApplicationArea = All;
                    Caption = 'Integration Log';
                    Image = Log;
                    RunObject = Page "Economic Integration Log";
                    ToolTip = 'View the integration log.';
                }
            }
        }
        area(Processing)
        {
            action(SyncAll)
            {
                ApplicationArea = All;
                Caption = 'Sync All';
                Image = Refresh;
                ToolTip = 'Synchronize all data with e-conomic.';
                RunObject = Page "Economic Integration Log";
            }
        }
    }
}