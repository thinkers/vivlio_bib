declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

let $items := doc("master.xml")//tei:list[@type='objects']/tei:item
let $objects := //tei:rs[@type="obRef"]

for $item in $items order by normalize-space(string($item/tei:name))
let $filtered := $objects[concat("#", $item/@xml:id) = tokenize(@ref, " ")]
return
<object>
	<name>{normalize-space(string($item/tei:name))}</name>
	<ref>{data($item/@xml:id)}</ref>
	<desc>{normalize-space(string($item/tei:desc))}</desc>
	<graphic>{data($item/tei:figure/tei:graphic/@url)}</graphic>
	<scenes>
	{
		for $i in $filtered/(preceding::tei:milestone)[last()]/@xml:id
		return <scene>{data($i)}</scene>
	}
	</scenes>
	<chapters>
	{
		for $i in $filtered/(ancestor-or-self::tei:div[@type="chapter"])[last()]/@n
		return <chapter id="{data($i/@xml:id)}">{data($i/@n)}</chapter>
	}
	</chapters>
</object>

