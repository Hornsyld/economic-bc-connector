page 51030 "Economic Entries Landing List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Economic Entries Landing";
    Caption = 'Economic Entries Landing';
    Editable = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number in the landing table.';
                }
                field("Economic Entry Number"; Rec."Economic Entry Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the original entry number from e-conomic.';
                }
                field("Accounting Year"; Rec."Accounting Year")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the accounting year this entry belongs to.';
                }
                field("Account Number"; Rec."Account Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the e-conomic account number.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total entry amount.';
                }
                field("Amount in Base Currency"; Rec."Amount in Base Currency")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total entry amount in base currency.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ISO 4217 currency code of the entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry issue date.';
                }
                field("Entry Text"; Rec."Entry Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a short description about the entry.';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of entry (customerInvoice, supplierPayment, etc.).';
                }
                field("Voucher Number"; Rec."Voucher Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the identifier of the voucher this entry belongs to.';
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current processing status of this entry.';
                }
                field("Import Date Time"; Rec."Import Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this entry was imported from e-conomic.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncEntriesFromEconomic)
            {
                ApplicationArea = All;
                Caption = 'Sync Entries from e-conomic';
                Image = Refresh;
                ToolTip = 'Synchronize entries from e-conomic API for all configured accounting years.';

                trigger OnAction()
                var
                    EconomicManagement: Codeunit "Economic Management";
                begin
                    EconomicManagement.SyncEntriesFromEconomic();
                    CurrPage.Update();
                end;
            }
            action(ProcessEntry)
            {
                ApplicationArea = All;
                Caption = 'Process Voucher Entries';
                Image = Process;
                ToolTip = 'Create processing records for all entries with the same voucher number and posting date.';

                trigger OnAction()
                var
                    ProcessedCount: Integer;
                begin
                    ProcessedCount := ProcessVoucherEntries(Rec."Voucher Number", Rec."Posting Date");
                    if ProcessedCount > 0 then
                        Message('Processing records created for %1 entries with voucher %2 and posting date %3.', 
                            ProcessedCount, Rec."Voucher Number", Rec."Posting Date")
                    else
                        Message('No entries were processed.');
                    CurrPage.Update();
                end;
            }
            action(ViewRawJSON)
            {
                ApplicationArea = All;
                Caption = 'View Raw JSON';
                Image = FileContract;
                ToolTip = 'View the raw JSON data from e-conomic API.';

                trigger OnAction()
                var
                    JSONText: Text;
                begin
                    JSONText := Rec.GetRawJSONData();
                    if JSONText <> '' then
                        Message(JSONText)
                    else
                        Message('No raw JSON data available for this entry.');
                end;
            }
        }
    }

    local procedure ProcessVoucherEntries(VoucherNumber: Integer; PostingDate: Date) ProcessedCount: Integer
    var
        LandingRec: Record "Economic Entries Landing";
        EconomicEntryProcessing: Record "Economic Entry Processing";
        ExistingProcessingRec: Record "Economic Entry Processing";
    begin
        ProcessedCount := 0;
        
        if VoucherNumber = 0 then
            exit(0);
            
        // Find all entries with the same voucher number and posting date
        LandingRec.SetRange("Voucher Number", VoucherNumber);
        LandingRec.SetRange("Posting Date", PostingDate);
        LandingRec.SetRange("Processing Status", LandingRec."Processing Status"::New);
        
        if LandingRec.FindSet() then
            repeat
                // Check if processing record already exists for this landing entry
                ExistingProcessingRec.SetRange("Landing Entry No.", LandingRec."Entry No.");
                if ExistingProcessingRec.IsEmpty then begin
                    EconomicEntryProcessing.CreateFromLandingRecord(LandingRec);
                    
                    // Update landing record status
                    LandingRec."Processing Status" := LandingRec."Processing Status"::Synced;
                    LandingRec.Modify();
                    
                    ProcessedCount += 1;
                end;
            until LandingRec.Next() = 0;
    end;
}