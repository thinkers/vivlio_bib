declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

let $items := //tei:list[@type='objects']//tei:item
return
element div {
	attribute class { ("objects", "container") },
	element p {
		attribute class { ("intro", "text-center") },
		data($items/../../tei:head)
	},
	element div {
		attribute class { ("row") },
		for $item in $items order by normalize-space(string($item/tei:name))
		return

		element div {
			attribute class { ("was-item", "text-center", "col-md-3", "col-sm-4", "col-xs-6") },
			element figure {
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
						attribute class { "was-name" },
						normalize-space(string($item/tei:name))
					},
					element p {
						attribute class { "was-desc" },
						normalize-space(string($item/tei:desc))
					}
				}
			}
		}
	}
}

