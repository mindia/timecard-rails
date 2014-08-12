class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:user_id]
      user_index
    elsif params[:project_id]
      project_index
    end
  end

  def user_index
    @user = User.find(params[:user_id])
    authorize! :report, @user
    @workloads = current_user.workloads
      .complete.daily
    render "user_index"
  end

  def project_index
    @project = Project.find(params[:project_id])
    authorize! :report, @project
    render "project_index"
  end
end
