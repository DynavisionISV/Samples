pageextension 50000 DYN22ReportLayoutSetupCard extends "ESCA Report Layout Setup Card" // 71096611
{
    layout
    {
        addlast(Options)
        {
            group("DYN Options")
            {
                Caption = 'DYN', Locked = true;

                field("DYN Print Quote Categories"; Rec."DYN Print Quote Categories")
                {
                    ApplicationArea = All;
                    Enabled = QuoteEnabled;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        QuoteEnabled := (Rec."Report ID" = Report::"ESCR Sales Quote") or (Rec."New Report ID" = Report::"ESCR Sales Quote");
    end;

    var
        QuoteEnabled: Boolean;
}