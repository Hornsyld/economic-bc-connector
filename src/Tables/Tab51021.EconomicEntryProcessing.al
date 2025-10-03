table 51021 "Economic Entry Processing"
{
    Caption = 'Economic Entry Processing';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Landing Entry No."; Integer)
        {
            Caption = 'Landing Entry No.';
            Description = 'Reference to the Economic Entries Landing record';
            TableRelation = "Economic Entries Landing";
        }
        field(3; "Economic Entry Number"; Integer)
        {
            Caption = 'Economic Entry Number';
            Description = 'Original entry number from e-conomic';
        }
        field(4; "Accounting Year"; Integer)
        {
            Caption = 'Accounting Year';
            Description = 'The accounting year this entry belongs to';
        }

        // Business Central Mapping
        field(10; "BC Document No."; Code[20])
        {
            Caption = 'BC Document No.';
            Description = 'Business Central document number for this entry';
        }
        field(11; "BC Journal Template"; Code[10])
        {
            Caption = 'BC Journal Template';
            Description = 'Business Central journal template to use';
            TableRelation = "Gen. Journal Template";
        }
        field(12; "BC Journal Batch"; Code[10])
        {
            Caption = 'BC Journal Batch';
            Description = 'Business Central journal batch to use';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("BC Journal Template"));
        }
        field(13; "BC Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'BC Account Type';
            Description = 'Business Central account type (G/L Account, Customer, Vendor)';
        }
        field(14; "BC Account No."; Code[20])
        {
            Caption = 'BC Account No.';
            Description = 'Business Central account number';
        }
        field(15; "BC Bal Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'BC Bal Account Type';
            Description = 'Business Central balancing account type';
        }
        field(16; "BC Bal Account No."; Code[20])
        {
            Caption = 'BC Bal Account No.';
            Description = 'Business Central balancing account number';
        }

        // Entry Data
        field(20; "Economic Account Number"; Integer)
        {
            Caption = 'Economic Account Number';
            Description = 'Original e-conomic account number';
        }
        field(21; Amount; Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 2 : 5;
            Description = 'Entry amount';
        }
        field(22; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DecimalPlaces = 2 : 5;
            Description = 'Entry amount in local currency';
        }
        field(23; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Description = 'Currency code';
            TableRelation = Currency;
        }
        field(24; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Description = 'Entry posting date';
        }
        field(25; "Due Date"; Date)
        {
            Caption = 'Due Date';
            Description = 'Due date if applicable';
        }
        field(26; "Document Date"; Date)
        {
            Caption = 'Document Date';
            Description = 'Document date if applicable';
        }
        field(27; Description; Text[100])
        {
            Caption = 'Description';
            Description = 'Entry description';
        }
        field(28; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            Description = 'External document number';
        }
        field(29; "Economic Voucher Number"; Integer)
        {
            Caption = 'Economic Voucher Number';
            Description = 'Original e-conomic voucher number';
        }

        // VAT Information
        field(30; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            Description = 'VAT Business Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(31; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            Description = 'VAT Product Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(32; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
            Description = 'VAT percentage';
        }
        field(33; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DecimalPlaces = 2 : 5;
            Description = 'VAT amount';
        }
        field(34; "VAT Base Amount"; Decimal)
        {
            Caption = 'VAT Base Amount';
            DecimalPlaces = 2 : 5;
            Description = 'VAT base amount';
        }
        field(35; "Economic VAT Code"; Code[10])
        {
            Caption = 'Economic VAT Code';
            Description = 'Original e-conomic VAT code';
        }

        // Customer/Vendor Information
        field(40; "Economic Customer No."; Integer)
        {
            Caption = 'Economic Customer No.';
            Description = 'e-conomic customer number';
        }
        field(41; "Economic Supplier No."; Integer)
        {
            Caption = 'Economic Supplier No.';
            Description = 'e-conomic supplier number';
        }
        field(42; "BC Customer No."; Code[20])
        {
            Caption = 'BC Customer No.';
            Description = 'Business Central customer number';
            TableRelation = Customer;
        }
        field(43; "BC Vendor No."; Code[20])
        {
            Caption = 'BC Vendor No.';
            Description = 'Business Central vendor number';
            TableRelation = Vendor;
        }

        // Dimensions
        field(50; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
            CaptionClass = '1,2,1';
            Description = 'Shortcut dimension 1 code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(51; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            CaptionClass = '1,2,2';
            Description = 'Shortcut dimension 2 code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(52; "Economic Project No."; Integer)
        {
            Caption = 'Economic Project No.';
            Description = 'e-conomic project number';
        }

        // Processing Status
        field(90; "Validation Status"; Option)
        {
            Caption = 'Validation Status';
            Description = 'Validation status of this entry';
            OptionMembers = "Not Validated","Validated","Validation Error";
            OptionCaption = 'Not Validated,Validated,Validation Error';
        }
        field(91; "Validation Error"; Text[250])
        {
            Caption = 'Validation Error';
            Description = 'Validation error message if any';
        }
        field(92; "Journal Lines Created"; Boolean)
        {
            Caption = 'Journal Lines Created';
            Description = 'Indicates if journal lines have been created';
        }
        field(93; "Journal Lines Posted"; Boolean)
        {
            Caption = 'Journal Lines Posted';
            Description = 'Indicates if journal lines have been posted';
        }
        field(94; "Processing Date Time"; DateTime)
        {
            Caption = 'Processing Date Time';
            Description = 'When this record was processed';
        }
        field(95; "Import Session ID"; Guid)
        {
            Caption = 'Import Session ID';
            Description = 'Reference to import session';
        }
        field(96; "Created By User ID"; Code[50])
        {
            Caption = 'Created By User ID';
            Description = 'User who created this processing record';
            TableRelation = User."User Name";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(LandingRef; "Landing Entry No.")
        {
        }
        key(EconomicEntry; "Economic Entry Number", "Accounting Year")
        {
        }
        key(DocNo; "BC Document No.", "Posting Date")
        {
        }
        key(Validation; "Validation Status", "Import Session ID")
        {
        }
        key(Journal; "BC Journal Template", "BC Journal Batch", "Posting Date")
        {
        }
    }

    trigger OnInsert()
    begin
        "Processing Date Time" := CurrentDateTime;
        "Created By User ID" := CopyStr(UserId, 1, MaxStrLen("Created By User ID"));
        if "Validation Status" = "Validation Status"::"Not Validated" then
            "Validation Status" := "Validation Status"::"Not Validated";
    end;

    procedure ValidateEntry(): Boolean
    var
        EconomicSetup: Record "Economic Setup";
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Currency: Record Currency;
        IsValid: Boolean;
    begin
        ClearLastError();
        "Validation Error" := '';
        IsValid := true;

        EconomicSetup.Get();

        // Validate dates
        if "Posting Date" = 0D then begin
            "Validation Error" := 'Posting Date is required';
            IsValid := false;
        end;

        // Validate amount
        if Amount = 0 then begin
            "Validation Error" := 'Amount cannot be zero';
            IsValid := false;
        end;

        // Validate account mapping
        if "BC Account No." = '' then begin
            // Try to map economic account to BC G/L Account
            "BC Account No." := GetMappedBCAccount();
            if "BC Account No." = '' then begin
                "Validation Error" := 'No BC Account mapping found for Economic Account ' + Format("Economic Account Number");
                IsValid := false;
            end;
        end;

        if "BC Account No." <> '' then begin
            case "BC Account Type" of
                "BC Account Type"::"G/L Account":
                    begin
                        if not GLAccount.Get("BC Account No.") then begin
                            "Validation Error" := StrSubstNo('G/L Account %1 does not exist', "BC Account No.");
                            IsValid := false;
                        end;
                    end;
                "BC Account Type"::Customer:
                    begin
                        if not Customer.Get("BC Customer No.") then begin
                            "Validation Error" := StrSubstNo('Customer %1 does not exist', "BC Customer No.");
                            IsValid := false;
                        end;
                    end;
                "BC Account Type"::Vendor:
                    begin
                        if not Vendor.Get("BC Vendor No.") then begin
                            "Validation Error" := StrSubstNo('Vendor %1 does not exist', "BC Vendor No.");
                            IsValid := false;
                        end;
                    end;
            end;
        end;

        // Validate currency
        if "Currency Code" <> '' then begin
            if not Currency.Get("Currency Code") then begin
                "Validation Error" := StrSubstNo('Currency %1 does not exist', "Currency Code");
                IsValid := false;
            end;
        end;

        // Validate journal template and batch
        if ("BC Journal Template" = '') or ("BC Journal Batch" = '') then begin
            "Validation Error" := 'Journal Template and Batch are required';
            IsValid := false;
        end;

        if IsValid then
            "Validation Status" := "Validation Status"::Validated
        else
            "Validation Status" := "Validation Status"::"Validation Error";

        exit(IsValid);
    end;

    procedure GetMappedBCAccount(): Code[20]
    var
        EconomicGLAccountMapping: Record "Economic GL Account Mapping";
    begin
        exit(EconomicGLAccountMapping.GetMappedAccount(Format("Economic Account Number")));
    end;

    procedure CreateFromLandingRecord(LandingRec: Record "Economic Entries Landing")
    var
        EconomicSetup: Record "Economic Setup";
        ExistingRec: Record "Economic Entry Processing";
    begin
        // Check if a processing record already exists for this landing entry
        ExistingRec.SetRange("Landing Entry No.", LandingRec."Entry No.");
        if not ExistingRec.IsEmpty then
            exit; // Record already exists, don't create duplicate

        Init();

        // Set next entry number
        "Entry No." := GetNextEntryNo();

        // Link to landing record
        "Landing Entry No." := LandingRec."Entry No.";
        "Economic Entry Number" := LandingRec."Economic Entry Number";
        "Posting Date" := LandingRec."Posting Date";

        // Copy economic data
        "Economic Account Number" := LandingRec."Account Number";
        Amount := LandingRec.Amount;
        "Amount (LCY)" := LandingRec."Amount in Base Currency";
        "Currency Code" := LandingRec."Currency Code";
        Description := CopyStr(LandingRec."Entry Text", 1, MaxStrLen(Description));
        "External Document No." := LandingRec."External Document No.";
        "Economic Voucher Number" := LandingRec."Voucher Number";

        // Set processing defaults
        EconomicSetup.Get();
        "BC Journal Template" := EconomicSetup."Entries Journal Template";
        if "BC Journal Template" = '' then
            "BC Journal Template" := EconomicSetup."Default Journal Template";

        // Set account type as G/L Account by default
        "BC Account Type" := "BC Account Type"::"G/L Account";

        // Set initial status
        "Validation Status" := "Validation Status"::"Not Validated";

        Insert(true);
    end;

    local procedure GetNextEntryNo(): Integer
    var
        EconomicEntryProcessing: Record "Economic Entry Processing";
    begin
        EconomicEntryProcessing.SetCurrentKey("Entry No.");
        if EconomicEntryProcessing.FindLast() then
            exit(EconomicEntryProcessing."Entry No." + 1)
        else
            exit(1);
    end;

    procedure CreateJournalLines(): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        LineNo: Integer;
    begin
        if "Validation Status" <> "Validation Status"::Validated then
            exit(false);

        if "Journal Lines Created" then
            exit(true);

        // Get journal batch
        if not GenJournalBatch.Get("BC Journal Template", "BC Journal Batch") then
            exit(false);

        // Get next line number
        GenJournalLine.SetRange("Journal Template Name", "BC Journal Template");
        GenJournalLine.SetRange("Journal Batch Name", "BC Journal Batch");
        if GenJournalLine.FindLast() then
            LineNo := GenJournalLine."Line No." + 10000
        else
            LineNo := 10000;

        // Create journal line
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := "BC Journal Template";
        GenJournalLine."Journal Batch Name" := "BC Journal Batch";
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Posting Date" := "Posting Date";
        GenJournalLine."Document Date" := "Document Date";
        GenJournalLine."Document No." := "BC Document No.";
        GenJournalLine."External Document No." := "External Document No.";
        GenJournalLine."Account Type" := "BC Account Type";

        case "BC Account Type" of
            "BC Account Type"::"G/L Account":
                GenJournalLine."Account No." := "BC Account No.";
            "BC Account Type"::Customer:
                GenJournalLine."Account No." := "BC Customer No.";
            "BC Account Type"::Vendor:
                GenJournalLine."Account No." := "BC Vendor No.";
        end;

        GenJournalLine.Description := CopyStr(Description, 1, MaxStrLen(GenJournalLine.Description));
        GenJournalLine.Amount := Amount;
        GenJournalLine."Currency Code" := "Currency Code";
        GenJournalLine."Due Date" := "Due Date";

        // Set VAT information
        if "VAT Bus. Posting Group" <> '' then
            GenJournalLine."VAT Bus. Posting Group" := "VAT Bus. Posting Group";
        if "VAT Prod. Posting Group" <> '' then
            GenJournalLine."VAT Prod. Posting Group" := "VAT Prod. Posting Group";

        // Set dimensions
        if "Shortcut Dimension 1 Code" <> '' then
            GenJournalLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
        if "Shortcut Dimension 2 Code" <> '' then
            GenJournalLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";

        // Set balancing account if specified
        if ("BC Bal Account Type" <> "BC Bal Account Type"::"G/L Account") and ("BC Bal Account No." <> '') then begin
            GenJournalLine."Bal. Account Type" := "BC Bal Account Type";
            GenJournalLine."Bal. Account No." := "BC Bal Account No.";
        end;

        GenJournalLine.Insert(true);

        "Journal Lines Created" := true;
        Modify();

        exit(true);
    end;

    procedure GetStatusText(): Text[50]
    begin
        case "Validation Status" of
            "Validation Status"::"Not Validated":
                exit('Not Validated');
            "Validation Status"::Validated:
                if "Journal Lines Created" then
                    if "Journal Lines Posted" then
                        exit('Posted')
                    else
                        exit('Journal Lines Created')
                else
                    exit('Validated');
            "Validation Status"::"Validation Error":
                exit('Validation Error');
        end;
    end;
}