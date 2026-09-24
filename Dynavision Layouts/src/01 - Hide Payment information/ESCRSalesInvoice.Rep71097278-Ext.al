reportextension 50002 DYN01SalesInvoice extends "ESCR Sales Invoice" // 71097278
{
    dataset
    {
        modify(CopyLoop)
        {
            trigger OnAfterAfterGetRecord()
            begin
                PaidDocumentAmount := 0;
                RemainingDocumentAmount := 0;
            end;
        }
    }
}