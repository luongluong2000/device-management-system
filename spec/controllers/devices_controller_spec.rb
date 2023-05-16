require "rails_helper"

RSpec.describe DevicesController, type: :controller do
    let!(:company) {FactoryBot.create :company}
    let!(:office) {FactoryBot.create :office, company: company}
    let!(:user) {FactoryBot.create :user, office: office}
    let!(:device) {FactoryBot.create :device, office: office}
    let!(:request) {FactoryBot.create :request, device: device, user: user}
    let!(:user_bod) {FactoryBot.create :user_bod, office: office}
    let!(:user_system_admin) {FactoryBot.create :user_system_admin, office: office}
    let!(:user_device_manager) {FactoryBot.create :user_device_manager, office: office}

    # Check Roles to access controller
    describe "check roles" do
        context "role user" do
            before{sign_in(user)}
            before {get :index}

            it "check roles user redirect" do
                expect(response).to redirect_to(root_path)
            end

            it "check roles user flash" do
                expect(flash[:alert]).to eq "You are not authorized to access this page."
            end
        end

        context "role system_admin" do
            before{sign_in(user_system_admin)}
            before {get :index}

            it "check roles system admim redirect" do
                expect(response).to render_template :index
            end
        end

        context "role device_manager" do
            before{sign_in(user_device_manager)}
            before {get :index}

            it "check roles system admim redirect" do
                expect(response).to render_template :index
            end
        end

        context "role bod" do
            before{sign_in(user_bod)}
            before {get :index}

            it "check roles system admim redirect" do
                expect(response).to render_template :index
            end
        end
    end

    #Test index controller
    describe "GET devices#index" do
        context "role system_admin data" do
            before{sign_in(user_system_admin)}
            before {get :index}
            let!(:devices) {user_system_admin.office.company.devices}

            it "check data" do
                expect(assigns(:devices)).to eq devices
            end
        end

        context "role device_manager data" do
            before{sign_in(user_device_manager)}
            before {get :index}
            let!(:devices) {user_device_manager.office.company.devices}

            it "check data" do
                expect(assigns(:devices)).to eq devices
            end
        end

        context "role bod data" do
            before{sign_in(user_bod)}
            before {get :index}
            let!(:devices) {user_bod.office.company.devices}

            it "check data" do
                expect(assigns(:devices)).to eq devices
            end
        end
    end
end
