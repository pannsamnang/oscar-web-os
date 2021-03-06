CIF.Program_streamsNew = CIF.Program_streamsEdit = CIF.Program_streamsCreate = CIF.Program_streamsUpdate = do ->
  @programStreamId = $('#program_stream_id').val()
  ENROLLMENT_URL   = "/api/program_streams/#{@programStreamId}/enrollment_fields"
  EXIT_PROGRAM_URL = "/api/program_streams/#{@programStreamId}/exit_program_fields"
  TRACKING_URL     = "/api/program_streams/#{@programStreamId}/tracking_fields"
  @formBuilder = []
  _init = ->
    @filterTranslation = ''
    _getTranslation()
    _initProgramSteps()
    _initCheckbox()
    _addFooterForSubmitForm()
    _handleInitProgramRules()
    _addRuleCallback()
    _initSelect2()
    _handleAddCocoon()
    _handleRemoveCocoon()
    _handleInitProgramFields()
    _initButtonSave()
    _handleSaveProgramStream()
    _handleClickAddTracking()
    _handleShowTracking()
    _handleHideTracking()
    _initSelect2TimeOfFrequency()
    _handleRemoveFrequency()
    _handleSelectFrequency()
    _initFrequencyNote()
    _editTrackingFormName()

  _initCheckbox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
    $($('.icheckbox_square-green.checked')[0]).removeClass('checked')

  _stickyFill = ->
    if $('.form-wrap').is(':visible') then $('.cb-wrap').Stickyfill()

  _initSelect2 = ->
    $('#description select, #rule-tab select').select2()

  _initSelect2TimeOfFrequency = ->
    $('.program_stream_trackings_frequency select').select2
      minimumInputLength: 0
      allowClear: true

  _handleRemoveProgramList = ->
    programExclusive = $('#program_stream_program_exclusive')
    mutualDependence = $('#program_stream_mutual_dependence')
    _selectOptonProgramExclusive(programExclusive, mutualDependence)
    _selectOptonMutualDependence(programExclusive, mutualDependence)

  _selectOptonProgramExclusive = (programExclusive, mutualDependence) ->
    if $(programExclusive).val() != null
      for value in $(programExclusive).val()
        $(mutualDependence).find("option[value=#{value}]").attr('disabled', true)

    $(programExclusive).on 'select2-selecting', (select)->
      $(mutualDependence).find("option[value=#{select.val}]").attr('disabled', true)

    $(programExclusive).on 'select2-removed', (select)->
      $(mutualDependence).find("option[value=#{select.val}]").removeAttr('disabled')

  _selectOptonMutualDependence = (programExclusive, mutualDependence) ->
    if $(mutualDependence).val() != null
      for value in mutualDependence.val()
        $(programExclusive).find("option[value=#{value}]").attr('disabled', true)

    $(mutualDependence).on 'select2-selecting', (select)->
      $(programExclusive).find("option[value=#{select.val}]").attr('disabled', true)

    $(mutualDependence).on 'select2-removed', (select)->
      $(programExclusive).find("option[value=#{select.val}]").removeAttr('disabled')

  _handleSelectTab = ->
    tab = $('.program-steps').data('tab')
    $('li[role="tab"]').each ->
      tabNumber = $(@).find('span.number').text()[0]
      if parseInt(tabNumber) == tab
        $(@).removeClass('disabled')
        $(@).find('a').trigger('click')
      else if parseInt(tabNumber) < tab
        $(@).removeClass('disabled')
        $(@).addClass('done')

  _handleSaveProgramStream = ->
    $('#btn-save-draft').on 'click', ->
      return false unless _handleCheckingDuplicateFields()
      return false if _handleMaximumProgramEnrollment()
      _handleRemoveUnuseInput()
      _handleAddRuleBuilderToInput()
      _handleSetValueToField()
      $('.tracking-builder').find('input, textarea').removeAttr('required')
      $('#program-stream').submit()

  _handleSetRules = ->
    rules = $('#program_stream_rules').val()
    rules = JSON.parse(rules.replace(/=>/g, ':'))
    $('#program-rule').queryBuilder('setRules', rules) unless $.isEmptyObject(rules)

  _addRuleCallback = ->
    $('#program-rule').on 'afterCreateRuleFilters.queryBuilder', ->
      _initSelect2()
      _handleSelectOptionChange()

  _getTranslation = ->
    @filterTranslation =
      addFilter: $('#program-rule').data('filter-translation-add-filter')
      addGroup: $('#program-rule').data('filter-translation-add-group')
      deleteGroup: $('#program-rule').data('filter-translation-delete-group')
      next: $('.program-steps').data('next')
      previous: $('.program-steps').data('previous')
      save: $('.program-steps').data('save')

  _handleSelectOptionChange = ->
    $('select').on 'select2-selecting', (e) ->
      setTimeout (->
        $('.rule-operator-container select, .rule-value-container select').select2(
          width: '180px'
        )
      ),100

  _handleInitProgramRules = ->
    $.ajax
      url: '/api/program_stream_add_rule/get_fields'
      method: 'GET'
      success: (response) ->
        fieldList = response.program_stream_add_rule
        builder = new CIF.AdvancedFilterBuilder($('#program-rule'), fieldList, filterTranslation)
        builder.initRule()
        setTimeout (->
          _handleSelectTab()
          _initSelect2()
          ), 100
        _handleSetRules()
        _handleSelectOptionChange()

  _handleAddCocoon = ->
    $('#trackings').on 'cocoon:after-insert', (e, element) ->
      trackingBuilder = $(element).find('.tracking-builder')
      _initProgramBuilder(trackingBuilder, [])
      _stickyFill()
      _editTrackingFormName()
      _handleRemoveCocoon()
      _initSelect2TimeOfFrequency()
      _handleRemoveFrequency()
      _handleSelectFrequency()
      _initFrequencyNote()

  _initProgramBuilder = (element, data) ->
    builderOption = new CIF.CustomFormBuilder()
    data = if data.length != 0 then data.replace(/=>/g, ':') else ''
    @formBuilder.push $(element).formBuilder({
      dataType: 'json'
      formData: data
      disableFields: ['autocomplete', 'header', 'hidden', 'paragraph', 'button','checkbox']
      showActionButtons: false
      messages: {
        cannotBeEmpty: 'name_separated_with_underscore'
      }

      typeUserEvents: {
        'checkbox-group': builderOption.eventCheckboxOption()
        date: builderOption.eventDateOption()
        file: builderOption.eventFileOption()
        number: builderOption.eventNumberOption()
        'radio-group': builderOption.eventRadioOption()
        select: builderOption.eventSelectOption()
        text: builderOption.eventTextFieldOption()
        textarea: builderOption.eventTextAreaOption()
      }
    }).data('formBuilder');

   _editTrackingFormName = ->
    inputNames = $(".program_stream_trackings_name input[type='text']")
    $(inputNames).on 'change', ->
      _checkDuplicateTrackingName()

  _checkDuplicateTrackingName = ->
    nameFields = $('.program_stream_trackings_name:visible input[type="text"]')
    values    = $(nameFields).map(-> $(@).val().trim()).get()

    duplicateValues = Object.values(values.getDuplicates())
    indexs    = [].concat.apply([], duplicateValues)

    noneDuplicates = values.elementWitoutDuplicates()
    $(nameFields).each (index, element) ->
      inputWrapper = $(element).parent()
      if indexs.includes(index)
        $(element).addClass('error')
        unless $(inputWrapper).find('label.error').is(':visible')
          $(inputWrapper).append('<label class="error">Tracking name must be unique</label>')
      else if noneDuplicates.includes($(element).val())
        $(element).removeClass('error')
        if $(inputWrapper).find('label.error').is(':visible')
          $(inputWrapper).find('label.error').remove()

  _handleRemoveCocoon = ->
    $('#trackings').on 'cocoon:after-remove', ->
      _checkDuplicateTrackingName()

  _handleCheckingDuplicateFields = ->
    errorNumber = $('.form-wrap.form-builder:visible').find('.has-error').size()
    if errorNumber > 0 then false else true

  _initProgramSteps = ->
    self = @
    form = $('#program-stream')
    form.children('.program-steps').steps
      headerTag: 'h4'
      bodyTag: 'section'
      transitionEffect: 'slideLeft'

      onStepChanging: (event, currentIndex, newIndex) ->
        if currentIndex == 0 and newIndex == 1 and $('#description').is(':visible')
          form.valid()
          name = $('#program_stream_name').val() == ''
          return false if name
        else if currentIndex == 3 and newIndex == 4 and $('#trackings').is(':visible')
          return true if $('#trackings').hasClass('hide-tracking-form')
          return _handleCheckingDuplicateFields() and _handleCheckTrackingName()
        else if $('#enrollment, #exit-program').is(':visible')
          return _handleCheckingDuplicateFields()
          return false if _handleCheckingDuplicateFields()
        else if $('#rule-tab').is(':visible')
          return false if _handleMaximumProgramEnrollment()
        $('section ul.frmb.ui-sortable').css('min-height', '266px')

      onStepChanged: (event, currentIndex, newIndex) ->
        _stickyFill()
        buttonSave = $('#btn-save-draft')
        if $('#rule-tab').is(':visible')
          _handleRemoveProgramList()
        else if $('#exit-program').is(':visible') then $(buttonSave).hide() else $(buttonSave).show()

      onFinished: (event, currentIndex) ->
        $('.actions a:contains("Finish")').removeAttr('href')
        return false unless _handleCheckingDuplicateFields()
        _handleRemoveUnuseInput()
        _handleAddRuleBuilderToInput()
        _handleSetValueToField()
        form.submit()

      labels:
        finish: self.filterTranslation.save
        next: self.filterTranslation.next
        previous: self.filterTranslation.previous

  _handleCheckTrackingName = ->
    nameFields = $('.program_stream_trackings_name:visible input[type="text"].error')
    if $(nameFields).length > 0 then false else true

  _handleClickAddTracking = ->
    if $('#trackings .frmb').length == 0
      $('.links a').trigger('click')

  _handleInitProgramFields = ->
    for element in $('#enrollment, #exit-program')
      dataElement = $(element).data('field')
      _initProgramBuilder($(element), (dataElement || []))
      if element.id == 'enrollment' and $('#program_stream_id').val() != ''
        _preventRemoveField(ENROLLMENT_URL, '#enrollment')
      else if element.id == 'exit-program' and $('#program_stream_id').val() != ''
        _preventRemoveField(EXIT_PROGRAM_URL, '#exit-program')

    trackings = $('.tracking-builder')
    for tracking in trackings
      trackingValue = $(tracking).data('tracking')
      _initProgramBuilder(tracking, (trackingValue || []))
    _preventRemoveField(TRACKING_URL, '') if $('#program_stream_id').val() != ''

  _initButtonSave = ->
    form = $('form#program-stream')
    btnSaveTranslation = filterTranslation.save
    form.find("[aria-label=Pagination]").append("<li><span id='btn-save-draft' class='btn btn-primary btn-sm'>#{btnSaveTranslation}</span></li>")

  _handleRemoveUnuseInput = ->
    elements = $('#program-rule ,#enrollment .form-wrap.form-builder, #tracking .form-wrap.form-builder, #exit-program .form-wrap.form-builder')
    $(elements).find('input, select, radio, checkbox, textarea').remove()

  _handleAddRuleBuilderToInput = ->
    rules = $('#program-rule').queryBuilder('getRules')
    $('ul.rules-list li').removeClass('has-error') if ($.isEmptyObject(rules))
    $('#program_stream_rules').val(_handleStringfyRules(rules)) if !($.isEmptyObject(rules))

  _handleSetValueToField = ->
    for formBuilder in @formBuilder
      element = formBuilder.element
      if $(element).is('#enrollment')
        $('#program_stream_enrollment').val(formBuilder.formData)
      else if $(element).is('.tracking-builder')
        hiddenField = $(element).find('.tracking-field-hidden input[type="hidden"]')
        $(hiddenField).val(formBuilder.formData)
      else if $(element).is('#exit-program')
        $('#program_stream_exit_program').val(formBuilder.formData)

  _handleStringfyRules = (rules) ->
    rules = JSON.stringify(rules)
    return rules.replace(/null/g, '""')

  _addFooterForSubmitForm = ->
    $('.actions.clearfix').addClass('ibox-footer')

  _handleHideTracking = ->
    if $('#program_stream_tracking_required').prop('checked')
      $('#trackings').addClass('hide-tracking-form')
    $('#program_stream_tracking_required').on 'ifChecked', ->
      $('#trackings').addClass('hide-tracking-form')

  _handleShowTracking = ->
    $('#program_stream_tracking_required').on 'ifUnchecked', ->
      $('#trackings').removeClass('hide-tracking-form')

  _preventRemoveField = (url, elementId) ->
    return false if @programStreamId == ''
    $.ajax
      method: 'GET'
      url: url
      dataType: "JSON"
      success: (response) ->
        if response.field == 'tracking'
          _hideActionInTracking(response)
        else
          fields = response.program_streams
          labelFields = $(elementId).find('label.field-label')
          for labelField in labelFields
            text = labelField.textContent
            if fields.includes(text)
              parent = $(labelField).parent()
              $(parent).children('div.field-actions').remove()

  _hideActionInTracking = (fields) ->
    trackings = $('#trackings .nested-fields')
    for tracking in trackings
      trackingName = $(tracking).find('input.string.optional.readonly.form-control')
      return if $(trackingName).length == 0
      name = $(trackingName).val()
      labelFields = $(tracking).find('label.field-label')
      for labelField in labelFields
        parent = $(labelField).parent()
        for field in fields[name]
          if labelField.textContent == field
            $(parent).children('div.field-actions').remove()
            $(tracking).find('.ibox-footer').remove()

  _initFrequencyNote = ->
    for nestedField in $('.nested-fields')
      select        = $(nestedField).find('.program_stream_trackings_frequency select')
      timeFrequency = $(nestedField).find('.program_stream_trackings_time_of_frequency input')
      elementNote   = $(nestedField).find('.frequency-note')
      frequency     = _convertFrequency($(select).val())
      value         = parseInt(timeFrequency.val())
      $(timeFrequency).attr(readonly: true) if frequency == ''
      _updateFrequencyNote(value, frequency, elementNote) if value > 0
      _timeOfFrequencyChange(timeFrequency, frequency, elementNote)

  _handleRemoveFrequency = ->
    frequencies = $('.program_stream_trackings_frequency select')
    $(frequencies).on 'select2-removed', (element) ->
      select          = element.currentTarget
      nestedField     = $(select).parents('.nested-fields')
      timeOfFrequency = $(nestedField).find('.program_stream_trackings_time_of_frequency input')
      $(nestedField).find('.frequency-note i').text('')
      $(timeOfFrequency).val(0)
      $(timeOfFrequency).attr(readonly: true)

  _handleSelectFrequency = ->
    frequencies = $('.program_stream_trackings_frequency select')
    $(frequencies).on 'select2-selecting', (element) ->
      select          = element.currentTarget
      frequencyNote   = select.parentElement.nextElementSibling
      frequencyValue  = _convertFrequency(element.val)

      nested = $(select).parents('.nested-fields')
      timeOfFrequency = $(nested).find('.program_stream_trackings_time_of_frequency input')
      $(timeOfFrequency).removeAttr('readonly')
      $(timeOfFrequency).val(1) if $(timeOfFrequency).val() <= 0
      value = parseInt($(timeOfFrequency).val())
      _updateFrequencyNote(value, frequencyValue, frequencyNote)
      _timeOfFrequencyChange(timeOfFrequency, frequencyValue, frequencyNote)

  _timeOfFrequencyChange = (timeOfFrequency, frequencyValue, frequencyNote) ->
    $(timeOfFrequency).on 'change', ->
      value = parseInt($(@).val())
      $(@).val(0) if value < 0
      _updateFrequencyNote(value, frequencyValue, frequencyNote)

  _updateFrequencyNote = (value, frequency, element) ->
    frequencyNote = 'This needs to be done once every'
    single = "#{frequencyNote} #{frequency}"
    plural = "#{frequencyNote} #{value} #{frequency}s"
    frequencNoteUpdate = if value == 1 then single else if value > 1 then plural
    $(element).find('i').text('')
    $(element).find('i').text(frequencNoteUpdate) if value > 0

  _convertFrequency = (frequency)->
    switch(frequency)
      when 'Daily'
        frequency = 'day'
      when 'Weekly'
        frequency = 'week'
      when 'Monthly'
        frequency = 'month'
      when 'Yearly'
        frequency = 'year'
      else
        frequency = ''

  _handleMaximumProgramEnrollment = ->
    quantity = $('#program_stream_quantity')
    if $(quantity).val() < $(quantity).data('maximun') && $(quantity).val() != ''
      $('.help-block.quantity').removeClass('hidden')
      return true
    else
      $('.help-block.quantity').addClass('hidden')
      return false

  { init: _init }
