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
                field("Email"; Rec."Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor email address.';
                }
                field("Phone"; Rec."Phone")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor phone number.';
                }
                field("City"; Rec."City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor city.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor currency code.';
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
            action(CreateAllVendors)
            {
                ApplicationArea = All;
                Caption = 'Create All Unsynced Vendors';
                Image = CreateForm;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Creates Business Central vendors for all unsynced e-conomic vendors.';

                trigger OnAction()
                begin
                    CreateAllUnsyncedVendors();
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

    local procedure CreateAllUnsyncedVendors()
    var
        EconomicVendorMapping: Record "Economic Vendor Mapping";
        Counter: Integer;
        SkippedCounter: Integer;
        TotalRecords: Integer;
        ProcessedRecords: Integer;
        Dialog: Dialog;
    begin
        // Find all records that haven't been synced yet
        EconomicVendorMapping.SetFilter("Sync Status", '<>%1', EconomicVendorMapping."Sync Status"::Synced);

        if not EconomicVendorMapping.FindSet() then begin
            Message('No unsynced vendors found.');
            exit;
        end;

        TotalRecords := EconomicVendorMapping.Count();
        Dialog.Open('Processing vendors #1############ / #2############');

        repeat
            ProcessedRecords += 1;
            Dialog.Update(1, ProcessedRecords);
            Dialog.Update(2, TotalRecords);

            if CreateSingleVendor(EconomicVendorMapping) then
                Counter += 1
            else
                SkippedCounter += 1;
        until EconomicVendorMapping.Next() = 0;

        Dialog.Close();
        Message('Created %1 vendors. Skipped %2 vendors.', Counter, SkippedCounter);
        CurrPage.Update(false);
    end;

    local procedure CreateSingleVendor(var EconomicVendorMapping: Record "Economic Vendor Mapping"): Boolean
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        NewVendorNo: Code[20];
        BankAccountCode: Code[20];
    begin
        // The Vendor No. field already contains the e-conomic vendor number
        NewVendorNo := EconomicVendorMapping."Vendor No.";
        if NewVendorNo = '' then
            exit(false); // Should not happen since we set this during API import

        // Check if vendor already exists
        if Vendor.Get(NewVendorNo) then begin
            // Update sync status to indicate vendor already exists
            EconomicVendorMapping."Sync Status" := EconomicVendorMapping."Sync Status"::Synced;
            EconomicVendorMapping."Last Sync DateTime" := CurrentDateTime;
            EconomicVendorMapping.Modify(true);
            exit(false);
        end;

        // Create new vendor with rich data from e-conomic
        Vendor.Init();
        Vendor."No." := NewVendorNo;

        // Use vendor name from the Vendor Name field if available, otherwise use vendor number
        if EconomicVendorMapping."Vendor Name" <> '' then
            Vendor.Name := CopyStr(EconomicVendorMapping."Vendor Name", 1, MaxStrLen(Vendor.Name))
        else
            Vendor.Name := CopyStr(StrSubstNo('e-conomic Vendor %1', EconomicVendorMapping."Vendor No."), 1, MaxStrLen(Vendor.Name));

        // Map contact information
        if EconomicVendorMapping."Email" <> '' then
            Vendor."E-Mail" := CopyStr(EconomicVendorMapping."Email", 1, MaxStrLen(Vendor."E-Mail"));
        if EconomicVendorMapping."Phone" <> '' then
            Vendor."Phone No." := CopyStr(EconomicVendorMapping."Phone", 1, MaxStrLen(Vendor."Phone No."));

        // Map address information
        if EconomicVendorMapping."Address" <> '' then
            Vendor.Address := CopyStr(EconomicVendorMapping."Address", 1, MaxStrLen(Vendor.Address));
        if EconomicVendorMapping."City" <> '' then
            Vendor.City := CopyStr(EconomicVendorMapping."City", 1, MaxStrLen(Vendor.City));
        if EconomicVendorMapping."Post Code" <> '' then
            Vendor."Post Code" := CopyStr(EconomicVendorMapping."Post Code", 1, MaxStrLen(Vendor."Post Code"));
        if EconomicVendorMapping."Country" <> '' then
            Vendor."Country/Region Code" := CopyStr(EconomicVendorMapping."Country", 1, MaxStrLen(Vendor."Country/Region Code"));

        // Map financial information
        if EconomicVendorMapping."Currency Code" <> '' then
            Vendor."Currency Code" := CopyStr(EconomicVendorMapping."Currency Code", 1, MaxStrLen(Vendor."Currency Code"));
        if EconomicVendorMapping."Corporate ID Number" <> '' then
            Vendor."VAT Registration No." := CopyStr(EconomicVendorMapping."Corporate ID Number", 1, MaxStrLen(Vendor."VAT Registration No."));

        Vendor.Insert(true);

        // Create Vendor Bank Account if bank account information is available
        if EconomicVendorMapping."Bank Account" <> '' then begin
            // Use a simple code for the bank account (could be enhanced with more logic)
            BankAccountCode := 'MAIN';

            // Check if bank account already exists
            if not VendorBankAccount.Get(NewVendorNo, BankAccountCode) then begin
                VendorBankAccount.Init();
                VendorBankAccount."Vendor No." := NewVendorNo;
                VendorBankAccount.Code := BankAccountCode;
                VendorBankAccount.Name := CopyStr(StrSubstNo('%1 - Main Account', Vendor.Name), 1, MaxStrLen(VendorBankAccount.Name));
                VendorBankAccount."Bank Account No." := CopyStr(EconomicVendorMapping."Bank Account", 1, MaxStrLen(VendorBankAccount."Bank Account No."));

                VendorBankAccount.Insert(true);

                // Update vendor to use this as the preferred bank account
                Vendor."Preferred Bank Account Code" := BankAccountCode;
                Vendor.Modify(true);
            end;
        end;

        // Update sync status to mark as successfully created
        EconomicVendorMapping."Sync Status" := EconomicVendorMapping."Sync Status"::Synced;
        EconomicVendorMapping."Last Sync DateTime" := CurrentDateTime;
        EconomicVendorMapping.Modify(true);

        exit(true);
    end;
}