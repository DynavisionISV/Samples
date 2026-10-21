codeunit 50004 "DYN Salesperson Text Constants"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCA Text Constant", OnAfterCreateDefaults, '', false, false)]
    local procedure "ESCA Text Constant_OnAfterCreateDefaults"()
    var
        TextConstant: Record "ESCA Text Constant";
    begin
        TextConstant.Create('DYN_SALESPERSON', 'Salesperson: ', 'Vendeur: ', 'Verkoper: ');
        TextConstant.Create('DYN_PURCHASER', 'Purchaser: ', 'Acheteur: ', 'Inkoper: ');
    end;
}
