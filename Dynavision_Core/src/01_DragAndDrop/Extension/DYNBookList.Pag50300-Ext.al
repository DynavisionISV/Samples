pageextension 50301 DYN01BookList extends "DYN Book List" // 50300
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

    #region OnAfterGetCurrRecord
    trigger OnAfterGetCurrRecord()
    begin
        // Load the contents, do NOT auto refresh the attachments (e.g. getting the latest attachment from the external source)
        CurrPage."Drag And Drop Factbox".Page.SetSource(Rec, true);
    end;
    #endregion OnAfterGetCurrRecord
}