class API < Grape::API
  prefix "api"
  version "v1", using: :header, vendor: "timecard"
  format :json
  formatter :json, Grape::Formatter::Jbuilder

  helpers do
    def warden
      env['warden']
    end

    def authenticated!
      if warden.authenticated?
        true
      else
        error!("401 Unauthorized", 401)
      end
    end

    def current_user
      warden.user
    end
  end

  namespace :my do
    PER_PAGE = 10

    resource :projects do
      desc "Return all my projects"
      get do
        authenticated!
        @projects = Project.visible(current_user)
      end

      route_param :id do
        params do
          optional :status, type: String, default: "open"
          optional :page, type: Integer, default: 1
        end

        get "issues", jbuilder: "issues" do
          authenticated!
          project = Project.find(params[:id])
          @issues = project.issues.with_status(params[:status]).where("assignee_id = ?", current_user.id).page(params[:page]).per(PER_PAGE)
        end
      end
    end

    resource :issues do
      params do
        optional :status, type: String, default: "open"
        optional :page, type: Integer, default: 1
      end
      desc "Return all my issues"
      get "", jbuilder: "issues" do
        authenticated!
        @current_user = current_user
        @issues = current_user.issues.with_status(params[:status]).page(params[:page]).per(PER_PAGE)
      end
    end

    resource :workloads do
      desc "Return latest my workloads"
      get "latest", jbuilder: "workloads" do
        authenticated!
        @workloads = current_user.workloads.order("updated_at DESC").limit(10)
      end
    end
  end
end
