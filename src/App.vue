<template>
  <v-app style="background-color: white!important;">

    <v-app-bar app color="primary" dark fixed >
    <v-app-bar-title>National Footprint Accounts</v-app-bar-title>

      <v-spacer></v-spacer>

      <v-select
          class="style-chooser"
          @change="constructMapData"
          v-model="valueYear"
          label="Select Year"
          :items="itemsYear"
          hide-details
          :menu-props="{top: true, offsetY: true,}"
      ></v-select>
      <v-select
          @change="constructMapData"
          v-model="valueAttr"
          label="Select Attribute"
          :items="itemsAttr"
          hide-details
          :menu-props="{top: true, offsetY: true}"
      ></v-select>
      <v-select
          @change="constructMapData"
          v-model="valueRecord"
          label="Select Record Type"
          :items="itemsRecord"
          hide-details
          :menu-props="{top: true, offsetY: true}"
      ></v-select>
      <v-btn @click="toggleDarkTheme"
             text rounded>Toggle Theme</v-btn>
    </v-app-bar>

    <v-main style="z-index: 0;">
       <v-row align-content-lg="center" no-gutters>
        <v-col lg=true>

          <Map
              style="z-index: 0;"
           v-if="map_data"
           :map_data="map_data"
              :attr_data="attr_data"
           :selectedAttr="valueAttr"
           :selectedRecord="valueRecord"
           @selectedCountry="createChartData"
           @selectedColor="loadSelectedColor"
          >

          </Map>
        </v-col>
       </v-row>
        <v-row align-content-lg="center" justify-lg="center" no-gutters >
          <v-col lg=true align="center">
            <WaffleChart
                v-if="waffleArr"
          :waffleArr="waffleArr"
                :waffleChartData="waffleChartData"
          :waffleSize="600"
          :padding="({x:10,y:40})"
          :width="900"
          :height="600" >

            </WaffleChart>
          </v-col>
          <v-col lg=true align="center">
            <LineChart
                v-if="lineData"
           :lineData="lineData"
                :margin="({top: 20,right: 20,bottom: 30,left: 30})"
                :height="350"
                :selectedAttrLine="valueAttr"
                :width="550"
                :selectedColor="selectedColor"
                :selectedCountry="selectedCountry"




            >

            </LineChart>
          </v-col>
        </v-row>
    </v-main>
  </v-app>
</template>
<script>
import Map from "./components/Map.vue"
import WaffleChart from "./components/WaffleChart.vue"
import LineChart from "@/components/LineChart";
import geoJson from "./data/countries.json"
import attr_data_import from "./data/attr_data.json"
import * as d3 from 'd3'

