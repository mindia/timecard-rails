class DataController < ApplicationController
  def show
    raise unless current_user
    raise if Member.where(user_id: current_user.id, project_id: params[:id].to_i).blank?
    res = {}
    project = Project.find(params[:id])
    res["name"] = project.name
    res["issues"] = project.issues.map do |issue|
      iss = JSON.parse(issue.to_json)
      iss["author_email"] = issue.author.email
      iss.delete("author_id")
      iss["created_at"] = issue.created_at.to_i
      iss["updated_at"] = issue.updated_at.to_i

      iss["workloads"] = Workload.where(issue_id: issue["id"]).map{|wl|
        wl_hash = JSON.parse(wl.to_json)
        wl_hash["start_at"] = wl.start_at.to_i
        wl_hash["end_at"] = wl.end_at.to_i
        wl_hash["user_email"] = wl.user.email
        wl_hash.delete("user_id")
        wl_hash
      }.map{|wl|
        wl.delete("id")
        wl.delete("issue_id")
        wl.delete("created_at")
        wl.delete("updated_at")
        wl
      }

      iss["comments"] = Comment.where(issue_id: issue["id"]).map do |comment|
        comment_hash = JSON.parse(comment.to_json)
        comment_hash["body"] = comment.body
        comment_hash["user_email"] = comment.user.email
        comment_hash
      end.map do |comment|
        comment.delete("id")
        comment.delete("user_id")
        comment.delete("issue_id")
        comment.delete("created_at")
        comment.delete("updated_at")
        comment
      end

      iss.delete("id")
      iss.delete("project_id")
      iss
    end

    render json: res.to_json
  end

  def create
    pjt = JSON.parse(params[:import].read)
    @project = Project.new(name: pjt["name"])
    @project.save
    if pjt["providers"] && pjt["providers"]["github"]
      pjtg = pjt["providers"]["github"].first
      @project.add_github("#{pjtg["owner_login"]}/#{pjtg["name"]}")
    end
    pjt["issues"].each do |iss|
      issue = Issue.new(subject: iss["subject"])
      issue.created_at = Time.at(iss["created_at"])
      issue.author_id = User.find_or_create_by(email: iss["author_email"]).id
      issue.project_id = @project.id
      issue.save

      if iss["providers"] && iss["providers"]["github"]
        issue.add_github(iss["providers"]["github"]["number"]) 
      end
      iss["workloads"].each do |wl|
        workload = Workload.new
        workload.user_id = User.find_or_create_by(email: wl["user_email"]).id
        workload.start_at = Time.at(wl["start_at"])
        workload.end_at = Time.at(wl["end_at"]) if wl["end_at"]
        workload.issue_id = issue.id
        workload.save
      end

      iss["comments"].each do |cmt|
        comment = Comment.new
        comment.user_id = User.find_or_create_by(email: cmt["user_email"]).id
        comment.body = cmt["body"]
        comment.issue_id = issue.id
        comment.save
      end
    end
    redirect_to project_path(@project)
  end
end
