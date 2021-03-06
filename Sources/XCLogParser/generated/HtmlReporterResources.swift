import Foundation

/// File generated by the rake `gen_resources` command.
/// Do not edit
public struct HtmlReporterResources {

      public static let css =
"""
body {
  background-color: #f5f5f5;
}

div.info-box {
  height: 120px;
}

main.main {
  padding-top: 30px;
}

.swift {
  background-color: #EE5541;
}

.objc {
  background-color: #5E565A;
}

.xc-build-info {
  text-align: right;
  color: #6c757d;
}
.xc-content {
  margin: 10px;
}

.xc-navbar {
  border: 1px solid rgba(0,0,0,.125);
  background-color: rgba(0,0,0,.03);
  border-bottom: 1px solid rgba(0,0,0,.125);
}

.navbar-light .navbar-brand {
  color: gray;
}

.xc-header {
  height: 40px;
}

.xc-topboxes {
  margin-left: 35px;
  margin-right: 35px;
  margin: 10px;
}

.callout-danger {
  border-left: 4px solid red !important;
}

.callout-warning {
  border-left: 4px solid #ffc107 !important;
}

.callout {
  position: relative;
  padding: 0 1rem;
  margin: 1rem 0;
  border-left: 4px solid #c8ced3;
  border-radius: .25rem;
}

.header-title {
  float: left
}
.header-action {
  float: right
}

.header-action a {
  color: gray;
  text-decoration: none;
}

"""

