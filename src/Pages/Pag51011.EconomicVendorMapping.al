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
        NewVendorNo: Code[20];
    begin
        // If no BC vendor number assigned, suggest one
        if EconomicVendorMapping."Vendor No." = '' then begin
            NewVendorNo := EconomicVendorMapping.SuggestVendorNo();
            if NewVendorNo = '' then
                exit(false);
            EconomicVendorMapping."Vendor No." := NewVendorNo;
        end else begin
            NewVendorNo := EconomicVendorMapping."Vendor No.";
        end;
        
        // Check if vendor already exists
        if Vendor.Get(NewVendorNo) then begin
            // Update sync status to indicate vendor already exists
            EconomicVendorMapping."Sync Status" := EconomicVendorMapping."Sync Status"::Synced;
            EconomicVendorMapping."Last Sync DateTime" := CurrentDateTime;
            EconomicVendorMapping.Modify(true);
            exit(false);
        end;

        // Create new vendor
        Vendor.Init();
        Vendor."No." := NewVendorNo;
        Vendor.Name := CopyStr(StrSubstNo('e-conomic Vendor %1', EconomicVendorMapping."Economic Vendor Number"), 1, MaxStrLen(Vendor.Name));
        
        Vendor.Insert(true);
        
        // Update sync status to mark as successfully created
        EconomicVendorMapping."Sync Status" := EconomicVendorMapping."Sync Status"::Synced;
        EconomicVendorMapping."Last Sync DateTime" := CurrentDateTime;
        EconomicVendorMapping.Modify(true);
        
        exit(true);
    end;
}