table 51000 "Economic Setup"
{
    Caption = 'Economic Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "API Secret Token"; Text[100])
        {
            Caption = 'API Secret Token';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(3; "Agreement Grant Token"; Text[100])
        {
            Caption = 'Agreement Grant Token';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(4; "Default Journal Template"; Code[10])
        {
            Caption = 'Default Journal Template';
            TableRelation = "Gen. Journal Template";
            DataClassification = CustomerContent;
        }
        field(5; "Default Journal Batch"; Code[10])
        {
            Caption = 'Default Journal Batch';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Default Journal Template"));
            DataClassification = CustomerContent;
        }

        // Entries Processing Configuration
        field(10; "Default GL Account No."; Code[20])
        {
            Caption = 'Default GL Account No.';
            Description = 'Default G/L Account for unmapped e-conomic accounts';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(11; "Entries Journal Template"; Code[10])
        {
            Caption = 'Entries Journal Template';
            Description = 'Journal template for entries processing';
            TableRelation = "Gen. Journal Template";
            DataClassification = CustomerContent;
        }
        field(12; "Auto Create Journal Batches"; Boolean)
        {
            Caption = 'Auto Create Journal Batches';
            Description = 'Automatically create journal batches by posting date';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(13; "Auto Post Journals"; Boolean)
        {
            Caption = 'Auto Post Journals';
            Description = 'Automatically post journals after creation';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(14; "Max Entries Per Batch"; Integer)
        {
            Caption = 'Max Entries Per Batch';
            Description = 'Maximum number of entries per journal batch (0 = unlimited)';
            DataClassification = CustomerContent;
            InitValue = 1000;
        }
        field(15; "Use Date Prefix in Doc No."; Boolean)
        {
            Caption = 'Use Date Prefix in Doc No.';
            Description = 'Prefix document numbers with posting date';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(16; "Default Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Default Bal. Account Type';
            Description = 'Default balancing account type for entries';
            DataClassification = CustomerContent;
        }
        field(17; "Default Bal. Account No."; Code[20])
        {
            Caption = 'Default Bal. Account No.';
            Description = 'Default balancing account number for entries';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                case "Default Bal. Account Type" of
                    "Default Bal. Account Type"::"G/L Account":
                        TestField("Default Bal. Account No.");
                    "Default Bal. Account Type"::Customer:
                        TestField("Default Bal. Account No.");
                    "Default Bal. Account Type"::Vendor:
                        TestField("Default Bal. Account No.");
                    "Default Bal. Account Type"::"Bank Account":
                        TestField("Default Bal. Account No.");
                end;
            end;

            trigger OnLookup()
            var
                GLAccount: Record "G/L Account";
                Customer: Record Customer;
                Vendor: Record Vendor;
                BankAccount: Record "Bank Account";
            begin
                case "Default Bal. Account Type" of
                    "Default Bal. Account Type"::"G/L Account":
                        if PAGE.RunModal(PAGE::"G/L Account List", GLAccount) = ACTION::LookupOK then
                            "Default Bal. Account No." := GLAccount."No.";
                    "Default Bal. Account Type"::Customer:
                        if PAGE.RunModal(PAGE::"Customer List", Customer) = ACTION::LookupOK then
                            "Default Bal. Account No." := Customer."No.";
                    "Default Bal. Account Type"::Vendor:
                        if PAGE.RunModal(PAGE::"Vendor List", Vendor) = ACTION::LookupOK then
                            "Default Bal. Account No." := Vendor."No.";
                    "Default Bal. Account Type"::"Bank Account":
                        if PAGE.RunModal(PAGE::"Bank Account List", BankAccount) = ACTION::LookupOK then
                            "Default Bal. Account No." := BankAccount."No.";
                end;
            end;
        }

        // Entries Period Configuration
        field(20; "Entries Sync From Year"; Integer)
        {
            Caption = 'Entries Sync From Year';
            Description = 'Starting accounting year for entries synchronization (e.g., 2022)';
            DataClassification = CustomerContent;
            MinValue = 2000;
            MaxValue = 9999;

            trigger OnValidate()
            begin
                if "Entries Sync From Year" <> 0 then begin
                    if "Entries Sync To Year" <> 0 then begin
                        if "Entries Sync From Year" > "Entries Sync To Year" then
                            Error('From Year cannot be greater than To Year');
                    end;
                end;
            end;
        }
        field(21; "Entries Sync To Year"; Integer)
        {
            Caption = 'Entries Sync To Year';
            Description = 'Ending accounting year for entries synchronization (0 = current year)';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 9999;

            trigger OnValidate()
            begin
                if "Entries Sync To Year" <> 0 then begin
                    if "Entries Sync From Year" <> 0 then begin
                        if "Entries Sync From Year" > "Entries Sync To Year" then
                            Error('From Year cannot be greater than To Year');
                    end;
                end;
            end;
        }
        field(22; "Entries Sync Years Count"; Integer)
        {
            Caption = 'Entries Sync Years Count';
            Description = 'Number of years to synchronize (alternative to From/To Year setup)';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10;

            trigger OnValidate()
            begin
                if "Entries Sync Years Count" <> 0 then begin
                    "Entries Sync From Year" := 0;
                    "Entries Sync To Year" := 0;
                end;
            end;
        }
        field(23; "Demo Data Year"; Integer)
        {
            Caption = 'Demo Data Year';
            Description = 'Specific year for demo/testing data (e.g., 2022)';
            DataClassification = CustomerContent;
            MinValue = 2000;
            MaxValue = 9999;
            InitValue = 2022;
        }
        field(24; "Use Demo Data Year"; Boolean)
        {
            Caption = 'Use Demo Data Year';
            Description = 'Use demo data year instead of sync period configuration';
            DataClassification = CustomerContent;
            InitValue = true;

            trigger OnValidate()
            begin
                if "Use Demo Data Year" then begin
                    if "Demo Data Year" = 0 then
                        "Demo Data Year" := 2022;
                end;
            end;
        }
        field(25; "Entries Sync Period Filter"; Text[100])
        {
            Caption = 'Entries Sync Period Filter';
            Description = 'Custom period filter for entries API (advanced users)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetAccountingYearsToSync() YearsList: List of [Integer]
    var
        CurrentYear: Integer;
        FromYear: Integer;
        ToYear: Integer;
        i: Integer;
    begin
        // Use demo data year if enabled
        if "Use Demo Data Year" then begin
            YearsList.Add("Demo Data Year");
            exit;
        end;

        CurrentYear := Date2DMY(Today, 3);

        // Use years count approach
        if "Entries Sync Years Count" > 0 then begin
            FromYear := CurrentYear - "Entries Sync Years Count" + 1;
            ToYear := CurrentYear;
        end else begin
            // Use specific from/to years
            FromYear := "Entries Sync From Year";
            if FromYear = 0 then
                FromYear := CurrentYear;

            ToYear := "Entries Sync To Year";
            if ToYear = 0 then
                ToYear := CurrentYear;
        end;

        // Add years to list
        for i := FromYear to ToYear do
            YearsList.Add(i);
    end;

    procedure GetAccountingYearFilter(): Text
    var
        YearsList: List of [Integer];
        Year: Integer;
        FilterText: Text;
    begin
        // Return custom filter if specified
        if "Entries Sync Period Filter" <> '' then
            exit("Entries Sync Period Filter");

        YearsList := GetAccountingYearsToSync();

        foreach Year in YearsList do begin
            if FilterText <> '' then
                FilterText += '|';
            FilterText += Format(Year);
        end;

        exit(FilterText);
    end;

    procedure GetCurrentSyncYear(): Integer
    begin
        if "Use Demo Data Year" then
            exit("Demo Data Year");

        exit(Date2DMY(Today, 3));
    end;

    procedure ValidatePeriodConfiguration(): Boolean
    var
        YearsList: List of [Integer];
    begin
        if "Use Demo Data Year" then begin
            if "Demo Data Year" = 0 then
                exit(false);
            exit(true);
        end;

        if ("Entries Sync Years Count" = 0) and
           ("Entries Sync From Year" = 0) and
           ("Entries Sync To Year" = 0) then
            exit(false);

        YearsList := GetAccountingYearsToSync();
        exit(YearsList.Count > 0);
    end;

    procedure GetEntriesAPIUrlWithFilter(BaseUrl: Text): Text
    var
        YearFilter: Text;
        UrlWithFilter: Text;
    begin
        // e-conomic API uses path structure: /accounting-years/{year}/entries
        // This method is deprecated - use GetEntriesAPIUrls() instead
        YearFilter := GetAccountingYearFilter();
        UrlWithFilter := BaseUrl;

        if YearFilter <> '' then begin
            if UrlWithFilter.Contains('?') then
                UrlWithFilter += '&'
            else
                UrlWithFilter += '?';
            UrlWithFilter += 'filter=accountingYear$in:' + YearFilter;
        end;

        exit(UrlWithFilter);
    end;

    procedure GetEntriesAPIUrls(BaseUrl: Text): List of [Text]
    var
        YearsList: List of [Integer];
        UrlsList: List of [Text];
        Year: Integer;
        YearUrl: Text;
    begin
        YearsList := GetAccountingYearsToSync();

        foreach Year in YearsList do begin
            YearUrl := BaseUrl;
            if not YearUrl.EndsWith('/') then
                YearUrl += '/';
            YearUrl += 'accounting-years/' + Format(Year) + '/entries';

            // Add demo parameter if using demo data year
            if "Use Demo Data Year" and (Year = "Demo Data Year") then
                YearUrl += '?demo=true';

            UrlsList.Add(YearUrl);
        end;

        exit(UrlsList);
    end;

    procedure GetEntriesAPIUrlForYear(BaseUrl: Text; Year: Integer): Text
    var
        YearUrl: Text;
    begin
        YearUrl := BaseUrl;
        if not YearUrl.EndsWith('/') then
            YearUrl += '/';
        YearUrl += 'accounting-years/' + Format(Year) + '/entries';

        // Add demo parameter if using demo data year
        if "Use Demo Data Year" and (Year = "Demo Data Year") then
            YearUrl += '?demo=true';

        exit(YearUrl);
    end;

    procedure GetEntriesAPIFilter(): Text
    var
        YearFilter: Text;
    begin
        YearFilter := GetAccountingYearFilter();

        if YearFilter <> '' then
            exit('accountingYear$in:' + YearFilter);

        exit('');
    end;
}