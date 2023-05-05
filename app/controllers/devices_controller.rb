class DevicesController < ApplicationController
  load_and_authorize_resource

  before_action :set_device, only: %i(show new_sub_devices add_sub_devices)
  before_action :check_device_ids_present, only: :add_sub_devices
  before_action :check_import_file_present, only: :import
  before_action :check_comfirm_device_ids_present, only: :confirm_devices
  before_action :check_user_have_office, only: :index

  def index
    @devices = @office.devices.not_draft.without_sub_device
                      .includes(:brand, :category, :sub_devices, {office: :office_info})
    @devices_belong = @office.devices.have_parent.includes(:brand, :category, :sub_devices, {office: :office_info})
    respond_to do |format|
      format.html{@pagy, @devices = pagy @devices, items: Settings.pagy.config.page.default}
      format.xlsx
    end
  end

  def show; end

  def new_sub_devices
    @sub_devices = sub_devices.recent
  end

  def add_sub_devices
    @sub_devices = sub_devices.by_ids params[:device_ids]
    @sub_devices.update device_id: @device.id
  end

  def import
    @import_history = Imports::Excel::Devices::CreatedListServices.new(file: params[:file], user: current_user).perform
    @devices = @import_history.devices.includes(:brand, :category)
  end

  def confirm_devices
    if @devices.update status: :ready
      redirect_to devices_path, notice: t(".success")
    else
      flash.now[:alert] = t ".failed"
      render "layouts/shared/flash"
    end
  end

  private

  def sub_devices
    current_user.office.devices.without_sub_device.without_current_device @device.id
  end

  def set_device
    return if @device = current_user.office.devices.find_by(id: params[:id])

    redirect_to user_devices_path, alert: t("shared.device_does_not_exist")
  end

  def check_device_ids_present
    if params[:device_ids].present?
      respond_to do |format|
        format.turbo_stream{flash.now[:notice] = t(".success")}
      end
    else
      respond_to do |format|
        format.turbo_stream{flash.now[:alert] = t(".failed")}
      end
    end
  end

  def check_import_file_present
    return if params[:file].present?

    flash.now[:alert] = t ".file_not_found"
    render :import_page, status: :bad_request
  end

  def check_user_have_office
    return if @office = current_user.office

    flash[:alert] = t ".office_not_found"
    redirect_to root_path
  end

  def check_comfirm_device_ids_present
    @devices = Device.by_ids params[:device_ids]
    return if @devices.any?

    flash.now[:alert] = t ".failed"
    render "layouts/shared/flash"
  end
end
