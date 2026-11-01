module PublicIndexing
  extend ActiveSupport::Concern

  ORIGIN = "https://news.jace.pro".freeze
  FILTERS = {
    "partners" => %w[search level build consulting country state has_people],
    "news_items" => %w[search participant],
    "applications" => %w[search company app_type price trial no_license dev_instance prod_instance min_reviews published_within sort direction],
    "participants" => %w[search],
    "financials" => %w[search type year],
    "mvp_awards" => %w[search year award_type],
    "knowledge_sessions" => %w[search company exclude_servicenow recorded venue room tags speaker_filter session_types list sort session_event all]
  }.freeze
  COLLECTIONS = {
    "partners" => :@partners, "news_items" => :@news_items,
    "applications" => :@apps, "participants" => :@participants,
    "financials" => :@financials, "mvp_awards" => :@participants,
    "knowledge_sessions" => :@sessions
  }.freeze

  included do
    before_action :validate_public_page_number
    after_action :set_public_indexing_status
    helper_method :public_canonical_url, :public_noindex?
  end

  def public_noindex?
    return true unless public_page?
    return true if action_name == "index" && public_filters?
    return true if controller_name == "search" && params[:q].present?

    response.status >= 400
  end

  def public_canonical_url
    return if public_noindex?

    path = case controller_name
    when "search" then root_path
    when "participants"
      action_name == "show" ? person_path(name: @participant.slug) : people_path
    when "knowledge_sessions" then event_sessions_path(@event)
    else request.path
    end
    # Preserve real pagination; tracking and unknown parameters do not change content.
    page = params[:page].to_i if action_name == "index" && FILTERS.key?(controller_name)
    query = page && page > 1 ? "?#{ { page: page }.to_query }" : ""
    "#{ORIGIN}#{path}#{query}"
  end

  private

  def public_page?
    !controller_path.start_with?("admin/") &&
      (FILTERS.key?(controller_name) || controller_name == "search") &&
      %w[index show].include?(action_name)
  end

  def public_filters?
    FILTERS.fetch(controller_name, []).any? { |key| params[key].present? }
  end

  def validate_public_page_number
    return unless public_page? && action_name == "index" && FILTERS.key?(controller_name)
    return unless params.key?(:page)

    head :not_found unless params[:page].to_s.match?(/\A[1-9]\d{0,8}\z/)
  end

  def set_public_indexing_status
    if public_page? && action_name == "index" && response.successful? && response.media_type == "text/html"
      collection = instance_variable_get(COLLECTIONS[controller_name]) if COLLECTIONS.key?(controller_name)
      # Display options alone do not describe a missing subset of records.
      result_filters = FILTERS.fetch(controller_name, []) - %w[sort direction all]
      empty_filter = result_filters.any? { |key| params[key].present? } && collection && collection.empty?
      beyond_last = collection.respond_to?(:out_of_range?) && collection.current_page > 1 && collection.out_of_range?
      beyond_last ||= controller_name == "knowledge_sessions" && @page && @page > [ @total_pages, 1 ].max
      response.status = :not_found if empty_filter || beyond_last
    end
    response.headers["X-Robots-Tag"] = "noindex, follow" if public_noindex?
  end
end
