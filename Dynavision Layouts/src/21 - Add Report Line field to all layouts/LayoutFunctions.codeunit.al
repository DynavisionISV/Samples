codeunit 50000 "DYN Layout Functions"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCA Report Document Lines", OnAfterCreateDocumentLine, '', false, false)]
    local procedure OnAfterCreateDocumentLine(Source: Variant; var ReportDocumentLine: Record "ESCA Report Document Line" temporary)
    begin
        AddFieldToReportDocumentLine(Source, ReportDocumentLine);
    end;

    local procedure AddFieldToReportDocumentLine(Source: Variant; var ReportDocumentLine: Record "ESCA Report Document Line" temporary)
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(Source, RecordRef) then
            exit;

        case RecordRef.Number() of
            Database::"Sales Line":
                begin
                    SalesLine := Source;
                    ReportDocumentLine."DYN Location Code" := SalesLine."Location Code";
                end;
            Database::"Purchase Line":
                begin
                    PurchaseLine := Source;
                    ReportDocumentLine."DYN Location Code" := PurchaseLine."Location Code";
                end;
            Database::"Warehouse Shipment Line":
                begin
                    WarehouseShipmentLine := Source;
                    ReportDocumentLine."DYN Location Code" := WarehouseShipmentLine."Location Code";
                end;
            else
                ReportDocumentLine."DYN Location Code" := '';
        end;
    end;
}