<!-- Your HTML goes here -->
<template>
    <div>View1</div>
</template>

<script>
import * as d3 from 'd3'

export default {
  name: 'View1', // Feel free to rename this and the file
  props: {
      // Feel free to add props to communicate between components
  },
  mounted() {
      this.init()
  },
  methods: {
      init() {
          console.log(d3) // This can be savely removed
          // This will be called when the page loads.
          // You can load your data and setup D3 here
      }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
/* Add your CSS here */
</style>