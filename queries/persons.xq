declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

let $items := doc("master.xml")//tei:listPerson/tei:person
let $persons := //tei:rs[@type="persRef"]

for $item in $items order by normalize-space(string($item/tei:persName[1]))
let $filtered := $persons[concat("#", $item/@xml:id) = tokenize(@ref, " ")]
return
<person>
	<names>
	{
		for $i in $item/tei:persName
		return <name>{normalize-space(string($i))}</name>
	}
	</names>
	<note>{data($item/tei:note)}</note>
	<ref>{data($item/@xml:id)}</ref>
	<sex>{data($item/@sex)}</sex>
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
</person>

