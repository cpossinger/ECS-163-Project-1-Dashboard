<!-- This file will be used to layout and connect your views -->
<template>
  <div id="app">
      <!-- This is only a basic setup to display your views. Use HTML and CSS to create your layout using these basic commands -->
      <View1 />
      <View2 />
      <View3 />
  </div>
</template>

<script>
// Try to use descriptive names like 'OverviewScatterPlot' or 'DetailLineChart'
import View1 from './components/View1.vue'
import View2 from './components/View2.vue'
import View3 from './components/View3.vue'

export default {
  name: 'App',
  components: {
    View1,
    View2,
    View3
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
