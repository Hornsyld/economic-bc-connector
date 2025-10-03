page 51002 "Economic Integration Log"
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
                field(Timestamp; Rec."Log Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this log entry was created.';
                }
                field("Event Type"; Rec."Event Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of event (Information, Warning, Error).';
                }
                field("Record Type"; Rec."Record Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of record that was processed.';
                }
                field("Record ID"; Rec."Record ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the record that was processed.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the operation.';
                }
                field("Operation"; Rec."Operation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of operation performed.';
                }
                field("Status Code"; Rec."Status Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the HTTP status code if applicable.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any error message.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who performed the operation.';
                }
            }
        }
        area(FactBoxes)
        {
            systempart("Links"; Links)
            {
                ApplicationArea = All;
            }
            systempart("Notes"; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ClearLog)
            {
                ApplicationArea = All;
                Caption = 'Clear Log';
                Image = ClearLog;
                ToolTip = 'Clears all log entries.';
                
                trigger OnAction()
                begin
                    if Confirm('Do you want to clear all log entries?') then begin
                        Rec.DeleteAll();
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(ExportLog)
            {
                ApplicationArea = All;
                Caption = 'Export Log';
                Image = Export;
                ToolTip = 'Exports the log entries to a file.';
                
                trigger OnAction()
                begin
                    Message('Export functionality will be implemented.');
                end;
            }
        }
        area(Navigation)
        {
            action(ShowRecord)
            {
                ApplicationArea = All;
                Caption = 'Show Record';
                Image = ShowList;
                ToolTip = 'Shows the record that was processed.';
                
                trigger OnAction()
                begin
                    if Format(Rec."Record ID") <> '' then
                        Message('Record ID: %1', Rec."Record ID");
                end;
            }
        }
    }
}