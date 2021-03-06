CIF.AssessmentsNew = CIF.AssessmentsEdit = CIF.AssessmentsCreate = CIF.AssessmentsUpdate = do ->
  _init = ->
    formid = $('form.assessment-form').attr('id')
    form   = $('#'+formid)

    _formValidate(form)
    _loadSteps(form)
    _addTasks()
    _postTask()
    _addElement()
    _translatePagination()
    _initUploader()
    _handleDeleteAttachment()
    _removeTask()
    _removeHiddenTaskArising()
    _saveAssessment(form)

  _handleAppendAddTaskBtn = ->
    scores = $('.score_option:visible').find('label.collection_radio_buttons.label-danger, label.collection_radio_buttons.label-warning')
    if $(scores).length > 0
      $(".assessment-task-btn, .task_required").removeClass('hidden').show()
    else
      $(".assessment-task-btn, .task_required").hide()

  _translatePagination = ->
    next     = $('#rootwizard').data('next')
    previous = $('#rootwizard').data('previous')
    finish   = $('#rootwizard').data('finish')
    save     = $('#rootwizard').data('save')
    $('#rootwizard a[href="#next"]').text(next)
    $('#rootwizard a[href="#previous"]').text(previous)
    $('#rootwizard a[href="#save"]').text(save)
    $('#rootwizard a[href="#finish"]').text(finish)

  _addElement = ->
    $('.actions.clearfix ul').before("<hr/>")

  _formValidate = (form) ->
    $('.score_option input').attr('required','required')
    $('.col-xs-12').on 'click', '.score_option label', ->

      currentTabLabels = $(@).parents('.score_option').find('label label')
      currentTabLabels.removeClass('active-label')
      $(@).children('label').addClass('active-label')

      $('.score_option').removeClass('is_error')
      labelColors = 'label-danger label-warning label-primary label-info'
      currentTabLabels.removeClass(labelColors)
      score       = $(@).children('label').text()
      scoreColor  = $(@).parents('.score_option').data("score-#{score}")
      domainId    = $(@).parents('.score_option').data("domain-id")

      $(@).children('label').addClass("label-#{scoreColor}")
      if(scoreColor == 'danger' or scoreColor == 'warning')
        $(".domain-#{domainId} .assessment-task-btn, .domain-#{domainId} .task_required").removeClass('hidden').show()
      else
        $(".domain-#{domainId} .assessment-task-btn, .domain-#{domainId} .task_required").hide()

    form.validate errorElement: 'em'
    errorPlacement: (error, element) ->
      element.before error

  _loadSteps = (form) ->
    $("#rootwizard").steps
      headerTag: 'h4'
      bodyTag: 'div'
      transitionEffect: 'slideLeft'
      autoFocus: true

      onInit: (event, currentIndex) ->
        _formEdit(currentIndex)
        _appendSaveButton()
        _handleAppendAddTaskBtn()

      onStepChanging: (event, currentIndex, newIndex) ->
        if currentIndex > newIndex
          return true

        form.validate().settings.ignore = ':disabled,:hidden'
        form.valid()
        _filedsValidator(currentIndex, newIndex)

      onStepChanged: (event, currentIndex, priorIndex) ->
        _formEdit(currentIndex)
        _handleAppendAddTaskBtn()
        if currentIndex == 11
          $("#rootwizard a[href='#save']").remove()

      onFinishing: (event, currentIndex, newIndex) ->
        form.validate().settings.ignore = ':disabled'
        form.valid()
        _filedsValidator(currentIndex,newIndex)

      onFinished: ->
        $('.actions a:contains("Done")').removeAttr('href')
        form.submit()
      labels:
        finish: 'Done'

  _appendSaveButton = ->
    action = $('#rootwizard').data('action')
    if action == 'edit'
      $('#rootwizard').find("[aria-label=Pagination]").append("<li><a id='btn-save' href='#save' class='btn btn-info' style='background: #21b9bb;'></a></li>")

  _saveAssessment = (form)->
    $("#rootwizard a[href='#save']").on 'click', ->
      form.valid()
      form.submit()

  _formEdit = (currentIndex) ->
    currentTab  = "#rootwizard-p-#{currentIndex}"
    scoreOption = $("#{currentTab} .score_option")
    chosenScore = scoreOption.find('label input:checked').val()
    scoreColor  = scoreOption.data("score-#{chosenScore}")
    scoreOption.find("label label:contains(#{chosenScore})").addClass("label-#{scoreColor}")

  _filedsValidator = (currentIndex, newIndex ) ->
      currentTab   = "#rootwizard-p-#{currentIndex}"
      scoreOption  = $("#{currentTab} .score_option")

      if(scoreOption.find('input.error').length)
        $(currentTab).find('.score_option').addClass('is_error')
        return false
      else
        $(currentTab).find('.score_option').removeClass('is_error')
        if $(currentTab).find('textarea.goal.valid').length and $(currentTab).find('textarea.reason.valid').length

          activeLabel = $(currentTab).find('.active-label')
          activeScore = activeLabel.text()
          activeScoreColor = $(activeLabel).parents('.score_option').data("score-#{activeScore}")

          if activeScoreColor == 'warning' || activeScoreColor == 'danger'
            return true if $("#{currentTab} ol.tasks-list li").length >= 1
          else
            return true

  _addTasks = ->
    $('.assessment-task-btn').on 'click', (e) ->
      _clearTaskForm()
      domainId = $(e.target).data('domain-id')
      $('#task_domain_id').val(domainId)

  _postTask = ->
    $('.add-task-btn').on 'click', (e) ->
      $('.add-task-btn').attr('disabled','disabled')
      e.preventDefault()
      actionUrl = undefined
      data      = undefined
      data      = $('#assessment_domain_task').serializeArray()
      actionUrl = $('#assessment_domain_task').attr('action').split('?')[0]

      $.ajax
        type: 'POST'
        url: "#{actionUrl}.json"
        data: data
        success: (response) ->
          _addElementToDom(response, actionUrl)
          $('.add-task-btn').removeAttr('disabled')
          $('#tasksFromModal').modal('hide')
        error: (response) ->
          $('.add-task-btn').removeAttr('disabled')
          _showTaskError(response.responseJSON)

  _addElementToDom = (data, actionUrl) ->
    appendElement  = $(".domain-#{data.domain_id} .task-arising");
    deleteUrl      = undefined
    element        = undefined
    deleteUrl      = "#{actionUrl}/#{data.id}"
    element        = "<li class='list-group-item' style='padding-bottom: 11px;'>#{data.name}<a class='pull-right remove-task fa fa-trash btn btn-outline btn-danger btn-xs' href='javascript:void(0)' data-url='#{deleteUrl}' style='margin: 0;'></a></li>"

    $(".domain-#{data.domain_id} .task-arising").removeClass('hidden')
    $(".domain-#{data.domain_id} .task-arising ol").append(element)
    _clearTaskForm()

    $('a.remove-task').on 'click', (e) ->
      _deleteTask(e)

  _removeHiddenTaskArising = ->
    tasksList = $('li.list-group-item')
    if $(tasksList).length > 0
      $(tasksList).parents('.task-arising').removeClass('hidden')

  _removeTask = ->
    $('a.remove-task').on 'click', (e) ->
      _deleteTask(e)

  _deleteTask = (e) ->
    url = $(e.target).data('url').split('?')[0]
    url = "#{url}.json"

    $.ajax
      type: 'delete'
      url: url
      success: (response) ->
    $(e.target).parent().remove()

  _removeTaskError = ->
    task = '#assessment_domain_task'
    $("#{task} .task_name, #{task} .task_completion_date").removeClass('has-error')
    $("#{task} .task_name_help, #{task} .task_completion_date_help").hide()

  _showTaskError = (error) ->
    task = '#assessment_domain_task'
    if error.completion_date != undefined and error.completion_date.length > 0
      $("#{task} .task_completion_date").addClass('has-error')
      $("#{task} .task_completion_date_help").show().html(error.completion_date[0])
    else
      $("#{task} .task_completion_date").removeClass('has-error')
      $("#{task} .task_completion_date_help").hide()

    if error.name != undefined and error.name.length > 0
      $("#{task} .task_name").addClass('has-error')
      $("#{task} .task_name_help").show().html(error.name[0])
    else
      $("#{task} .task_name").removeClass('has-error')
      $("#{task} .task_name_help").hide()

  _clearTaskForm = ->
    _removeTaskError()
    task = '#assessment_domain_task'
    $("#{task} #task_name").val('')
    $("#{task} #task_completion_date").val('')

  _initUploader = ->
    $('.file .optional').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  _handleDeleteAttachment = ->
    rows = $('.row-file')
    $(rows).each (_k, element) ->
      deleteBtn = $(element).find('.delete')
      confirmDelete = $(deleteBtn).data('comfirm')
      $(deleteBtn).click ->
        result = confirm(confirmDelete)
        return unless result
        BtnURL = $(deleteBtn)[0].dataset.url
        $.ajax
          dataType: "json"
          url: BtnURL
          method: 'DELETE'
          success: (response) ->
            $(element).remove()
            index = 0
            attachments = $('.row-file:visible')
            if attachments.length > 0
              for td in attachments
                td.getElementsByClassName('delete')[0].dataset.url = _replaceUrlParam(td.getElementsByClassName('delete')[0].dataset.url, 'file_index', index++)
            _initNotification(response.message)

  _initNotification = (message)->
    messageOption = {
      "closeButton": true,
      "debug": true,
      "progressBar": true,
      "positionClass": "toast-top-center",
      "showDuration": "400",
      "hideDuration": "1000",
      "timeOut": "7000",
      "extendedTimeOut": "1000",
      "showEasing": "swing",
      "hideEasing": "linear",
      "showMethod": "fadeIn",
      "hideMethod": "fadeOut"
    }
    toastr.success(message, '', messageOption)

  _replaceUrlParam = (url, paramName, paramValue) ->
    if paramValue == null
      paramValue = ''
    pattern = new RegExp('\\b(' + paramName + '=).*?(&|$)')
    if url.search(pattern) >= 0
      return url.replace(pattern, '$1' + paramValue + '$2')
    url + (if url.indexOf('?') > 0 then '&' else '?') + paramName + '=' + paramValue

  { init: _init }
