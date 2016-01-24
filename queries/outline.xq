declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

declare default element namespace "http://www.w3.org/1999/xhtml";

let $chapters := //tei:div[@type="chapter"]
for $chapter in $chapters
return element section {
	attribute id { data($chapter/@xml:id) },
	element h1 { data($chapter/tei:head) },

	for $item in $chapter//(tei:milestone, tei:note[@type="mSummary"], tei:anchor, tei:figure[@rend="nav"])
	return typeswitch($item)
		case element(tei:note)      return element     p { data($item) }
		case element(tei:anchor)    return element    h2 { attribute id { data($item/@xml:id) }, data($item/@n) }
		case element(tei:milestone) return element    h3 { attribute id { data($item/@xml:id) }, data($item/@n) }
		case element(tei:figure)    return element   div { attribute class { "graphic" }, element img { attribute src { data($item/tei:graphic[@rend="crop"]/@url) } } }
		default                     return element error { concat("UNKNOWN TAG: ", data($item/name())) }
}

