codeunit 51001 "Economic HTTP Client"
{
    Access = Internal;

    var
        Client: HttpClient;
        IsInitialized: Boolean;
        Logger: Codeunit "Economic Integration Logger";

    procedure InitializeClient() Success: Boolean
    var
        EconomicSetup: Record "Economic Setup";
        Headers: HttpHeaders;
        ErrorText: Text;
    begin
        Success := false;
        
        if not EconomicSetup.Get() then begin
            Logger.LogSetupError('InitializeClient', 'Economic Setup record does not exist');
            exit(false);
        end;

        if not ValidateSetup(EconomicSetup) then
            exit(false);

        Clear(Client);
        Client.Clear();
        
        // Set default headers
        Client.DefaultRequestHeaders().Clear();
        Client.DefaultRequestHeaders().Add('Accept', 'application/json');
        
        // Add authentication headers for e-conomic API
        Client.DefaultRequestHeaders().Add('X-AppSecretToken', EconomicSetup."API Secret Token");
        Client.DefaultRequestHeaders().Add('X-AgreementGrantToken', EconomicSetup."Agreement Grant Token");
        LogAuthenticationHeaders();

        IsInitialized := true;
        Success := true;
        Logger.LogSuccess('InitializeClient', 'HTTP Client initialized successfully');
    end;

    procedure SendGetRequest(Endpoint: Text; var ResponseContent: Text; RequestType: Enum "Economic Request Type") Success: Boolean
    var
        Response: HttpResponseMessage;
        ErrorText: Text;
    begin
        Success := false;
        
        if not IsInitialized then
            if not InitializeClient() then
                exit(false);

        Logger.LogAPIRequest('GET', Endpoint, RequestType, '');

        if not Client.Get(Endpoint, Response) then begin
            Logger.LogError(RequestType, 'HTTP GET request failed', 'SendGetRequest');
            exit(false);
        end;

        Logger.LogAPIResponse(Response, RequestType, ErrorText);
        
        if not Response.IsSuccessStatusCode() then begin
            Logger.LogError(RequestType, ErrorText, 'SendGetRequest');
            exit(false);
        end;

        if not Response.Content().ReadAs(ResponseContent) then begin
            Logger.LogError(RequestType, 'Failed to read response content', 'SendGetRequest');
            exit(false);
        end;

        Success := true;
    end;

    procedure SendPostRequest(Endpoint: Text; RequestBody: Text; var ResponseContent: Text; RequestType: Enum "Economic Request Type") Success: Boolean
    var
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        ErrorText: Text;
    begin
        Success := false;
        
        if not IsInitialized then
            if not InitializeClient() then
                exit(false);

        Logger.LogAPIRequest('POST', Endpoint, RequestType, RequestBody);

        Content.WriteFrom(RequestBody);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        if not Client.Post(Endpoint, Content, Response) then begin
            Logger.LogError(RequestType, 'HTTP POST request failed', 'SendPostRequest');
            exit(false);
        end;

        Logger.LogAPIResponse(Response, RequestType, ErrorText);
        
        if not Response.IsSuccessStatusCode() then begin
            Logger.LogError(RequestType, ErrorText, 'SendPostRequest');
            exit(false);
        end;

        if not Response.Content().ReadAs(ResponseContent) then begin
            Logger.LogError(RequestType, 'Failed to read response content', 'SendPostRequest');
            exit(false);
        end;

        Success := true;
    end;

    procedure SendPutRequest(Endpoint: Text; RequestBody: Text; var ResponseContent: Text; RequestType: Enum "Economic Request Type") Success: Boolean
    var
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        ErrorText: Text;
    begin
        Success := false;
        
        if not IsInitialized then
            if not InitializeClient() then
                exit(false);

        Logger.LogAPIRequest('PUT', Endpoint, RequestType, RequestBody);

        Content.WriteFrom(RequestBody);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        if not Client.Put(Endpoint, Content, Response) then begin
            Logger.LogError(RequestType, 'HTTP PUT request failed', 'SendPutRequest');
            exit(false);
        end;

        Logger.LogAPIResponse(Response, RequestType, ErrorText);
        
        if not Response.IsSuccessStatusCode() then begin
            Logger.LogError(RequestType, ErrorText, 'SendPutRequest');
            exit(false);
        end;

        if not Response.Content().ReadAs(ResponseContent) then begin
            Logger.LogError(RequestType, 'Failed to read response content', 'SendPutRequest');
            exit(false);
        end;

        Success := true;
    end;

    procedure SendDeleteRequest(Endpoint: Text; var ResponseContent: Text; RequestType: Enum "Economic Request Type") Success: Boolean
    var
        Response: HttpResponseMessage;
        ErrorText: Text;
    begin
        Success := false;
        
        if not IsInitialized then
            if not InitializeClient() then
                exit(false);

        Logger.LogAPIRequest('DELETE', Endpoint, RequestType, '');

        if not Client.Delete(Endpoint, Response) then begin
            Logger.LogError(RequestType, 'HTTP DELETE request failed', 'SendDeleteRequest');
            exit(false);
        end;

        Logger.LogAPIResponse(Response, RequestType, ErrorText);
        
        if not Response.IsSuccessStatusCode() then begin
            Logger.LogError(RequestType, ErrorText, 'SendDeleteRequest');
            exit(false);
        end;

        if not Response.Content().ReadAs(ResponseContent) then begin
            Logger.LogError(RequestType, 'Failed to read response content', 'SendDeleteRequest');
            exit(false);
        end;

        Success := true;
    end;

    procedure GetBaseUrl(): Text
    begin
        // Base URL is hardcoded for e-conomic API
        exit('https://restapi.e-conomic.com');
    end;

    procedure IsClientInitialized(): Boolean
    begin
        exit(IsInitialized);
    end;

    procedure ResetClient()
    begin
        Clear(Client);
        IsInitialized := false;
    end;

    local procedure ValidateSetup(var EconomicSetup: Record "Economic Setup") Success: Boolean
    begin
        Success := true;
        
        if EconomicSetup."API Secret Token" = '' then begin
            Logger.LogSetupError('ValidateSetup', 'API Secret Token is not configured');
            Success := false;
        end;
        
        if EconomicSetup."Agreement Grant Token" = '' then begin
            Logger.LogSetupError('ValidateSetup', 'Agreement Grant Token is not configured');
            Success := false;
        end;
    end;

    local procedure LogAuthenticationHeaders()
    begin
        Logger.LogSuccess('Authentication', 'Authentication headers configured successfully');
    end;
}