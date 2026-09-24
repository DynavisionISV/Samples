codeunit 50100 "DYN Disable Promo Web Order"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", ESCQ_OnBeforeGetDisableInstantPromotions, '', false, false)]
    local procedure OnBeforeGetDisableInstantPromotions(var Rec: Record "Sales Header"; var DisableInstantPromotions: Boolean)
    begin
        if Rec."DYN Web Order" then
            DisableInstantPromotions := true;
    end;
}