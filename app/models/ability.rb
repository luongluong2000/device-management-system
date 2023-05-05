# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize user
    alias_action :show, :new, :create, :edit, :destroy, :update, to: :only_current

    return if user.blank?

    if user.role_system_admin?
      authenication_system_admin
    elsif user.role_bod?
      authenication_bod user
    elsif user.role_device_manager?
      authenication_device_manager user
    elsif user.role_staff?
      authenication_staff
    end
  end

  private

  def authenication_system_admin
    can :manage, :all
  end

  def authenication_bod user
    can :manage, [Device, UserDevice, Request]
    can :only_current, Company, id: user.office.company_id
    can :manage, Office
  end

  def authenication_device_manager user
    can :manage, [Device, UserDevice, Request]
    can :only_current, Company, id: user.office.company_id
    can :only_current, Office
  end

  def authenication_staff
    cannot :manage, :all

    can :manage, UserDevice
    can :manage, Request
  end
end
