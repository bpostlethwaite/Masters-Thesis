<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="1.8.0-Lisboa" minimumScale="0" maximumScale="1e+08" hasScaleBasedVisibilityFlag="0">
  <transparencyLevelInt>255</transparencyLevelInt>
  <renderer-v2 symbollevels="0" type="RuleRenderer">
    <rules>
      <rule filter=" &quot;m2Vp&quot;  &lt; 6.287 OR  &quot;m2Vp&quot;  > 6.528  OR (&quot;m2Vp&quot;  > 6.317 AND  &quot;m2Vp&quot;  &lt; 6.497)" symbol="0" label="Outside Ranges"/>
      <rule filter=" &quot;m2Vp&quot;  >= 6.497 AND  &quot;m2Vp&quot;  &lt;= 6.528" symbol="1" label="Upper Peak"/>
      <rule filter=" &quot;m2Vp&quot;  >= 6.287 AND  &quot;m2Vp&quot;  &lt;= 6.317" symbol="2" label="Lower Peak"/>
    </rules>
    <symbols>
      <symbol outputUnit="MM" alpha="0" type="marker" name="0">
        <layer pass="0" class="SimpleMarker" locked="0">
          <prop k="angle" v="0"/>
          <prop k="color" v="8,1,134,255"/>
          <prop k="color_border" v="0,0,0,255"/>
          <prop k="name" v="star"/>
          <prop k="offset" v="0,0"/>
          <prop k="size" v="3"/>
        </layer>
      </symbol>
      <symbol outputUnit="MM" alpha="1" type="marker" name="1">
        <layer pass="0" class="SimpleMarker" locked="0">
          <prop k="angle" v="0"/>
          <prop k="color" v="0,0,255,255"/>
          <prop k="color_border" v="0,0,0,255"/>
          <prop k="name" v="star"/>
          <prop k="offset" v="0,0"/>
          <prop k="size" v="3"/>
        </layer>
      </symbol>
      <symbol outputUnit="MM" alpha="1" type="marker" name="2">
        <layer pass="0" class="SimpleMarker" locked="0">
          <prop k="angle" v="0"/>
          <prop k="color" v="255,0,0,255"/>
          <prop k="color_border" v="0,0,0,255"/>
          <prop k="name" v="star"/>
          <prop k="offset" v="0,0"/>
          <prop k="size" v="3"/>
        </layer>
      </symbol>
    </symbols>
  </renderer-v2>
  <customproperties/>
  <displayfield>mcode</displayfield>
  <label>0</label>
  <labelattributes>
    <label fieldname="" text="Label"/>
    <family fieldname="" name="Ubuntu"/>
    <size fieldname="" units="pt" value="12"/>
    <bold fieldname="" on="0"/>
    <italic fieldname="" on="0"/>
    <underline fieldname="" on="0"/>
    <strikeout fieldname="" on="0"/>
    <color fieldname="" red="0" blue="0" green="0"/>
    <x fieldname=""/>
    <y fieldname=""/>
    <offset x="0" y="0" units="pt" yfieldname="" xfieldname=""/>
    <angle fieldname="" value="0" auto="0"/>
    <alignment fieldname="" value="center"/>
    <buffercolor fieldname="" red="255" blue="255" green="255"/>
    <buffersize fieldname="" units="pt" value="1"/>
    <bufferenabled fieldname="" on=""/>
    <multilineenabled fieldname="" on=""/>
    <selectedonly on=""/>
  </labelattributes>
  <edittypes>
    <edittype type="0" name="AGERXTP"/>
    <edittype type="0" name="AGETPRCH"/>
    <edittype type="0" name="AREA"/>
    <edittype type="0" name="AREA_2"/>
    <edittype type="0" name="CNT_GEOLPR"/>
    <edittype type="0" name="EPOCH"/>
    <edittype type="0" name="EPOQUE"/>
    <edittype type="0" name="ERA"/>
    <edittype type="0" name="ERE"/>
    <edittype type="0" name="GEOLPROV"/>
    <edittype type="0" name="LEN"/>
    <edittype type="0" name="LEN_2"/>
    <edittype type="0" name="PERIOD"/>
    <edittype type="0" name="PERIODE"/>
    <edittype type="0" name="RXTP"/>
    <edittype type="0" name="SUBRXTP"/>
    <edittype type="0" name="SUBTPRCH"/>
    <edittype type="0" name="SYMBOL"/>
    <edittype type="0" name="TPRCH"/>
    <edittype type="0" name="UNIT"/>
    <edittype type="0" name="UNITE"/>
    <edittype type="0" name="m2H"/>
    <edittype type="0" name="m2Vp"/>
    <edittype type="0" name="mcode"/>
  </edittypes>
  <editform>.</editform>
  <editforminit></editforminit>
  <annotationform>.</annotationform>
  <attributeactions/>
</qgis>
