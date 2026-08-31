# Companyweb / Liza — Custom Page Sample

This sample shows how to extend a custom page so it fully supports **Companyweb** / **Liza** functionality.

## Sample

[`PTEContactCard.al`](PTEContactCard.al) is a page extension of **Contact Card** that demonstrates the pattern. The same approach applies to any custom page whose source table is **Customer**, **Vendor**, or **Contact**.

## What the sample covers

- **Data & Payment Experience factboxes** — add the Companyweb factbox parts and keep them in sync when the record or key fields change
- **Get Data action** — retrieve company data via `CWEBF Get Company Data`
- **Field validation** — refresh factboxes after changes to country, VAT registration no., or registration number
- **Country support** — show provider actions only when the country is supported

Use this as a template when wiring Companyweb / Liza into your own Customer, Vendor, or Contact-based pages.
