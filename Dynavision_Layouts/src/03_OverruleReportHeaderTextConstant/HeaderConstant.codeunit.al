codeunit 50001 "DYN Header Constant"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCA Report Layout Lines", OnBeforeAddOneHeaderColumnToBuffer, '', false, false)]
    local procedure "ESCA Report Layout Lines_OnBeforeAddOneHeaderColumnToBuffer"(var ReportLineColumn: Record "ESCA Report Line Column"; Source: Variant)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(Source, RecRef) then
            exit;

        if RecRef.Number() <> Database::"Sales Invoice Header" then
            exit;

        SalesInvoiceHeader := Source;

        if SalesInvoiceHeader."Prices Including VAT" then
            ReportLineColumn.Content := 'AMOUNTINCLVAT' // Name of the text constant specifying the amount including VAT
        else
            ReportLineColumn.Content := 'AMOUNTEXCLVAT'; // Name of the text constant specifying the amount excluding VAT
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCA Text Constant", OnAfterCreateDefaults, '', false, false)]
    local procedure "ESCA Text Constant_OnAfterCreateDefaults"()
    var
        TextConstant: Record "ESCA Text Constant";
    begin
        TextConstant.Create('AMOUNTINCLVAT', 'Amount Incl. VAT', 'Montant TTC', 'Bedrag incl. BTW');
        TextConstant.Create('AMOUNTEXCLVAT', 'Amount Excl. VAT', 'Montant hors TVA', 'Bedrag excl. BTW');
    end;
}