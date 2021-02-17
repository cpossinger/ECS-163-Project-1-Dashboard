<template>
  <div>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
          integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A=="
          crossorigin=""/>
    <script type="application/javascript" src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"
            integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA=="
            crossorigin=""></script>

  <div id="mapid" @dblclick="zoomOut"></div>
  </div>
</template>

<script>
import * as d3 from 'd3'
import * as L from "leaflet"
//import * as chroma from "chroma-js"

export default {
  name: 'Map',
  props: {
    map_data: {
      required: true
    },
    lineChartCountry: {
    },
    selectedAttr: {
      required: true
    },
    max: {
      required: true
    },
    min: {
      required: true
    },
    selectedRecord: {
      required: true
    }


  },
  watch: {
    map_data: {
      handler: function (val) {
        this.map_data = val;
        this.init();
      },
      deep: true
    },
    lineChartCountry: {
      handler: function (val) {
        this.lineChartCountry = val;
        this.flyToLineCountry()
      },
      deep: true
    },
    selectedRecord: {
      handler: function (val) {
        this.selectedRecord = val;
        this.init();
      },
      deep: true
    },
    selectedAttr: {
      handler: function (val) {
        this.selectedAttr = val;
      },
      deep: true
    },
    max: {
      handler: function (val) {
        this.max = val;
        this.init();
      },
      deep: true
    },
    min: {
      handler: function (val) {
        this.min = val;
      },
      deep: true
    },

  },
  data: () => ({
    selectedCountry: null,
    info: null,
    legend: null,
    colorArr: null,
    legendLabels: null,
    firstQuantile: null,
    secondQuantile: null,
    thirdQuantile: null,
    fourthQuantile: null,
    fifthQuantile: null,
    sixthQuantile: null,
    seventhQuantile: null,
    selectedColor: null


  }),
  created() {
  },
  mounted() {
    //console.log("init map");
    this.map = L.map("mapid").setView([51.505, -0.09], 2);

    this.map.doubleClickZoom.disable();
    L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
      attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
      maxZoom: 10,
      id: 'mapbox/light-v9',
      tileSize: 512,
      zoomOffset: -1,
      accessToken: 'pk.eyJ1IjoiY3Bvc3NpbmdlciIsImEiOiJja2tqMHV5bjExNHIzMnVudzc1bzJ4dWhoIn0.53g3xS17ONQ80xyG80Fzpw'
    }).addTo(this.map);

    this.init()
  },
  methods: {
    init() {


      this.colorArr = [];

      for (const feature of this.map_data.features) {
        let obj = feature.properties;
        if (obj[this.selectedAttr] !== undefined) {
          this.colorArr.push(obj[this.selectedAttr]);
        }
      }


      this.firstQuantile = d3.quantile(this.colorArr, 0.0125);
      this.secondQuantile = d3.quantile(this.colorArr, 0.25);
      this.thirdQuantile = d3.quantile(this.colorArr, 0.375);
      this.fourthQuantile = d3.quantile(this.colorArr, 0.50);
      this.fifthQuantile = d3.quantile(this.colorArr, 0.625);
      this.sixthQuantile = d3.quantile(this.colorArr, 0.75);
      this.seventhQuantile = d3.quantile(this.colorArr, 0.875);

      this.legendLabels = [];
      this.legendLabels.push(this.firstQuantile)
      this.legendLabels.push(this.secondQuantile)
      this.legendLabels.push(this.thirdQuantile)
      this.legendLabels.push(this.fourthQuantile)
      this.legendLabels.push(this.fifthQuantile)
      this.legendLabels.push(this.sixthQuantile)
      this.legendLabels.push(this.seventhQuantile)
      this.legendLabels.unshift(0);

      L.geoJSON(this.map_data).addTo(this.map);
      this.geoJson = L.geoJSON(this.map_data, {style: this.style, onEachFeature: this.onEachFeature}).addTo(this.map);



      if (this.info != null) {
        this.info.remove();
      }
      if (this.legend != null) {
        //console.log("remove legend")
        this.legend.remove();
      }

      this.info = L.control();

      // eslint-disable-next-line no-unused-vars
      this.info.onAdd = function (map) {
        //console.log("on add");
        this._div = L.DomUtil.create('div', 'info'); // create a div with a class "info"
        this.update()
        return this._div;
      }

      this.info.update = function (props,selectedAttr,selectedRecord) {

        if (props === undefined) {
          this._div.innerHTML = '<h4>Country</h4>' + 'Hover over a Country';
        } else {
          if (props[selectedAttr] === undefined) {
            this._div.innerHTML = '<h4>Country</h4>' +
                '<b>' + props.ADMIN + '</b><br />' + "No Data";
          } else {
            this._div.innerHTML = '<h4>Country</h4>' +
                '<b>' + props.ADMIN + '</b><br />' + props[selectedAttr] + " " + selectedRecord;
          }

        }


      };


      this.info.addTo(this.map);

      this.legend = L.control({position: "bottomright"});

      // eslint-disable-next-line no-unused-vars
      this.legend.onAdd = function (map) {
        //console.log("legend on add")
        this.div = L.DomUtil.create('div', 'info legend')
        return this.div;
      }

      this.legend.update = function (self) {
        //console.log("legend update");
        for (var i = 0; i < self.legendLabels.length; i++) {
          this.div.innerHTML +=
              '<i style="background:' + self.getColor(self.legendLabels[i] + 0.01) + '"></i> ' +
              self.legendLabels[i].toFixed(4) + (self.legendLabels[i + 1] ? '&ndash;' + self.legendLabels[i + 1].toFixed(4) + '<br>' : '+');
        }
      }


      this.legend.addTo(this.map);
      this.legend.update(this);

      if (this.selectedAttr === "Forest_Land") {
        this.selectedColor = "#74c476";
        this.$emit("selectedColor",this.selectedColor);
      } else if (this.selectedAttr === "Fishing_Ground") {
        this.selectedColor = "#74a9cf";
        this.$emit("selectedColor",this.selectedColor);
      } else if (this.selectedAttr === "Crop_Land") {
       this.selectedColor = "#fe9929";
        this.$emit("selectedColor",this.selectedColor);
      } else if (this.selectedAttr === "Grazing_Land") {
        this.selectedColor = "#78c679";
        this.$emit("selectedColor",this.selectedColor);
      } else if (this.selectedAttr === "Built_up_Land") {
        this.selectedColor = "#df65b0";
        this.$emit("selectedColor",this.selectedColor);
      } else if (this.selectedAttr === "Carbon") {
        this.selectedColor = "#fb6a4a";
        this.$emit("selectedColor",this.selectedColor);
      } else if (this.selectedAttr === "Total_Land") {
        this.selectedColor = "#8c96c6";
        this.$emit("selectedColor",this.selectedColor);
      } else if (this.selectedAttr === "GDP_per_Capita") {
        this.selectedColor = "#74c476";
        this.$emit("selectedColor",this.selectedColor);
      } else {
        this.selectedColor = "#969696";
        this.$emit("selectedColor",this.selectedColor);
      }


    },
    style(feature) {
      //console.log("styling")

      return {
        fillColor: this.getColor(feature.properties[this.selectedAttr]),
        weight: 2,
        opacity: 1,
        color: 'white',
        dashArray: '3',
        fillOpacity: 0.7
      }
    },
    highlightFeature(e) {
      //console.log("highlighFeature")

      var layer = e.target;

      layer.setStyle({
        weight: 5,
        color: '#666',
        dashArray: '',
        fillOpacity: 0.7
      });

      if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
        layer.bringToFront();
      }
      this.info.update(layer.feature.properties, this.selectedAttr, this.selectedRecord);
    },

    resetHighlight(e) {
      //console.log("resetHighlight")
      this.geoJson.resetStyle(e.target);
      this.info.update()
    },

    zoomToFeature(e) {
      //console.log("zoomToFeature")
      this.map.fitBounds(e.target.getBounds());
      this.selectedCountry = e.sourceTarget.feature.properties.ADMIN;
      this.$emit("selectedCountry", this.selectedCountry);
    },

    zoomOut() {
      this.map.flyTo([51.505, -0.09], 2);
      this.selectedCountry = "World"
      this.$emit("selectedCountry", this.selectedCountry);
    },

    onEachFeature(feature, layer) {
      //console.log("onEachFeature")
      layer.on({
        mouseover: this.highlightFeature,
        mouseout: this.resetHighlight,
        click: this.zoomToFeature,
        dblclick: this.zoomOut
      });
    },
    flyToLineCountry() {
console.log(this.map_data);
for(const feature of this.map_data.features){
  let obj = feature.properties
  console.log(obj);
  if(obj.ADMIN === this.lineChartCountry){
    this.map.flyTo(obj.geometry.coordinates[0])
  }
  else{
    continue;
  }

}
    },

    getColor(d) {
      if (this.selectedAttr === "Forest_Land") {
        this.selectedColor = "#74c476";
        this.$emit("selectedColor",this.selectedColor);
        return d > this.seventhQuantile ? '#005a32' :
            d > this.sixthQuantile ? '#238b45' :
                d > this.fifthQuantile ? '#41ab5d' :
                    d > this.fourthQuantile ? '#74c476' :
                        d > this.thirdQuantile ? '#a1d99b ' :
                            d > this.secondQuantile ? '#c7e9c0' :
                                d > this.firstQuantile ? '#e5f5e0' :
                                    '#f7fcf5';


      } else if (this.selectedAttr === "Fishing_Ground") {
        this.selectedColor = "#74a9cf";
        this.$emit("selectedColor",this.selectedColor);
        return d > this.seventhQuantile ? '#034e7b' :
            d > this.sixthQuantile ? '#0570b0' :
                d > this.fifthQuantile ? '#3690c0' :
                    d > this.fourthQuantile ? '#74a9cf' :
                        d > this.thirdQuantile ? '#a6bddb' :
                            d > this.secondQuantile ? '#d0d1e6' :
                                d > this.firstQuantile ? '#ece7f2' :
                                    '#fff7fb'


      } else if (this.selectedAttr === "Crop_Land") {
        return d > this.seventhQuantile ? '#8c2d04' :
            d > this.sixthQuantile ? '#cc4c02' :
                d > this.fifthQuantile ? '#ec7014' :
                    d > this.fourthQuantile ? '#fe9929' :
                        d > this.thirdQuantile ? '#fec44f' :
                            d > this.secondQuantile ? '#fee391' :
                                d > this.firstQuantile ? '#fff7bc' :
                                    '#ffffe5'

      } else if (this.selectedAttr === "Grazing_Land") {
        return d > this.seventhQuantile ? '#005a32' :
            d > this.sixthQuantile ? '#238443' :
                d > this.fifthQuantile ? '#41ab5d' :
                    d > this.fourthQuantile ? '#78c679' :
                        d > this.thirdQuantile ? '#addd8e' :
                            d > this.secondQuantile ? '#d9f0a3' :
                                d > this.firstQuantile ? '#f7fcb9' :
                                    '#ffffe5'
      } else if (this.selectedAttr === "Built_up_Land") {
        return d > this.seventhQuantile ? '#91003f' :
            d > this.sixthQuantile ? '#ce1256' :
                d > this.fifthQuantile ? '#e7298a' :
                    d > this.fourthQuantile ? '#df65b0' :
                        d > this.thirdQuantile ? '#c994c7' :
                            d > this.secondQuantile ? '#d4b9da' :
                                d > this.firstQuantile ? '#e7e1ef' :
                                    '#f7f4f9'

      } else if (this.selectedAttr === "Carbon") {
        return d > this.seventhQuantile ? '#99000d' :
            d > this.sixthQuantile ? '#cb181d' :
                d > this.fifthQuantile ? '#ef3b2c' :
                    d > this.fourthQuantile ? '#fb6a4a' :
                        d > this.thirdQuantile ? '#fc9272' :
                            d > this.secondQuantile ? '#fcbba1' :
                                d > this.firstQuantile ? '#fee0d2' :
                                    '#fff5f0'
      } else if (this.selectedAttr === "Total_Land") {
        return d > this.seventhQuantile ? '#6e016b' :
            d > this.sixthQuantile ? '#88419d' :
                d > this.fifthQuantile ? '#8c6bb1' :
                    d > this.fourthQuantile ? '#8c96c6' :
                        d > this.thirdQuantile ? '#9ebcda' :
                            d > this.secondQuantile ? '#bfd3e6' :
                                d > this.firstQuantile ? '#e0ecf4' :
                                    '#f7fcfd'
      } else if (this.selectedAttr === "GDP_per_Capita") {
        return d > this.seventhQuantile ? '#005a32' :
            d > this.sixthQuantile ? '#238b45' :
                d > this.fifthQuantile ? '#41ab5d' :
                    d > this.fourthQuantile ? '#74c476' :
                        d > this.thirdQuantile ? '#a1d99b' :
                            d > this.secondQuantile ? '#c7e9c0' :
                                d > this.firstQuantile ? '#e5f5e0' :
                                    '#f7fcf5'
      } else {
        return d > this.seventhQuantile ? '#252525' :
            d > this.sixthQuantile ? '#525252' :
                d > this.fifthQuantile ? '#737373' :
                    d > this.fourthQuantile ? '#969696' :
                        d > this.thirdQuantile ? '#bdbdbd' :
                            d > this.secondQuantile ? '#d9d9d9' :
                                d > this.firstQuantile ? '#f0f0f0' :
                                    '#ffffff'
      }
    }


  },
};

</script>

<style>
#mapid {
  height: 480px;
}

 .v-application .info  {
  padding: 6px 8px;
  font: 14px/16px Arial, Helvetica, sans-serif;
  background: white !important;
  background: rgba(255,255,255,0.8) !important;
  box-shadow: 0 0 15px rgba(0,0,0,0.2);
  border-radius: 5px;
}
.info h4 {
  margin: 0 0 5px;
  color: #777;
}
.legend {
  line-height: 18px;
  color: #555;
}
.legend i {
  width: 18px;
  height: 18px;
  float: left;
  margin-right: 8px;
  opacity: 0.7;
}
</style>