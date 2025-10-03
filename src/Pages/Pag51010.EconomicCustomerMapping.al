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
                // Core e-conomic Information
                field("Economic Customer Number"; Rec."Economic Customer Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number in e-conomic.';
                    StyleExpr = StatusStyleExpr;
                }
                field("Economic Customer Name"; Rec."Economic Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name from e-conomic.';
                    StyleExpr = StatusStyleExpr;
                }
                
                // e-conomic Address Information
                field("Economic Address"; Rec."Economic Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the address from e-conomic.';
                }
                field("Economic City"; Rec."Economic City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city from e-conomic.';
                }
                field("Economic Post Code"; Rec."Economic Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the postal code from e-conomic.';
                }
                field("Economic Country"; Rec."Economic Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country from e-conomic.';
                }
                
                // e-conomic Contact Information
                field("Economic Email"; Rec."Economic Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email from e-conomic.';
                }
                field("Economic Phone"; Rec."Economic Phone")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the phone number from e-conomic.';
                }
                field("Economic Mobile Phone"; Rec."Economic Mobile Phone")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mobile phone number from e-conomic.';
                }
                field("Economic Telephone Fax"; Rec."Economic Telephone Fax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the telephone/fax number from e-conomic.';
                }
                
                // e-conomic Business Information
                field("Economic VAT Number"; Rec."Economic VAT Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the VAT registration number from e-conomic.';
                }
                field("Economic Corporate ID"; Rec."Economic Corporate ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the corporate identification number from e-conomic.';
                }
                field("Economic Customer Group"; Rec."Economic Customer Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer group from e-conomic.';
                }
                field("Economic Currency Code"; Rec."Economic Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency code from e-conomic.';
                }
                field("Economic Payment Terms"; Rec."Economic Payment Terms")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payment terms from e-conomic.';
                }
                field("Economic Payment Terms No."; Rec."Economic Payment Terms No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payment terms number from e-conomic.';
                }
                field("Economic Credit Limit"; Rec."Economic Credit Limit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the credit limit from e-conomic.';
                }
                field("Economic Blocked"; Rec."Economic Blocked")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the customer is blocked in e-conomic.';
                }
                field("Economic Barred"; Rec."Economic Barred")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the customer is barred in e-conomic.';
                }
                
                // Staging Control
                field("Create BC Customer"; Rec."Create BC Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to create a Business Central customer for this e-conomic customer.';
                }
                
                // Business Central Mapping
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mapped Business Central customer number.';

                    trigger OnAssistEdit()
                    begin
                        SuggestCustomerMapping();
                    end;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the mapped Business Central customer.';
                }
                
                // Status Information
                field("Sync Status"; Rec."Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the synchronization status.';
                    StyleExpr = StatusStyleExpr;
                }
                field("Last Sync DateTime"; Rec."Last Sync DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the customer was last synchronized.';
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
                PromotedIsBig = true;
                ToolTip = 'Retrieves customers from e-conomic.';

                trigger OnAction()
                var
                    EconomicMgt: Codeunit "Economic Management";
                begin
                    EconomicMgt.GetCustomers();
                end;
            }
            action(CreateCustomers)
            {
                ApplicationArea = All;
                Caption = 'Create BC Customers';
                Image = NewCustomer;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Creates Business Central customers from selected e-conomic customers.';

                trigger OnAction()
                begin
                    CreateSelectedCustomers();
                end;
            }
            action(CreateAllCustomers)
            {
                ApplicationArea = All;
                Caption = 'Create All Marked Customers';
                Image = CreateForm;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Creates Business Central customers for all e-conomic customers marked for creation.';

                trigger OnAction()
                begin
                    CreateAllMarkedCustomers();
                end;
            }
            action(SuggestMappings)
            {
                ApplicationArea = All;
                Caption = 'Suggest Customer Mappings';
                Image = Suggest;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Suggests Business Central customer numbers for e-conomic customers.';

                trigger OnAction()
                begin
                    SuggestAllCustomerMappings();
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

    local procedure SuggestCustomerMapping()
    var
        SuggestedNo: Code[20];
    begin
        SuggestedNo := Rec.SuggestCustomerNo();
        if SuggestedNo <> '' then begin
            Rec.Validate("Customer No.", SuggestedNo);
            Rec.Modify(true);
            CurrPage.Update(false);
        end;
    end;

    local procedure SuggestAllCustomerMappings()
    var
        EconomicCustomerMapping: Record "Economic Customer Mapping";
        Counter: Integer;
    begin
        // Find records without BC customer numbers
        EconomicCustomerMapping.SetRange("Customer No.", '');
        EconomicCustomerMapping.SetRange("Create BC Customer", true);
        if EconomicCustomerMapping.FindSet(true) then
            repeat
                EconomicCustomerMapping.Validate("Customer No.", EconomicCustomerMapping.SuggestCustomerNo());
                EconomicCustomerMapping.Modify(true);
                Counter += 1;
            until EconomicCustomerMapping.Next() = 0;

        Message('Suggested customer numbers for %1 e-conomic customers.', Counter);
        CurrPage.Update(false);
    end;

    local procedure CreateSelectedCustomers()
    var
        EconomicCustomerMapping: Record "Economic Customer Mapping";
        SelectedRecords: Record "Economic Customer Mapping";
        Counter: Integer;
        SkippedCounter: Integer;
    begin
        CurrPage.SetSelectionFilter(SelectedRecords);
        if not SelectedRecords.FindSet() then begin
            Message('No customers selected.');
            exit;
        end;

        repeat
            EconomicCustomerMapping.Get(SelectedRecords."Economic Customer Id");
            if EconomicCustomerMapping."Create BC Customer" and (EconomicCustomerMapping."Sync Status" <> EconomicCustomerMapping."Sync Status"::Synced) then begin
                if CreateSingleCustomer(EconomicCustomerMapping) then
                    Counter += 1
                else
                    SkippedCounter += 1;
            end else
                SkippedCounter += 1;
        until SelectedRecords.Next() = 0;

        Message('Created %1 customers. Skipped %2 customers.', Counter, SkippedCounter);
        CurrPage.Update(false);
    end;

    local procedure CreateAllMarkedCustomers()
    var
        EconomicCustomerMapping: Record "Economic Customer Mapping";
        Counter: Integer;
        SkippedCounter: Integer;
        TotalRecords: Integer;
        ProcessedRecords: Integer;
        Dialog: Dialog;
    begin
        // Find all records marked for creation that haven't been synced yet
        EconomicCustomerMapping.SetRange("Create BC Customer", true);
        EconomicCustomerMapping.SetFilter("Sync Status", '<>%1', EconomicCustomerMapping."Sync Status"::Synced);
        
        if not EconomicCustomerMapping.FindSet() then begin
            Message('No customers marked for creation found.');
            exit;
        end;

        TotalRecords := EconomicCustomerMapping.Count();
        Dialog.Open('Processing customers #1############ / #2############');

        repeat
            ProcessedRecords += 1;
            Dialog.Update(1, ProcessedRecords);
            Dialog.Update(2, TotalRecords);
            
            if CreateSingleCustomer(EconomicCustomerMapping) then
                Counter += 1
            else
                SkippedCounter += 1;
        until EconomicCustomerMapping.Next() = 0;

        Dialog.Close();
        Message('Created %1 customers. Skipped %2 customers.', Counter, SkippedCounter);
        CurrPage.Update(false);
    end;

    local procedure CreateSingleCustomer(var EconomicCustomerMapping: Record "Economic Customer Mapping"): Boolean
    var
        Customer: Record Customer;
        CountryMapping: Record "Economic Country Mapping";
        NewCustomerNo: Code[20];
    begin
        // If no BC customer number assigned, suggest one
        if EconomicCustomerMapping."Customer No." = '' then begin
            NewCustomerNo := EconomicCustomerMapping.SuggestCustomerNo();
            if NewCustomerNo = '' then
                exit(false);
            EconomicCustomerMapping."Customer No." := NewCustomerNo;
        end else begin
            NewCustomerNo := EconomicCustomerMapping."Customer No.";
        end;
        
        // Check if customer already exists
        if Customer.Get(NewCustomerNo) then begin
            // Update sync status to indicate customer already exists
            EconomicCustomerMapping."Sync Status" := EconomicCustomerMapping."Sync Status"::Synced;
            EconomicCustomerMapping."Last Sync DateTime" := CurrentDateTime;
            EconomicCustomerMapping.Modify(true);
            exit(false);
        end;

        // Create new customer
        Customer.Init();
        Customer."No." := NewCustomerNo;
        Customer.Name := EconomicCustomerMapping."Economic Customer Name";
        Customer.Address := EconomicCustomerMapping."Economic Address";
        Customer.City := EconomicCustomerMapping."Economic City";
        Customer."Post Code" := EconomicCustomerMapping."Economic Post Code";
        Customer."E-Mail" := EconomicCustomerMapping."Economic Email";
        Customer."Phone No." := EconomicCustomerMapping."Economic Phone";
        Customer."VAT Registration No." := EconomicCustomerMapping."Economic VAT Number";
        
        // Map country if available
        if CountryMapping.Get(EconomicCustomerMapping."Economic Country") then
            Customer."Country/Region Code" := CountryMapping."Country/Region Code";

        Customer.Insert(true);
        
        // Update sync status to mark as successfully created
        EconomicCustomerMapping."Sync Status" := EconomicCustomerMapping."Sync Status"::Synced;
        EconomicCustomerMapping."Last Sync DateTime" := CurrentDateTime;
        EconomicCustomerMapping.Modify(true);
        
        exit(true);
    end;
}