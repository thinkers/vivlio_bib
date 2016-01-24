declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare default element namespace "http://www.tei-c.org/ns/1.0";

declare function local:wrap_id($id as xs:string, $list as item()) as item() {
	element div { attribute xml:id { $id }, attribute type { concat("list_", $id) }, $list }
};

declare function local:wrap_list($type as xs:string, $objects as item()*) as item() {
	switch ($type)
	case "persons" return element listPerson { $objects }
	case "places"  return element listPlace { $objects }
	case ""        return element list { $objects }
	default        return element list { attribute type { $type }, $objects }
};

declare function local:sort_by_id($objects as item()*) as item()* {
	for $item in $objects order by $item/@xml:id
	return if ($item/tei:list)
	then element { $item/name() } { $item/@*, $item/(* except tei:list), local:wrap_list("", local:sort_by_id($item/tei:list/tei:item)) }
	else $item
};

let $masterdoc := "master.xml"
let $objects := doc($masterdoc)//tei:list[@type='objects']/tei:item
let $persons := doc($masterdoc)//tei:listPerson/tei:person
let $places  := doc($masterdoc)//tei:listPlace/tei:place

return (
	local:wrap_id("objects", local:wrap_list("objects", local:sort_by_id($objects)))
	,
	local:wrap_id("persons", local:wrap_list("persons", local:sort_by_id($persons)))
	,
	local:wrap_id("places",  local:wrap_list("places",  local:sort_by_id($places)))
)

