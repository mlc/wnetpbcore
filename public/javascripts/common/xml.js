/**
 * xml.js: utilities for creating, loading, parsing, serializing,
 *         transforming and extracting data from XML documents.
 *
 * From the book JavaScript: The Definitive Guide, 5th Edition,
 * by David Flanagan. Copyright 2006 O'Reilly Media, Inc. (ISBN: 0596101996)
 */

// Make sure we haven't already been loaded
var OraXML;
if (OraXML && (typeof OraXML != "object" || OraXML.NAME))
    throw new Error("Namespace 'OraXML' already exists");

// Create our namespace, and specify some meta-information
OraXML = {};
OraXML.NAME = "OraXML";     // The name of this namespace
OraXML.VERSION = 1.0;    // The version of this namespace

/**
 * Create a new Document object.  If no arguments are specified, 
 * the document will be empty.  If a root tag is specified, the document
 * will contain that single root tag.  If the root tag has a namespace
 * prefix, the second argument must specify the URL that identifies the
 * namespace.
 */
OraXML.newDocument = function(rootTagName, namespaceURL) {
    if (!rootTagName) rootTagName = "";
    if (!namespaceURL) namespaceURL = "";
    
    if (document.implementation && document.implementation.createDocument) {
        // This is the W3C standard way to do it
        return document.implementation.createDocument(namespaceURL,
                                                      rootTagName, null);
    }
    else { // This is the IE way to do it
        // Create an empty document as an ActiveX object
        // If there is no root element, this is all we have to do
        var doc = new ActiveXObject("MSXML2.DOMDocument.3.0");

        // If there is a root tag, initialize the document
        if (rootTagName) {
            // Look for a namespace prefix
            var prefix = "";
            var tagname = rootTagName;
            var p = rootTagName.indexOf(':');
            if (p != -1) {
                prefix = rootTagName.substring(0, p);
                tagname = rootTagName.substring(p+1);
            }

            // Create the root element (with optional namespace) as a
            // string of text
            var text = "<" + (prefix?(prefix+":"):"") +  tagname +
                (namespaceURL
                 ?(" xmlns" + (prefix?(":"+prefix):"") + '="' + namespaceURL +'"')
                 :"") +
                "/>";
            // And parse that text into the empty document
            doc.loadXML(text);
        }
        return doc;
    }
};

/**
 * Serialize an XML Document or Element and return it as a string.
 */
OraXML.serialize = function(node) {
    if (typeof XMLSerializer != "undefined")
        return (new XMLSerializer()).serializeToString(node);
    else if (node.xml) return node.xml;
    else throw "XML.serialize is not supported or can't serialize " + node;
};
