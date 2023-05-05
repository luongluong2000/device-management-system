class CompaniesController < ApplicationController
  load_and_authorize_resource

  before_action :set_company, only: %i(show edit update)
  before_action :check_current_company, only: :index

  def index
    @query = Company.ransack params[:query]
    @pagy, @companies = pagy @query.result(distinct: true).includes(:office_info).recent,
                             items: Settings.pagy.config.page.default
  end

  def show; end

  def new
    @company = Company.new
    @company.office_infos.build
  end

  def edit; end

  def create
    @company = Company.new company_params
    if @company.save
      respond_to do |format|
        format.turbo_stream{flash.now[:notice] = t(".success")}
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @company.update company_params
      respond_to do |format|
        format.turbo_stream{flash.now[:notice] = t(".success")}
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_company
    return if @company = Company.find_by(id: params[:id])

    redirect_to companies_path, alert: t("shared.company_does_not_exist")
  end

  def company_params
    params.require(:company).permit Company::ATTR_PARAMS
  end

  def check_current_company
    return if current_user.role_system_admin?

    redirect_to company_path(current_user.office.company)
  end
end
