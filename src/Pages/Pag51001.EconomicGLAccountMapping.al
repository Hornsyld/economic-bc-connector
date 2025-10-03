page 51001 "Economic GL Account Mapping"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Economic GL Account Mapping";
    Caption = 'Migration Account Mapping';
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = true;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                IndentationColumn = Rec.Indentation;
                ShowAsTree = true;

                field("Economic Account No."; Rec."Economic Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the account number from e-conomic';
                    StyleExpr = AccountStyleTxt;
                }
                field("Economic Account Name"; Rec."Economic Account Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the account name from e-conomic';
                    StyleExpr = AccountStyleTxt;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of account from e-conomic';
                    StyleExpr = AccountStyleTxt;
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the current balance of the account';
                    StyleExpr = AccountStyleTxt;
                }
                field("Total From Account"; Rec."Total From Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the account that this account totals from';
                    StyleExpr = AccountStyleTxt;
                }
                field("BC Account No."; Rec."BC Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mapped Business Central G/L Account number';
                    StyleExpr = StatusStyleTxt;

                    trigger OnAssistEdit()
                    begin
                        // Temporary solution until G/L Account lookup is available
                        Message('Please enter the G/L Account number manually for now. Lookup will be available after publishing.');
                    end;
                }
                field("BC Account Name"; Rec."BC Account Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the name of the mapped Business Central G/L Account';
                }
                field("Entry Count"; Rec."Entry Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the number of entries for this account in e-conomic';
                    Visible = false; // Temporarily hidden until entry staging is implemented
                }
                field("Migration Status"; Rec."Migration Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the current status of the migration for this account';
                    StyleExpr = StatusStyleTxt;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetAccounts)
            {
                ApplicationArea = All;
                Caption = 'Get Accounts';
                Image = Account;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Retrieve accounts from e-conomic';

                trigger OnAction()
                begin
                    GetAccountsFromEconomic();
                end;
            }

            action(CreateJournalEntries)
            {
                ApplicationArea = All;
                Caption = 'Create General Journal Entries';
                Image = GeneralLedger;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create general journal entries based on the mapped accounts';

                trigger OnAction()
                begin
                    CreateGeneralJournalEntries();
                end;
            }

            action(CreateGLAccounts)
            {
                ApplicationArea = All;
                Caption = 'Create G/L Accounts';
                Image = NewChartOfAccounts;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create Business Central G/L Accounts from the mapped e-conomic accounts';

                trigger OnAction()
                var
                    EconomicManagement: Codeunit "Economic Management";
                begin
                    if Confirm('Do you want to create G/L Accounts in Business Central from the mapped e-conomic accounts?\This will create actual G/L Account records based on the mapping information.') then
                        EconomicManagement.CreateGLAccountsFromMapping();
                end;
            }
            action(DeleteAllRecords)
            {
                ApplicationArea = All;
                Caption = 'Delete All Records';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Delete all account mapping records';

                trigger OnAction()
                var
                    EconomicGLAccountMapping: Record "Economic GL Account Mapping";
                    DeletedCount: Integer;
                begin
                    if not Confirm('Are you sure you want to delete ALL account mapping records?\This action cannot be undone.') then
                        exit;

                    if EconomicGLAccountMapping.FindSet() then begin
                        repeat
                            DeletedCount += 1;
                        until EconomicGLAccountMapping.Next() = 0;
                        
                        EconomicGLAccountMapping.DeleteAll();
                        Message('Successfully deleted %1 account mapping records.', DeletedCount);
                        CurrPage.Update(false);
                    end else
                        Message('No records found to delete.');
                end;
            }
            action(DeleteSelectedRecords)
            {
                ApplicationArea = All;
                Caption = 'Delete Selected Records';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Delete the currently selected account mapping records';

                trigger OnAction()
                var
                    EconomicGLAccountMapping: Record "Economic GL Account Mapping";
                    SelectedRecord: Record "Economic GL Account Mapping";
                    DeletedCount: Integer;
                begin
                    CurrPage.SetSelectionFilter(SelectedRecord);
                    
                    if not SelectedRecord.FindSet() then begin
                        Message('No records selected for deletion.');
                        exit;
                    end;

                    if not Confirm('Are you sure you want to delete the selected account mapping records?\This action cannot be undone.') then
                        exit;

                    repeat
                        EconomicGLAccountMapping.Get(SelectedRecord."Economic Account No.");
                        EconomicGLAccountMapping.Delete();
                        DeletedCount += 1;
                    until SelectedRecord.Next() = 0;

                    Message('Successfully deleted %1 account mapping records.', DeletedCount);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        StatusStyleTxt: Text;
        AccountStyleTxt: Text;

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
        SetAccountStyle();
    end;

    local procedure SetStatusStyle()
    begin
        StatusStyleTxt := GetStatusStyleText(Rec."Migration Status");
    end;

    local procedure SetAccountStyle()
    begin
        // Set the style based on account type
        case Rec."Account Type" of
            Rec."Account Type"::heading,
            Rec."Account Type"::headingStart:
                AccountStyleTxt := 'Strong';
            Rec."Account Type"::totalFrom:
                AccountStyleTxt := 'StrongAccent';
            Rec."Account Type"::sumInterval,
            Rec."Account Type"::sumAlpha:
                AccountStyleTxt := 'AccentText';
            else
                AccountStyleTxt := 'Standard';
        end;

        // Override style for blocked accounts
        if Rec."Block Direct Entries" then
            AccountStyleTxt := 'Subordinate';
    end;

    local procedure GetStatusStyleText(Status: Option "Not Started","In Progress",Completed,Error): Text
    begin
        case Status of
            Status::"Not Started":
                exit('Standard');
            Status::"In Progress":
                exit('Attention');
            Status::Completed:
                exit('Favorable');
            Status::Error:
                exit('Unfavorable');
        end;
    end;

    local procedure GetAccountsFromEconomic()
    var
        EconomicMgt: Codeunit "Economic Management";
    begin
        EconomicMgt.GetAccounts();
    end;

    local procedure CreateGeneralJournalEntries()
    var
        EconomicMgt: Codeunit "Economic Management";
    begin
        EconomicMgt.CreateGeneralJournalEntries();
    end;
}