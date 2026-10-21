reportextension 50007 DYN26TransferOrder extends "ESCR Transfer Order" // 71097286
{
    dataset
    {
        modify(Line)
        {
            trigger OnAfterAfterGetRecord()
            begin
                // When the line is skipped in the OnAfterGetRecord, we still get into this trigger.
                // https://github.com/microsoft/AL/issues/7039
                // So we need to check if the line is skipped and exit if it is.
                if ReportDocumentLine."Source SystemId" <> Line.SystemId then
                    exit;

                ReportDocumentLine."DYN Shelf No." := GetItemShelfNo(Line."Item No.");
                ReportDocumentLine.SetTransferSortingValue();
                ReportDocumentLine.Modify(false);
            end;
        }
    }

    local procedure GetItemShelfNo(ItemNo: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then
            exit(Item."Shelf No.");
        exit('');
    end;
}