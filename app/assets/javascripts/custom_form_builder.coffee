class CIF.CustomFormBuilder
  constructor: () ->

  eventCheckboxOption: ->
    self = @
    onadd: (fld) ->
      $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.hideOptionValue()
      self.addOptionCallback(fld)
      self.generateValueForSelectOption(fld)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.hideOptionValue()
        self.addOptionCallback(fld)
        self.generateValueForSelectOption(fld)
        ),50

  eventDateOption: ->
    self = @
    onadd: (fld) ->
      $('.className-wrap, .value-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
      ),50

  eventFileOption: ->
    self = @
    onadd: (fld) ->
      $('.className-wrap, .value-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
      ),50

  eventNumberOption: ->
    self = @
    onadd: (fld) ->
      $('.className-wrap, .value-wrap, .step-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
      ),50

  eventRadioOption: ->
    self = @
    onadd: (fld) ->
      $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.hideOptionValue()
      self.addOptionCallback(fld)
      self.generateValueForSelectOption(fld)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.hideOptionValue()
        self.addOptionCallback(fld)
        self.generateValueForSelectOption(fld)
        ),50

  eventSelectOption: ->
    self = @
    onadd: (fld) ->
      $('.className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.hideOptionValue()
      self.addOptionCallback(fld)
      self.generateValueForSelectOption(fld)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.hideOptionValue()
        self.addOptionCallback(fld)
        self.generateValueForSelectOption(fld)
        ),50

  eventTextFieldOption: ->
    self = @
    onadd: (fld) ->
      $('.fld-subtype ').find('option:contains(color)').remove()
      $('.fld-subtype ').find('option:contains(tel)').remove()
      $('.fld-subtype ').find('option:contains(password)').remove()
      $('.className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
      ),50

  eventTextAreaOption: ->
    self = @
    onadd: (fld) ->
      $('.rows-wrap, .className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
      ),50

  hideOptionValue: ->
    $('.option-selected, .option-value').hide()

  addOptionCallback: (field) ->
    $('.add-opt').on 'click', ->
      setTimeout ( ->
        $(field).find('.option-selected, .option-value').hide()
        )
  generateValueForSelectOption: (field) ->
    $(field).find('input.option-label').on 'keyup change', ->
      value = $(@).val()
      $(@).siblings('.option-value').val(value)

  handleCheckingForm: ->
    @handleDisplayDuplicateWarning()
    @actionRemoveField()
    @actionEditField()

  getDuplicateValues: (elements) ->
    self = @
    $(elements).each (index, label) ->
      displayText = $(label).text()
      $(elements).each (cIndex, cLabel) ->
        return if cIndex == index
        cText = $(cLabel).text()
        if cText == displayText
          self.addDuplicateWarning(label)

  handleDisplayDuplicateWarning: ->
    if $('#trackings').is(':visible') and $('.nested-fields').is(':visible')
      elementFrmbs = $('ul.frmb:visible')
      for element in elementFrmbs
        elements  = $(element).find('.field-label:visible')
        @getDuplicateValues(elements)
    else
      elements = $('ul.frmb:visible .field-label:visible')
      @getDuplicateValues(elements)

  addDuplicateWarning: (element) ->
    errorText = 'Field labels must be unique, please click the edit icon to set a unique field label'
    parentElement = $(element).parents('li.form-field')
    $(parentElement).addClass('has-error')
    $(parentElement).find('input, textarea, select').addClass('error')
    unless $(parentElement).find('label.error').is(':visible')
      $(parentElement).append("<label class='error'>#{errorText}</label>")
      $('#custom-field-submit').attr('disabled', 'true') if $('#custom-field-submit').length

  actionRemoveField: ->
    self = @
    $('.field-actions a.del-button').click ->
      setTimeout ( -> self.removeFieldDuplicate()),300

  actionEditField: ->
    self = @
    labels = $('.field-label:visible')
    $('.field-actions a.icon-pencil').click ->
      $(".form-elements input[name='label']").on 'change', ->
        setTimeout ( ->
          self.removeFieldDuplicate()
          self.handleDisplayDuplicateWarning(labels)
        ), 300

  getNoneDuplicateLabel: (elements) ->
    labels    = $(elements).map(-> $(@).text().trim()).get()
    values = labels.elementWitoutDuplicates()
    for element in elements
      text = $(element).text().trim()
      if values.includes(text)
        @removeDuplicateWarning(element)

  removeFieldDuplicate: ->
    if $('#trackings').is(':visible') and $('.nested-fields').is(':visible')
      elementFrmbs = $('ul.frmb:visible')
      for element in elementFrmbs
        elements  = $(element).find('.field-label:visible')
        @getNoneDuplicateLabel(elements)
    else
      elements = $('ul.frmb:visible .field-label:visible')
      @getNoneDuplicateLabel(elements)

  removeDuplicateWarning: (element) ->
    field = $(element).parents('li.form-field')
    $(field).removeClass('has-error')
    $(field).find('input, textarea, select').removeClass('error')
    $(field).find('label.error').remove()
    $('#custom-field-submit').removeAttr('disabled') if $('#custom-field-submit').length
