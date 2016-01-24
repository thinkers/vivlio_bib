declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

let $items := //tei:listPerson/tei:person
return
element div {
	attribute class { ("characters", "container") },
	element p {
		attribute class { ("intro", "text-center") },
		data($items/../../tei:head)
	},
	element div {
		attribute class { ("row") },
		for $item in $items order by normalize-space(string($item/tei:persName[1]))
		return
		element div {
			attribute class { ("was-person", "text-center", "col-md-4", "col-sm-6", "col-xs-12") },
			element figure {
				attribute data-sex { data($item/@sex) },
				attribute data-id  { data($item/@xml:id) },
				element img {
					attribute class { ("was-graphic", "thumb", "img-responsive", "center-block") },
					attribute src {
						if ("" != $item/tei:figure/tei:graphic/@url)
						then $item/tei:figure/tei:graphic/@url
						else "media/characters/blank.jpg"
					}
				},
				element figcaption {
					element label {
						attribute class { "was-persName" },
						normalize-space(string-join( data($item/tei:persName), ' '))
					},
					element p {
						attribute class { ("was-note") },
						data($item/tei:note)
					},
					element a {
						attribute class { ("text-muted", "small") },
						attribute href { concat("cards/", $item/@xml:id, ".html") },
						attribute title { "more" },
						"MORE"
					}
				}
			}
		}
	}
}

