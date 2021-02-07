<!-- This file will be used to layout and connect your views -->
<template>
  <v-app>
    <v-app-bar app></v-app-bar>
    <v-btn @click="toggleTheme" text rounded> Toggle Theme</v-btn>
    <v-main>
      <v-container>
        Hello World
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
// Try to use descriptive names like 'OverviewScatterPlot' or 'DetailLineChart'
//import View1 from './components/View1.vue'
//import View2 from './components/View2.vue'
//import View3 from './components/View3.vue'

export default {
  name: 'App',
  components: {
//    View1,
 //   View2,
  //  View3
  },
  methods: {
    toggleTheme(){
      this.$vuetify.theme.themes.dark.anchor = "#41B883"
      this.$vuetify.theme.dark = !this.$vuetify.theme.dark
    }
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
