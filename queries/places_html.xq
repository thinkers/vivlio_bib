declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

let $items := //tei:listPlace/tei:place
return
element div {
	attribute class { ("places", "container") },
	element p {
		attribute class { ("intro", "text-center") },
		data($items/../../tei:head)
	},
	element div {
		attribute class { ("row") },
		for $item in $items order by normalize-space(string($item/tei:placeName))
		return

		element div {
			attribute class { ("was-item", "was-place", "text-center", "col-md-3", "col-sm-4", "col-xs-6") },
			element figure {
				element img {
					attribute class { ("was-graphic", "thumb", "img-responsive", "center-block") },
					attribute alt { $item//tei:figure/tei:head },
					attribute src {
						if ("" != $item//tei:figure/tei:graphic/@url)
						then $item//tei:figure/tei:graphic/@url
						else "media/blank.jpg"
					}
				},
				element figcaption {
					element label {
						attribute class { "was-name" },
						normalize-space(string($item/tei:placeName))
					},
					element p {
						attribute class { "was-desc" },
						data($item//tei:figure/tei:figDesc)
					}
				}
			}
		}
	}
}

