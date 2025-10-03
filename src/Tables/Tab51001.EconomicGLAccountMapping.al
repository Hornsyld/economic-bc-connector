table 51001 "Economic GL Account Mapping"
{
    Caption = 'Economic GL Account Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "Economic GL Account Mapping";
    LookupPageId = "Economic GL Account Mapping";

    fields
    {
        field(1; "Economic Account No."; Code[20])
        {
            Caption = 'Account No.';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Economic Account Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "BC Account No."; Code[20])
        {
            Caption = 'Mapped To Account No.';
            DataClassification = CustomerContent;
        }
        field(4; "BC Account Name"; Text[100])
        {
            Caption = 'Mapped Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Entry Count"; Integer)
        {
            Caption = 'Entries';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Migration Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = "Not Started","In Progress","Completed","Error";
            OptionCaption = 'Not Started,In Progress,Completed,Error';
            DataClassification = CustomerContent;
        }
        field(7; "Account Type"; Option)
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionMembers = " ",profitAndLoss,status,totalFrom,heading,headingStart,sumInterval,sumAlpha;
            OptionCaption = ' ,Profit/Loss,Status,Total,Heading,Heading Start,Sum Interval,Sum Alpha';
        }
        field(13; "Indentation"; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Total From Account"; Code[20])
        {
            Caption = 'Total From Account';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Economic GL Account Mapping"."Economic Account No." where("Account Type" = const(totalFrom));
        }
        field(8; Balance; Decimal)
        {
            Caption = 'Balance';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Block Direct Entries"; Boolean)
        {
            Caption = 'Block Direct Entries';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Debit Credit"; Code[10])
        {
            Caption = 'Debit Credit';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "VAT Code"; Code[20])
        {
            Caption = 'VAT Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Last Synced"; DateTime)
        {
            Caption = 'Last Synced';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Economic Account No.")
        {
            Clustered = true;
        }
        key(Key2; "BC Account No.") { }
        key(Key3; "Migration Status", "Economic Account No.") { }
    }

    procedure GetMappedAccount(EconomicAccountNo: Code[20]): Code[20]
    var
        EconomicSetup: Record "Economic Setup";
    begin
        // Try to find mapping for this account
        if Get(EconomicAccountNo) and ("BC Account No." <> '') then
            exit("BC Account No.");

        // Fallback to default account
        EconomicSetup.Get();
        if EconomicSetup."Default GL Account No." <> '' then
            exit(EconomicSetup."Default GL Account No.");

        // No mapping and no default account
        exit('');
    end;

    procedure CreateMappingFromEconomicAccount(EconomicAccountNo: Code[20]; EconomicAccountName: Text[100]; AccountType: Text; DebitCredit: Code[10]; VATCode: Code[20])
    var
        EconomicGLAccountMapping: Record "Economic GL Account Mapping";
    begin
        EconomicGLAccountMapping.Init();
        EconomicGLAccountMapping."Economic Account No." := EconomicAccountNo;
        EconomicGLAccountMapping."Economic Account Name" := EconomicAccountName;
        EconomicGLAccountMapping."Debit Credit" := DebitCredit;
        EconomicGLAccountMapping."VAT Code" := VATCode;
        
        // Set account type based on e-conomic data
        case AccountType of
            'profitAndLoss':
                EconomicGLAccountMapping."Account Type" := EconomicGLAccountMapping."Account Type"::profitAndLoss;
            'status':
                EconomicGLAccountMapping."Account Type" := EconomicGLAccountMapping."Account Type"::status;
            'totalFrom':
                EconomicGLAccountMapping."Account Type" := EconomicGLAccountMapping."Account Type"::totalFrom;
            'heading':
                EconomicGLAccountMapping."Account Type" := EconomicGLAccountMapping."Account Type"::heading;
            'headingStart':
                EconomicGLAccountMapping."Account Type" := EconomicGLAccountMapping."Account Type"::headingStart;
            'sumInterval':
                EconomicGLAccountMapping."Account Type" := EconomicGLAccountMapping."Account Type"::sumInterval;
            'sumAlpha':
                EconomicGLAccountMapping."Account Type" := EconomicGLAccountMapping."Account Type"::sumAlpha;
            else
                EconomicGLAccountMapping."Account Type" := EconomicGLAccountMapping."Account Type"::" ";
        end;
        
        EconomicGLAccountMapping."Migration Status" := EconomicGLAccountMapping."Migration Status"::"Not Started";
        EconomicGLAccountMapping."Last Synced" := CurrentDateTime;
        
        if not EconomicGLAccountMapping.Insert(true) then
            EconomicGLAccountMapping.Modify(true);
    end;

    procedure ValidateMapping(): Boolean
    var
        GLAccount: Record "G/L Account";
    begin
        if "BC Account No." = '' then
            exit(false);

        exit(GLAccount.Get("BC Account No."));
    end;

    procedure UpdateEntryCount(NewCount: Integer)
    begin
        "Entry Count" := NewCount;
        Modify(true);
    end;

    procedure SetMigrationStatus(NewStatus: Option)
    begin
        "Migration Status" := NewStatus;
        "Last Synced" := CurrentDateTime;
        Modify(true);
    end;
}