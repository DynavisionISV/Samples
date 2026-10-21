codeunit 50012 "DYN Stock Text Constants"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCA Text Constant", OnAfterCreateDefaults, '', false, false)]
    local procedure "ESCA Text Constant_OnAfterCreateDefaults"()
    var
        TextConstant: Record "ESCA Text Constant";
    begin
        TextConstant.Create('DYN_NOSTOCK', 'No stock available ', 'Pas de stock disponible ', 'Geen voorraad beschikbaar');
        TextConstant.Create('DYN_PARTSTOCK', 'Partial stock available ', 'Stock partiel disponible ', 'Gedeeltelijke voorraad beschikbaar');
    end;
}