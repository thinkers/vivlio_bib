declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

let $chapters := doc("book.xml")//tei:div[@type="chapter"]
return
element div {
	attribute class { ("illustrations", "container") },
	element div {
		attribute class { ("row") },
		for $chapter in $chapters
		let $items := $chapter//tei:figure
		for $item in $items order by normalize-space(string($item/tei:name))
		return
		element div {
			attribute class { ("was-item", "text-center", "col-md-3", "col-sm-4", "col-xs-6") },
			element figure {
				element img {
					attribute class { ("was-graphic", "thumb", "img-responsive", "center-block") },
					attribute src {
						if ("" != $item/tei:graphic[@rend="crop"]/@url)
						then $item/tei:graphic[@rend="crop"]/@url
						else "media/characters/blank.jpg"
					}
				},
				element figcaption {
					element label {
						concat(
							"Ch ",
							normalize-space(string($chapter/@n)),
							"—p.",
							replace($item/tei:graphic[@rend="crop"]/@url, ".*page_c_0?|[.].*$", "")
						)
					},
					element p {
						attribute class { "was-head" },
						normalize-space(string($item/tei:head))
					}
				}
			}
		}
	}
}

