page 51031 "Economic Entry Processing List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Economic Entry Processing";
    Caption = 'Economic Entry Processing';

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number in the processing table.';
                }
                field("Landing Entry No."; Rec."Landing Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reference to the Economic Entries Landing record.';
                }
                field("Economic Entry Number"; Rec."Economic Entry Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the original entry number from e-conomic.';
                }
                field("Economic Account Number"; Rec."Economic Account Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the e-conomic account number.';
                }
                field("BC Account Type"; Rec."BC Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central account type.';
                }
                field("BC Account No."; Rec."BC Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central account number.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry amount.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry amount in local currency.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency code.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posting date for this entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description for this entry.';
                }
                field("Validation Status"; Rec."Validation Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the validation status of this entry.';
                }
                field("Validation Error"; Rec."Validation Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any validation error for this entry.';
                    Style = Unfavorable;
                    StyleExpr = Rec."Validation Error" <> '';
                }
                field("BC Journal Template"; Rec."BC Journal Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central journal template to use.';
                }
                field("BC Journal Batch"; Rec."BC Journal Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central journal batch to use.';
                }
                field("Journal Lines Created"; Rec."Journal Lines Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether journal lines have been created for this entry.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ValidateEntry)
            {
                ApplicationArea = All;
                Caption = 'Validate Entry';
                Image = TestReport;
                ToolTip = 'Validate this entry for Business Central integration.';

                trigger OnAction()
                begin
                    if Rec.ValidateEntry() then
                        Message('Entry %1 validated successfully.', Rec."Entry No.")
                    else
                        Message('Entry %1 validation failed: %2', Rec."Entry No.", Rec."Validation Error");
                    CurrPage.Update();
                end;
            }
            action(CreateJournalLines)
            {
                ApplicationArea = All;
                Caption = 'Create Journal Lines';
                Image = CreateLinesFromJob;
                ToolTip = 'Create journal lines from this validated entry.';
                Enabled = Rec."Validation Status" = Rec."Validation Status"::Validated;

                trigger OnAction()
                begin
                    if Rec.CreateJournalLines() then
                        Message('Journal lines created successfully for entry %1.', Rec."Entry No.")
                    else
                        Message('Failed to create journal lines for entry %1.', Rec."Entry No.");
                    CurrPage.Update();
                end;
            }
            action(ViewLandingRecord)
            {
                ApplicationArea = All;
                Caption = 'View Landing Record';
                Image = ViewDetails;
                ToolTip = 'View the original landing record for this entry.';

                trigger OnAction()
                var
                    EconomicEntriesLanding: Record "Economic Entries Landing";
                begin
                    if EconomicEntriesLanding.Get(Rec."Landing Entry No.") then
                        Page.Run(Page::"Economic Entries Landing List", EconomicEntriesLanding)
                    else
                        Message('Landing record not found.');
                end;
            }
        }
        area(Navigation)
        {
            group(Related)
            {
                Caption = 'Related';
                action(ViewGLAccountMapping)
                {
                    ApplicationArea = All;
                    Caption = 'G/L Account Mapping';
                    Image = ChartOfAccounts;
                    ToolTip = 'View the G/L account mapping for this economic account.';

                    trigger OnAction()
                    var
                        EconomicGLAccountMapping: Record "Economic GL Account Mapping";
                    begin
                        EconomicGLAccountMapping.SetRange("Economic Account No.", Format(Rec."Economic Account Number"));
                        Page.Run(Page::"Economic GL Account Mapping", EconomicGLAccountMapping);
                    end;
                }
            }
        }
    }
}