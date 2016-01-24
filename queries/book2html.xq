declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

declare default element namespace "http://www.w3.org/1999/xhtml";

(: -------------------------------------------------------------------------- :)
(: --------------------------------------------------------------- helpers -- :)

declare function local:substring-after-if-contains($str as xs:string, $delim as xs:string) as xs:string {
	if (contains($str, $delim)) then substring-after($str, $delim) else $str
};

(: -------------------------------------------------------------------------- :)
(: -------------------------------------------------------------- handlers -- :)

declare function local:convertElementTo($node as node(), $elname as xs:string, $root) as item()* {
	element { $elname } {
		for $attr in $node/(@* except (@part, @org, @sample, @anchored))
		return
			attribute {
				concat("data-", local:substring-after-if-contains(name($attr), ":"))
			} { string($attr) },
			attribute class { concat("was-", $node/name()) },
			local:transform($node/node(), $root)
	}
};

declare function local:handleP($node as node(), $root) as item()* {
	if ($node//tei:said/ancestor::tei:p[every $n in (node() except (comment(), tei:pb, tei:said)) satisfies normalize-space($n) = ''])
	then local:unwrapElement($node, $root)
	else local:convertElementTo($node, $node/name(), $root)
};

declare function local:handleDiv($node as node(), $root) as item()* {
	let $new := local:convertElementTo($node, "section", $root)
	return element { $new/name() } {
		$new/@*,
		attribute id { data($new/@data-id) },
		attribute role { "chapter" },
		$new/node()
	}
};

declare function local:handleHead($node as node(), $root) as item()* {
	let $tag := if ($node/../name() = "figure") then "figcaption" else "h1"
	return local:convertElementTo($node, $tag, $root)
};

declare function local:handleNote($node as node(), $root) as item()* {
	let $tag := if ($node//ancestor::tei:p) then "span" else "p"
	return local:convertElementTo($node, $tag, $root)
};

declare function local:handleSaid($node as node(), $root as node()) as item()* {
	if ($node[every $n in (following-sibling::node() except (comment(), tei:pb, tei:said)) satisfies normalize-space($n) = '']
		and $node[every $n in (preceding-sibling::node() except (comment(), tei:pb, tei:said)) satisfies normalize-space($n) = ''])
	then local:convertElementTo($node, "p", $root)
	else local:convertElementTo($node, "span", $root)
};

declare function local:handleGraphic($node as node(), $root as node()) as item()* {
	let $new := local:convertElementTo($node, "img", $root)
	return element { $new/name() } {
		$new/@*,
		attribute alt { string($node/../tei:figDesc) },
		attribute src { "" },
		$new/node()
	}
};

declare function local:handleAnchor($node as node(), $root as node()) as item()* {
	let $new := local:convertElementTo($node, "p", $root)
	return element { $new/name() } {
		$new/(@* except (@data-n)),
		data($new/@data-n),
		$new/node()
	}
};

declare function local:handleMilestone($node as node(), $root as node()) as item()* {
	let $new := local:convertElementTo($node, "p", $root)
	return element { $new/name() } {
		$new/(@* except (@data-n)),
		data($new/@data-n),
		$new/node()
	}
};

declare function local:fetchRsAttrs($type as xs:string, $ref as xs:string, $root as node()) as item()* {
	let $docname := "master.xml"
	let $refs    := tokenize($ref, "\s+")
	return switch($type)
		case "obRef" return
			let $el := $root//tei:list[@type = "objects"]/tei:item[concat("#", @xml:id) = $refs]
			return (
				attribute data-name { string($el/tei:name) },
				attribute data-desc { string($el/tei:desc) },
				attribute data-url  { string($el/tei:figure/tei:graphic/@url) }
			)
		case "placeRef" return
			let $el := $root//tei:listPlace/tei:place[concat("#", @xml:id) = $refs]
			return (
				attribute data-name { string($el/tei:placeName) },
				attribute data-desc { string($el/tei:note[@type="fingertip_small"]) },
				attribute data-geo  { string($el/tei:location/tei:geo) },
				attribute data-figure-url  { string($el//tei:figure/tei:graphic/@url) },
				attribute data-figure-alt  { string($el//tei:figure/tei:head) },
				attribute data-figure-desc { string($el//tei:figure/tei:figDesc) },
				attribute data-figure-avail      { string($el//tei:figure/tei:note[@type="availability"]) },
				attribute data-figure-source-lbl { string($el//tei:figure/tei:note[@type="source"]/@source) },
				attribute data-figure-source-url { string($el//tei:figure/tei:note[@type="source"]) }
			)
		case "persRef" return
			let $el := $root//tei:listPerson/tei:person[concat("#", @xml:id) = $refs]
			return (
				attribute data-name { string($el/tei:persName) },
				attribute data-desc { string($el/tei:note[@type="fingertip_small"]) },
				attribute data-birth { normalize-space(string($el/tei:birth)) },
				attribute data-death { normalize-space(string($el/tei:death)) },
				attribute data-figure-url  { string($el//tei:figure/tei:graphic/@url) },
				attribute data-figure-alt  { string($el//tei:figure/tei:head) },
				attribute data-figure-desc { string($el//tei:figure/tei:figDesc) },
				attribute data-figure-avail  { string($el//tei:figure/tei:note[@type="availability"]) },
				attribute data-figure-source { string($el//tei:figure/tei:note[@type="source"]) }
			)
		default return ()
};

declare function local:handleRs($node as node(), $root as node()) as item()* {
	let $new   := local:convertElementTo($node, "span", $root)
	let $attrs :=
		if ($node/@type and $node/@ref)
		then local:fetchRsAttrs($node/@type, $node/@ref, $root)
		else (attribute data-empty { "empty" } )
	return
		element { $new/name() } {
			$new/@*,
			$attrs,
			$new/node()
		}
};

(: -------------------------------------------------------------------------- :)
(: -------------------------------------------------------- transformation -- :)

declare function local:transform($nodes as node()*, $root as node()) as item()* {
	for $node in $nodes
	return typeswitch($node)
		case text()    return $node
		case comment() return local:skipElement($node)
		case element() return local:transformElement($node, $root)
		default        return local:transform($node/node(), $root)
};

declare function local:skipElement($node as node()) as item()* {
	()
};

declare function local:unwrapElement($node as node(), $root) as item()* {
	local:transform($node/node(), $root)
};

declare function local:transformElement($node as node(), $root as node()) as item()* {
	typeswitch($node)
	case element(tei:p)         return local:handleP($node, $root)

	case element(tei:div)       return local:handleDiv($node, $root)
	case element(tei:head)      return local:handleHead($node, $root)

	case element(tei:milestone) return local:handleMilestone($node, $root)
	case element(tei:anchor)    return local:handleAnchor($node, $root)

	case element(tei:note)      return local:handleNote($node, $root)
	case element(tei:date)      return local:convertElementTo($node, "span", $root)
	case element(tei:time)      return local:convertElementTo($node, "span", $root)

	case element(tei:lg)        return local:convertElementTo($node, "div", $root)
	case element(tei:l)         return local:convertElementTo($node, "p", $root)

	case element(tei:distinct)  return local:convertElementTo($node, "span", $root)
	case element(tei:choice)    return local:unwrapElement($node, $root)
	case element(tei:orig)      return local:convertElementTo($node, "span", $root)
	case element(tei:reg)       return local:convertElementTo($node, "span", $root)

	case element(tei:graphic)   return local:handleGraphic($node, $root)
	case element(tei:figDesc)   return local:skipElement($node)

	case element(tei:rs)        return local:handleRs($node, $root)
	case element(tei:said)      return local:handleSaid($node, $root)

	case element(tei:measure)   return local:convertElementTo($node, "span", $root)
	case element(tei:view)      return local:convertElementTo($node, "span", $root)
	case element(tei:seg)       return local:convertElementTo($node, "span", $root)
	case element(tei:pb)        return local:convertElementTo($node, "span", $root)

	case element(tei:emph)      return local:convertElementTo($node, "em", $root)
	case element(tei:hi)        return local:convertElementTo($node, "em", $root)

	default                     return local:convertElementTo($node, $node/name(), $root)
};

(: -------------------------------------------------------------------------- :)
(: -------------------------------------------------------- main execution -- :)

let $root := /
let $book := $root//tei:div[@xml:id="book"]
(:
return local:transform($book, $root)
:)
let $chapters := $book//tei:div[@type="chapter"]
return local:transform($chapters[@xml:id="c1"], $root)

