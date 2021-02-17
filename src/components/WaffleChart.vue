<template>
    <div>
      <svg id="svg-container"></svg>
    </div>
</template>

<script>
import * as d3 from 'd3'

export default {
  name: 'WaffleChart',
  props: {
    waffleArr: {
      required: true
    },
    waffleSize: {
      required: true
    },
    height: {
      required: true
    },
    width: {
      required: true
    },
    padding: {
      required: true
    },
    waffleChartData: {
      required: true
    }


  },
  watch: {
    waffleArr: {
      handler: function (val) {
        this.waffleArr = val;
        this.init();
      },
      deep: true
    },
    waffleChartData: {
      handler: function (val) {
        this.waffleChartData = val;
      },
      deep: true
    }
  },
  data: () => ({
    legend: null,
    cells: null,
    svg: null,


  }),
  created() {
    this.scale = null;
        this.waffleColorScale= null;
        this.sequence= null;

  },

  mounted() {
      this.init()
  },
  methods: {
      init() {
        this.sequence = (length) => Array.apply(null, {length: length}).map((d, i) => i);
       this.waffleColorScale = d3.scaleOrdinal(["#fe9929","#78c679","#74c476","#74a9cf","#df65b0"])
           .domain(this.sequence(this.waffleChartData.length))

        this.scale = d3.scaleBand()
            .domain(this.sequence(10))
            .range([0, this.waffleSize])
            .padding(0.1)


         this.svg = d3.select("#svg-container")
            .style("cursor", "default")
            .attr("viewBox", [0, 0, this.width, this.height])
            .on("onchange",this.cellTransition);

        const g = this.svg.selectAll(".waffle")
            .data(this.waffleArr)
            .join("g")
            .attr("class", "waffle");

        const numPerRow = Math.floor(this.width / (this.waffleSize + this.padding.x));
        g.attr("transform", (d, i) => {
          var r = Math.floor(i / numPerRow);
          var c = i - r * numPerRow;
          return `translate(${c * (this.waffleSize + this.padding.x)},${r * (this.waffleSize + this.padding.y)})`
        });

        const cellSize = this.scale.bandwidth();

         this.cells = g.append("g")
            .selectAll("rect")
            .data(d => d)
            .join("rect")
            .attr("fill", d => d.index === -1 ? "#ddd" : this.waffleColorScale(d.index));



        this.cells.attr("x", d => this.scale(d.x))
              .attr("y", d => this.scale(d.y))
              .attr("rx", 3).attr("ry", 3)
              .attr("width", cellSize).attr("height", cellSize)

   this.cellsTransition();


      },
    cellsTransition(){
        console.log("cell transition")
      this.cells.transition()
          .duration(d => d.y * 100)
          .ease(d3.easeBounceOut)
          .attr("y", d => console.log(this.scale(d.y)) || this.scale(d.y));

      this.svg.transition().delay(550)
          .on("end", this.drawLegend);
      console.log("cells:",this.cells);


    },


    drawLegend() {
        d3.selectAll(".legend").remove()
      this.legend = this.svg.selectAll(".legend")
          .data(this.waffleChartData.filter(d => d.ratio_spread != 0).map(d => d.landType))
          .join("g")
          .attr("opacity", 1)
          .attr("class","legend")
          .attr("transform", (d, i) => `translate(${this.waffleSize + 20},${i * 30})`)
          .on("mouseover", this.highlight)
          .on("mouseout", this.restore)

      this.legend.append("rect")
          .attr("rx", 3).attr("ry", 3)
          .attr("width", 30).attr("height", 20)
          .attr("fill", (d, i) => this.waffleColorScale(i));

      this.legend.append("text")
          .attr("dx", 40)
          .attr("alignment-baseline", "hanging")
          .text((d, i) =>  `${d} (${this.waffleChartData[i].ratio_spread}%)`);
          //.text((d, i) =>  `${d} (${this.waffleChartData.filter(d => d.ratio_spread != 0)[i].ratio_spread}%)`);

    },
    highlight(e) {
      const i = this.legend.nodes().indexOf(e.currentTarget);
      this.cells.transition().duration(500)
          .attr("fill", d => d.index === i ? this.waffleColorScale(d.index) : "#ccc");
   },
    restore() {
      this.cells.transition().duration(500).attr("fill", d => this.waffleColorScale(d.index))
    }
  }
}
</script>

<style>
</style>