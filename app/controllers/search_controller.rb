class SearchController < ApplicationController
  allow_unauthenticated_access if respond_to?(:allow_unauthenticated_access)

  def index
    @query = params[:q].to_s.strip
    @type = params[:type].presence
    @search = GlobalSearch.new(query: @query, type: @type).call
  end
end
