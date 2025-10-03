page 51002 "Economic Integration Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Economic Integration Log";
    Caption = 'Economic Integration Log';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number';
                }
                field("Date Time"; Rec."Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the operation was performed';
                }
                field(Operation; Rec.Operation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of operation performed';
                }
                field("Status Code"; Rec."Status Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the HTTP status code received';
                    StyleExpr = StatusStyle;
                }
                field("Status Text"; Rec."Status Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status message';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any error message received';
                }
                field("Request URL"; Rec."Request URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API endpoint called';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewResponse)
            {
                ApplicationArea = All;
                Caption = 'View Response Data';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View the full response data';

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    InStr: InStream;
                    ResponseText: Text;
                begin
                    Rec.CalcFields("Response Data");
                    if not Rec."Response Data".HasValue then
                        exit;

                    Rec."Response Data".CreateInStream(InStr, TextEncoding::UTF8);
                    InStr.ReadText(ResponseText);
                    Message(ResponseText);
                end;
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;

    local procedure SetStatusStyle()
    begin
        if (Rec."Status Code" >= 200) and (Rec."Status Code" < 300) then
            StatusStyle := 'Favorable'
        else if (Rec."Status Code" >= 400) then
            StatusStyle := 'Unfavorable'
        else
            StatusStyle := 'Standard';
    end;
}