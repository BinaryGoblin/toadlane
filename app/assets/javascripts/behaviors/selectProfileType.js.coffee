App.registerBehavior 'SelectProfileType'

class Behavior.SelectProfileType
  constructor: ($el) ->
    @$el = $el

    @$variables = {
      'profile_options': '.profileOptions',
      'company_information': '.companyInformation',
      'user_information': '.userInformation',
      'company_documents': '.companyDocuments',
      'user_documents': '.userDocuments',
      'physical_document': '.physicalDocument'
    }

    @$company_last_physical_document = $(@$variables['company_documents']).find(@$variables['physical_document']).last()

    do @changes

    $(@$el).on 'change', => do @changes

  changes: =>
    switch @$el.val()
      when 'tier_1'
        do @show_profile
        do @show_company_information
        do @hide_user_information
        do @show_company_documents
        do @hide_company_physical_document
        do @hide_user_documents
      when 'tier_2'
        do @show_profile
        do @show_company_information
        do @show_user_information
        do @show_company_documents
        do @show_company_physical_document
        do @text_change_for_tier_2
        do @show_user_documents
      when 'tier_3'
        do @show_profile
        do @show_company_information
        do @show_user_information
        do @show_company_documents
        do @show_company_physical_document
        do @text_change_for_tier_3
        do @show_user_documents
      else
        do @hide_user_documents
        do @hide_company_documents
        do @hide_user_information
        do @hide_company_information
        do @hide_profile

  show_profile: =>
    $(@$variables['profile_options']).removeClass('hide')
    $(@$variables['profile_options']).addClass('show')

  hide_profile: =>
    $(@$variables['profile_options']).removeClass('show')
    $(@$variables['profile_options']).addClass('hide')

  show_company_information: =>
    $(@$variables['company_information']).removeClass('hide')
    $(@$variables['company_information']).addClass('show')

  hide_company_information: =>
    $(@$variables['company_information']).removeClass('show')
    $(@$variables['company_information']).addClass('hide')

  show_user_information: =>
    $(@$variables['user_information']).removeClass('hide')
    $(@$variables['user_information']).addClass('show')

  hide_user_information: =>
    $(@$variables['user_information']).removeClass('show')
    $(@$variables['user_information']).addClass('hide')

  show_company_documents: =>
    $(@$variables['company_documents']).removeClass('hide')
    $(@$variables['company_documents']).addClass('show')

  hide_company_documents: =>
    $(@$variables['company_documents']).removeClass('show')
    $(@$variables['company_documents']).addClass('hide')

  show_user_documents: =>
    $(@$variables['user_documents']).removeClass('hide')
    $(@$variables['user_documents']).addClass('show')

  hide_user_documents: =>
    $(@$variables['user_documents']).removeClass('show')
    $(@$variables['user_documents']).addClass('hide')

  show_company_physical_document: =>
    @$company_last_physical_document.removeClass('hide')
    @$company_last_physical_document.addClass('show')

  hide_company_physical_document: =>
    @$company_last_physical_document.removeClass('show')
    @$company_last_physical_document.addClass('hide')

  text_change_for_tier_2: =>
    @$company_last_physical_document.find('label').text('Address Proof:')

  text_change_for_tier_3: =>
    @$company_last_physical_document.find('label').text('Bank Statement:')
