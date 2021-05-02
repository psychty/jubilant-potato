var width = 600,
  height = 600;

var xCenter = [200, 400, 300];
var yCenter = [100, 100, 300];

var Ages = [
  "Note yet eligible due to age alone",
  "40-44 years",
  "45-49 years",
  "50-54 years",
  "55-59 years",
  "60-64 years",
  "65-69 years",
  "70-74 years",
  "75-79 years",
  "80-84 years",
  "85-89 years",
  "90 and over",
];

var Status = [
  "Received first dose only",
  "Received two doses",
  "Yet to receive single dose",
];

var Age_colours = [
  "#dbdbdb",
  "#fafa6e",
  "#ffe85b",
  "#ffd64b",
  "#ffc340",
  "#ffaf3a",
  "#ff9a39",
  "#ff843c",
  "#ff6d42",
  "#ff544a",
  "#ff3754",
  "#ff005e",
];

var Scale_age_colours = d3.scaleOrdinal().domain(Ages).range(Age_colours);
var Scale_xstatus = d3.scaleOrdinal().domain(Status).range(xCenter);
var Scale_ystatus = d3.scaleOrdinal().domain(Status).range(yCenter);

var request = new XMLHttpRequest();
request.open("GET", "./black_age_status.json", false);
request.send(null);
var nodes_1 = JSON.parse(request.responseText); // parse the fetched json data into a variable

var Scale_radius = d3
  .scaleLinear()
  .domain([
    0,
    d3.max(nodes_1, function (d) {
      return +d.Individuals;
    }),
  ])
  .range([0, 25]);

console.log(nodes_1);

// create a tooltip
var Tooltip = d3
  .select("#bubble_1")
  .append("div")
  .style("opacity", 0)
  .attr("class", "tooltip_class")
  .style("position", "absolute")
  .style("z-index", "10")
  .style("background-color", "white")
  .style("border", "solid")
  .style("border-width", "1px")
  .style("border-radius", "5px")
  .style("padding", "10px")
  .attr("visibility", "hidden");

// Three function that change the tooltip when user hover / move / leave a cell
var mousemove = function (d) {
  Tooltip.html(
    "<u>" + d.Status + "</u>" + "<p>" + d.Age_group + " </p><p>" + d.Individuals
  )
    .style("left", d3.mouse(this)[0] + 20 + "px")
    .style("top", d3.mouse(this)[1] + "px")
    .style("opacity", 1)
    .attr("visibility", "visible");
};
var mouseleave = function (d) {
  Tooltip.style("opacity", 0).attr("visibility", "hidden");
};

// What happens when a circle is dragged?
function dragstarted(d) {
  if (!d3.event.active) simulation.alphaTarget(0.03);
  // simulation.alphaTarget(0.03);
  d.fx = d.x;
  d.fy = d.y;
}

function dragged(d) {
  d.fx = d3.event.x;
  d.fy = d3.event.y;
}

function dragended(d) {
  if (!d3.event.active) simulation.alphaTarget(0.03);
  d.fx = null;
  d.fy = null;
}

// Features of the forces applied to the nodes:
var simulation = d3
  .forceSimulation()
  .force(
    "x",
    d3
      .forceX()
      .strength(0.2)
      .x(function (d) {
        return Scale_xstatus(d.Status);
      })
  )
  .force(
    "y",
    d3
      .forceY()
      .strength(0.1)
      .y(function (d) {
        return Scale_ystatus(d.Status);
      })
  )
  .force(
    "center",
    d3
      .forceCenter()
      .x(width / 2)
      .y(height / 2)
  ) // Attraction to the center of the svg area
  .force("charge", d3.forceManyBody().strength(1)) // Nodes are attracted one each other of value is > 0
  .force(
    "collide",
    d3
      .forceCollide()
      .strength(0.2)
      .radius(function (d) {
        return Scale_radius(d.Individuals) + 1;
      })
      .iterations(1)
  ); // Force that avoids circle overlapping

// Apply these forces to the nodes and update their positions.
// Once the force algorithm is happy with positions ('alpha' value is low enough), simulations will stop.
simulation.nodes(nodes_1).on("tick", function (d) {
  node
    .attr("cx", function (d) {
      return d.x;
    })
    .attr("cy", function (d) {
      return d.y;
    });
});

var svg = d3
  .select("#bubble_1")
  .append("svg")
  .attr("width", width)
  .attr("height", height);

// Initialize the circle: all located at the center of the svg area
var node = svg
  .append("g")
  .selectAll("circle")
  .data(nodes_1)
  .enter()
  .append("circle")
  .attr("r", function (d) {
    return Scale_radius(d.Individuals);
  })
  .attr("cx", width / 2)
  .attr("cy", height / 2)
  .style("fill", function (d) {
    return Scale_age_colours(d.Age_group);
  })
  .style("fill-opacity", 0.8)
  .attr("stroke", "black")
  .style("stroke-width", 1)
  // .on("mouseover", mouseover) // What to do when hovered
  .on("mousemove", mousemove)
  .on("mouseleave", mouseleave)
  .call(
    d3
      .drag() // call specific function when circle is dragged
      .on("start", dragstarted)
      .on("drag", dragged)
      .on("end", dragended)
  );
