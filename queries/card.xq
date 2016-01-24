declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

let $c_id := "c_julius_caesar"
let $character := //tei:listPerson/tei:person[@xml:id = $c_id]
let $chapters := //tei:div[@type="chapter"]

return
element section {
	attribute id { $c_id },
	attribute class { ("card", "container") },

	element section {
		attribute class { ("navigation", "text-center", "hidden-xs") },
		element ul {
			attribute class { ("list-inline") },
			element li {
				element a {
					attribute href { "/index.html" },
					"HOME"
				}
			},
			element li {
				element a {
					attribute href { "#about" },
					"ABOUT"
				}
			},
			element li {
				element a {
					attribute href { "#quotes" },
					"QUOTES"
				}
			},
			element li {
				element a {
					attribute href { "#illustrations" },
					"ILLUSTRATIONS"
				}
			},
			element li {
				element a {
					attribute href { "#objects" },
					"OBJECTS"
				}
			},
			element li {
				element a {
					attribute href { "#relations" },
					"RELATIONS"
				}
			}
		}
	},

	element section {
		attribute id { "about" },
		attribute class { ("intro", "row", "text-center") },
		element div {
			attribute class { ("col-md-12", "col-sm-12", "col-xs-12") },
			element label {
				normalize-space($character//tei:persName)
			}
		},
		element div {
			attribute class { ("col-md-offset-2", "col-md-4", "col-sm-5", "col-xs-12") },
			element img {
				attribute class { ("img-responsive") },
				attribute src {
					if ("" != $character/tei:figure/tei:graphic/@url)
					then $character/tei:figure/tei:graphic/@url
					else "media/characters/blank.jpg"
				}
			}
		},
		element div {
			attribute class { ("caption", "col-md-4", "col-sm-4", "col-xs-12") },
			element p {
				normalize-space($character/tei:note[@type="fingertip_small"])
			}
		}
	},

	element section {
		attribute id { "quotes" },
		attribute class { ("quotes", "text-center") },
		element label {
			"QUOTES"
		},
		element div {
			attribute class { ("listofquotes", "owl-carousel") },
			for $chapter in $chapters
			let $quotes := $chapter//tei:said[@rend = "card" and @who = concat("#", $c_id)]
			return
			for $quote in $quotes
			return
			element div {
				element div {
					attribute class { ("text") },
					normalize-space(data($quote))
				},
				element div {
					attribute class { ("source") },
					concat("Ch. ", $chapter/@n)
				}
			}
		}
	},

	element section {
		attribute id { "illustrations" },
		attribute class { ("illustrations", "text-center") },
		element label {
			"ILLUSTRATIONS"
		},
		element div {
			attribute class { ("listofillustrations", "row") },
			for $chapter in $chapters
			let $graphics := $chapter//tei:figure[not(@exclude = "true") and concat("#", $c_id) = tokenize(@corresp, "\s")]/tei:graphic[@rend = "crop"]
			return
			for $graphic in $graphics
			return
			element div {
				attribute class { ("col-md-2", "col-sm-3", "col-xs-6") },
				element figure {
					element img {
						attribute src {
							if ("" != $graphic/@url)
							then $graphic/@url
							else "media/characters/blank.jpg"
						}
					},
					element figcaption {
						attribute class { ("source") },
						concat(
							"Ch. ",
							normalize-space(string($chapter/@n)),
							"—p.",
							replace($graphic/@url, ".*page_c_0?|[.].*$", "")
						)
					}
				}
			}
		}
	},

	element section {
		attribute id { "objects" },
		attribute class { ("objects", "text-center") },
		element label {
			"OBJECTS"
		},
		element div {
			attribute class { ("listofobjects", "owl-carousel") },
			for $chapter in $chapters
			let $objects := $chapter//tei:rs[@type = "obRef" and not(@exclude = "true") and concat("#", $c_id) = tokenize(@ref, "\s")]

			let $nodups := $objects[index-of($objects/@ref, ./@ref)[1]]

			return
			for $rs in $nodups
			let $ob_id :=
				for $r in tokenize($rs/@ref, "\s")
				where starts-with($r, "#ob_")
				return $r
			let $object := //tei:list[@type='objects']//tei:item[$ob_id = concat("#", @xml:id)]
			return
			element div {
				element figure {
					element img {
						attribute src {
							if ("" != $object/tei:figure/tei:graphic/@url)
							then $object/tei:figure/tei:graphic/@url
							else "media/characters/blank.jpg"
						}
					},
					element figcaption {
						element label {
							attribute class { ("title") },
							normalize-space($object/tei:name)
						},
						element p {
							attribute class { ("desc") },
							normalize-space($object/tei:desc)
						}
					}
				}
			}
		}
	},

	element section {
		attribute id { "relations" },
		attribute class { ("relations", "text-center") },
		element label {
			"RELATIONS"
		},
		element ul {
			attribute class { ("listofrelations", "list-inline") },
			element li {
				(: "XXXXXX TODO grab relatives XXXXXX" :)
			}
		}
	}
}

