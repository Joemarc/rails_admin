feature 'Charge many services in the admin' do
  let(:admin){ create(:admin) }

  let!(:service_1){ create(:service, status: 'finished') }
  let!(:service_2){ create(:service, status: 'finished') }
  let!(:service_3){ create(:service, status: 'paid') }

  let(:services_ids){ [service_1.id, service_2.id, service_3.id] }
  let(:path) {rails_admin.bulk_action_path(
                bulk_action: 'charge_services',
                model_name: 'service',
                bulk_ids: services_ids,
                '_method' => 'get')}

  before do
    ResqueSpec.reset!
  end

  describe '#charge_services' do
    context 'skipping the actual job' do
      it 'enques de mass charging' do
        login_as(admin)

        with_rack_test_driver do
          page.driver.submit :post, path, {}
        end
        
        expect(ServiceCharger).to have_queued(services_ids)
      end
    end

    context 'with actual jobs being run' do
      before do
        ResqueSpec.inline = true
        expect_any_instance_of(User).to receive(:charge!).and_return(Payment.new(status: 'paid'))
        expect_any_instance_of(Service).to receive(:amount_by_reported_hours).and_return(0)
        expect_any_instance_of(Service).to receive(:pay!).and_call_original
      end

      after do
        ResqueSpec.inline = false
      end

      it 'marks the services as paid' do
        login_as(admin)


        with_resque do
          with_rack_test_driver do
            page.driver.submit :post, path, {}
          end
        end

        expect(service_1.reload).to be_paid
      end
    end
  end
end
