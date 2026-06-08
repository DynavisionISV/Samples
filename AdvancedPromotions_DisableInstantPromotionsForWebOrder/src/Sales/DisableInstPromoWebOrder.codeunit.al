codeunit 50100 "DYN Disable Promo Web Order"
{
    // Delay instant promotions for web orders until Check for Promotions is run.
    #region EventSubscriber Table "Sales Header" ESCQ_OnBeforeGetDisableInstantPromotions
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", ESCQ_OnBeforeGetDisableInstantPromotions, '', false, false)]
    local procedure OnBeforeGetDisableInstantPromotions(var Rec: Record "Sales Header"; var DisableInstantPromotions: Boolean)
    begin
        if Rec."Web Order" then
            DisableInstantPromotions := true;
    end;
    #endregion EventSubscriber Table "Sales Header" ESCQ_OnBeforeGetDisableInstantPromotions
}
