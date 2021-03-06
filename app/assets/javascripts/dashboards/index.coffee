CIF.DashboardsIndex = do ->
  _init = ->
    _clientGenderChart()
    _clientStatusChart()
    _familyType()
    _resizeChart()

  _resizeChart = ->
    $('.minimalize-styl-2').click ->
      setTimeout (->
        window.dispatchEvent new Event('resize')
    ), 220

  _clientGenderChart = ->
    element = $('#client-by-gender')
    data    = $(element).data('content-count')
    report = new CIF.ReportCreator(data, '', '', element)
    report.donutChart()

  _clientStatusChart = ->
    element = $('#client-by-status')
    data    = $(element).data('content-count')
    report = new CIF.ReportCreator(data, '', '', element)
    report.pieChart()

  _familyType = ->
    element = $('#family-type')
    data    = $(element).data('content-count')
    report = new CIF.ReportCreator(data, '', '', element)
    report.pieChart()

  { init: _init }
