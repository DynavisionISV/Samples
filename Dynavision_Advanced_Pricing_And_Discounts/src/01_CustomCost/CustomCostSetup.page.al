page 50400 "DYN Custom Cost Setup"
{
    ApplicationArea = All;
    Caption = 'Custom Cost Setup';
    PageType = Card;
    SourceTable = "DYN Custom Cost Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Setup';

                field(Active; Rec.Active) { }

                group(CostCalculation)
                {
                    Caption = 'Cost Calculation';

                    field("Cost Factor"; Rec."Cost Factor") { }
                    field("Fixed Cost Addition"; Rec."Fixed Cost Addition") { }
                }

                group(CostSource)
                {
                    Caption = 'Cost Source';
                    field("Margin Cost Source"; Rec."Margin Cost Source") { }
                    field("Purch. Price Form. Cost Source"; Rec."Purch. Price Form. Cost Source") { }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InsertIfNotExists();
    end;
}