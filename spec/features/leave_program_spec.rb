describe LeaveProgram, 'Leave Program' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:client) { create(:client, date_of_birth: 10.years.ago) }
  let!(:program_stream) { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client) }

  before do
    login_as admin
  end

  feature 'Create', js: true do
    before do
      program_stream.reload
      program_stream.update_columns(completed: true)

      visit client_client_enrolled_programs_path(client)
      click_link('Exit')
    end

    scenario 'Valid' do
      within('#new_leave_program') do
        find('.numeric').set(4)
        find('#exit_date').set(Date.today)
        find('#leave_program_properties_description').set('Good client')
        find('input[type="email"]').set('test@example.com')

        click_button 'Save'
      end
      expect(page).to have_content('4')
      expect(page).to have_content(Date.today.strftime('%d %B, %Y'))
      expect(page).to have_content('Good client')
      expect(page).to have_content('test@example.com')
    end

    scenario 'Invalid' do
      within('#new_leave_program') do
        find('.numeric').set(6)
        find('#leave_program_properties_description').set('')
        find('input[type="email"]').set('testexample')

        click_button 'Save'
      end
      expect(page).to have_css('div.form-group.has-error')
    end
  end

  feature 'Show', js: true do
    let!(:leave_program) { create(:leave_program, client_enrollment: client_enrollment, program_stream: program_stream) }

    before do
      visit client_client_enrolled_program_leave_enrolled_program_path(client, client_enrollment, leave_program)
    end

    scenario 'Age' do
      expect(page).to have_content('3')
    end

    scenario 'Email' do
      expect(page).to have_content('test@example.com')
    end

    scenario 'Description' do
      expect(page).to have_content('this is testing')
    end

    scenario 'Back link' do
      expect(page).to have_link("Back")
    end
  end

  feature 'Update', js: true do
    let!(:leave_program) { create(:leave_program, client_enrollment: client_enrollment, program_stream: program_stream) }

    before do
      visit edit_client_client_enrolled_program_leave_enrolled_program_path(client, client_enrollment, leave_program, program_stream_id: program_stream.id)
    end

    scenario 'success' do
      find('#exit_date').set(Date.today)
      find('#leave_program_properties_description').set('this is editing')
      find('input[type="submit"]').click
      expect(page).to have_content(Date.today.strftime('%d %B, %Y'))
      expect(page).to have_content('this is editing')
    end

    scenario 'fail' do
      find('#leave_program_properties_description').set('')
      find('input[type="submit"]').click
      expect(page).to have_css('div.form-group.has-error')
    end
  end
end
