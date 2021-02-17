<!-- Your HTML goes here -->
<template>
    <div id="svg-container-line">
      <v-btn text rounded @click="reset">Reset Zoom</v-btn>
    </div>
</template>

<script>
import * as d3 from 'd3'
//import * as uid from "@/plugins/uid";

export default {
  name: 'LineChart', // Feel free to rename this and the file
  props: {
    lineData: {
      required: true
    },
    selectedColor: {
      required: true
    },
    selectedCountry: {
      required: true
    },
    height: {
      required: true
    },
    margin: {
      required: true
    },
    selectedAttr: {
      required: true
    },
    width: {
      required: true
    }

  },
  watch: {
    lineData: {
      handler: function (val) {
        this.lineData = val;
        this.init();
      },
      deep: true
    },
    selectedColor: {
      handler: function (val) {
        this.selectedColor = val;
        this.init();
      },
      deep: true
    },
    selectedCountry: {
      handler: function (val) {
        this.selectedColor = val;
        this.init();
      },
      deep: true
    },
    selectedAttr: {
      handler: function (val) {
        this.selectedAttrUpper = val;
      },
      deep: true
    }

  },
  data: () => ({
    x: null,
    y: null,
    line: null,
    xAxis: null,
    yAxis: null,
    svg: null,
    gx: null,
    gy: null,
    path: null,
    dot: null,
    zoomLine: null,
    zx: null,
    zy: null,
    zoom: null,
    s: null,
    xm: null



  }),
  created() {


  },
  mounted() {

    console.log("mounted line chart")
    this.init();
  },
  methods: {
    init() {
      this.selectedAttr = this.selectedAttr.toLowerCase();


      this.x = d3.scaleUtc()
          .domain(d3.extent(this.lineData.dates))
          .range([this.margin.left, this.width - this.margin.right])

      this.y = d3.scaleLinear()
          .domain([0, d3.max(this.lineData.series, d => d3.max(d[this.selectedAttr]))]).nice()
          .range([this.height - this.margin.bottom, this.margin.top])

      this.line = d3.line()
          .defined(d => !isNaN(d))
          .x((d, i) =>  this.x(this.lineData.dates[i]))
          .y(d => this.y(d))

      this.xAxis = (g,x) => g
          .attr("transform", `translate(0,${this.height})`)
          .call(d3.axisBottom(x).ticks(this.width / 80).tickSizeOuter(0))
          .call(g => g.select(".domain").attr("display","none"))

      this.yAxis = g => g
          //.attr("transform", `translate(${this.margin.left},0)`)
          .call(d3.axisLeft(this.y))
          .call(g => g.select(".domain").remove())
          .call(g => g.select(".domain").attr("display","none"))
          .call(g => g.select(".tick:last-of-type text").clone()
              .attr("x", 3)
              .attr("text-anchor", "start")
              .attr("font-weight", "bold")
              .text(this.lineData.y))
      this.renderLineChart();

    },
    renderLineChart() {
      console.log("render line chart")
      d3.select(".lineChart").remove();
      this.svg = d3.select("#svg-container-line").append("svg")
          .attr("class", "lineChart")
          .style("overflow", "visible")
          .attr("viewBox", [0, 0, this.width, this.height]);



      this.svg
          .append("defs")
          .append("clipPath")
          .attr("id","clip")
          .append("rect")
          .attr("width",this.width)
          .attr("height",this.height);


      this.svg.append("g")
          .call(this.yAxis);


        this.path = this.svg.append("g")
            .attr("fill", "none")
            .attr("stroke", this.selectedColor)
            .attr("stroke-width", 1.5)
            .attr("stroke-linejoin", "round")
            .attr("stroke-linecap", "round")
            .attr("class", "line")
            .selectAll("path")
            .data(this.lineData.series)
            .join("path")
            .style("mix-blend-mode", "multiply")
            .attr("d", d => this.line(d[this.selectedAttr]))
            .attr("country", d => d.name)



      this.path.attr("clip-path","url(#clip)")

      this.gx = this.svg.append("g");

      this.gy = this.svg.append("g");


       this.zoom = d3.zoom()
          .scaleExtent([1,5])
          .on("zoom", this.zoomed);

      this.svg.call(this.zoom).call(this.zoom.transform, d3.zoomIdentity);



      this.svg.call(this.hover);
    },
    zoomed({transform}) {
      console.log("zoomed")
       this.zx = transform.rescaleX(this.x).interpolate(d3.interpolateDate);
      //this.zy = transform.rescaleY(this.y).interpolate(d3.interpolateNumber);

      this.zoomLine = d3.line()
          .x((d, i) =>  this.zx(this.lineData.dates[i]))
          .y(d =>  this.y(d))

      this.path.attr("d", d => this.zoomLine(d[this.selectedAttr]));
      this.gx.call(this.xAxis, this.zx);
      //this.gy.call(this.yAxis, this.zy);
    },
    reset() {
      this.svg.transition()
          .duration(750)
          .call(this.zoom.transform, d3.zoomIdentity);
    },
    hover() {
      if ("ontouchstart" in document)
        this.svg
          .style("-webkit-tap-highlight-color", "transparent")
          .on("touchmove", this.moved)
          .on("touchstart", this.entered)
          .on("touchend", this.left)
      else this.svg
          .on("mousemove", this.moved)
          .on("mouseenter", this.entered)
          .on("mouseleave", this.left);



      this.dot = this.svg.append("g")
          .attr("display", "none");

      this.dot.append("circle")
          .attr("r", 2.5);

      this.dot.append("text")
          .attr("font-family", "sans-serif")
          .attr("font-size", 10)
          .attr("text-anchor", "middle")
          .attr("y", -8);

    },


    moved(event) {
      event.preventDefault();
      const pointer = d3.pointer(event);
       this.xm = this.zx.invert(pointer[0]);
      const ym = this.y.invert(pointer[1]);
      const i = d3.bisectCenter(this.lineData.dates, this.xm);
      this.s = d3.least(this.lineData.series, d =>  Math.abs(d[this.selectedAttr][i] - ym));
      this.path.attr("stroke", d => d === this.s ? null : "#ddd").filter(d => d === this.s).raise();
      this.dot.attr("transform", `translate(${this.zx(this.lineData.dates[i])},${this.y(this.s[this.selectedAttr][i])})`);
      this.dot.select("text").text(this.s.name);
    },
    entered() {
      this.path.style("mix-blend-mode", null).attr("stroke", "#ddd");
      this.dot.attr("display", null);
    },
    left() {
      this.path.style("mix-blend-mode", "multiply").attr("stroke", null);
      this.dot.attr("display", "none");
    },
    /*
    selectCountry(event){
      event.preventDefault();
      const pointer = d3.pointer(event);
      const xm = this.zx.invert(pointer[0]);
      const ym = this.y.invert(pointer[1]);
      const i = d3.bisectCenter(this.lineData.dates, xm);
      const s = d3.least(this.lineData.series, d =>  Math.abs(d[this.selectedAttr][i] - ym));
      this.$emit("lineChartCountry",s.name);
      this.$emit("lineChartYear",xm.getUTCFullYear());
    }
     */
  },
}
</script>

<style>
</style>