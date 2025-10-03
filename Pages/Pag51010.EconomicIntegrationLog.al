page 51010 "Economic Integration Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Economic Integration Log";
    Caption = 'Economic Integration Log';
    Editable = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(LogEntries)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number of the log entry.';
                }
                field(Timestamp; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this log entry was created.';
                }
                field("Event Type"; Rec."Event Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of event that occurred.';
                    StyleExpr = EventTypeStyle;
                }
                field("Record Type"; Rec."Record Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of record that was affected.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of what happened.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message if an error occurred.';
                    Visible = false;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who initiated the operation.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        StyleText: Text;
    begin
        case Rec."Event Type" of
            Rec."Event Type"::Information:
                StyleText := 'Standard';
            Rec."Event Type"::Warning:
                StyleText := 'Attention';
            Rec."Event Type"::Error:
                StyleText := 'Unfavorable';
            else
                StyleText := 'Standard';
        end;
        EventTypeStyle := StyleText;
    end;

    var
        EventTypeStyle: Text;
}