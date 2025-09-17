<template>
  <div class="container">
    <div class="row">
      <div class="col-md-8 offset-md-2">
        <div class="card">
          <div class="card-header">
            Current Users Online
          </div>
          <div class="card-body">
            <canvas
              id="myChart"
              height="100"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Chart from "chart.js";

export default {
  data() {
    return {
      count: 0,
      labels: ["Online"],
      chart: null,
    };
  },
  mounted() {
    this.update();
    this.drawChart();
  },
  methods: {
    drawChart() {
      const ctx = document.getElementById("myChart");
      this.chart = new Chart(ctx, {
        type: "bar",
        data: {
          labels: this.labels,
          datasets: [
            {
              label: "Number of users online",
              data: [this.count],
              borderWidth: 1,
            },
          ],
        },
        options: {
          scales: {
            yAxes: [
              {
                ticks: {
                  beginAtZero: true,
                },
              },
            ],
          },
        },
      });
    },
    update() {
      if (!window.Echo) {
        return;
      }

      window.Echo.join("chart")
        .here((users) => {
          this.count = users.length;
          this.drawChart();
        })
        .joining(() => {
          this.count++;
          this.drawChart();
        })
        .leaving(() => {
          this.count--;
          this.drawChart();
        });
    },
  },
};
</script>
