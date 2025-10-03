codeunit 51000 "Economic Management"
{
    var
        Setup: Record "Economic Setup";
        IntegrationLog: Record "Economic Integration Log";
        ResponseText: Text;
        AccountsEndpointLbl: Label 'https://restapi.e-conomic.com/accounts', Locked = true;
        EntriesEndpointLbl: Label 'https://restapi.e-conomic.com/accounts/entries', Locked = true;
        MissingSetupErr: Label 'The e-conomic API setup is not complete. Please check the setup page.';
        AccountsFetchedMsg: Label 'Successfully fetched %1 accounts from e-conomic.';
        CustomersEndpointLbl: Label 'https://restapi.e-conomic.com/customers', Locked = true;
        CustomersFetchedMsg: Label 'Successfully fetched %1 customers from e-conomic.';
        NoAccountsFoundErr: Label 'No accounts were found in e-conomic.';
        JournalCreatedMsg: Label 'Successfully created general journal entries.';
        HttpErrorMsg: Label 'The request failed with status code %1. Details: %2';
        InvalidJsonErr: Label 'Invalid JSON response from the API.';
        InvalidTokenErr: Label 'Invalid token in JSON response.';
        ProcessingErr: Label '%1 failed with error: %2';

    local procedure LogAPIRequest(RequestMethod: Text; Endpoint: Text; RequestType: Enum "Economic Request Type"; Body: Text)
    begin
        IntegrationLog.Init();
        IntegrationLog."Entry No." := GetNextLogEntryNo();
        IntegrationLog."Request Type" := RequestType;
        IntegrationLog."Request URL" := CopyStr(Endpoint, 1, MaxStrLen(IntegrationLog."Request URL"));
        IntegrationLog.Operation := RequestMethod;
        IntegrationLog."Description" := CopyStr(StrSubstNo('API Request: %1 %2', RequestMethod, Endpoint), 1, MaxStrLen(IntegrationLog."Description"));
        IntegrationLog."Log Timestamp" := CurrentDateTime;
        if Body <> '' then
            IntegrationLog."Error Message" := CopyStr(Body, 1, MaxStrLen(IntegrationLog."Error Message"));
        IntegrationLog.Insert(true);
    end;

    local procedure LogAPIResponse(Response: HttpResponseMessage; RequestType: Enum "Economic Request Type"; var ErrorText: Text)
    var
        Success: Boolean;
    begin
        Success := Response.IsSuccessStatusCode();

        IntegrationLog.Init();
        IntegrationLog."Entry No." := GetNextLogEntryNo();
        IntegrationLog."Request Type" := RequestType;
        IntegrationLog."Log Timestamp" := CurrentDateTime;
        if Success then
            IntegrationLog."Event Type" := IntegrationLog."Event Type"::Information
        else
            IntegrationLog."Event Type" := IntegrationLog."Event Type"::Error;
        IntegrationLog."Request URL" := CopyStr(GetResponseUrl(Response), 1, MaxStrLen(IntegrationLog."Request URL"));
        IntegrationLog.Description := CopyStr(
            StrSubstNo('API Response: Status %1 - %2',
                Response.HttpStatusCode,
                GetResponseReasonPhrase(Response)),
            1,
            MaxStrLen(IntegrationLog."Description"));

        if not Success then begin
            ErrorText := GetErrorText(Response);
            IntegrationLog."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(IntegrationLog."Error Message"));
        end;

        IntegrationLog.Insert(true);
    end;

    local procedure LogError(RequestType: Enum "Economic Request Type"; ErrorText: Text; Context: Text)
    begin
        IntegrationLog.Init();
        IntegrationLog."Entry No." := GetNextLogEntryNo();
        IntegrationLog."Request Type" := RequestType;
        IntegrationLog."Event Type" := IntegrationLog."Event Type"::Error;
        IntegrationLog."Log Timestamp" := CurrentDateTime;
        IntegrationLog.Description := CopyStr(Context, 1, MaxStrLen(IntegrationLog."Description"));
        IntegrationLog."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(IntegrationLog."Error Message"));
        IntegrationLog.Insert(true);
    end;

    local procedure GetRequestMethodOption(Method: Text): Option
    begin
        case UpperCase(Method) of
            'GET':
                exit(0);
            'POST':
                exit(1);
            'PUT':
                exit(2);
            'PATCH':
                exit(3);
            'DELETE':
                exit(4);
            else
                exit(0);
        end;
    end;

    local procedure GetResponseUrl(Response: HttpResponseMessage): Text
    var
        Values: List of [Text];
    begin
        if Response.Headers.Contains('Location') then begin
            Response.Headers.GetValues('Location', Values);
            if Values.Count > 0 then
                exit(Values.Get(1));
        end;
        exit('');
    end;

    local procedure GetResponseReasonPhrase(Response: HttpResponseMessage): Text
    begin
        if Response.ReasonPhrase <> '' then
            exit(Response.ReasonPhrase)
        else
            exit(Format(Response.HttpStatusCode));
    end;

    local procedure GetErrorText(Response: HttpResponseMessage) ErrorText: Text
    var
        Content: Text;
    begin
        Response.Content.ReadAs(Content);
        if Content <> '' then
            ErrorText := Content
        else
            ErrorText := Response.ReasonPhrase;

        if ErrorText = '' then
            ErrorText := StrSubstNo(HttpErrorMsg, Response.HttpStatusCode, 'No additional details available');
    end;

    local procedure GetRequestBodyOutStream(LogEntryNo: Integer) OutStr: OutStream
    var
        IntegrationLog: Record "Economic Integration Log";
    begin
        if IntegrationLog.Get(LogEntryNo) then
            IntegrationLog."Response Data".CreateOutStream(OutStr, TextEncoding::UTF8);
    end;

    local procedure GetResponseBodyOutStream(LogEntryNo: Integer) OutStr: OutStream
    var
        IntegrationLog: Record "Economic Integration Log";
    begin
        if IntegrationLog.Get(LogEntryNo) then
            IntegrationLog."Response Data".CreateOutStream(OutStr, TextEncoding::UTF8);
    end;

    procedure GetAccounts()
    var
        GLAccountMapping: Record "Economic GL Account Mapping";
        Client: HttpClient;
        Response: HttpResponseMessage;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        TotalFromObject: JsonObject;
        AccountCount: Integer;
        RequestUrl: Text;
        ErrorContext: Text;
        ErrorText: Text;
    begin
        Clear(Response);
        Clear(ResponseText);

        ErrorContext := 'Initializing API client';
        if not InitializeClient(Client) then begin
            LogError("Economic Request Type"::Account, MissingSetupErr, ErrorContext);
            Error(MissingSetupErr);
        end;

        RequestUrl := AccountsEndpointLbl;
        LogAPIRequest('GET', RequestUrl, "Economic Request Type"::Account, '');

        // Set Accept header for JSON response
        Client.DefaultRequestHeaders.Remove('Accept');
        if not Client.DefaultRequestHeaders.Add('Accept', 'application/json') then begin
            LogError("Economic Request Type"::Account, 'Failed to set Accept header', ErrorContext);
            Error('Failed to set Accept header');
        end;

        if not Client.Get(RequestUrl, Response) then begin
            LogAPIResponse(Response, "Economic Request Type"::Account, ErrorText);
            Error(ErrorText);
        end;

        LogAPIResponse(Response, "Economic Request Type"::Account, ErrorText);
        if not Response.IsSuccessStatusCode() then
            Error(ErrorText);

        Response.Content().ReadAs(ResponseText);

        // Parse the root JSON object
        if not JsonObject.ReadFrom(ResponseText) then begin
            LogError("Economic Request Type"::Account, InvalidJsonErr, ResponseText);
            Error(InvalidJsonErr);
        end;

        // Get the collection property
        if not JsonObject.Get('collection', JsonToken) then begin
            LogError("Economic Request Type"::Account, InvalidTokenErr, ResponseText);
            Error(InvalidTokenErr);
        end;

        JsonArray := JsonToken.AsArray();

        if JsonArray.Count = 0 then begin
            LogError("Economic Request Type"::Account, NoAccountsFoundErr, ResponseText);
            Error(NoAccountsFoundErr);
        end;

        foreach JsonToken in JsonArray do begin
            JsonObject := JsonToken.AsObject();
            if not GLAccountMapping.Get(GetJsonToken(JsonObject, 'accountNumber').AsValue().AsCode()) then begin
                ErrorContext := 'Processing account data';
                GLAccountMapping.Init();
                GLAccountMapping."Economic Account No." := CopyStr(GetJsonToken(JsonObject, 'accountNumber').AsValue().AsText(), 1, MaxStrLen(GLAccountMapping."Economic Account No."));
                GLAccountMapping."Economic Account Name" := CopyStr(GetJsonToken(JsonObject, 'name').AsValue().AsText(), 1, MaxStrLen(GLAccountMapping."Economic Account Name"));

                // Map the account type to the corresponding option
                case LowerCase(GetJsonToken(JsonObject, 'accountType').AsValue().AsText()) of
                    'profitandloss':
                        GLAccountMapping."Account Type" := GLAccountMapping."Account Type"::profitAndLoss;
                    'status':
                        GLAccountMapping."Account Type" := GLAccountMapping."Account Type"::status;
                    'totalfrom':
                        GLAccountMapping."Account Type" := GLAccountMapping."Account Type"::totalFrom;
                    'heading':
                        GLAccountMapping."Account Type" := GLAccountMapping."Account Type"::heading;
                    'headingstart':
                        GLAccountMapping."Account Type" := GLAccountMapping."Account Type"::headingStart;
                    'suminterval':
                        GLAccountMapping."Account Type" := GLAccountMapping."Account Type"::sumInterval;
                    'sumalpha':
                        GLAccountMapping."Account Type" := GLAccountMapping."Account Type"::sumAlpha;
                end;
                GLAccountMapping.Balance := GetJsonToken(JsonObject, 'balance').AsValue().AsDecimal();
                GLAccountMapping."Block Direct Entries" := GetJsonToken(JsonObject, 'blockDirectEntries').AsValue().AsBoolean();
                GLAccountMapping."Debit Credit" := CopyStr(GetJsonToken(JsonObject, 'debitCredit').AsValue().AsText(), 1, MaxStrLen(GLAccountMapping."Debit Credit"));

                // Handle Total From Account from nested object
                if HasTotalFromAccount(JsonObject) then begin
                    JsonToken := GetJsonToken(JsonObject, 'totalFromAccount');
                    TotalFromObject := JsonToken.AsObject();
                    GLAccountMapping."Total From Account" := CopyStr(GetJsonToken(TotalFromObject, 'accountNumber').AsValue().AsText(), 1, MaxStrLen(GLAccountMapping."Total From Account"));
                    GLAccountMapping.Indentation := 1;
                end else begin
                    GLAccountMapping.Indentation := 0;
                end;

                // Handle VAT Account if present
                if HasVatAccount(JsonObject) then begin
                    JsonToken := GetJsonToken(JsonObject, 'vatAccount');
                    JsonObject := JsonToken.AsObject();
                    GLAccountMapping."VAT Code" := CopyStr(GetJsonToken(JsonObject, 'vatCode').AsValue().AsText(), 1, MaxStrLen(GLAccountMapping."VAT Code"));
                end;

                GLAccountMapping."Last Synced" := CurrentDateTime;
                GLAccountMapping.Insert(true);
            end;
            AccountCount += 1;
        end;

        // Update indentation for all accounts after import
        UpdateAccountIndentation();

        Message(AccountsFetchedMsg, AccountCount);
    end;

    procedure CreateGeneralJournalEntries()
    var
        IntegrationLog: Record "Economic Integration Log";
        GLAccountMapping: Record "Economic GL Account Mapping";
        GenJournalLine: Record "Gen. Journal Line";
        TotalEntries: Integer;
        LogEntryNo: Integer;
    begin
        LogEntryNo := CreateLogEntry(IntegrationLog, EntriesEndpointLbl, 'POST', Enum::"Economic Request Type"::Account);

        // Loop through account mappings
        if GLAccountMapping.FindSet() then
            repeat
                TotalEntries += CreateJournalEntriesForAccount(GLAccountMapping, GenJournalLine, LogEntryNo);
            until GLAccountMapping.Next() = 0;

        // Update log entry with result
        if TotalEntries > 0 then begin
            UpdateLogEntry(LogEntryNo, true, StrSubstNo(JournalCreatedMsg, TotalEntries));
            Message(JournalCreatedMsg, TotalEntries);
        end else begin
            UpdateLogEntry(LogEntryNo, false, 'No entries were created.');
            Message('No entries were created.');
        end;
    end;

    local procedure CreateJournalEntriesForAccount(GLAccountMapping: Record "Economic GL Account Mapping"; var GenJournalLine: Record "Gen. Journal Line"; LogEntryNo: Integer): Integer
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        EntryCount: Integer;
        DocumentNo: Code[20];
        RequestUrl: Text;
        RequestStream: OutStream;
        ResponseStream: OutStream;
    begin
        if not InitializeClient(Client) then
            Error(MissingSetupErr);

        // Get entries for the specific account
        RequestUrl := StrSubstNo('%1?filter=account.accountNumber$eq:%2', EntriesEndpointLbl, GLAccountMapping."Economic Account No.");
        RequestStream := GetRequestBodyOutStream(LogEntryNo);
        RequestStream.WriteText(RequestUrl);

        if not Client.Get(RequestUrl, Response) then
            Error(GetLastErrorText());

        ResponseStream := GetResponseBodyOutStream(LogEntryNo);
        Response.Content().ReadAs(ResponseText);
        ResponseStream.WriteText(ResponseText);

        if not Response.IsSuccessStatusCode() then
            Error(GetHttpErrorMsg(Response));

        JsonArray.ReadFrom(ResponseText);
        foreach JsonToken in JsonArray do begin
            JsonObject := JsonToken.AsObject();
            if JsonObject.Get('id', JsonToken) then
                DocumentNo := Format(JsonToken.AsValue().AsText());

            GenJournalLine.Init();
            GenJournalLine."Document No." := DocumentNo;
            GenJournalLine."Account No." := GLAccountMapping."BC Account No.";
            // Add other fields as needed from the JsonObject
            // GenJournalLine.Amount := ...
            // GenJournalLine."Posting Date" := ...
            if GenJournalLine.Insert() then
                EntryCount += 1;
        end;

        exit(EntryCount);
    end;

    local procedure CreateLogEntry(var IntegrationLog: Record "Economic Integration Log"; Endpoint: Text; Method: Text; RequestType: Enum "Economic Request Type"): Integer
    begin
        IntegrationLog.Init();
        IntegrationLog."Entry No." := GetNextLogEntryNo();
        IntegrationLog."Request URL" := Endpoint;
        IntegrationLog.Operation := Method;
        IntegrationLog."Request Type" := RequestType;
        IntegrationLog."Log Timestamp" := CurrentDateTime;
        if IntegrationLog.Insert() then
            exit(IntegrationLog."Entry No.")
        else
            Error('Failed to insert Integration Log entry');
    end;

    local procedure UpdateLogEntry(EntryNo: Integer; Success: Boolean; Message: Text)
    var
        IntegrationLog: Record "Economic Integration Log";
    begin
        if IntegrationLog.Get(EntryNo) then begin
            IntegrationLog."Log Timestamp" := CurrentDateTime;
            if Success then
                IntegrationLog."Event Type" := IntegrationLog."Event Type"::Information
            else
                IntegrationLog."Event Type" := IntegrationLog."Event Type"::Error;
            IntegrationLog.Description := Message;
            IntegrationLog.Modify();
        end;
    end;

    local procedure InitializeClient(var Client: HttpClient): Boolean
    var
        Headers: HttpHeaders;
        ErrorText: Text;
    begin
        if not ValidateSetup(ErrorText) then begin
            LogSetupError('Authentication Setup Error', ErrorText);
            exit(false);
        end;

        Client.DefaultRequestHeaders.Clear();

        if not Client.DefaultRequestHeaders.Add('X-AppSecretToken', Setup."API Secret Token") then
            Error('Failed to add X-AppSecretToken header');

        if not Client.DefaultRequestHeaders.Add('X-AgreementGrantToken', Setup."Agreement Grant Token") then
            Error('Failed to add X-AgreementGrantToken header');

        if (Setup."API Secret Token" = 'demo') and (Setup."Agreement Grant Token" = 'demo') then
            if not Client.DefaultRequestHeaders.Add('X-DemoToken', 'true') then
                Error('Failed to add X-DemoToken header');

        LogAuthenticationHeaders(Client);
        exit(true);
    end;

    local procedure ValidateSetup(var ErrorText: Text): Boolean
    begin
        if not Setup.Get() then begin
            ErrorText := 'Economic setup record not found. Please open the setup page and enter the required information.';
            exit(false);
        end;

        if Setup."API Secret Token" = '' then begin
            ErrorText := 'API Secret Token is required. Please enter it in the Economic setup page.';
            exit(false);
        end;

        if Setup."Agreement Grant Token" = '' then begin
            ErrorText := 'Agreement Grant Token is required. Please enter it in the Economic setup page.';
            exit(false);
        end;

        exit(true);
    end;

    local procedure LogSetupError(Operation: Text; ErrorText: Text)
    var
        OutStream: OutStream;
    begin
        IntegrationLog.Init();
        IntegrationLog."Entry No." := GetNextLogEntryNo();
        IntegrationLog."Log Timestamp" := CurrentDateTime;
        IntegrationLog.Operation := CopyStr(Operation, 1, MaxStrLen(IntegrationLog.Operation));
        IntegrationLog."Status Code" := 0;
        IntegrationLog."Event Type" := IntegrationLog."Event Type"::Error;
        IntegrationLog.Description := 'Setup Error';
        IntegrationLog."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(IntegrationLog."Error Message"));
        IntegrationLog."Request URL" := '';

        IntegrationLog."Response Data".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ErrorText);

        IntegrationLog.Insert();
    end;

    local procedure LogAuthenticationHeaders(var Client: HttpClient)
    var
        Headers: HttpHeaders;
        HeaderText: Text;
    begin
        HeaderText := 'Request Headers:\';
        Headers := Client.DefaultRequestHeaders;

        if Headers.Contains('X-AppSecretToken') then
            HeaderText += 'X-AppSecretToken: [PRESENT]\';

        if Headers.Contains('X-AgreementGrantToken') then
            HeaderText += 'X-AgreementGrantToken: [PRESENT]\';

        if Headers.Contains('Accept') then
            HeaderText += 'Accept: application/json\';

        if Headers.Contains('X-DemoToken') then
            HeaderText += 'X-DemoToken: true\';

        LogSetupError('Authentication Headers', HeaderText);
    end;

    local procedure GetFirstValue(var Values: List of [Text]): Text
    var
        Value: Text;
    begin
        foreach Value in Values do
            exit(Value);
    end;

    local procedure LogAPICall(Operation: Text; Response: HttpResponseMessage; ResponseContent: Text)
    var
        OutStream: OutStream;
        RequestUrl: Text;
    begin
        RequestUrl := AccountsEndpointLbl;

        if not IntegrationLog.WritePermission then
            Error('No write permission for Integration Log table');

        IntegrationLog.Init();
        IntegrationLog."Log Timestamp" := CurrentDateTime;
        IntegrationLog.Operation := CopyStr(Operation, 1, MaxStrLen(IntegrationLog.Operation));

        if Response.IsSuccessStatusCode() then begin
            IntegrationLog."Status Code" := Response.HttpStatusCode;
            IntegrationLog.Description := CopyStr(Response.ReasonPhrase, 1, MaxStrLen(IntegrationLog.Description));
        end else begin
            IntegrationLog."Status Code" := 0;
            IntegrationLog.Description := 'Error';
        end;

        IntegrationLog."Request URL" := CopyStr(RequestUrl, 1, MaxStrLen(IntegrationLog."Request URL"));

        // Only store response in Error Message if it's an error
        if not Response.IsSuccessStatusCode() then
            IntegrationLog."Error Message" := CopyStr(ResponseContent, 1, MaxStrLen(IntegrationLog."Error Message"));

        // Always store full response in Response Data
        IntegrationLog."Response Data".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ResponseContent);

        // Get next Entry No.
        IntegrationLog."Entry No." := GetNextLogEntryNo();

        if not IntegrationLog.Insert() then
            Error('Failed to insert Integration Log entry');
    end;

    local procedure GetHttpErrorMsg(Response: HttpResponseMessage): Text
    var
        Result: Text;
    begin
        Response.Content().ReadAs(Result);
        exit(StrSubstNo(HttpErrorMsg, Response.HttpStatusCode, Result));
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error(InvalidTokenErr);
    end;

    local procedure HasVatAccount(JsonObject: JsonObject): Boolean
    var
        Token: JsonToken;
    begin
        if not JsonObject.Get('vatAccount', Token) then
            exit(false);
        exit(true);
    end;

    local procedure HasTotalFromAccount(JsonObject: JsonObject): Boolean
    var
        Token: JsonToken;
    begin
        if not JsonObject.Get('totalFromAccount', Token) then
            exit(false);
        exit(true);
    end;

    #region Country Mapping
    local procedure Maximum(Value1: Decimal; Value2: Decimal): Decimal
    begin
        if Value1 > Value2 then
            exit(Value1);
        exit(Value2);
    end;

    local procedure Minimum(Value1: Decimal; Value2: Decimal): Decimal
    begin
        if Value1 < Value2 then
            exit(Value1);
        exit(Value2);
    end;

    procedure SuggestCountryMappings()
    var
        CountryRegion: Record "Country/Region";
        CountryMapping: Record "Economic Country Mapping";
        Distance: Integer;
        BestMatch: Text[10];
        BestDistance: Integer;
        MinimumSimilarity: Integer;
    begin
        MinimumSimilarity := 80; // Minimum similarity percentage

        if not CountryMapping.FindSet() then
            exit;

        repeat
            if CountryMapping."Country/Region Code" = '' then begin
                BestMatch := '';
                BestDistance := 0;

                // Find best matching country/region
                if CountryRegion.FindSet() then
                    repeat
                        Distance := CalculateLevenshteinDistance(
                            LowerCase(CountryMapping."Economic Country Name"),
                            LowerCase(CountryRegion.Name));

                        // Convert distance to similarity percentage
                        Distance := 100 - Round(Distance / Maximum(StrLen(CountryMapping."Economic Country Name"),
                            StrLen(CountryRegion.Name)) * 100, 1);

                        if (Distance > BestDistance) and (Distance >= MinimumSimilarity) then begin
                            BestDistance := Distance;
                            BestMatch := CountryRegion.Code;
                        end;
                    until CountryRegion.Next() = 0;

                if BestMatch <> '' then begin
                    CountryMapping.Validate("Country/Region Code", BestMatch);
                    CountryMapping.Modify(true);
                end;
            end;
        until CountryMapping.Next() = 0;

        Message('Country mapping suggestions have been updated.');
    end;

    procedure ApplyCountryMappingToCustomers(EconomicCountryName: Text[100])
    var
        Customer: Record Customer;
        CountryMapping: Record "Economic Country Mapping";
    begin
        if not CountryMapping.Get(EconomicCountryName) then
            Error('Country mapping not found for %1', EconomicCountryName);

        if CountryMapping."Country/Region Code" = '' then
            Error('No country/region code mapped for %1', EconomicCountryName);

        Customer.SetCurrentKey("Country/Region Code");
        Customer.SetRange("Country/Region Code", ''); // Only update unmapped customers

        if Customer.FindSet() then begin
            repeat
                if StrPos(LowerCase(Customer.County), LowerCase(EconomicCountryName)) > 0 then begin
                    Customer.Validate("Country/Region Code", CountryMapping."Country/Region Code");
                    Customer.Modify(true);
                end;
            until Customer.Next() = 0;
        end;

        CountryMapping."Last Used Date" := Today;
        CountryMapping.Modify();

        Message('Country mapping has been applied to matching customers.');
    end;

    procedure ApplyCountryMappingToVendors(EconomicCountryName: Text[100])
    var
        Vendor: Record Vendor;
        CountryMapping: Record "Economic Country Mapping";
    begin
        if not CountryMapping.Get(EconomicCountryName) then
            Error('Country mapping not found for %1', EconomicCountryName);

        if CountryMapping."Country/Region Code" = '' then
            Error('No country/region code mapped for %1', EconomicCountryName);

        Vendor.SetCurrentKey("Country/Region Code");
        Vendor.SetRange("Country/Region Code", ''); // Only update unmapped vendors

        if Vendor.FindSet() then begin
            repeat
                if StrPos(LowerCase(Vendor.County), LowerCase(EconomicCountryName)) > 0 then begin
                    Vendor.Validate("Country/Region Code", CountryMapping."Country/Region Code");
                    Vendor.Modify(true);
                end;
            until Vendor.Next() = 0;
        end;

        CountryMapping."Last Used Date" := Today;
        CountryMapping.Modify();

        Message('Country mapping has been applied to matching vendors.');
    end;

    local procedure CalculateLevenshteinDistance(Text1: Text; Text2: Text): Integer
    var
        Distance: array[2, 50] of Integer;
        Length1, Length2, i, j, Cost : Integer;
        Above, Left, Diagonal : Integer;
    begin
        Length1 := StrLen(Text1);
        Length2 := StrLen(Text2);

        if Length1 = 0 then exit(Length2);
        if Length2 = 0 then exit(Length1);

        // Initialize first row
        for j := 0 to Length2 do
            Distance[1, j] := j;

        for i := 1 to Length1 do begin
            Distance[2, 0] := i;

            for j := 1 to Length2 do begin
                if CopyStr(Text1, i, 1) = CopyStr(Text2, j, 1) then
                    Cost := 0
                else
                    Cost := 1;

                Above := Distance[2, j - 1] + 1;
                Left := Distance[1, j] + 1;
                Diagonal := Distance[1, j - 1] + Cost;

                Distance[2, j] := Minimum(Above, Minimum(Left, Diagonal));
            end;

            // Copy current row to previous row
            for j := 0 to Length2 do
                Distance[1, j] := Distance[2, j];
        end;

        exit(Distance[2, Length2]);
    end;

    local procedure UpdateAccountIndentation()
    var
        GLAccountMapping: Record "Economic GL Account Mapping";
    begin
        GLAccountMapping.SetCurrentKey("Economic Account No.");
        if GLAccountMapping.FindSet() then
            repeat
                GLAccountMapping.Indentation := CalculateAccountIndentation(GLAccountMapping."Economic Account No.");
                GLAccountMapping.Modify();
            until GLAccountMapping.Next() = 0;
    end;

    local procedure CalculateAccountIndentation(AccountNo: Code[20]): Integer
    var
        GLAccountMapping: Record "Economic GL Account Mapping";
        ParentAccountNo: Code[20];
        IndentLevel: Integer;
    begin
        if not GLAccountMapping.Get(AccountNo) then
            exit(0);

        if GLAccountMapping."Total From Account" = '' then
            exit(0);

        ParentAccountNo := GLAccountMapping."Total From Account";
        IndentLevel := 1;

        // Check for deeper nesting (up to 5 levels to prevent infinite loops)
        while (ParentAccountNo <> '') and (IndentLevel < 5) do begin
            if GLAccountMapping.Get(ParentAccountNo) then begin
                if GLAccountMapping."Total From Account" <> '' then begin
                    ParentAccountNo := GLAccountMapping."Total From Account";
                    IndentLevel += 1;
                end else
                    ParentAccountNo := '';
            end else
                ParentAccountNo := '';
        end;

        exit(IndentLevel);
    end;

    /// <summary>
    /// Creates G/L Accounts in Business Central from the mapped e-conomic accounts
    /// </summary>
    procedure CreateGLAccountsFromMapping()
    var
        GLAccountMapping: Record "Economic GL Account Mapping";
        GLAccount: Record "G/L Account";
        GLSetup: Record "General Ledger Setup";
        Counter: Integer;
        SkippedCounter: Integer;
    begin
        GLSetup.Get();
        
        GLAccountMapping.SetCurrentKey("Economic Account No.");
        if GLAccountMapping.FindSet() then
            repeat
                if GLAccountMapping."BC Account No." <> '' then begin
                    if not GLAccount.Get(GLAccountMapping."BC Account No.") then begin
                        GLAccount.Init();
                        GLAccount."No." := GLAccountMapping."BC Account No.";
                        GLAccount.Name := GLAccountMapping."Economic Account Name";
                        
                        // Map account types
                        case GLAccountMapping."Account Type" of
                            GLAccountMapping."Account Type"::heading,
                            GLAccountMapping."Account Type"::headingStart:
                                GLAccount."Account Type" := GLAccount."Account Type"::Heading;
                            GLAccountMapping."Account Type"::totalFrom:
                                GLAccount."Account Type" := GLAccount."Account Type"::Total;
                            GLAccountMapping."Account Type"::profitAndLoss:
                                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                            GLAccountMapping."Account Type"::status:
                                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                            else
                                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                        end;

                        // Set income/balance type based on account type
                        if GLAccountMapping."Account Type" in [GLAccountMapping."Account Type"::profitAndLoss] then
                            GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement"
                        else
                            GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet";

                        // Set debit/credit based on the economic account
                        if GLAccountMapping."Debit Credit" = 'credit' then
                            GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Credit
                        else
                            GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Debit;

                        // Set totaling for total accounts
                        if GLAccountMapping."Account Type" = GLAccountMapping."Account Type"::totalFrom then
                            if GLAccountMapping."Total From Account" <> '' then
                                GLAccount.Totaling := GLAccountMapping."Total From Account";

                        // Set blocked if direct entries are blocked
                        GLAccount."Direct Posting" := not GLAccountMapping."Block Direct Entries";

                        // Set indentation
                        GLAccount.Indentation := GLAccountMapping.Indentation;

                        GLAccount.Insert(true);
                        Counter += 1;
                    end else begin
                        SkippedCounter += 1;
                    end;
                end else begin
                    SkippedCounter += 1;
                end;
            until GLAccountMapping.Next() = 0;

        Message('G/L Account creation completed.\Created: %1\Skipped (already exists or no BC Account No.): %2', Counter, SkippedCounter);
    end;

    local procedure GetNextLogEntryNo(): Integer
    var
        LastLog: Record "Economic Integration Log";
    begin
        if LastLog.FindLast() then
            exit(LastLog."Entry No." + 1)
        else
            exit(1);
    end;
    #endregion

    /// <summary>
    /// Gets all customers from e-conomic and creates/updates mappings.
    /// </summary>
    procedure GetCustomers()
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
        JArray: JsonArray;
        JToken: JsonToken;
        JObject: JsonObject;
        CustomerMapping: Record "Economic Customer Mapping";
        Counter: Integer;
    begin
        if not InitializeClient(Client) then
            Error(MissingSetupErr);

        // Get response
        if not Client.Get(CustomersEndpointLbl, Response) then
            Error('Failed to get customers from e-conomic');

        if not Response.IsSuccessStatusCode() then
            Error('Failed to get customers. Status code: %1', Response.HttpStatusCode);

        // Get response content
        Response.Content().ReadAs(ResponseText);

        LogAPICall('Get Customers - Success', Response, ResponseText);

        // Parse JSON response
        JArray.ReadFrom(ResponseText);
        foreach JToken in JArray do begin
            JObject := JToken.AsObject();
            ProcessCustomerJson(JObject);
            Counter += 1;
        end;

        Message(CustomersFetchedMsg, Counter);
    end;

    /// <summary>
    /// Synchronizes a specific customer with e-conomic.
    /// </summary>
    /// <param name="CustomerNo">The Business Central customer number to synchronize.</param>
    procedure SyncCustomer(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        CustomerMapping: Record "Economic Customer Mapping";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
        JObject: JsonObject;
        RequestText: Text;
    begin
        if not InitializeClient(Client) then
            Error(MissingSetupErr);

        // Get customer
        if not Customer.Get(CustomerNo) then
            Error('Customer %1 not found', CustomerNo);

        // Check if customer mapping exists
        CustomerMapping.SetRange("Customer No.", CustomerNo);
        if CustomerMapping.FindFirst() then begin
            // Update existing customer
            CreateCustomerJson(Customer, JObject);
            JObject.WriteTo(RequestText);

            Content.WriteFrom(RequestText);
            Content.GetHeaders(Headers);
            Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');

            if not Client.Put(StrSubstNo('%1/%2', CustomersEndpointLbl, CustomerMapping."Economic Customer Id"), Content, Response) then
                Error('Failed to update customer in e-conomic');

            if not Response.IsSuccessStatusCode() then
                Error('Failed to update customer. Status code: %1', Response.HttpStatusCode);

            Response.Content().ReadAs(ResponseText);

            LogAPICall('Update Customer - Success', Response, ResponseText);

            // Update mapping
            CustomerMapping.Validate("Sync Status", CustomerMapping."Sync Status"::Synced);
            CustomerMapping."Last Sync DateTime" := CurrentDateTime;
            CustomerMapping.Modify(true);
        end else begin
            // Create new customer
            CreateCustomerJson(Customer, JObject);
            JObject.WriteTo(RequestText);

            Content.WriteFrom(RequestText);
            Content.GetHeaders(Headers);
            Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');

            if not Client.Post(CustomersEndpointLbl, Content, Response) then
                Error('Failed to create customer in e-conomic');

            if not Response.IsSuccessStatusCode() then
                Error('Failed to create customer. Status code: %1', Response.HttpStatusCode);

            Response.Content().ReadAs(ResponseText);

            LogAPICall('Create Customer - Success', Response, ResponseText);

            // Create new mapping
            CustomerMapping.Init();
            CustomerMapping.Validate("Customer No.", CustomerNo);
            ParseCustomerResponse(ResponseText, CustomerMapping);
            CustomerMapping.Insert(true);
        end;
    end;

    local procedure ProcessCustomerJson(JObject: JsonObject)
    var
        CustomerMapping: Record "Economic Customer Mapping";
        Customer: Record Customer;
        JToken: JsonToken;
        CustomerId: Integer;
        CustomerNumber: Text;
    begin
        // Get customer ID and number from JSON
        if not JObject.Get('customerNumber', JToken) or
           JToken.AsValue().IsNull then
            exit;
        CustomerNumber := JToken.AsValue().AsText();

        if not JObject.Get('id', JToken) or
           JToken.AsValue().IsNull then
            exit;
        CustomerId := JToken.AsValue().AsInteger();

        // Check if mapping already exists
        CustomerMapping.SetRange("Economic Customer Id", CustomerId);
        if not CustomerMapping.FindFirst() then begin
            // Create new mapping
            CustomerMapping.Init();
            CustomerMapping."Economic Customer Id" := CustomerId;
            CustomerMapping."Economic Customer Number" := CustomerNumber;

            // Try to find matching customer by number
            if Customer.Get(CustomerNumber) then
                CustomerMapping.Validate("Customer No.", CustomerNumber);

            CustomerMapping."Last Sync DateTime" := CurrentDateTime;
            CustomerMapping.Insert(true);
        end;
    end;

    local procedure CreateCustomerJson(Customer: Record Customer; var JObject: JsonObject)
    begin
        JObject.Add('name', Customer.Name);
        JObject.Add('customerNumber', Customer."No.");
        // Add more fields as needed
    end;

    local procedure ParseCustomerResponse(ResponseText: Text; var CustomerMapping: Record "Economic Customer Mapping")
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(ResponseText);

        if JObject.Get('id', JToken) then
            CustomerMapping."Economic Customer Id" := JToken.AsValue().AsInteger();

        if JObject.Get('customerNumber', JToken) then
            CustomerMapping."Economic Customer Number" := JToken.AsValue().AsText();

        CustomerMapping."Last Sync DateTime" := CurrentDateTime;
        CustomerMapping.Validate("Sync Status", CustomerMapping."Sync Status"::Synced);
    end;
}