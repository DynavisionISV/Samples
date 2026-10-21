pageextension 50300 DYN01BookCard extends "DYN Book Card" // 50301
{
    layout
    {
        addfirst(factboxes)
        {
            part("Drag And Drop Factbox"; "ESCA Drag And Drop Factbox")
            {
                ApplicationArea = All;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // Load the contents, do NOT auto refresh the attachments (e.g. getting the latest attachment from the external source)
        CurrPage."Drag And Drop Factbox".Page.SetSource(Rec);
    end;
}