pageextension 50501 DYN01QuotationBufferList extends "ESCZ Quotation Buffer List" // 71177541
{
    layout
    {
        modify("Has Properties")
        {
            Visible = false;
        }
        addafter("Has Properties")
        {
            field(DYNHasProperties; HasProperties)
            {
                Caption = 'Has Properties', Locked = true;
                ToolTip = 'Specifies if extra properties are present.', Locked = true;
                ApplicationArea = All;

                #region OnDrillDown
                trigger OnDrillDown()
                begin
                    ShowProperties();
                end;
                #endregion OnDrillDown
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        QuotBufferPropValue: Record "DYN Quot. Buffer Prop. Value";
    begin
        QuotBufferPropValue.SetRange("Quotation Id", Rec.Id);
        HasProperties := not QuotBufferPropValue.IsEmpty();
    end;

    local procedure ShowProperties()
    var
        QuotBufferPropValue: Record "DYN Quot. Buffer Prop. Value";
    begin
        QuotBufferPropValue.FilterGroup(2);
        QuotBufferPropValue.SetRange("Quotation Id", Rec.Id);
        QuotBufferPropValue.FilterGroup(0);

#pragma warning disable AC0006
        Page.RunModal(0, QuotBufferPropValue);
#pragma warning restore AC0006
    end;

    var
        HasProperties: Boolean;
}