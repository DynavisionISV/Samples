reportextension 50005 DYN24WarehouseShipment extends "ESCR Warehouse Shipment" // 71097288
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

                GetOriginalQuantity();

                if (ReportDocumentLine."DYN Original Qty" > 0) then
                    if (Line."Qty. to Ship" = 0) then
                        ReportLayout.AddTextLine(ReportDocumentLine, TextConstant.ReturnTextConstant('DYN_NOSTOCK', LanguageCode), LineSorting)
                    else
                        if Line."Qty. to Ship" < ReportDocumentLine."DYN Original Qty" then
                            ReportLayout.AddTextLine(ReportDocumentLine, TextConstant.ReturnTextConstant('DYN_PARTSTOCK', LanguageCode), LineSorting);
            end;
        }
    }

    requestpage
    {
        layout
        {
            modify("Print Quantity")
            {
                Importance = Standard;
            }
        }

        trigger OnOpenPage()
        begin
#pragma warning disable AL0603
            if CurrReport.UseRequestPage() then
                // WhsePrintQuantity := "ESCR Whse. Quantity Type"::"Quantity to Ship";
                WhsePrintQuantity := 1;
#pragma warning restore AL0603
        end;
    }

    local procedure GetOriginalQuantity()
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        WarehouseShipmentLine.Reset();
        WarehouseShipmentLine.SetRange("No.", Line."No.");
        WarehouseShipmentLine.SetRange("Line No.", Line."Line No.");
        if WarehouseShipmentLine.FindFirst() then begin
            ReportDocumentLine."DYN Original Qty" := WarehouseShipmentLine.Quantity;
            ReportDocumentLine.Modify(false);
        end
        else begin
            ReportDocumentLine."DYN Original Qty" := Line.Quantity;
            ReportDocumentLine.Modify(false);
        end;
    end;
}