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
            group("Entries Configuration")
            {
                Caption = 'Entries Processing';
                field("Default GL Account No."; Rec."Default GL Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default G/L Account for unmapped e-conomic accounts';
                }
                field("Entries Journal Template"; Rec."Entries Journal Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the journal template for entries processing';
                }
                field("Auto Create Journal Batches"; Rec."Auto Create Journal Batches")
                {
                    ApplicationArea = All;
                    ToolTip = 'Automatically create journal batches by posting date';
                }
                field("Auto Post Journals"; Rec."Auto Post Journals")
                {
                    ApplicationArea = All;
                    ToolTip = 'Automatically post journals after creation';
                }
                field("Max Entries Per Batch"; Rec."Max Entries Per Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Maximum number of entries per journal batch (0 = unlimited)';
                }
                field("Use Date Prefix in Doc No."; Rec."Use Date Prefix in Doc No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Prefix document numbers with posting date';
                }
                field("Default Bal. Account Type"; Rec."Default Bal. Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Default balancing account type for entries';
                }
                field("Default Bal. Account No."; Rec."Default Bal. Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Default balancing account number for entries';
                }
            }
            group("Period Configuration")
            {
                Caption = 'Synchronization Period';
                field("Use Demo Data Year"; Rec."Use Demo Data Year")
                {
                    ApplicationArea = All;
                    ToolTip = 'Use demo data year instead of sync period configuration';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Demo Data Year"; Rec."Demo Data Year")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specific year for demo/testing data (e.g., 2022)';
                    Enabled = Rec."Use Demo Data Year";
                }
                group("Advanced Period Setup")
                {
                    Caption = 'Advanced Period Setup';
                    Visible = not Rec."Use Demo Data Year";

                    field("Entries Sync Years Count"; Rec."Entries Sync Years Count")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Number of years to synchronize (alternative to From/To Year setup)';
                    }
                    field("Entries Sync From Year"; Rec."Entries Sync From Year")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Starting accounting year for entries synchronization';
                        Enabled = Rec."Entries Sync Years Count" = 0;
                    }
                    field("Entries Sync To Year"; Rec."Entries Sync To Year")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Ending accounting year for entries synchronization (0 = current year)';
                        Enabled = Rec."Entries Sync Years Count" = 0;
                    }
                    field("Entries Sync Period Filter"; Rec."Entries Sync Period Filter")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Custom period filter for entries API (advanced users)';
                        MultiLine = true;
                    }
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
            action(TestPeriodConfiguration)
            {
                ApplicationArea = All;
                Caption = 'Test Period Configuration';
                Image = TestReport;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Test the current period configuration and show which years will be synchronized';

                trigger OnAction()
                var
                    YearsList: List of [Integer];
                    UrlsList: List of [Text];
                    Year: Integer;
                    Url: Text;
                    MessageText: Text;
                    YearFilter: Text;
                    APIFilter: Text;
                    LineBreak: Text;
                begin
                    if not Rec.ValidatePeriodConfiguration() then begin
                        Message('Period configuration is not valid. Please configure either Demo Data Year or sync period settings.');
                        exit;
                    end;

                    YearsList := Rec.GetAccountingYearsToSync();
                    YearFilter := Rec.GetAccountingYearFilter();
                    APIFilter := Rec.GetEntriesAPIFilter();
                    UrlsList := Rec.GetEntriesAPIUrls('https://restapi.e-conomic.com');
                    LineBreak := '\';

                    MessageText := 'Period Configuration Test:' + LineBreak;
                    MessageText += 'Years to synchronize: ';

                    foreach Year in YearsList do begin
                        if MessageText <> 'Period Configuration Test:' + LineBreak + 'Years to synchronize: ' then
                            MessageText += ', ';
                        MessageText += Format(Year);
                    end;

                    MessageText += LineBreak + LineBreak;
                    MessageText += 'API URLs that will be called:' + LineBreak;

                    foreach Url in UrlsList do begin
                        MessageText += '• ' + Url + LineBreak;
                    end;

                    MessageText += LineBreak + 'Legacy Filter (deprecated): ' + APIFilter;

                    Message(MessageText);
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