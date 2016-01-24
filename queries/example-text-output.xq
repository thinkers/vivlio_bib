declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";

let $message := 'Hello World!'
let $persons := //tei:person[@sex]
let $aperson := $persons[1]

return (
"The message is:", $message,
(: notice new line here - quote opens and changes line :) "
The person is:", data(normalize-space($aperson//tei:persName))
)

