codeunit 51003 "Economic Data Processor"
{
    Access = Internal;

    var
        Logger: Codeunit "Economic Integration Logger";
        HttpClient: Codeunit "Economic HTTP Client";

    procedure GetCustomers() Success: Boolean
    var
        ResponseContent: Text;
        RequestType: Enum "Economic Request Type";
        ProgressDialog: Dialog;
    begin
        ProgressDialog.Open('Fetching customers from e-conomic API...');
        
        RequestType := RequestType::Customer;
        Success := HttpClient.SendGetRequest(HttpClient.GetBaseUrl() + '/customers', ResponseContent, RequestType);
        
        ProgressDialog.Close();
        
        if Success then
            Success := ProcessCustomerJson(ResponseContent);
    end;

    procedure GetVendors() Success: Boolean
    var
        ResponseContent: Text;
        RequestType: Enum "Economic Request Type";
        ProgressDialog: Dialog;
    begin
        ProgressDialog.Open('Fetching vendors from e-conomic API...');
        
        RequestType := RequestType::Vendor;
        Success := HttpClient.SendGetRequest(HttpClient.GetBaseUrl() + '/suppliers', ResponseContent, RequestType);
        
        ProgressDialog.Close();
        
        if Success then
            Success := ProcessVendorJson(ResponseContent);
    end;

    procedure ProcessCustomerJson(JsonText: Text) Success: Boolean
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        CustomerToken: JsonToken;
        CustomerObject: JsonObject;
        EconomicCustomerMapping: Record "Economic Customer Mapping";
        CustomerCount: Integer;
        ProcessedCount: Integer;
        ProgressDialog: Dialog;
        ProgressText: Text;
    begin
        Success := false;
        
        if not JsonObject.ReadFrom(JsonText) then begin
            Logger.LogError(Enum::"Economic Request Type"::Customer, 'Invalid JSON format in customer response', 'ProcessCustomerJson');
            exit(false);
        end;

        if not JsonObject.Get('collection', JsonToken) then begin
            Logger.LogError(Enum::"Economic Request Type"::Customer, 'Collection property not found in JSON', 'ProcessCustomerJson');
            exit(false);
        end;

        if not JsonToken.IsArray() then begin
            Logger.LogError(Enum::"Economic Request Type"::Customer, 'Collection is not an array', 'ProcessCustomerJson');
            exit(false);
        end;

        JsonArray := JsonToken.AsArray();
        CustomerCount := JsonArray.Count();
        
        if CustomerCount = 0 then begin
            Logger.LogSuccess('ProcessCustomerJson', 'No customers found in response');
            exit(true);
        end;

        // Show progress dialog
        ProgressDialog.Open('Processing customers from e-conomic...\Progress: #1##################\Customer: #2##################');
        
        foreach CustomerToken in JsonArray do begin
            if CustomerToken.IsObject() then begin
                CustomerObject := CustomerToken.AsObject();
                
                // Update progress dialog
                ProcessedCount += 1;
                ProgressText := StrSubstNo('%1 of %2', ProcessedCount, CustomerCount);
                ProgressDialog.Update(1, ProgressText);
                ProgressDialog.Update(2, GetCustomerDisplayName(CustomerObject));
                
                if not ProcessSingleCustomer(CustomerObject, EconomicCustomerMapping) then
                    ProcessedCount -= 1; // Adjust count if processing failed
            end;
        end;
        
        ProgressDialog.Close();

        Logger.LogSuccess('ProcessCustomerJson', StrSubstNo('Successfully fetched %1 customers from e-conomic', CustomerCount));
        Success := true;
    end;

    procedure ProcessVendorJson(JsonText: Text) Success: Boolean
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        VendorToken: JsonToken;
        VendorObject: JsonObject;
        EconomicVendorMapping: Record "Economic Vendor Mapping";
        VendorCount: Integer;
        ProcessedCount: Integer;
        ProgressDialog: Dialog;
        ProgressText: Text;
    begin
        Success := false;
        
        if not JsonObject.ReadFrom(JsonText) then begin
            Logger.LogError(Enum::"Economic Request Type"::Vendor, 'Invalid JSON format in vendor response', 'ProcessVendorJson');
            exit(false);
        end;

        if not JsonObject.Get('collection', JsonToken) then begin
            Logger.LogError(Enum::"Economic Request Type"::Vendor, 'Collection property not found in JSON', 'ProcessVendorJson');
            exit(false);
        end;

        if not JsonToken.IsArray() then begin
            Logger.LogError(Enum::"Economic Request Type"::Vendor, 'Collection is not an array', 'ProcessVendorJson');
            exit(false);
        end;

        JsonArray := JsonToken.AsArray();
        VendorCount := JsonArray.Count();
        
        if VendorCount = 0 then begin
            Logger.LogSuccess('ProcessVendorJson', 'No vendors found in response');
            exit(true);
        end;

        // Show progress dialog
        ProgressDialog.Open('Processing vendors from e-conomic...\Progress: #1##################\Vendor: #2##################');
        
        foreach VendorToken in JsonArray do begin
            if VendorToken.IsObject() then begin
                VendorObject := VendorToken.AsObject();
                
                // Update progress dialog
                ProcessedCount += 1;
                ProgressText := StrSubstNo('%1 of %2', ProcessedCount, VendorCount);
                ProgressDialog.Update(1, ProgressText);
                ProgressDialog.Update(2, GetVendorDisplayName(VendorObject));
                
                if not ProcessSingleVendor(VendorObject, EconomicVendorMapping) then
                    ProcessedCount -= 1; // Adjust count if processing failed
            end;
        end;
        
        ProgressDialog.Close();

        Logger.LogSuccess('ProcessVendorJson', StrSubstNo('Successfully fetched %1 vendors from e-conomic', VendorCount));
        Success := true;
    end;

    procedure CreateCustomerFromMapping(var CustomerMapping: Record "Economic Customer Mapping") Success: Boolean
    var
        Customer: Record Customer;
        CustomerNo: Code[20];
    begin
        Success := false;
        
        if CustomerMapping."Economic Customer Id" = 0 then begin
            Logger.LogError(Enum::"Economic Request Type"::Customer, 'Economic Customer Id is required', 'CreateCustomerFromMapping');
            exit(false);
        end;

        // Check if customer already exists
        if Customer.Get(CustomerMapping."Customer No.") then begin
            Logger.LogSuccess('CreateCustomerFromMapping', StrSubstNo('Customer %1 already exists', CustomerMapping."Customer No."));
            CustomerMapping."Sync Status" := CustomerMapping."Sync Status"::Synced;
            CustomerMapping.Modify(true);
            exit(true);
        end;

        // Generate customer number if needed
        CustomerNo := CustomerMapping."Customer No.";
        if CustomerNo = '' then
            CustomerNo := CustomerMapping.SuggestCustomerNo();

        // Create new customer
        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Name := CopyStr(CustomerMapping."Economic Customer Name", 1, MaxStrLen(Customer.Name));
        Customer.Address := CopyStr(CustomerMapping."Economic Address", 1, MaxStrLen(Customer.Address));
        Customer.City := CopyStr(CustomerMapping."Economic City", 1, MaxStrLen(Customer.City));
        Customer."Post Code" := CopyStr(CustomerMapping."Economic Post Code", 1, MaxStrLen(Customer."Post Code"));
        Customer."Phone No." := CopyStr(CustomerMapping."Economic Phone", 1, MaxStrLen(Customer."Phone No."));
        Customer."E-Mail" := CopyStr(CustomerMapping."Economic Email", 1, MaxStrLen(Customer."E-Mail"));
        Customer."VAT Registration No." := CopyStr(CustomerMapping."Economic VAT Number", 1, MaxStrLen(Customer."VAT Registration No."));

        if not Customer.Insert(true) then begin
            Logger.LogError(Enum::"Economic Request Type"::Customer, GetLastErrorText(), 'CreateCustomerFromMapping');
            exit(false);
        end;

        // Update mapping record
        CustomerMapping."Customer No." := Customer."No.";
        CustomerMapping."Sync Status" := CustomerMapping."Sync Status"::Synced;
        CustomerMapping.Modify(true);

        Logger.LogSuccess('CreateCustomerFromMapping', StrSubstNo('Customer %1 created successfully from Economic Customer Id %2', Customer."No.", CustomerMapping."Economic Customer Id"));
        Success := true;
    end;

    procedure CreateBulkCustomersFromMappings(var CustomerMappings: Record "Economic Customer Mapping") ProcessedCount: Integer
    var
        Customer: Record Customer;
        Window: Dialog;
        TotalCount: Integer;
        CurrentCount: Integer;
    begin
        ProcessedCount := 0;
        
        if not CustomerMappings.FindSet() then
            exit(0);

        TotalCount := CustomerMappings.Count();
        Window.Open('Creating customers...\Progress: #1########## of #2##########');
        
        repeat
            CurrentCount += 1;
            Window.Update(1, CurrentCount);
            Window.Update(2, TotalCount);
            
            if CustomerMappings."Sync Status" <> CustomerMappings."Sync Status"::Synced then begin
                if CreateCustomerFromMapping(CustomerMappings) then
                    ProcessedCount += 1;
            end else
                ProcessedCount += 1; // Already synced
                
        until CustomerMappings.Next() = 0;
        
        Window.Close();
        Logger.LogSuccess('CreateBulkCustomersFromMappings', StrSubstNo('Processed %1 of %2 customer mappings', ProcessedCount, TotalCount));
    end;

    local procedure ProcessSingleCustomer(CustomerObject: JsonObject; var EconomicCustomerMapping: Record "Economic Customer Mapping") Success: Boolean
    var
        EconomicCustomerId: Integer;
    begin
        Success := false;

        // Get Economic Customer ID
        EconomicCustomerId := GetJsonValueAsInteger(CustomerObject, 'customerNumber');
        if EconomicCustomerId = 0 then begin
            Logger.LogError(Enum::"Economic Request Type"::Customer, 'customerNumber not found or invalid in customer object', 'ProcessSingleCustomer');
            exit(false);
        end;

        // Initialize or get existing mapping record
        if not EconomicCustomerMapping.Get(EconomicCustomerId) then begin
            EconomicCustomerMapping.Init();
            EconomicCustomerMapping."Economic Customer Id" := EconomicCustomerId;
        end;

        // Map all available fields
        MapCustomerFields(CustomerObject, EconomicCustomerMapping);

        // Set sync status
        EconomicCustomerMapping."Sync Status" := EconomicCustomerMapping."Sync Status"::New;

        // Insert or modify record
        if EconomicCustomerMapping."Economic Customer Id" <> 0 then begin
            if not EconomicCustomerMapping.Insert(true) then
                EconomicCustomerMapping.Modify(true);
            Success := true;
        end;
    end;

    local procedure ProcessSingleVendor(VendorObject: JsonObject; var EconomicVendorMapping: Record "Economic Vendor Mapping") Success: Boolean
    var
        EconomicVendorId: Integer;
    begin
        Success := false;

        // Get Economic Vendor ID
        EconomicVendorId := GetJsonValueAsInteger(VendorObject, 'supplierNumber');
        if EconomicVendorId = 0 then begin
            Logger.LogError(Enum::"Economic Request Type"::Vendor, 'supplierNumber not found or invalid in vendor object', 'ProcessSingleVendor');
            exit(false);
        end;

        // Initialize or get existing mapping record
        if not EconomicVendorMapping.Get(EconomicVendorId) then begin
            EconomicVendorMapping.Init();
            EconomicVendorMapping."Economic Vendor Id" := EconomicVendorId;
        end;

        // Map all available fields
        MapVendorFields(VendorObject, EconomicVendorMapping);

        // Set sync status
        EconomicVendorMapping."Sync Status" := EconomicVendorMapping."Sync Status"::New;

        // Insert or modify record
        if EconomicVendorMapping."Economic Vendor Id" <> 0 then begin
            if not EconomicVendorMapping.Insert(true) then
                EconomicVendorMapping.Modify(true);
            Success := true;
        end;
    end;

    local procedure MapCustomerFields(CustomerObject: JsonObject; var CustomerMapping: Record "Economic Customer Mapping")
    begin
        // Basic information using correct field names
        CustomerMapping."Economic Customer Name" := CopyStr(GetJsonValueAsText(CustomerObject, 'name'), 1, MaxStrLen(CustomerMapping."Economic Customer Name"));
        CustomerMapping."Economic Corporate ID" := CopyStr(GetJsonValueAsText(CustomerObject, 'corporateIdentificationNumber'), 1, MaxStrLen(CustomerMapping."Economic Corporate ID"));
        CustomerMapping."Economic Email" := CopyStr(GetJsonValueAsText(CustomerObject, 'email'), 1, MaxStrLen(CustomerMapping."Economic Email"));
        CustomerMapping."Economic Phone" := CopyStr(GetJsonValueAsText(CustomerObject, 'telephoneAndFaxNumber'), 1, MaxStrLen(CustomerMapping."Economic Phone"));

        // Address information
        CustomerMapping."Economic Address" := CopyStr(GetJsonValueAsText(CustomerObject, 'address'), 1, MaxStrLen(CustomerMapping."Economic Address"));
        CustomerMapping."Economic City" := CopyStr(GetJsonValueAsText(CustomerObject, 'city'), 1, MaxStrLen(CustomerMapping."Economic City"));
        CustomerMapping."Economic Post Code" := CopyStr(GetJsonValueAsText(CustomerObject, 'zip'), 1, MaxStrLen(CustomerMapping."Economic Post Code"));

        // VAT and business information
        CustomerMapping."Economic VAT Number" := CopyStr(GetJsonValueAsText(CustomerObject, 'vatNumber'), 1, MaxStrLen(CustomerMapping."Economic VAT Number"));
        
        // Additional fields that may be available
        CustomerMapping."Economic Currency Code" := CopyStr(GetJsonValueAsText(CustomerObject, 'currency'), 1, MaxStrLen(CustomerMapping."Economic Currency Code"));
        CustomerMapping."Economic Credit Limit" := GetJsonValueAsDecimal(CustomerObject, 'creditLimit');
        CustomerMapping."Economic Payment Terms" := CopyStr(GetJsonValueAsText(CustomerObject, 'paymentTerms'), 1, MaxStrLen(CustomerMapping."Economic Payment Terms"));
        CustomerMapping."Economic Customer Group" := CopyStr(GetJsonValueAsText(CustomerObject, 'customerGroup'), 1, MaxStrLen(CustomerMapping."Economic Customer Group"));
    end;

    local procedure MapVendorFields(VendorObject: JsonObject; var VendorMapping: Record "Economic Vendor Mapping")
    begin
        // Basic information - this would need the actual vendor mapping table structure
        // For now, just log that vendor processing is available
        Logger.LogSuccess('MapVendorFields', 'Vendor field mapping available for implementation');
    end;

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

    local procedure GetJsonValueAsDecimal(JsonObject: JsonObject; PropertyName: Text) PropertyValue: Decimal
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(PropertyName, JsonToken) and JsonToken.IsValue() then
            PropertyValue := JsonToken.AsValue().AsDecimal()
        else
            PropertyValue := 0;
    end;

    local procedure GetCustomerDisplayName(CustomerObject: JsonObject) DisplayName: Text
    var
        CustomerName: Text;
        CustomerNumber: Text;
    begin
        CustomerName := GetJsonValueAsText(CustomerObject, 'name');
        CustomerNumber := GetJsonValueAsText(CustomerObject, 'customerNumber');
        
        if CustomerName <> '' then
            DisplayName := StrSubstNo('%1 (%2)', CustomerName, CustomerNumber)
        else
            DisplayName := StrSubstNo('Customer %1', CustomerNumber);
    end;

    local procedure GetVendorDisplayName(VendorObject: JsonObject) DisplayName: Text
    var
        VendorName: Text;
        SupplierNumber: Text;
    begin
        VendorName := GetJsonValueAsText(VendorObject, 'name');
        SupplierNumber := GetJsonValueAsText(VendorObject, 'supplierNumber');
        
        if VendorName <> '' then
            DisplayName := StrSubstNo('%1 (%2)', VendorName, SupplierNumber)
        else
            DisplayName := StrSubstNo('Vendor %1', SupplierNumber);
    end;
}