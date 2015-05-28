# -*- encoding : utf-8 -*-
feature 'UserController' do
  let!(:conekta_card){ create(:conekta_card)}
  let!(:user){ create(:user, password: '12345678',
                             first_name: 'Juan',
                             last_name: 'Perez',
                             phone: '6666',
                             email: 'juan@perez.com')}
    
  describe '#edit' do
    before do
      login_as(user)

      allow_any_instance_of(User).to receive(:default_payment_provider).and_return(conekta_card)
      allow_any_instance_of(User).to receive(:missing_payment_provider_choice?).and_return(false)

      visit edit_users_path user
    end

    it 'lets the user change all its attributes without changing the password' do
      fill_in 'user_first_name', with: 'Guillermo'
      fill_in 'user_last_name', with: 'Siliceo'
      fill_in 'user_phone', with: '9392923983'
      fill_in 'user_email', with: 'prueba@aliada.mx'

      click_button 'Guardar'

      user.reload
      expect(user.first_name).to eql 'Guillermo'
      expect(user.last_name).to eql 'Siliceo'
      expect(user.phone).to eql '9392923983'
      expect(user.email).to eql 'prueba@aliada.mx'
    end

    it 'lets the user change its password' do
      previous_password = user.encrypted_password

      fill_in 'user_password', with: '0987654321'
      fill_in 'user_password_confirmation', with: '0987654321'

      click_button 'Guardar'

      user.reload
      expect(user.encrypted_password).to_not eql previous_password
    end
  end

  describe '#previous_services' do
    let(:starting_datetime) { Time.zone.parse('01 Jan 2015 13:00:00') }
    let!(:service) { create(:service, datetime: starting_datetime - 1.day,
                                      user: user,
                                      status: 'finished') }

    before do
      Timecop.freeze(starting_datetime)

      allow_any_instance_of(User).to receive(:missing_payment_provider_choice?).and_return(false)
      allow_any_instance_of(User).to receive(:default_payment_provider).and_return(conekta_card)
      login_as(user)

      visit previous_services_users_path user
    end
    
    after do
      Timecop.return
    end

    it 'lets the user see previous services' do
      service_formatted_date = I18n.l service.tz_aware_datetime, format: :default_with_hour

      within ".service_history_table" do
        expect(page).to have_content service_formatted_date
      end
    end
  end
end

