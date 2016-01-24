declare namespace tei  = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";

let $items := doc("master.xml")//tei:list[@type="distinct"]/tei:item
let $distincts := //tei:distinct

for $item in $items order by normalize-space(string($item/tei:name))
let $filtered := $distincts[$item/@xml:id = @type]
return
<distinct>
	<name>{normalize-space(string($item/tei:name))}</name>
	<ref>{data($item/@xml:id)}</ref>
	<choices>
	{
		for $c in $filtered order by normalize-space(string($c//tei:orig))
		return
		<choice>
			<orig>{normalize-space(string($c//tei:orig))}</orig>
			<reg>{normalize-space(string($c//tei:reg))}</reg>
			<scenes>
			{
				for $i in $c/(preceding::tei:milestone)[last()]/@xml:id
				return <scene>{data($i)}</scene>
			}
			</scenes>
			<chapters>
			{
				for $i in $c/(ancestor-or-self::tei:div[@type="chapter"])[last()]/@n
				return <chapter id="{data($i/@xml:id)}">{data($i/@n)}</chapter>
			}
			</chapters>
		</choice>
	}
	</choices>
</distinct>

