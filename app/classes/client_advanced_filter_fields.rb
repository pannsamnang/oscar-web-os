class  ClientAdvancedFilterFields
  def initialize(options = {})
    @result = []
    @user = options[:user]
  end

  def render
    number_fields       = number_type_list.map{ |item| AdvancedFilterTypes.number_options(item.first, item.last) }
    text_fields         = text_type_list.map{ |item| AdvancedFilterTypes.text_options(item.first, item.last) }
    date_picker_fields  = date_type_list.map{ |item| AdvancedFilterTypes.date_picker_options(item.first, item.second)}
    drop_list_fields    = drop_down_type_list.map{ |item| AdvancedFilterTypes.drop_list_options(item.first, item.second, item.last)}

    text_fields + drop_list_fields + number_fields + date_picker_fields
  end

  private
  def number_type_list
    [
      ['code', 'Code'],
      ['grade', 'School grade'],
      ['family_id', 'Family ID'],
      ['age', 'Age']
    ]
  end

  def text_type_list
    [
      ['first_name', 'Name'],
      ['family_name', 'Family name'],
      ['slug', 'ID'],
      ['referral_phone', 'Referral phone'],
      ['school_name', 'School name']
    ]
  end

  def date_type_list
    [
      ['placement_date', 'Placement start date'],
      ['date_of_birth', 'Date of birth'],
      ['initial_referral_date', 'Initial referral date'],
      ['follow_up_date', 'Follow-up date']
    ]
  end

  def drop_down_type_list
    [
      ['gender','Gender', { male: 'Male', female: 'Female' }],
      ['status', 'Status', client_status],
      ['case_type', 'Case type', { EC: 'EC', KC: 'KC', FC: 'FC' }],
      ['agency_name', 'Agency name', agencies_options],
      ['received_by_id', 'Received by', received_by_options],
      ['birth_province_id', 'Birth province', provinces],
      ['province_id', 'Current province', provinces],
      ['referral_source_id', 'Referral source', referral_source_options],
      ['followed_up_by_id', 'Followed-up by', followed_up_by_options],
      ['has_been_in_government_care', 'Has been in government care', { true: 'Yes', false: 'No' }],
      ['able_state', 'Able state', client_able_state],
      ['has_been_in_orphanage', 'Has been in orphanage', { true: 'Yes', false: 'No'}],
      ['user_id', 'Case Worker', user_select_options]
    ]
  end

  def client_status
    Client::CLIENT_STATUSES.map{ |s| {s => s.capitalize} }
  end

  def client_able_state
    Client::ABLE_STATES.map{ |s| {s => s} }
  end

  def provinces
   Client.province_is.to_h.invert
  end

  def received_by_options
    clients = @user.admin? ? Client.is_received_by : Client.where(user_id: @user.id).is_received_by
    clients.to_h.invert
  end

  def referral_source_options
    clients = @user.admin? ? Client.referral_source_is : Client.where(user_id: @user.id).referral_source_is
    clients.to_h.invert
  end


  def followed_up_by_options
    clients = @user.admin? ? Client.is_followed_up_by : Client.where(user_id: @user.id).is_followed_up_by
    clients.to_h.invert
  end

  def agencies_options
    Agency.joins(:clients).pluck(:id, :name).uniq.to_h
  end

  def user_select_options
    User.has_clients.map{ |user| { user.id => user.name }}
  end

  def family_options
    ids = []
    Case.active.most_recents.joins(:client).group_by(&:client_id).each do |key, c|
      ids << c.first.id
    end

    Client.joins(:cases).where("cases.id IN (?)", ids).joins(:families).uniq.map{|f| { f.id => f.id }}
  end
end