# Copyright 2011-2012 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of ViSH (Virtual Science Hub).
#
# ViSH is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ViSH is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with ViSH.  If not, see <http://www.gnu.org/licenses/>.

class ResourcesController < ApplicationController
  def search
    headers['Last-Modified'] = Time.now.httpdate

    if params[:live].present?
      @found_resources = ThinkingSphinx.search params[:q], search_options.deep_merge!( { :classes => [Embed] } )
    elsif params[:object].present?
      @found_resources = ThinkingSphinx.search params[:q], search_options.deep_merge!( { :classes => [Embed, Swf, Officedoc] } )
    else
      @found_resources = ThinkingSphinx.search params[:q], search_options.deep_merge!( { :classes => [Document, Embed, Link] } )
    end
    respond_to do |format|
      format.html { render :layout => false }
      format.json {
        if params[:object].present?
          render :partial => 'objects/object_search_result'
        else
          render :json => @found_resources
        end
      }
    end
  end

  private
  def search_options
    opts = search_scope_options

    # search only live resources
    if params[:live].present?
      opts.deep_merge!( { :with => { :live => true } } )
    end

    # Pagination
    opts.merge!({
      :order => :created_at,
      :sort_mode => :desc,
      :per_page => params[:per_page] || 20,
      :page => params[:page]
    })

      opts
  end

  def search_subject
    @search_subject ||=
      ( Actor.find_by_slug(URI(request.referer).path.split("/")[2]) || current_subject )
  end

  def search_scope_options
    if params[:scope].blank? || search_subject.blank?
      return {}
    end

    case params[:scope]
    when "me"
      { :with => { :author_id => [ search_subject.id ] } }
    when "net"
      { :with => { :author_id => search_subject.following_actor_ids } }
    when "other"
      { :without => { :author_id => search_subject.following_actor_and_self_ids } }
    else
      raise "Unknown search scope #{ params[:scope] }"
    end
  end

end