export default {
  name: 'App',
  components: {
    LineChart,
    Map,
    WaffleChart

  },

  data: () => ({
    map_data: null,
    attr_data: null,
    itemsYear: null,
    itemsAttr: ["Crop_Land","Grazing_Land","Forest_Land", "Fishing_Ground","Built_Up_Land", "Total","Population"],
    itemsRecord: null,
    valueYear: 2014,
    valueAttr: "Forest_Land",
    valueRecord: "BiocapPerCap",
    max_val: null,
    min_val: null,
    waffleChartData: null,
    waffleArr: null,
    lineData: null,
    selectedColor: "#74c476",
    selectedCountry: null,

  }),
  created() {
    this.itemsYear =  [...new Set(attr_data_import.map(item => item.year))].sort().reverse();
    this.itemsRecord =  [...new Set(attr_data_import.map(item => item.record))];
    this.$vuetify.theme.themes.light.background = '#FFF';
    this.$vuetify.theme.themes.dark.background = '#FFF';
  },
  mounted() {

    console.log("mounted")
    this.constructMapData();
    this.createChartData();


  },
  methods: {
    toggleTheme() {
    //  console.log("toggle theme")
     // console.log(this.selectedColor);
      this.$vuetify.theme.themes.light.primary = this.selectedColor
      this.$vuetify.theme.themes.dark.primary = this.selectedColor
    },
    toggleDarkTheme(){
      this.$vuetify.theme.themes.dark.anchor = "#41B883"
      this.$vuetify.theme.dark = !this.$vuetify.theme.dark
    },
    constructMapData() {
      console.log("constructing");


      console.log(attr_data_import[36641])
      this.attr_data = attr_data_import.filter(d => d.year === this.valueYear && d.record === this.valueRecord);
      console.log(this.attr_data);
      for(const feature of geoJson.features) {
        for (const obj of this.attr_data) {
          if (feature.properties.ADMIN === obj.country) {
              feature.properties[this.valueAttr] = obj[this.valueAttr.toLowerCase()];
          } else {
            continue;
          }
        }
      }
      this.map_data = geoJson;
      this.createLineData();

    },
    createChartData(selectedCountry) {
      this.selectedCountry = selectedCountry;
      require("largest-remainder-round")
      let filteredData = this.attr_data.filter(d => d.country === selectedCountry)[0]
      if (filteredData == undefined) {
      filteredData =  this.attr_data.filter(d => d.country === "World")[0]

      }
      let chartData = [];
        let total = filteredData.total
      for (const [key,value] of Object.entries(filteredData)){
        if(key.split("_").length-1 !== 0){
          chartData.push({"landType": key, "value": value, "ratio": value / total * 100});
        }
      }
      chartData.spread({prop: "ratio"});
      this.waffleChartData = chartData;
      this.createWaffle();
    },
createWaffle() {
  var array = [];
  const max = this.waffleChartData.length;
  var index = 0, curr = 1,
      accu = this.waffleChartData[0].ratio_spread, waffle = [];

  for (var y = 9; y >= 0; y--)
    for (var x = 0; x < 10; x ++) {
      if (curr > accu && index < max) {
        var r = this.waffleChartData[++index].ratio_spread;

        while(r === 0 && index < max) r = this.waffleChartData[++index].ratio_spread;
        accu += r;
      }
      waffle.push({x, y, index});
      curr++;
    }
  array.push(waffle);

      this.waffleArr = array;

},
    createLineData() {
     let filtered_data = attr_data_import.filter(d => d.country != "World" & d.record === this.valueRecord);
      let timeParser = d3.utcParse("%Y")

     this.lineData = {
       y: undefined,
       series: [],
       dates: undefined


     }

      var groupBy = function(xs, key) {
        return xs.reduce(function(rv, x) {
          (rv[x[key]] = rv[x[key]] || []).push(x);
          return rv;
        }, {});
      };

      let grouped_data = groupBy(filtered_data,"country");

      let yearFilteredData = attr_data_import.filter(d => d.country === "Australia" & d.record === this.valueRecord);
      let dateArr = yearFilteredData.map(d => +d.year);
      this.lineData.dates = dateArr;

      for (const [key,value] of Object.entries(grouped_data)){
        var push_obj = {
          name: undefined,
        }
      push_obj.name = key;
      for (const obj of value){
        for (const [prop_key,prop_val] of Object.entries(obj)){
          if(!(isNaN(prop_val) && prop_key !== "year")){
            if (Object.keys(push_obj).includes(prop_key)) {
                push_obj[prop_key].push(prop_val);
            }
            else {
              push_obj[prop_key] = [];
              push_obj[prop_key].push(prop_val);
              }
            }
          }
        }
        this.lineData.series.push(push_obj);
      }

      //console.log("series data:",this.lineData.series);

      var i;
for(i = 0; i < this.lineData.series.length; i++){
  if(this.lineData.series[i].year.length === 54){
    continue
  }
  let minYear = this.lineData.series[i].year[0];
  let maxYear = this.lineData.series[i].year.slice(-1)[0];
  let minYearIndex = this.lineData.dates.indexOf(minYear);
  let maxYearIndex = this.lineData.dates.indexOf(maxYear);
  let lowerArrLen = this.lineData.dates.slice(1,minYearIndex).length;
  let higherArrLen = this.lineData.dates.slice(maxYearIndex).length;

let lowerArr = Array(lowerArrLen).fill(0)
     let higherArr = Array(higherArrLen).fill(0)

  for(const [series_prop_key,series_prop_val] of Object.entries(this.lineData.series[i])){

    if(typeof series_prop_val[0] === "number"){

        let firstArr = lowerArr.concat(series_prop_val);
        let finalArr = firstArr.concat(higherArr);
        //console.log("before:",this.lineData.series[i][series_prop_key]);
        this.lineData.series[i][series_prop_key] = finalArr;
        //console.log("after:",this.lineData.series[i][series_prop_key]);

    }

  }
}



      if(this.valueAttr === "Population"){
        this.lineData.y = "People";
      }
      else if(this.valueAttr === "GDP_per_Capita"){
        this.lineData.y = "GDP_per_Capita";
      }
      else{
        this.lineData.y = this.valueRecord;
      }
      dateArr = yearFilteredData.map(d => timeParser(d.year));
      this.lineData.dates = dateArr;

      console.log("this.lineData:",this.lineData);


    },
    loadSelectedColor(color){
      //console.log("loadSelectedColor")
      this.selectedColor = color;
      this.toggleTheme();
    },








  },


};
</script>
<style>
#mapid {
  height: 480px;
}
.v-application .info {
  background-color: white !important;
  border-color:white !important;
}
</style>
