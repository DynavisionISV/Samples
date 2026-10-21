codeunit 50002 "DYN Warehouse Events"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCR Warehouse Reports", OnBeforeGetDefaultPrintPricesOnShipmentFromCustomer, '', false, false)]
    local procedure "ESCR Warehouse Reports_OnBeforeGetDefaultPrintPricesOnShipmentFromCustomer"(var PrintPrices: Boolean; var IsHandled: Boolean)
    begin
        PrintPrices := false;
        IsHandled := true;
    end;
}