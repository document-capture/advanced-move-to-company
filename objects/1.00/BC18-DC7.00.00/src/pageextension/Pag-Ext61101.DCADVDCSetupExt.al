pageextension 61101 "DCADV DC Setup Ext." extends "CDC Document Capture Setup"
{
    layout
    {
        addafter("Fill-out LCY")
        {
            field("Use Advanced Move to Company"; Rec."Use Advanced Move to Company")
            {
                ApplicationArea = All;
                ToolTip = 'Enable the advanced company identification app.';
                AboutTitle = 'Advanced move to company';
                AboutText = 'Enable this option to force the system to find all defined identification texts before moving the document and can limit the letterbox area.';

                trigger OnValidate()
                begin
                    ShowAdvancedMoveToCompany := Rec."Use Advanced Move to Company";
                    //                    CurrPage.UPDATE(TRUE);
                end;
            }
            group(AdvancedMoveToCompany)
            {
                Caption = 'Advanced move to company';
                Visible = ShowAdvancedMoveToCompany;

                field("Letterhead Top"; Rec."Letterhead Top")
                {
                    ApplicationArea = All;
                }
                field("Letterhead Left"; Rec."Letterhead Left")
                {
                    ApplicationArea = All;
                }
                field("Letterhead Bottom"; Rec."Letterhead Bottom")
                {
                    ApplicationArea = All;
                }
                field("Letterhead Right"; Rec."Letterhead Right")
                {
                    ApplicationArea = All;

                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        ShowAdvancedMoveToCompany := Rec."Use Advanced Move to Company";
    end;

    var
        [InDataSet]
        ShowAdvancedMoveToCompany: Boolean;
}