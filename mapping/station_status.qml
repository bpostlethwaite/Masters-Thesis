<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="1.8.0-Lisboa" minimumScale="0" maximumScale="1e+08" hasScaleBasedVisibilityFlag="0">
  <transparencyLevelInt>255</transparencyLevelInt>
  <renderer-v2 attr="status" symbollevels="0" type="categorizedSymbol">
    <categories>
      <category symbol="0" value="bad station" label="bad station"/>
      <category symbol="1" value="data corruption" label="data corruption"/>
      <category symbol="2" value="not aquired" label="not aquired"/>
      <category symbol="3" value="processed-notok" label="processed-notok"/>
      <category symbol="4" value="processed-ok" label="processed-ok"/>
      <category symbol="5" value="aquired" label="aquired"/>
      <category symbol="6" value="picked" label="picked"/>
    </categories>
    <symbols>
      <symbol outputUnit="MM" alpha="1" type="marker" name="0">
        <layer pass="0" class="SimpleMarker" locked="0">
          <prop k="angle" v="0"/>
          <prop k="color" v="228,26,28,255"/>
          <prop k="color_border" v="0,0,0,255"/>
          <prop k="name" v="equilateral_triangle"/>
          <prop k="offset" v="0,0"/>
          <prop k="size" v="2"/>
        </layer>
      </symbol>
      <symbol outputUnit="MM" alpha="1" type="marker" name="1">
        <layer pass="0" class="SimpleMarker" locked="0">
          <prop k="angle" v="0"/>
          <prop k="color" v="170,0,0,255"/>
          <prop k="color_border" v="0,0,0,255"/>
          <prop k="name" v="equilateral_triangle"/>
          <prop k="offset" v="0,0"/>
          <prop k="size" v="2"/>
        </layer>
      </symbol>
      <symbol outputUnit="MM" alpha="1" type="marker" name="2">
        <layer pass="0" class="SimpleMarker" locked="0">
          <prop k="angle" v="0"/>
          <prop k="color" v="0,0,0,255"/>
          <prop k="color_border" v="0,0,0,255"/>
          <prop k="name" v="equilateral_triangle"/>
          <prop k="offset" v="0,0"/>
          <prop k="size" v="2"/>
        </layer>
      </symbol>
      <symbol outputUnit="MM" alpha="1" type="marker" name="3">
        <layer pass="0" class="SimpleMarker" locked="0">
          <prop k="angle" v="0"/>
          <prop k="color" v="255,127,0,255"/>
          <prop k="color_border" v="0,0,0,255"/>
          <prop k="name" v="equilateral_triangle"/>
          <prop k="offset" v="0,0"/>
          <prop k="size" v="2"/>
        </layer>
      </symbol>
      <symbol outputUnit="MM" alpha="1" type="marker" name="4">
        <layer pass="0" class="SimpleMarker" locked="0">
          <prop k="angle" v="0"/>
          <prop k="color" v="0,255,0,255"/>
          <prop k="color_border" v="0,0,0,255"/>
          <prop k="name" v="equilateral_triangle"/>
          <prop k="offset" v="0,0"/>
          <prop k="size" v="2"/>
        </layer>
      </symbol>
      <symbol outputUnit="MM" alpha="1" type="marker" name="5">
        <layer pass="0" class="SimpleMarker" locked="0">
          <prop k="angle" v="0"/>
          <prop k="color" v="85,0,127,255"/>
          <prop k="color_border" v="0,0,0,255"/>
          <prop k="name" v="equilateral_triangle"/>
          <prop k="offset" v="0,0"/>
          <prop k="size" v="2"/>
        </layer>
      </symbol>
      <symbol outputUnit="MM" alpha="1" type="marker" name="6">
        <layer pass="0" class="SimpleMarker" locked="0">
          <prop k="angle" v="0"/>
          <prop k="color" v="170,85,0,255"/>
          <prop k="color_border" v="0,0,0,255"/>
          <prop k="name" v="equilateral_triangle"/>
          <prop k="offset" v="0,0"/>
          <prop k="size" v="2"/>
        </layer>
      </symbol>
    </symbols>
    <source-symbol>
      <symbol outputUnit="MM" alpha="1" type="marker" name="0">
        <layer pass="0" class="SimpleMarker" locked="0">
          <prop k="angle" v="0"/>
          <prop k="color" v="170,255,255,255"/>
          <prop k="color_border" v="0,0,0,255"/>
          <prop k="name" v="equilateral_triangle"/>
          <prop k="offset" v="0,0"/>
          <prop k="size" v="2"/>
        </layer>
      </symbol>
    </source-symbol>
    <colorramp type="colorbrewer" name="[source]">
      <prop k="colors" v="7"/>
      <prop k="schemeName" v="Set1"/>
    </colorramp>
    <rotation field=""/>
    <sizescale field=""/>
  </renderer-v2>
  <customproperties/>
  <displayfield>network</displayfield>
  <label>1</label>
  <labelfield>Vp</labelfield>
  <labelattributes>
    <label fieldname="Vp" text="Label"/>
    <family fieldname="" name="Ubuntu"/>
    <size fieldname="" units="pt" value="12"/>
    <bold fieldname="" on="0"/>
    <italic fieldname="" on="0"/>
    <underline fieldname="" on="0"/>
    <strikeout fieldname="" on="0"/>
    <color fieldname="" red="255" blue="0" green="255"/>
    <x fieldname=""/>
    <y fieldname=""/>
    <offset x="0" y="0" units="pt" yfieldname="" xfieldname=""/>
    <angle fieldname="" value="0" auto="0"/>
    <alignment fieldname="" value="above"/>
    <buffercolor fieldname="" red="255" blue="255" green="255"/>
    <buffersize fieldname="" units="pt" value="1"/>
    <bufferenabled fieldname="" on=""/>
    <multilineenabled fieldname="" on=""/>
    <selectedonly on="1"/>
  </labelattributes>
  <edittypes>
    <edittype type="0" name="H"/>
    <edittype type="0" name="R"/>
    <edittype type="0" name="Vp"/>
    <edittype type="0" name="network"/>
    <edittype type="0" name="station"/>
    <edittype type="0" name="status"/>
    <edittype type="0" name="stdH"/>
    <edittype type="0" name="stdR"/>
    <edittype type="0" name="stdVp"/>
  </edittypes>
  <editform></editform>
  <editforminit></editforminit>
  <annotationform>.</annotationform>
  <attributeactions/>
</qgis>
