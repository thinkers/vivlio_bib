declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

let $items := doc("master.xml")//tei:list[@type="distinct"]/tei:item
let $distincts := doc("book.xml")//tei:distinct
return
element div {
	attribute class { ("words", "container") },
	element p {
		attribute class { ("intro", "text-center") },
		data($items/../../tei:head)
	},
	for $item in $items order by normalize-space(string($item/tei:name))
	let $filtered := $distincts[$item/@xml:id = @type]
	let $nodups := $filtered[index-of($filtered//tei:orig, .//tei:orig)[1]]
	return
	element div {
		attribute class { ("was-distinct", "text-center") },
		element label {
			attribute class { "was-name" },
			normalize-space(string($item/tei:name))
		},
		for $c in $nodups order by normalize-space(string($c//tei:orig))
		return
		element div {
			attribute class { ("row", "choices") },
			element p { attribute class { ("col-xs-6", "col-sm-6", "col-md-6", "text-right", "was-orig") }, data($c//tei:orig) },
			element p { attribute class { ("col-xs-6", "col-sm-6", "col-md-6", "text-left", "was-reg") },  data($c//tei:reg)  }
		}
	}
}