      public static let appJS =
"""
// Copyright (c) 2019 Spotify AB.
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

let mainStep;
let targets;
let cFiles;
let swiftFiles;

const rowHeight = 45;

const swiftAggregatedCompilation = 'swiftAggregatedCompilation';

const swiftCompilation = 'swiftCompilation';

const cCompilation = 'cCompilation'

const incidentSource = "<details>" +
  "<summary><span class='font-weight-bold'>{{count}}</span>{{summary}}</summary>" +
  "<p class='bg-light'>" +
  "<ul>" +
  "{{#each details}}" +
  "{{#if documentURL}}" +
  "<li>{{clangWarning}} {{title}} " +
  "In <a href='{{documentURL}}'>{{documentURL}}</a> Line {{startingLineNumber}} column {{startingColumnNumber}}</li>" +
  "{{else}}" +
  "<li>{{clangWarning}} {{title}}</li>" +
  "{{/if}}" +
  "{{/each}}" +
  "</ul>" +
  "</p>" +
  "</details>";

const incidentTemplate = Handlebars.compile(incidentSource);

drawCharts();

function drawCharts() {
  const target = getRequestedTarget();
  if (target === 'main') {
    loadMainData();
  } else {
    loadTargetData(target);
  }
  drawHeaders(target);
  drawErrors(target);
  drawWarnings(target);
  drawTimeline(target);
  drawSlowestTargets(target);

  if (target === 'main') {
    document.getElementById('files-row').style.display = 'flex';
    drawSlowestFiles(cFiles, '#top_cfiles');
    drawSlowestFiles(swiftFiles, '#top_swiftfiles');
  } else {
    document.getElementById('files-row').style.display = 'none';
  }
}

function drawHeaders(target) {
  setBuildStatus();
  document.getElementById('build-info').innerHTML = getBuildInfo();
  if (target === 'main') {
    document.getElementById('schema-title').innerHTML = 'Schema';
    document.getElementById('schema').innerHTML = mainStep.schema;
    document.getElementById('targets-title').innerHTML = 'Targets';
  } else {
    document.getElementById('schema-title').innerHTML = 'Target';
    document.getElementById('schema').innerHTML = mainStep.title.replace('Build target', '');
    document.getElementById('targets-title').innerHTML = 'Files';
  }
  const status = mainStep.buildStatus.charAt(0).toUpperCase() + mainStep.buildStatus.slice(1);
  document.getElementById('build-status').innerHTML = status;
  const duration = moment.duration(mainStep.duration * 1000);
  var durationText = '';
  if (duration.hours() > 0) {
    durationText += duration.hours() + ' hrs, ';
  }
  if (duration.minutes() > 0) {
    durationText += duration.minutes() + ' mins, ';
  }
  durationText += Math.round(duration.seconds()) + ' secs';
  document.getElementById('build-time').innerHTML = durationText;
  document.getElementById('targets').innerHTML = targets.length.toLocaleString('en');
  document.getElementById('c-files').innerHTML = cFiles.length.toLocaleString('en');
  document.getElementById('swift-files').innerHTML = swiftFiles.length.toLocaleString('en');

}

function setBuildStatus() {
  const infoData = buildData[0];
  const status = mainStep.buildStatus.charAt(0).toUpperCase() + mainStep.buildStatus.slice(1);
  const statusBox = document.getElementById('status-box');
  if (status.toLowerCase() === 'succeeded') {
    statusBox.classList.add('bg-success');
  } else if (status.toLowerCase().includes('failed') || status.toLowerCase().includes('errors')) {
    statusBox.classList.add('bg-danger');
  } else {
    statusBox.classList.add('bg-warning');
  }
}

function getBuildInfo() {
  const infoData = buildData[0];
  const buildDate = new Date(infoData.startTimestamp * 1000);
  let info = infoData.title.replace('Build ', '');
  info += ' Build ' + infoData.identifier + ', generated on ';
  info += buildDate.toLocaleString();
  return info;
}

function loadMainData() {
  mainStep = buildData[0];
  targets = buildData.filter(function (step) {
    return step.type === 'target';
  });
  cFiles = buildData.filter(function (step) {
    return step.type === 'detail' && step.detailStepType === cCompilation;
  });
  swiftFiles = buildData.filter(function (step) {
    return step.type === 'detail' && step.detailStepType === swiftCompilation;
  });
}

function loadTargetData(target) {
  mainStep = buildData.find(function (element) {
    return element.type === 'target' && element.identifier === target
  });
  targets = buildData.filter(function (element) {
    return element.parentIdentifier === target;
  });

  // In xcodebuild, the swift files compilation are under an Aggregated build step.
  // This code adds them and removes the aggregated steps
  swiftAggregatedBuilds = targets.filter(function (step) {
    return step.detailStepType === swiftAggregatedCompilation;
  });
  const aggregatedSubSteps = swiftAggregatedBuilds.flatMap(function (aggregate) {
    return buildData.filter(function (element) {
      return element.parentIdentifier === aggregate.identifier;
    });
  });
  targets = targets.concat(aggregatedSubSteps).filter(function (step) {
    return step.detailStepType != swiftAggregatedCompilation;
  }).sort(function (lhs, rhs) {
    return lhs.startTimestamp - rhs.startTimestamp;
  });

  cFiles = targets.filter(function (step) {
    return step.detailStepType === cCompilation;
  });
  swiftFiles = targets.filter(function (step) {
    return step.detailStepType === swiftCompilation;
  });
}

function drawTimeline(target) {
  const dataSeries = targets.map(function (target) {
    const title = getShortFilename(target.title, target.architecture);
    var targetStartTimestamp = target.startTimestamp;
    var targetEndTimestamp = target.endTimestamp;
    if (targetStartTimestamp < mainStep.startTimestamp) {
      targetStartTimestamp = mainStep.startTimestamp;
      targetEndTimestamp = mainStep.startTimestamp;
    }
    var start = targetStartTimestamp;
    var end = targetEndTimestamp === targetStartTimestamp ? targetEndTimestamp + 1 : targetEndTimestamp;

    return {
      x: title,
      y: [new Date(start * 1000).getTime(),
      new Date(end * 1000).getTime()],
      start: targetStartTimestamp,
      end: targetEndTimestamp
    };
  });
  const options = {
    chart: {
      height: dataSeries.length * rowHeight,
      type: 'rangeBar',
      events: {
        dataPointSelection: function (event, chartContext, config) {
          const selectedItem = targets[config.dataPointIndex];
          itemSelected(selectedItem);
        }
      }
    },
    title: {
      text: "Build times"
    },
    theme: {
      mode: 'light',
      palette: 'palette3'
    },
    plotOptions: {
      bar: {
        horizontal: true
      }
    },
    series: [{ data: dataSeries }],
    yaxis: {
      min: new Date(mainStep.startTimestamp * 1000).getTime(),
      max: new Date(mainStep.endTimestamp * 1000).getTime(),
      tooltip: {
        enabled: true,
        offsetX: 0,
      },
      labels: {
        show: true,
        align: 'right',
        minWidth: 0,
        maxWidth: 300,
        style: {
          color: undefined,
          fontSize: '12px',
          fontFamily: 'Helvetica, Arial, sans-serif',
          cssClass: 'apexcharts-yaxis-label',
        }
      }
    },

    tooltip: {
      enabled: true,
      custom: function ({ series, seriesIndex, dataPointIndex, w }) {
        const serie = dataSeries[dataPointIndex];
        const start = serie.start;
        const end = serie.end;
        const duration = (end - start).toFixed(3);
        return '<div class="arrow_box">' +
          '<span>' + serie.x + ' </span><br>' +
          '<span>' + duration + ' seconds</span>' +
          '</div>'
      },
      y: {
        enabled: true,
        show: true,
        formatter: undefined,
        title: {
          formatter: (seriesName) => seriesName,
        },
      },

    },
    xaxis: {
      type: 'datetime',

      labels: {
        formatter: function (value, timestamp, index) {
          return moment(new Date(value)).format("H:mm:ss");
        }
      }
    },
  }

  var chart = new ApexCharts(
    document.querySelector("#timeline"),
    options
  );
  chart.render();
}

function drawSlowestTargets(target) {
  let clone = targets.slice(0);
  const targetsData = clone.sort(function (lhs, rhs) {
    return rhs.duration - lhs.duration
  });
  const top = Math.min(20, targetsData.length);
  const topTargets = targetsData.slice(0, top);
  const durations = topTargets.map(function (target) {
    return target.duration.toFixed(3);
  });
  const names = topTargets.map(function (step) {
    if (target === 'main') {
      return step.title.replace('Build target ', '');
    } else {
      return getShortFilename(step.title, step.architecture);
    }
  });
  const options = {
    chart: {
      height: names.length * rowHeight,
      type: 'bar',
      events: {
        dataPointSelection: function (event, chartContext, config) {
          const selectedItem = topTargets[config.dataPointIndex];
          itemSelected(selectedItem);
        }
      }
    },
    plotOptions: {
      bar: {
        distributed: true,
        horizontal: true
      }
    },
    theme: {
      mode: 'light',
      palette: 'palette3'
    },
    dataLabels: {
      enabled: false
    },
    series: [{
      data: durations
    }],
    xaxis: {
      categories: names
    },
    tooltip: {
      y: {
        title: {
          formatter: function () {
            return 'Seconds'
          }
        }
      }
    }
  }

  var chart = new ApexCharts(
    document.querySelector("#bartargets"),
    options
  );

  chart.render();
}


function drawSlowestFiles(collection, element) {
  const sortedData = collection.sort(function (lhs, rhs) {
    return rhs.duration - lhs.duration;
  });
  const top = Math.min(20, sortedData.length);
  const topTargets = sortedData.slice(0, top);
  const durations = topTargets.map(function (target) {
    return target.duration.toFixed(3);
  });
  const names = topTargets.map(function (step) {
    return getShortFilename(step.title, step.architecture);
  });
  const options = {
    chart: {
      height: names.length * rowHeight,
      type: 'bar',
      events: {
        dataPointSelection: function (event, chartContext, config) {
          const selectedItem = topTargets[config.dataPointIndex];
          itemSelected(selectedItem);
        }
      }
    },
    plotOptions: {
      bar: {
        distributed: true,
        horizontal: true
      }
    },
    theme: {
      mode: 'light',
      palette: 'palette3'
    },
    dataLabels: {
      enabled: false
    },
    series: [{
      data: durations
    }],
    xaxis: {
      categories: names
    },
    tooltip: {
      y: {
        title: {
          formatter: function () {
            return 'Seconds'
          }
        }
      }
    }
  }

  var chart = new ApexCharts(
    document.querySelector(element),
    options
  );

  chart.render();
}

function getRequestedTarget() {
  let name = "target"
  if (name = (new RegExp('[?&]' + encodeURIComponent(name) + '=([^&]*)')).exec(location.search)) {
    return decodeURIComponent(name[1]);
  } else {
    return "main"
  }
}

function getShortFilename(fileName, arch) {
  if (fileName.includes('/')) {
    const components = fileName.replace('Compile ', '').split('/');
    const command = fileName.split(' ')[0]
    const startIndex = Math.max(3, components.length - 3);
    if (arch != '') {
      return command + ' ' + arch + ' ' + components.slice(startIndex, components.length).join('/');
    }
    return command + ' ' + components.slice(startIndex, components.length).join('/');
  } else {
    return fileName
  }
}

function drawErrors(target) {
  $('#errors-count').html(mainStep.errorCount);
  showErrors(target);
}

function drawWarnings(target) {
  $('#warnings-count').html(mainStep.warningCount);
  showWarnings(target);
}

function showErrors(target) {
  const steps = target === 'main' ? buildData : targets;
  const stepsWithErrors = steps.filter(function (step) {
    return step.type != 'main' && step.type != 'target' && step.errorCount > 0;
  }).sort(function (lhs, rhs) {
    return rhs.warningCount - lhs.warningCount;
  });
  var summaries = '';
  stepsWithErrors.forEach(function (step) {
    const errorLegend = step.errorCount > 1 ? " errors in " : " error in ";
    summaries += incidentTemplate({ "count": step.errorCount + errorLegend, "summary": step.signature, "details": step.errors });
  });
  $('#errors-summary').html(summaries);
  if (stepsWithErrors.length > 0) {
    $('#errors').show();
  } else {
    $('#errors').hide();
  }
}

function showWarnings(target) {
  const steps = target === 'main' ? buildData : targets;
  const stepsWithWarnings = steps.filter(function (step) {
    return step.warnings.length > 0;
  }).sort(function (lhs, rhs) {
    return rhs.warningCount - lhs.warningCount;
  });
  var summaries = '';
  stepsWithWarnings.forEach(function (step) {
    if (step.warnings.length > 0) {
      const warningLegend = step.warningCount > 1 ? " warnings in " : " warning in ";
      summaries += incidentTemplate({ "count": step.warningCount + warningLegend, "summary": step.signature, "details": step.warnings });
    }
  });
  $('#warnings-summary').html(summaries);
  if (stepsWithWarnings.length > 0) {
    $('#warnings').show();
  } else {
    $('#warnings').hide();
  }
}

function itemSelected(selectedItem) {
  if (selectedItem.type === 'target') {
    window.location.href = window.location.href + "?target=" + selectedItem.identifier;
  } else if (selectedItem.type === 'detail') {
    const stepUrl = window.location.href.replace('index.html', 'step.html');
    window.location.href =  stepUrl + "?step=" + selectedItem.identifier;
  }
}

"""

