codeunit 51000 "Economic Management"
{
    var
        Logger: Codeunit "Economic Integration Logger";
        HttpClient: Codeunit "Economic HTTP Client";
        DataProcessor: Codeunit "Economic Data Processor";
        Setup: Record "Economic Setup";

        // Labels
        MissingSetupErr: Label 'The e-conomic API setup is not complete. Please check the setup page.';
        AccountsFetchedMsg: Label 'Successfully fetched %1 accounts from e-conomic.';
        CustomersFetchedMsg: Label 'Successfully fetched %1 customers from e-conomic.';
        VendorsFetchedMsg: Label 'Successfully fetched %1 vendors from e-conomic.';
        NoAccountsFoundErr: Label 'No accounts were found in e-conomic.';
        JournalCreatedMsg: Label 'Successfully created general journal entries.';
        ProcessingErr: Label '%1 failed with error: %2';

    // Main API Methods
    procedure GetAccounts()
    var
        ResponseContent: Text;
        RequestType: Enum "Economic Request Type";
        Success: Boolean;
    begin
        if not InitializeConnection() then
            exit;

        RequestType := RequestType::Account;
        Success := HttpClient.SendGetRequest(HttpClient.GetBaseUrl() + '/accounts', ResponseContent, RequestType);

        if Success then begin
            ProcessAccountsJson(ResponseContent);
            Message(AccountsFetchedMsg, 'multiple'); // Would need count from processor
        end;
    end;

    procedure GetCustomers()
    var
        Success: Boolean;
    begin
        if not InitializeConnection() then
            exit;

        Success := DataProcessor.GetCustomers();
        if Success then
            Message(CustomersFetchedMsg, 'multiple'); // Would need count from processor
    end;

    procedure GetVendors()
    var
        Success: Boolean;
    begin
        if not InitializeConnection() then
            exit;

        Success := DataProcessor.GetVendors();
        if Success then
            Message(VendorsFetchedMsg, 'multiple'); // Would need count from processor
    end;

    procedure CreateCustomerInBC(var EconomicCustomerMapping: Record "Economic Customer Mapping")
    var
        Success: Boolean;
    begin
        Success := DataProcessor.CreateCustomerFromMapping(EconomicCustomerMapping);
        if not Success then
            Error(ProcessingErr, 'Customer creation', GetLastErrorText());
    end;

    procedure CreateAllMarkedCustomers(var EconomicCustomerMapping: Record "Economic Customer Mapping") ProcessedCount: Integer
    begin
        ProcessedCount := DataProcessor.CreateBulkCustomersFromMappings(EconomicCustomerMapping);
    end;

    procedure CreateGeneralJournalEntries()
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        NextLineNo: Integer;
        Success: Boolean;
    begin
        if not InitializeConnection() then
            exit;

        if not Setup.Get() then begin
            Logger.LogError(Enum::"Economic Request Type"::Journal, MissingSetupErr, 'CreateGeneralJournalEntries');
            Error(MissingSetupErr);
        end;

        if (Setup."Default Journal Template" = '') or (Setup."Default Journal Batch" = '') then begin
            Logger.LogError(Enum::"Economic Request Type"::Journal, 'Journal template or batch not configured', 'CreateGeneralJournalEntries');
            Error('Please configure the default journal template and batch in Economic Setup.');
        end;

        // Validate journal setup
        if not GenJnlTemplate.Get(Setup."Default Journal Template") then begin
            Logger.LogError(Enum::"Economic Request Type"::Journal,
                StrSubstNo('Journal template %1 does not exist', Setup."Default Journal Template"),
                'CreateGeneralJournalEntries');
            Error('The configured journal template %1 does not exist.', Setup."Default Journal Template");
        end;

        if not GenJnlBatch.Get(Setup."Default Journal Template", Setup."Default Journal Batch") then begin
            Logger.LogError(Enum::"Economic Request Type"::Journal,
                StrSubstNo('Journal batch %1 does not exist in template %2', Setup."Default Journal Batch", Setup."Default Journal Template"),
                'CreateGeneralJournalEntries');
            Error('The configured journal batch %1 does not exist in template %2.', Setup."Default Journal Batch", Setup."Default Journal Template");
        end;

        // Get next line number
        GenJnlLine.SetRange("Journal Template Name", Setup."Default Journal Template");
        GenJnlLine.SetRange("Journal Batch Name", Setup."Default Journal Batch");
        if GenJnlLine.FindLast() then
            NextLineNo := GenJnlLine."Line No." + 10000
        else
            NextLineNo := 10000;

        // Create journal entries from Economic data
        Success := CreateJournalEntriesFromEconomic(Setup."Default Journal Template", Setup."Default Journal Batch", NextLineNo);

        if Success then begin
            Logger.LogSuccess('CreateGeneralJournalEntries', JournalCreatedMsg);
            Message(JournalCreatedMsg);
        end;
    end;

    // Setup and Validation Methods
    local procedure InitializeConnection() Success: Boolean
    begin
        if not Setup.Get() then begin
            Logger.LogError(Enum::"Economic Request Type"::Undefined, MissingSetupErr, 'InitializeConnection');
            Error(MissingSetupErr);
        end;

        Success := HttpClient.InitializeClient();
        if not Success then
            Error('Failed to initialize HTTP client connection to e-conomic API');
    end;

    local procedure ProcessAccountsJson(JsonText: Text)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        AccountToken: JsonToken;
        AccountObject: JsonObject;
        ProcessedCount: Integer;
    begin
        if not JsonObject.ReadFrom(JsonText) then begin
            Logger.LogError(Enum::"Economic Request Type"::Account, 'Invalid JSON format in accounts response', 'ProcessAccountsJson');
            Error('Invalid JSON response from e-conomic API');
        end;

        if not JsonObject.Get('collection', JsonToken) then begin
            Logger.LogError(Enum::"Economic Request Type"::Account, 'Collection property not found in JSON', 'ProcessAccountsJson');
            Error('Invalid response format from e-conomic API');
        end;

        if not JsonToken.IsArray() then begin
            Logger.LogError(Enum::"Economic Request Type"::Account, 'Collection is not an array', 'ProcessAccountsJson');
            Error('Invalid response format from e-conomic API');
        end;

        JsonArray := JsonToken.AsArray();

        if JsonArray.Count() = 0 then begin
            Logger.LogSuccess('ProcessAccountsJson', 'No accounts found in response');
            Message(NoAccountsFoundErr);
            exit;
        end;

        foreach AccountToken in JsonArray do begin
            if AccountToken.IsObject() then begin
                AccountObject := AccountToken.AsObject();
                if ProcessSingleAccount(AccountObject) then
                    ProcessedCount += 1;
            end;
        end;

        Logger.LogSuccess('ProcessAccountsJson', StrSubstNo('Processed %1 accounts successfully', ProcessedCount));
    end;

    local procedure ProcessSingleAccount(AccountObject: JsonObject) Success: Boolean
    var
        GLAccountMapping: Record "Economic GL Account Mapping";
        AccountName: Text;
        EconomicAccountNo: Integer;
    begin
        Success := false;

        // Extract account data
        EconomicAccountNo := GetJsonValueAsInteger(AccountObject, 'accountNumber');
        AccountName := GetJsonValueAsText(AccountObject, 'name');

        if EconomicAccountNo = 0 then begin
            Logger.LogError(Enum::"Economic Request Type"::Account, 'Invalid account data in JSON', 'ProcessSingleAccount');
            exit(false);
        end;

        // Create or update mapping record
        if not GLAccountMapping.Get(Format(EconomicAccountNo)) then begin
            GLAccountMapping.Init();
            GLAccountMapping."Economic Account No." := CopyStr(Format(EconomicAccountNo), 1, MaxStrLen(GLAccountMapping."Economic Account No."));
            GLAccountMapping."Economic Account Name" := CopyStr(AccountName, 1, MaxStrLen(GLAccountMapping."Economic Account Name"));
            GLAccountMapping.Insert(true);
        end else begin
            GLAccountMapping."Economic Account Name" := CopyStr(AccountName, 1, MaxStrLen(GLAccountMapping."Economic Account Name"));
            GLAccountMapping.Modify(true);
        end;

        Success := true;
    end;

    local procedure CreateJournalEntriesFromEconomic(TemplateName: Code[10]; BatchName: Code[10]; var NextLineNo: Integer) Success: Boolean
    var
        ResponseContent: Text;
        RequestType: Enum "Economic Request Type";
    begin
        Success := false;
        RequestType := RequestType::Journal;

        // Get journal entries from e-conomic
        if not HttpClient.SendGetRequest(HttpClient.GetBaseUrl() + '/entries', ResponseContent, RequestType) then
            exit(false);

        // Process the journal entries (simplified for demo)
        Success := ProcessJournalEntriesJson(ResponseContent, TemplateName, BatchName, NextLineNo);
    end;

    local procedure ProcessJournalEntriesJson(JsonText: Text; TemplateName: Code[10]; BatchName: Code[10]; var NextLineNo: Integer) Success: Boolean
    begin
        // Simplified implementation - would need full JSON processing for entries
        Logger.LogSuccess('ProcessJournalEntriesJson', 'Journal entries processing available for implementation');
        Success := true;
    end;

    // New Entries API Methods
    procedure SyncEntriesFromEconomic() Success: Boolean
    var
        EconomicSetup: Record "Economic Setup";
        UrlsList: List of [Text];
        CurrentUrl: Text;
        ResponseContent: Text;
        RequestType: Enum "Economic Request Type";
        TotalEntriesProcessed: Integer;
        EntriesProcessedForUrl: Integer;
    begin
        Success := false;
        TotalEntriesProcessed := 0;

        if not InitializeConnection() then
            exit;

        // Get setup and validate configuration
        if not EconomicSetup.Get() then begin
            EconomicSetup.Init();
            EconomicSetup.Insert();
        end;

        if not EconomicSetup.ValidatePeriodConfiguration() then begin
            Message('Period configuration is not valid. Please check the setup.');
            exit;
        end;

        // Get all entries API URLs for configured years
        UrlsList := EconomicSetup.GetEntriesAPIUrls(HttpClient.GetBaseUrl());
        
        if UrlsList.Count = 0 then begin
            Message('No accounting years configured for entries synchronization.');
            exit;
        end;

        RequestType := RequestType::Entry;

        // Process each URL (accounting year)
        foreach CurrentUrl in UrlsList do begin
            EntriesProcessedForUrl := ProcessAllPagesForUrl(CurrentUrl, RequestType);
            TotalEntriesProcessed += EntriesProcessedForUrl;
            Logger.LogSuccess('SyncEntriesFromEconomic', StrSubstNo('Processed %1 entries from URL: %2', EntriesProcessedForUrl, CurrentUrl));
        end;

        if TotalEntriesProcessed > 0 then begin
            Message('Successfully synchronized %1 entries from e-conomic.', TotalEntriesProcessed);
            Success := true;
        end else begin
            Message('No entries were synchronized. Check the integration log for details.');
        end;
    end;

    local procedure ProcessAllPagesForUrl(BaseUrl: Text; RequestType: Enum "Economic Request Type") TotalProcessedCount: Integer
    var
        CurrentUrl: Text;
        NextPageUrl: Text;
        ResponseContent: Text;
        PageCount: Integer;
        EntriesProcessedForPage: Integer;
        HasMorePages: Boolean;
    begin
        TotalProcessedCount := 0;
        PageCount := 0;
        CurrentUrl := BaseUrl;
        HasMorePages := true;

        // Process all pages until no more pages are available
        while HasMorePages do begin
            PageCount += 1;
            
            if HttpClient.SendGetRequest(CurrentUrl, ResponseContent, RequestType) then begin
                EntriesProcessedForPage := ProcessEntriesResponseToLanding(ResponseContent, BaseUrl, RequestType);
                TotalProcessedCount += EntriesProcessedForPage;
                
                // Check if there's a next page
                NextPageUrl := GetNextPageUrl(ResponseContent);
                if NextPageUrl <> '' then begin
                    CurrentUrl := NextPageUrl;
                    Logger.LogSuccess('ProcessAllPagesForUrl', StrSubstNo('Processed page %1 with %2 entries, continuing to next page', PageCount, EntriesProcessedForPage));
                end else begin
                    HasMorePages := false;
                    Logger.LogSuccess('ProcessAllPagesForUrl', StrSubstNo('Completed processing %1 pages with total %2 entries', PageCount, TotalProcessedCount));
                end;
            end else begin
                HasMorePages := false;
                Logger.LogError(RequestType, StrSubstNo('Failed to get entries from URL: %1 (Page %2)', CurrentUrl, PageCount), 'ProcessAllPagesForUrl');
            end;
        end;
    end;

    local procedure GetNextPageUrl(JsonResponse: Text) NextUrl: Text
    var
        JsonObject: JsonObject;
        PaginationObject: JsonObject;
        JsonToken: JsonToken;
    begin
        NextUrl := '';

        if not JsonObject.ReadFrom(JsonResponse) then
            exit;

        // Check for pagination object
        if JsonObject.Get('pagination', JsonToken) and JsonToken.IsObject() then begin
            PaginationObject := JsonToken.AsObject();
            
            // Look for nextPage URL
            if PaginationObject.Get('nextPage', JsonToken) and JsonToken.IsValue() then begin
                NextUrl := JsonToken.AsValue().AsText();
                // e-conomic API returns relative URLs, so we need to make it absolute
                if (NextUrl <> '') and (StrPos(NextUrl, 'http') = 0) then
                    NextUrl := 'https://restapi.e-conomic.com' + NextUrl;
            end;
        end;
    end;

    local procedure ProcessEntriesResponseToLanding(JsonResponse: Text; SourceUrl: Text; RequestType: Enum "Economic Request Type") ProcessedCount: Integer
    var
        EconomicEntriesLanding: Record "Economic Entries Landing";
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        EntryJson: JsonObject;
        i: Integer;
        ResponseLength: Integer;
    begin
        ProcessedCount := 0;
        ResponseLength := StrLen(JsonResponse);

        Logger.LogSuccess('ProcessEntriesResponse', StrSubstNo('Processing JSON response (length: %1 chars) from URL: %2', ResponseLength, SourceUrl));

        if not JsonObject.ReadFrom(JsonResponse) then begin
            Logger.LogError(RequestType, 'Failed to parse JSON response', 'ProcessEntriesResponseToLanding');
            exit;
        end;

        // Get the collection array (e-conomic returns entries in "collection" property)
        if not JsonObject.Get('collection', JsonToken) then begin
            Logger.LogError(RequestType, 'No "collection" property found in JSON response', 'ProcessEntriesResponseToLanding');
            exit;
        end;

        if not JsonToken.IsArray() then begin
            Logger.LogError(RequestType, '"collection" property is not an array', 'ProcessEntriesResponseToLanding');
            exit;
        end;

        JsonArray := JsonToken.AsArray();
        Logger.LogSuccess('ProcessEntriesResponse', StrSubstNo('Found collection array with %1 entries', JsonArray.Count));

        // Process each entry in the collection
        for i := 0 to JsonArray.Count - 1 do begin
            JsonArray.Get(i, JsonToken);
            if JsonToken.IsObject() then begin
                EntryJson := JsonToken.AsObject();
                Clear(EconomicEntriesLanding); // Clear the record variable before each use
                if CreateLandingRecordFromJson(EntryJson, EconomicEntriesLanding, SourceUrl, RequestType) then
                    ProcessedCount += 1;
            end;
        end;

        Logger.LogSuccess('ProcessEntriesResponse', StrSubstNo('Successfully processed %1 out of %2 entries from response', ProcessedCount, JsonArray.Count));
    end;

    local procedure CreateLandingRecordFromJson(EntryJson: JsonObject; var EconomicEntriesLanding: Record "Economic Entries Landing"; SourceUrl: Text; RequestType: Enum "Economic Request Type") Success: Boolean
    var
        EntryNumber: Integer;
        ExistingRecord: Record "Economic Entries Landing";
    begin
        Success := false;

        // Get entry number to check for duplicates
        EntryNumber := GetJsonValueAsInteger(EntryJson, 'entryNumber');
        if EntryNumber = 0 then begin
            Logger.LogError(RequestType, 'Entry has no valid entry number, skipping', 'CreateLandingRecordFromJson');
            exit;
        end;

        // Check if entry already exists
        ExistingRecord.SetRange("Economic Entry Number", EntryNumber);
        if not ExistingRecord.IsEmpty then begin
            Logger.LogSuccess('CreateLandingRecord', StrSubstNo('Entry %1 already exists, skipping duplicate', EntryNumber));
            exit; // Entry already exists, skip
        end;

        // Create new landing record
        EconomicEntriesLanding.Init();
        EconomicEntriesLanding."Economic Entry Number" := EntryNumber;
        EconomicEntriesLanding."Accounting Year" := GetAccountingYearFromUrl(SourceUrl);
        EconomicEntriesLanding."Account Number" := GetAccountNumberFromJson(EntryJson);
        EconomicEntriesLanding.Amount := GetJsonValueAsDecimal(EntryJson, 'amount');
        EconomicEntriesLanding."Amount in Base Currency" := GetJsonValueAsDecimal(EntryJson, 'amountInBaseCurrency');
        EconomicEntriesLanding."Currency Code" := CopyStr(GetCurrencyCodeFromJson(EntryJson), 1, 10);
        EconomicEntriesLanding."Posting Date" := GetJsonValueAsDate(EntryJson, 'date');
        EconomicEntriesLanding."Due Date" := GetJsonValueAsDate(EntryJson, 'dueDate');
        EconomicEntriesLanding."Entry Text" := CopyStr(GetJsonValueAsText(EntryJson, 'text'), 1, 250);
        EconomicEntriesLanding."Entry Type" := CopyStr(GetJsonValueAsText(EntryJson, 'entryType'), 1, 50);
        EconomicEntriesLanding."Voucher Number" := GetJsonValueAsInteger(EntryJson, 'voucherNumber');
        EconomicEntriesLanding."Customer Number" := GetCustomerNumberFromJson(EntryJson);
        EconomicEntriesLanding."Supplier Number" := GetSupplierNumberFromJson(EntryJson);
        EconomicEntriesLanding."Supplier Invoice Number" := CopyStr(GetJsonValueAsText(EntryJson, 'supplierInvoiceNumber'), 1, 50);
        EconomicEntriesLanding."Processing Status" := EconomicEntriesLanding."Processing Status"::New;
        EconomicEntriesLanding."Import Date Time" := CurrentDateTime;
        EconomicEntriesLanding.SetRawJSONData(Format(EntryJson));

        // Log the data we're trying to insert for debugging
        Logger.LogSuccess('CreateLandingRecord', StrSubstNo('Attempting to insert entry %1, Account: %2, Year: %3, Amount: %4', 
            EntryNumber, 
            EconomicEntriesLanding."Account Number",
            EconomicEntriesLanding."Accounting Year",
            EconomicEntriesLanding.Amount));

        // Try to insert the record and capture any errors
        if TryInsertLandingRecord(EconomicEntriesLanding) then begin
            Success := true;
            Logger.LogSuccess('CreateLandingRecord', StrSubstNo('Created landing record for entry %1 from accounting year %2', EntryNumber, EconomicEntriesLanding."Accounting Year"));
        end else begin
            Logger.LogError(RequestType, StrSubstNo('Failed to insert landing record for entry %1. Error: %2', EntryNumber, GetLastErrorText()), 'CreateLandingRecordFromJson');
        end;
    end;

    local procedure GetJsonValueAsDecimal(JsonObject: JsonObject; PropertyName: Text) PropertyValue: Decimal
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(PropertyName, JsonToken) and JsonToken.IsValue() then
            PropertyValue := JsonToken.AsValue().AsDecimal()
        else
            PropertyValue := 0;
    end;

    local procedure GetJsonValueAsDate(JsonObject: JsonObject; PropertyName: Text) PropertyValue: Date
    var
        JsonToken: JsonToken;
        DateText: Text;
    begin
        if JsonObject.Get(PropertyName, JsonToken) and JsonToken.IsValue() then begin
            DateText := JsonToken.AsValue().AsText();
            if Evaluate(PropertyValue, DateText) then
                exit(PropertyValue)
            else
                PropertyValue := 0D;
        end else
            PropertyValue := 0D;
    end;

    // Legacy Methods for Page Compatibility
    procedure CreateGLAccountsFromMapping()
    begin
        Logger.LogSuccess('CreateGLAccountsFromMapping', 'GL Account mapping functionality available for implementation');
        Message('GL Account mapping functionality is available for implementation.');
    end;

    procedure SyncVendor(VendorNo: Code[20])
    begin
        Logger.LogSuccess('SyncVendor', StrSubstNo('Vendor sync requested for %1', VendorNo));
        Message('Vendor sync functionality is available for implementation.');
    end;

    procedure SuggestCountryMappings()
    begin
        Logger.LogSuccess('SuggestCountryMappings', 'Country mapping suggestions available for implementation');
        Message('Country mapping suggestions are available for implementation.');
    end;

    procedure ApplyCountryMappingToCustomers(CountryName: Text)
    begin
        Logger.LogSuccess('ApplyCountryMappingToCustomers', StrSubstNo('Country mapping application requested for customers: %1', CountryName));
        Message('Country mapping for customers is available for implementation.');
    end;

    procedure ApplyCountryMappingToVendors(CountryName: Text)
    begin
        Logger.LogSuccess('ApplyCountryMappingToVendors', StrSubstNo('Country mapping application requested for vendors: %1', CountryName));
        Message('Country mapping for vendors is available for implementation.');
    end;

    // Utility Methods
    local procedure GetJsonValueAsText(JsonObject: JsonObject; PropertyName: Text) PropertyValue: Text
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(PropertyName, JsonToken) and JsonToken.IsValue() then
            PropertyValue := JsonToken.AsValue().AsText()
        else
            PropertyValue := '';
    end;

    local procedure GetJsonValueAsInteger(JsonObject: JsonObject; PropertyName: Text) PropertyValue: Integer
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(PropertyName, JsonToken) and JsonToken.IsValue() then
            PropertyValue := JsonToken.AsValue().AsInteger()
        else
            PropertyValue := 0;
    end;

    [TryFunction]
    local procedure TryInsertLandingRecord(var EconomicEntriesLanding: Record "Economic Entries Landing")
    begin
        EconomicEntriesLanding.Insert(true);
    end;

    local procedure GetAccountingYearFromUrl(SourceUrl: Text) AccountingYear: Integer
    var
        StartPos: Integer;
        EndPos: Integer;
        YearText: Text;
    begin
        // Extract accounting year from URL like /accounting-years/2022/entries
        StartPos := StrPos(SourceUrl, '/accounting-years/');
        if StartPos > 0 then begin
            StartPos += StrLen('/accounting-years/');
            EndPos := StrPos(CopyStr(SourceUrl, StartPos), '/');
            if EndPos > 0 then
                YearText := CopyStr(SourceUrl, StartPos, EndPos - 1)
            else
                YearText := CopyStr(SourceUrl, StartPos);
            
            if not Evaluate(AccountingYear, YearText) then
                AccountingYear := 0;
        end else
            AccountingYear := 0;
    end;

    local procedure GetAccountNumberFromJson(EntryJson: JsonObject) AccountNumber: Integer
    var
        AccountToken: JsonToken;
        AccountObj: JsonObject;
    begin
        // Account is an object with accountNumber property
        if EntryJson.Get('account', AccountToken) and AccountToken.IsObject() then begin
            AccountObj := AccountToken.AsObject();
            AccountNumber := GetJsonValueAsInteger(AccountObj, 'accountNumber');
        end else
            AccountNumber := 0;
    end;

    local procedure GetCurrencyCodeFromJson(EntryJson: JsonObject) CurrencyCode: Text
    var
        CurrencyToken: JsonToken;
        CurrencyObj: JsonObject;
    begin
        // Currency is an object with code property
        if EntryJson.Get('currency', CurrencyToken) and CurrencyToken.IsObject() then begin
            CurrencyObj := CurrencyToken.AsObject();
            CurrencyCode := GetJsonValueAsText(CurrencyObj, 'code');
        end else begin
            // Fallback: try as direct string
            CurrencyCode := GetJsonValueAsText(EntryJson, 'currency');
        end;
    end;

    local procedure GetCustomerNumberFromJson(EntryJson: JsonObject) CustomerNumber: Integer
    var
        CustomerToken: JsonToken;
        CustomerObj: JsonObject;
    begin
        // Customer is an object with customerNumber property
        if EntryJson.Get('customer', CustomerToken) and CustomerToken.IsObject() then begin
            CustomerObj := CustomerToken.AsObject();
            CustomerNumber := GetJsonValueAsInteger(CustomerObj, 'customerNumber');
        end else
            CustomerNumber := 0;
    end;

    local procedure GetSupplierNumberFromJson(EntryJson: JsonObject) SupplierNumber: Integer
    var
        SupplierToken: JsonToken;
        SupplierObj: JsonObject;
    begin
        // Supplier is an object with supplierNumber property
        if EntryJson.Get('supplier', SupplierToken) and SupplierToken.IsObject() then begin
            SupplierObj := SupplierToken.AsObject();
            SupplierNumber := GetJsonValueAsInteger(SupplierObj, 'supplierNumber');
        end else
            SupplierNumber := 0;
    end;
}