page 51000 "Economic Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Economic Setup";
    Caption = 'Economic Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(IntegrationStatus; Format(GetLastLogEntry()))
                {
                    ApplicationArea = All;
                    Caption = 'Last Integration Status';
                    Editable = false;
                    ToolTip = 'Shows the status of the last integration attempt';

                    trigger OnDrillDown()
                    var
                        IntegrationLog: Record "Economic Integration Log";
                        IntegrationLogPage: Page "Economic Integration Log";
                    begin
                        IntegrationLogPage.RunModal();
                    end;
                }
            }
            group(Authentication)
            {
                Caption = 'Authentication';
                field("API Secret Token"; Rec."API Secret Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API Secret Token for e-conomic integration';
                }
                field("Agreement Grant Token"; Rec."Agreement Grant Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Agreement Grant Token for e-conomic integration';
                }
            }
            group("Journal Setup")
            {
                Caption = 'Journal Setup';
                field("Default Journal Template"; Rec."Default Journal Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default general journal template to use for migration';
                }
                field("Default Journal Batch"; Rec."Default Journal Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default general journal batch to use for migration';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenRoleCenter)
            {
                ApplicationArea = All;
                Caption = 'Open Economic Integration Role Center';
                Image = Home;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Open the Economic Integration Role Center for centralized access to all integration features';

                trigger OnAction()
                begin
                    Page.Run(Page::"Economic Role Center");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    local procedure GetLastLogEntry(): Text
    var
        IntegrationLog: Record "Economic Integration Log";
    begin
        IntegrationLog.SetCurrentKey("Entry No.");
        IntegrationLog.SetAscending("Entry No.", false);
        if IntegrationLog.FindFirst() then
            exit(StrSubstNo('%1 - %2 (%3)', IntegrationLog."Log Timestamp", IntegrationLog.Operation, IntegrationLog.Description))
        else
            exit('No integration attempts yet');
    end;
}