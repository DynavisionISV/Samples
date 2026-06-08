## Use case

Web shop integrations create sales orders with lines, although instant promotions are not calculated immediately. Instead, instant promotion calculation must be included as part of the 'Check for Promotions' function.

This sample shows how to:
- Calculate both instant and normal promotions in one step when **Check for Promotions** is run

The same pattern applies to any Sales Header condition (custom field, external document number, integration flag, and so on).

## How it works

Advanced Promotions resolves the disable flag through `GetDisableInstantPromotions()`:

1. Raise `ESCQ_OnBeforeGetDisableInstantPromotions` (your subscriber can set the flag)
2. If still `false`, read **Disable Instant Promotions** from Advanced Promotions Setup

Setting `DisableInstantPromotions` to `true` only affects **line-entry** instant calculation. 
**Check for Promotions** will include delayed instant promotions when the flag is `true`.

## Sample implementation

### Table extension — `DYN Web Order Sales Header` (50100)

Adds a **Web Order** boolean on Sales Header (field 50100). In production, set this field from your web shop integration when the order is created or imported.

```al
field(50100; "Web Order"; Boolean)
{
    Caption = 'Web Order';
    DataClassification = CustomerContent;
    ToolTip = 'Specifies whether this sales document originates from a web shop. When enabled, instant promotions are not calculated on line entry but are included when Check for Promotions is run.';
}
```

### Codeunit — `DYN Disable Promo Web Order` (50100)

```al
[EventSubscriber(ObjectType::Table, Database::"Sales Header", ESCQ_OnBeforeGetDisableInstantPromotions, '', false, false)]
local procedure OnBeforeGetDisableInstantPromotions(var Rec: Record "Sales Header"; var DisableInstantPromotions: Boolean)
begin
    if Rec."Web Order" then
        DisableInstantPromotions := true;
end;
```

Subscribe to the event on `Database::"Sales Header"`. The publisher lives on the `ESCQ Sales Header` table extension in Dynavision Advanced Promotions.

## How to test

1. Publish **Dynavision Advanced Promotions** and this sample extension.
2. Ensure **Disable Instant Promotions** is `false` in **ESCQ Advanced Promotions Setup** (so the per-order override is visible).
3. Create a Sales Order and set **Web Order** to `true` (via your integration, a page extension, or test code).
4. Add item lines — no instant promotion lines should appear on line entry.
5. Run **Check for Promotions** — instant and normal promotions should be calculated.
6. Repeat with **Web Order** = `false` — instant promotions should appear on line entry (default behaviour).


## Adapting for production

Replace the **Web Order** boolean with your own detection logic:

- A field set by your web shop connector
- **External Document No.** or a custom reference field
- A document source enum or integration log entry
- ...

Keep the subscriber pattern: evaluate the Sales Header and set `DisableInstantPromotions := true` when instant calculation on line entry should be delayed.

The event override is one-way: subscribers can force `true` before the setup is read. They cannot force `false` when the global setup already disables instant promotions.
