declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

let $items := doc("master.xml")//tei:listPlace/tei:place
let $places := //tei:rs[@type="placeRef"]

for $item in $items order by normalize-space(string($item/tei:placeName/tei:name))
let $filtered := $places[concat("#", $item/@xml:id) = tokenize(@ref, " ")]
return
<place>
	<name>{normalize-space(string($item/tei:placeName/tei:name))}</name>
	<ref>{data($item/@xml:id)}</ref>
	<graphic>{data($item/tei:placeName/tei:figure/tei:graphic/@url)}</graphic>
	<scenes>
	{
		for $i in $filtered/(preceding::tei:milestone)[last()]/@xml:id
		return <scene>{data($i)}</scene>
	}
	</scenes>
	<chapters>
	{
		for $i in $filtered/(ancestor-or-self::tei:div[@type="chapter"])[last()]
		return <chapter id="{data($i/@xml:id)}">{data($i/@n)}</chapter>
	}
	</chapters>
</place>

