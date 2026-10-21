# Samples - Dynavision Core

This folder contains individual samples that extend Dynavision Core.

## Core Samples

### 01 - Drag and Drop

**Overview**

This sample demonstrates how to extend a custom table and its pages with the Dynavision Core **Drag and Drop** functionality, so users can drop files onto a record and have them stored as attachments on the external storage location.

**Use Case**

A custom entity (in this sample a **Book**) needs to have documents attached to it, such as a cover, a contract or a review. Instead of using the standard attachment dialogs, users want to drag files from their computer straight onto the record. The files must be stored in a structured way on the external storage location and removed again when the record is deleted.

**What It Does**

1. Adds the **Drag And Drop Factbox** (`ESCA Drag And Drop Factbox`) as the first factbox on the Book List and Book Card pages.
2. Calls `SetSource` on the factbox in `OnAfterGetCurrRecord` to load the attachments of the current book.
    - The attachments are **not** refreshed automatically from the external source.
    - On the list page `SetSource(Rec, true)` is used, on the card page `SetSource(Rec)`.
3. Creates a simple document structure for the Book table, so attachments are stored in a structured way on the external storage location. This is done by subscribing to `OnAfterCreateStandardDocumentStructures` on codeunit `ESCA Create Document Structure`.
4. Links attachments to a book by `SystemId` (`ESCA Source System ID` on `Document Attachment`) instead of by Document Type, Line No. and/or No. This is done by subscribing to:
    - `OnAfterGetRefTable` to resolve the book from a document attachment.
    - `OnAfterSetDocumentAttachmentFiltersForRecRef` to filter the attachments of a book.
5. Deletes the attached documents when a book is deleted (`OnAfterDeleteEvent` on the Book table).

### 02 - FTP

**Overview**

This sample demonstrates how to use the Dynavision Core **FTP** functionality from AL code to upload a file to an FTP location.

**Use Case**

A process needs to send a file from Business Central to an external FTP server, for example an export file, an image or a document that must be picked up by another system. The connection details are configured once in the FTP setup, so the code only has to refer to an FTP code.

**What It Does**

1. Adds the **Sample FTP** page (`DYN Sample FTP`, page 50302), available through search as a task.
2. Lets the user select an **FTP Code** (mandatory) from the `ESCA FTP Setup` table and optionally enter an **FTP Path**.
3. Provides an **Upload File** action that:
    - Checks that an FTP Code is entered.
    - Checks that the **FTP Request Type** of the selected FTP setup is **Upload File**.
    - Asks the user to select a file and reads it into a `Temp Blob`.
    - Calls `UploadFile` on codeunit `ESCA FTP Request Mgt.` with the FTP code, path, file content and file name (truncated to 250 characters). The `ESCA FTP Request` record is returned as a var parameter.
    - Shows a message when the upload succeeded and an error when it failed.
4. Passes `not GuiAllowed()` as the silent parameter of `UploadFile`, so the same call can be used when running in the background.

**Notes**

- Before using the sample, create an FTP setup in Dynavision Core with the **FTP Request Type** set to **Upload File**.

### 03 - Message API

**Overview**

This sample demonstrates how to build your own **Message Format** on top of the Dynavision Core **Message API**. Two examples are included: a **Push** example that sends a record to another environment, and a **Pull** example that requests data from another environment.

**Use Case**

Two Business Central environments (or companies) need to exchange data without building a custom web service. With the Message API, Dynavision Core takes care of sending, receiving, logging and processing the messages. The extension only has to describe how the content is created and how an incoming message is processed.

- **Push:** one environment sends a record to the other side, for example a document or a master data record, and the receiver creates it.
- **Pull:** one environment asks the other side for information, for example the details of an item, and creates a new record from the response.

**What It Does**

1. Registers two new values on the enums `ESCA Message Type` and `ESCA Message Format`: **Message API Push Example** and **Message API Pull Example**. Each format value links to the codeunit that implements the interfaces:
    - Push: `ESCA Message Format` and `ESCA Message API`.
    - Pull: `ESCA Message Format`, `ESCA Message API` and `ESCA Message Request API`.
2. Extends the **Message Type Card** (`ESCA Message Type Card`) with an action to run the example. The action is only visible when the message format of the message type is the matching example.
3. Provides default settings for the message type (code, description, direction *Both*, communication method *API* and *Auto Process*), through `GetDefaultMessageTypeCode` and `ApplyDefaultMessageTypeSettings`.
4. Provides `DYN Json Tools` (codeunit 50303) to convert a record to a JSON object (`Rec2Json`) and a JSON object back to a record (`Json2Rec`) based on the field names. It is used by both examples.

**Push Example**

1. Adds the **Message API Test** table (`DYN Message API Test`, table 50301) that stores a test record with the ID, AAD tenant, environment, company, direction, message entry no., error and original ID.
2. Adds the **Message API Push Example** page (`DYN Message API Push Example`, page 50304) that lists the test records, newest first. Records with an error are highlighted.
3. The **Send Message** action creates a test record with direction **Outgoing** and sends it with `Send` on codeunit `ESCA Message`. When sending fails, the error is stored on the record.
4. `GetMessageContent` converts the record to JSON and puts it in the message content.
5. `ProcessIncomingMessage` runs on the receiving side. It reads the JSON from the attachment, creates a new test record with direction **Incoming**, keeps the sender's ID in **Original ID** and gives the record a new ID.

**Pull Example**

1. The **Sample** action on the Message Type Card calls `ImportItem` on the codeunit. The **Get Item No. Info** dialog (`DYN Get Item No. Info`, page 50303) asks for:
    - **Existing Item No.**, the item to retrieve from the other side.
    - **New Item No.**, the item to create on this side. The dialog checks that this item does not exist yet.
2. The request, a JSON object with the `itemNo`, is sent with `ImportData` on the message type.
3. On the other side, `ProcessIncomingRequest` reads the item no. from the request, looks up the item, and returns a response with a subset of the item fields (no., descriptions, unit price and unit cost). A temporary item is used so no additional data needs to be retrieved.
4. Back on the requesting side, `ProcessIncomingMessage` reads the response, creates the new item with the entered **New Item No.** and opens the item card. An error is shown when the item could not be retrieved.
