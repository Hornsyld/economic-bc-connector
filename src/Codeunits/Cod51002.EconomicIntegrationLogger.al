codeunit 51002 "Economic Integration Logger"
{
    Access = Internal;

    var
        IntegrationLog: Record "Economic Integration Log";

    procedure LogAPIRequest(RequestMethod: Text; Endpoint: Text; RequestType: Enum "Economic Request Type"; Body: Text): Integer
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
        exit(IntegrationLog."Entry No.");
    end;

    procedure LogAPIResponse(Response: HttpResponseMessage; RequestType: Enum "Economic Request Type"; var ErrorText: Text)
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
        IntegrationLog.Operation := CopyStr(GetResponseReasonPhrase(Response), 1, MaxStrLen(IntegrationLog.Operation));
        IntegrationLog."Description" := CopyStr(StrSubstNo('API Response: %1 %2', Response.HttpStatusCode(), GetResponseReasonPhrase(Response)), 1, MaxStrLen(IntegrationLog."Description"));
        IntegrationLog."Status Code" := Response.HttpStatusCode();

        if not Success then begin
            ErrorText := GetErrorText(Response);
            IntegrationLog."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(IntegrationLog."Error Message"));
        end;

        IntegrationLog."User ID" := CopyStr(UserId, 1, MaxStrLen(IntegrationLog."User ID"));
        IntegrationLog.Insert(true);
    end;

    procedure LogError(RequestType: Enum "Economic Request Type"; ErrorText: Text; Context: Text)
    begin
        IntegrationLog.Init();
        IntegrationLog."Entry No." := GetNextLogEntryNo();
        IntegrationLog."Request Type" := RequestType;
        IntegrationLog."Event Type" := IntegrationLog."Event Type"::Error;
        IntegrationLog.Operation := CopyStr(Context, 1, MaxStrLen(IntegrationLog.Operation));
        IntegrationLog."Description" := CopyStr(StrSubstNo('Error in %1: %2', Context, ErrorText), 1, MaxStrLen(IntegrationLog."Description"));
        IntegrationLog."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(IntegrationLog."Error Message"));
        IntegrationLog."Log Timestamp" := CurrentDateTime;
        IntegrationLog."User ID" := CopyStr(UserId, 1, MaxStrLen(IntegrationLog."User ID"));
        IntegrationLog.Insert(true);
    end;

    procedure LogSuccess(Operation: Text; Message: Text)
    begin
        IntegrationLog.Init();
        IntegrationLog."Entry No." := GetNextLogEntryNo();
        IntegrationLog."Event Type" := IntegrationLog."Event Type"::Information;
        IntegrationLog.Operation := CopyStr(Operation, 1, MaxStrLen(IntegrationLog.Operation));
        IntegrationLog."Description" := CopyStr(Message, 1, MaxStrLen(IntegrationLog."Description"));
        IntegrationLog."Log Timestamp" := CurrentDateTime;
        IntegrationLog."User ID" := CopyStr(UserId, 1, MaxStrLen(IntegrationLog."User ID"));
        IntegrationLog.Insert(true);
    end;

    procedure CreateLogEntry(var IntegrationLogRec: Record "Economic Integration Log"; Endpoint: Text; Method: Text; RequestType: Enum "Economic Request Type"): Integer
    begin
        IntegrationLogRec.Init();
        IntegrationLogRec."Entry No." := GetNextLogEntryNo();
        IntegrationLogRec."Request Type" := RequestType;
        IntegrationLogRec."Request URL" := CopyStr(Endpoint, 1, MaxStrLen(IntegrationLogRec."Request URL"));
        IntegrationLogRec.Operation := CopyStr(Method, 1, MaxStrLen(IntegrationLogRec.Operation));
        IntegrationLogRec."Description" := CopyStr(StrSubstNo('%1 %2', Method, Endpoint), 1, MaxStrLen(IntegrationLogRec."Description"));
        IntegrationLogRec."Log Timestamp" := CurrentDateTime;
        IntegrationLogRec."User ID" := CopyStr(UserId, 1, MaxStrLen(IntegrationLogRec."User ID"));
        IntegrationLogRec.Insert(true);
        exit(IntegrationLogRec."Entry No.");
    end;

    procedure UpdateLogEntry(EntryNo: Integer; Success: Boolean; Message: Text)
    begin
        if IntegrationLog.Get(EntryNo) then begin
            IntegrationLog."Event Type" := GetEventTypeFromSuccess(Success);
            IntegrationLog."Description" := CopyStr(Message, 1, MaxStrLen(IntegrationLog."Description"));
            if not Success then
                IntegrationLog."Error Message" := CopyStr(Message, 1, MaxStrLen(IntegrationLog."Error Message"));
            IntegrationLog.Modify(true);
        end;
    end;

    procedure LogSetupError(Operation: Text; ErrorText: Text)
    begin
        IntegrationLog.Init();
        IntegrationLog."Entry No." := GetNextLogEntryNo();
        IntegrationLog."Event Type" := IntegrationLog."Event Type"::Error;
        IntegrationLog.Operation := CopyStr(Operation, 1, MaxStrLen(IntegrationLog.Operation));
        IntegrationLog."Description" := CopyStr(StrSubstNo('Setup Error in %1: %2', Operation, ErrorText), 1, MaxStrLen(IntegrationLog."Description"));
        IntegrationLog."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(IntegrationLog."Error Message"));
        IntegrationLog."Log Timestamp" := CurrentDateTime;
        IntegrationLog."User ID" := CopyStr(UserId, 1, MaxStrLen(IntegrationLog."User ID"));
        IntegrationLog.Insert(true);
    end;

    procedure LogAPICall(Operation: Text; Response: HttpResponseMessage; ResponseContent: Text)
    var
        Success: Boolean;
        StatusCodeText: Text;
        EventType: Option Information,Warning,Error;
    begin
        Success := Response.IsSuccessStatusCode();
        StatusCodeText := Format(Response.HttpStatusCode());

        if Success then
            EventType := IntegrationLog."Event Type"::Information
        else
            EventType := IntegrationLog."Event Type"::Error;

        IntegrationLog.Init();
        IntegrationLog."Entry No." := GetNextLogEntryNo();
        IntegrationLog."Event Type" := EventType;
        IntegrationLog.Operation := CopyStr(Operation, 1, MaxStrLen(IntegrationLog.Operation));
        IntegrationLog."Description" := CopyStr(StrSubstNo('%1 - Status: %2', Operation, StatusCodeText), 1, MaxStrLen(IntegrationLog."Description"));
        IntegrationLog."Status Code" := Response.HttpStatusCode();
        IntegrationLog."Request URL" := CopyStr(GetResponseUrl(Response), 1, MaxStrLen(IntegrationLog."Request URL"));

        if not Success then
            IntegrationLog."Error Message" := CopyStr(ResponseContent, 1, MaxStrLen(IntegrationLog."Error Message"));

        IntegrationLog."Log Timestamp" := CurrentDateTime;
        IntegrationLog."User ID" := CopyStr(UserId, 1, MaxStrLen(IntegrationLog."User ID"));
        IntegrationLog.Insert(true);
    end;

    local procedure GetNextLogEntryNo(): Integer
    var
        TempIntegrationLog: Record "Economic Integration Log";
    begin
        if TempIntegrationLog.FindLast() then
            exit(TempIntegrationLog."Entry No." + 1);
        exit(1);
    end;

    local procedure GetEventTypeFromSuccess(Success: Boolean): Option
    begin
        if Success then
            exit(IntegrationLog."Event Type"::Information);
        exit(IntegrationLog."Event Type"::Error);
    end;

    local procedure GetResponseUrl(Response: HttpResponseMessage): Text
    begin
        // Note: HttpResponseMessage doesn't expose request URL directly
        exit('Economic API');
    end;

    local procedure GetResponseReasonPhrase(Response: HttpResponseMessage): Text
    begin
        exit(Response.ReasonPhrase());
    end;

    local procedure GetErrorText(Response: HttpResponseMessage) ErrorText: Text
    begin
        if not Response.Content().ReadAs(ErrorText) then
            ErrorText := StrSubstNo('HTTP %1: %2', Response.HttpStatusCode(), Response.ReasonPhrase());
    end;
}