      public static let buildJS =
"""
const buildData = {{build}};
"""

public static let indexHTML =
"""
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Build Data</title>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
  <link rel="stylesheet" href="css/styles.css">
</head>

<body class="app header-fixed">
  <header class="app-header navbar navbar-expand-lg navbar-light xc-navbar">

    <a href="index.html" class="navbar-brand">XCLogParser</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent"
      aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <div class="navbar-nav ml-md-auto" style="padding-right: 30px;">
      </div>
    </div>
  </header>

  <div class="app-body">
    <main class="main">
      <div class="container-fluid">
          <div class="row">
            <div class="col-12 xc-build-info warning" id='build-info'>
            </div>
          </div>
          <div class="row">
            <div class="col-md-2 col-sm-1">
              <div class="card xc-topboxes text-white bg-primary info-box">
                <div class="card-header" id="schema-title">Schema</div>
                <div class="card-body">
                  <div id="schema" class="card-text"></div>
                </div> <!-- card body -->
              </div> <!-- card-->
            </div> <!-- col -->
            <div class="col-md-2 col-sm-1">
              <div id="status-box" class="card xc-topboxes text-white info-box">
                <div class="card-header">Build status</div>
                <div class="card-body">
                  <div id="build-status" class="card-text"></div>
                </div> <!-- card body -->
              </div> <!-- card-->
            </div> <!-- col -->
            <div class="col-md-2 col-sm-1">
              <div class="card text-white xc-topboxes bg-info info-box">
                <div class="card-header">Build time</div>
                <div class="card-body">
                  <div id="build-time" class="card-text"></div>
                </div> <!-- card-body -->
              </div> <!-- card -->
            </div>
            <!--/.col-->
            <div class="col-md-2 col-sm-1">
              <div class="card text-white xc-topboxes bg-info info-box">
                <div class="card-header" id="targets-title">Number of targets</div>
                <div class="card-body">
                  <div id="targets" class="card-text"></div>
                </div> <!-- card-body -->
              </div> <!-- card -->
            </div>
            <!--/.col-->
            <div class="col-md-2 col-sm-1">
              <div class="card text-white xc-topboxes objc info-box">
                <div class="card-header">C files</div>
                <div class="card-body">
                  <div id="c-files" class="card-text"></div>
                </div> <!-- card-body -->
              </div> <!-- card -->
            </div>
            <!--/.col-->
            <div class="col-md-2 col-sm-1">
              <div class="card text-white xc-topboxes swift info-box">
                  <div class="card-header">Swift files</div>
                <div class="card-body">
                  <div id="swift-files" class="card-text"></div>
                </div> <!-- card-body -->
              </div> <!-- card -->
            </div>
            <!--/.col-->
          </div> <!-- row -->


        <div class="row" id="errors-row">
          <div class="col-12">
            <div class="card xc-content">
              <div class="card-header">
                <div class="header-title">🛑 Errors</div>
                <div class="header-action">
                  <a class="card-header-action" href="#" data-toggle="collapse"
                    data-target="#collapse-errors" aria-expanded="true">
                    △
                  </a>
                </div>
              </div> <!-- card header-->
              <div id="collapse-errors" class="collapse show">
                <div class="card-body">
                  <div class="row">
                    <div class="col-sm-6">
                      <div class="callout callout-danger">
                        <small class="text-muted">Total</small>
                        <br>
                        <strong class="h4" id="errors-count"></strong>
                      </div>
                    </div>
                  </div>
                  <div class="row" id="errors">
                    <div class="col-sm-12">
                      <details>
                        <summary>Show errors</summary>
                          <p id="errors-summary"></p>
                      </details>
                    </div>
                  </div>
                </div> <!-- card body -->
              </div> <!-- collapse-errors -->
            </div> <!-- card -->
          </div> <!-- errors col-->
        </div> <!-- errors row -->

        <div class="row" id="warnings-row">
          <div class="col-12">
            <div class="card xc-content">
              <div class="card-header">
                <div class="header-title">⚠️ Warnings</div>
                <div class="header-action">
                  <a class="card-header-action" href="#" data-toggle="collapse"
                    data-target="#collapse-warnings" aria-expanded="true">
                    △
                  </a>
                </div>
              </div> <!-- card header-->
              <div id="collapse-warnings" class="collapse show">
              <div class="card-body">
                <div class="row">
                  <div class="col-sm-6">
                    <div class="callout callout-warning">
                      <small class="text-muted">Total</small>
                      <br>
                      <strong class="h4" id="warnings-count"></strong>
                    </div>
                  </div>
                </div>
                <div class="row" id="warnings">
                    <div class="col-sm-12">
                      <details>
                        <summary>Show warnings</summary>
                        <p id="warnings-summary"></p>
                      </details>
                    </div>
                </div>
              </div> <!-- card body -->
            </div> <!-- collapse-warnings -->
            </div> <!-- card -->
          </div> <!-- warnings col-->
        </div> <!-- warnings row -->

        <div class="row h-90">
          <div class="col-12">
            <div class="card xc-content">
              <div class="card-header">
                <div class="header-title">🕗 Timeline</div>
                <div class="header-action">
                  <a class="card-header-action" href="#" data-toggle="collapse"
                    data-target="#collapse-timeline" aria-expanded="true">
                    △
                  </a>
                </div>
              </div> <!-- card header-->
              <div id="collapse-timeline" class="collapse show">
                <div class="card-body" id="timeline-body">
                  <div id="timeline"></div>
                </div> <!-- card body -->
              </div> <!-- collapse-timeline -->

            </div> <!-- card -->
          </div> <!-- timeline col-->
        </div> <!-- timeline row -->

        <div class="row">
          <div class="col-12">
            <div class="card xc-content">
              <div class="card-header">
                <div class="header-title">⏳ Slowest targets</div>
                <div class="header-action">
                  <a class="card-header-action" href="#" data-toggle="collapse"
                    data-target="#collapse-bartargets" aria-expanded="true">
                    △
                  </a>
                </div>
              </div>
              <div id="collapse-bartargets" class="collapse show">
                <div class="card-body">
                  <div id="bartargets"></div>
                </div> <!-- card-body -->
              </div> <!--collapse-bartargets -->
            </div> <!-- card -->
          </div> <!-- col -->
        </div> <!-- row -->
        <div class="row" id="files-row">
          <div class="col-6">
            <div class="card xc-content">
              <div class="card-header">
                <div class="header-title">⏳ Slowest C files compilation</div>
                <div class="header-action">
                  <a class="card-header-action" href="#" data-toggle="collapse"
                    data-target="#collapse-top_cfiles" aria-expanded="true">
                    △
                  </a>
                </div> <!-- header-action -->
              </div> <!-- card header -->
              <div id="collapse-top_cfiles" class="collapse show">
                <div class="card-body">
                  <div id="top_cfiles" style="width: 100%; height: 70%;"></div>
                </div> <!-- card body -->
              </div> <!-- collapse-top_cfiles -->
            </div> <!-- card -->
          </div> <!-- col -->

          <div class="col-6">
            <div class="card xc-content">
              <div class="card-header">
                <div class="header-title">⏳ Slowest Swift files compilation</div>
                <div class="header-action">
                  <a class="card-header-action" href="#" data-toggle="collapse"
                    data-target="#collapse-top_swiftfiles" aria-expanded="true">
                    △
                  </a>
                </div> <!-- header-action -->
              </div> <!-- card title -->
              <div id="collapse-top_swiftfiles" class="collapse show">
                <div class="card-body">
                  <div id="top_swiftfiles" style="width: 100%; height: 70%;"></div>
                </div> <!-- card body -->
              </div> <!-- collapse-top_cfiles -->
            </div> <!-- card -->
          </div> <!-- col -->
        </div> <!-- top files row -->

      </div> <!-- container-fluid -->

    </main>

  </div> <!-- app body-->

  <footer class="app-footer">
    <!-- Footer content here -->
  </footer>
  <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.1.2/handlebars.min.js"></script>
  <script type="text/javascript" src="js/build.js"></script>
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.23.0/moment-with-locales.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
  <script type="text/javascript" src="js/app.js"></script>
</body>
</html>

"""

public static let stepHTML =
"""
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Client iOS Build Data</title>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
  <link rel="stylesheet" href="css/styles.css">
</head>

<body class="app header-fixed">
  <header class="app-header navbar navbar-expand-lg navbar-light xc-navbar">

    <a href="index.html" class="navbar-brand">xclogparser</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent"
      aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <div class="navbar-nav ml-md-auto" style="padding-right: 30px;">
      </div>
    </div>
  </header>

  <div class="app-body">
    <main class="main">
      <div class="container-fluid">
        <div class="row">
          <div class="col-12 xc-build-info warning" id='build-info'>
          </div>
        </div>

        <div class="row" id="info-row">
          <div class="col-12">
            <div class="card xc-content">
              <div class="card-header">
                <div class="header-title" id="info-title"></div>
                <div class="header-action">
                  <a class="card-header-action" href="#" data-toggle="collapse"
                    data-target="#collapse-info" aria-expanded="true">
                    △
                  </a>
                </div>
              </div> <!-- card header-->
              <div id="collapse-info" class="collapse show">
                <div class="card-body">
                  <div class="row">
                    <div class="col-sm-2">
                      File
                    </div>
                    <div class="col-sm-10">
                      <a id="info-url" href=""></a>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-sm-2">
                      Duration
                    </div>
                    <div class="col-sm-10">
                        <div id="info-duration"></div>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-sm-2">
                      Start time
                    </div>
                    <div class="col-sm-10">
                      <div id="info-start-time"></div>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-sm-2">
                      End time
                    </div>
                    <div class="col-sm-10">
                      <div id="info-end-time"></div>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-sm-2">
                      Signature
                    </div>
                    <div class="col-sm-10">
                      <div id="info-signature"></div>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-sm-2">
                      Architecture
                    </div>
                    <div class="col-sm-10">
                      <div id="info-arch"></div>
                    </div>
                  </div>
                </div> <!-- card body -->
              </div> <!-- collapse-info -->
            </div> <!-- card -->
          </div> <!-- info col-->
        </div> <!-- info row -->

        <div class="row" id="errors-row">
            <div class="col-12">
              <div class="card xc-content">
                <div class="card-header">
                  <div class="header-title">🛑 Errors</div>
                  <div class="header-action">
                    <a class="card-header-action" href="#" data-toggle="collapse"
                      data-target="#collapse-errors" aria-expanded="true">
                      △
                    </a>
                  </div>
                </div> <!-- card header-->
                <div id="collapse-errors" class="collapse show">
                <div class="card-body">
                  <div class="row">
                    <div class="col-sm-6">
                      <div class="callout callout-danger">
                        <small class="text-muted">Total</small>
                        <br>
                        <strong class="h4" id="errors-count"></strong>
                      </div>
                    </div>
                  </div>
                  <div class="row" id="errors">
                      <div class="col-sm-12" id="errors-summary">
                      </div>
                  </div>
                </div> <!-- card body -->
              </div> <!-- collapse-errors -->
              </div> <!-- card -->
            </div> <!-- errors col-->
          </div> <!-- errors row -->

        <div class="row" id="warnings-row">
          <div class="col-12">
            <div class="card xc-content">
              <div class="card-header">
                <div class="header-title">⚠️ Warnings</div>
                <div class="header-action">
                  <a class="card-header-action" href="#" data-toggle="collapse"
                    data-target="#collapse-warnings" aria-expanded="true">
                    △
                  </a>
                </div>
              </div> <!-- card header-->
              <div id="collapse-warnings" class="collapse show">
              <div class="card-body">
                <div class="row">
                  <div class="col-sm-6">
                    <div class="callout callout-warning">
                      <small class="text-muted">Total</small>
                      <br>
                      <strong class="h4" id="warnings-count"></strong>
                    </div>
                  </div>
                </div>
                <div class="row" id="warnings">
                    <div class="col-sm-12" id="warnings-summary">
                    </div>
                </div>
              </div> <!-- card body -->
            </div> <!-- collapse-warnings -->
            </div> <!-- card -->
          </div> <!-- warnings col-->
        </div> <!-- warnings row -->

        <div class="row" id="functions-row">
            <div class="col-12">
              <div class="card xc-content">
                <div class="card-header">
                  <div class="header-title">Swift function times</div>
                  <div class="header-action">
                    <a class="card-header-action" href="#" data-toggle="collapse"
                      data-target="#collapse-functions" aria-expanded="true">
                      △
                    </a>
                  </div>
                </div> <!-- card header-->

                <div class="card-body">
                  <div class="row" id="functions">
                    <div class="col-sm-12" id="functions-summary">
                    </div>
                  </div>
                </div> <!-- card body -->
              </div> <!-- card -->
            </div> <!-- functions col-->
        </div> <!-- functions row -->



      </div> <!-- container-fluid -->

    </main>

  </div> <!-- app body-->

  <footer class="app-footer">
    <!-- Footer content here -->
  </footer>

  <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.1.2/handlebars.min.js"></script>
  <script type="text/javascript" src="js/build.js"></script>
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.23.0/moment-with-locales.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
  <script type="text/javascript" src="js/step.js"></script>
</body>
</html>

"""

public static let stepJS =
"""
const incidentSource = "<ul>" +
  "{{#each details}}" +
  "{{#if documentURL}}" +
  "<li>{{clangWarning}} {{title}} " +
  "In <a href='{{documentURL}}'>{{documentURL}}</a> Line {{startingLineNumber}} column {{startingColumnNumber}}</li>" +
  "{{else}}" +
  "<li>{{clangWarning}} {{title}}</li>" +
  "{{/if}}" +
  "{{/each}}" +
  "</ul>" +
  "</p>" +
  "</details>";

const incidentTemplate = Handlebars.compile(incidentSource);

const swiftFunctionSource = "<table class=\\"table table-sm table-hover table-responsive\\">" +
  "<thead>" +
  "<tr>" +
  "<th scope=\\"col\\">Duration (ms)</th>" +
  "<th scope=\\"col\\">Function</th>" +
  "<th scope=\\"col\\">Line</th>" +
  "<th scope=\\"col\\">Column</th>" +
  "</tr>" +
  "</thead>" +
  "{{#each functions}}" +
  "<tr>" +
  "<th scope=\\"col\\">{{durationMS}}</th>" +
  "<th scope=\\"col\\">{{signature}}</th>" +
  "<th scope=\\"col\\">{{startingLine}}</th>" +
  "<th scope=\\"col\\">{{startingColumn}}</th>" +
  "</tr>" +
  "{{/each}}" +
  "</table>";

const swiftFunctionWarning = "<div class=\\"callout callout-warning\\">" +
"<small class=\\"text-muted\\">Warning: No Swift function compilation times were found.</small>" +
"<br>" +
"Did you compile your project with the flags -Xfrontend -debug-time-function-bodies?" +
"</div>";

const swiftFunctionTemplate = Handlebars.compile(swiftFunctionSource);

const timestampFormat = 'MMMM Do YYYY, h:mm:ss a';

showStep();

function showStep() {
  const step = loadStep();
  if (step != null) {
    $('#info-title').html(step.title);
    $('#info-signature').html(step.signature);
    $('#info-arch').html(step.architecture);
    $('#info-url').html(step.documentURL);
    $('#info-url').attr("href", step.documentURL);
    $('#info-duration').html(step.duration + ' secs.');
    $('#info-start-time').html(moment(new Date(step.startTimestamp * 1000)).format(timestampFormat));
    $('#info-end-time').html(moment(new Date(step.endTimestamp * 1000)).format(timestampFormat));
    showStepErrors(step);
    showStepWarnings(step);
    showSwiftFunctionTimes(step);
  }
}

function loadStep() {
  const stepId = getRequestedStepId();
  if (stepId != null) {
    const steps = buildData.filter(function (step) {
      return stepId == step.identifier;
    });
    return steps[0];
  }
  return null;
}

function getRequestedStepId() {
  let name = "step"
  if (name = (new RegExp('[?&]' + encodeURIComponent(name) + '=([^&]*)')).exec(location.search)) {
    return decodeURIComponent(name[1]);
  } else {
    return null;
  }
}

function showStepErrors(step) {
  const errorLegend = step.errorCount > 1 ? " errors in " : " error in ";
  const summaries = incidentTemplate({ "count": step.errorCount + errorLegend, "summary": step.signature, "details": step.errors });
  $('#errors-count').html(step.errorCount);
  $('#errors-summary').html(summaries);
}

function showStepWarnings(step) {
  const warningLegend = step.warningCount > 1 ? " warnings in " : " warning in ";
  const summaries = incidentTemplate({ "count": step.warningCount + warningLegend, "summary": step.signature, "details": step.warnings });
  $('#warnings-count').html(step.warningCount);
  $('#warnings-summary').html(summaries);
}

function showSwiftFunctionTimes(step) {
  if (step.detailStepType === 'swiftCompilation') {
    $('#functions-row').show();
    if (step.swiftFunctionTimes && step.swiftFunctionTimes.length > 0) {
      const functions = swiftFunctionTemplate({"functions": step.swiftFunctionTimes});
      $('#functions-summary').html(functions);
    } else {
      $('#functions-summary').html(swiftFunctionWarning);
    }

  } else {
    $('#functions-row').hide();
  }
}

"""

}
