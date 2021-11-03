// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!
tableextension 61101 "DCADV Doc. Category Ext." extends "CDC Document Capture Setup"
{
    fields
    {
        field(61101; "Use Advanced Move to Company"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(61102; "Letterhead Top"; Integer)
        {
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(61103; "Letterhead Left"; Integer)
        {
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(61104; "Letterhead Bottom"; Integer)
        {
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(61105; "Letterhead Right"; Integer)
        {
            DataClassification = CustomerContent;
            BlankZero = true;
        }
    }
}