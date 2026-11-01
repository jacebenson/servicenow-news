class SitemapsController < ActionController::Base
  PAGE_SIZE = 5_000
  TYPES = %w[news partners applications people].freeze

  def index
    @sitemaps = TYPES.flat_map do |type|
      pages = (records_for(type).count.to_f / PAGE_SIZE).ceil
      (1..pages).map { |page| "#{PublicIndexing::ORIGIN}/sitemaps/#{type}-#{page}.xml" }
    end
    @sitemaps.unshift("#{PublicIndexing::ORIGIN}/sitemaps/pages.xml")
    expires_in 1.hour, public: true
  end

  def pages
    @paths = [ root_path, items_path, partners_path, applications_path, people_path,
      financials_path, mvps_path, sessions_path ] +
      %w[k20 k21 k22 k23 k24 k25 k26 nulledge25].map { |event| "/#{event}" }
    expires_in 1.hour, public: true
  end

  def show
    return head :not_found unless TYPES.include?(params[:type]) && params[:page].match?(/\A[1-9]\d{0,8}\z/)

    @type = params[:type]
    # Bound each sitemap response rather than loading the entire news corpus.
    @records = records_for(@type).order(:id).offset((params[:page].to_i - 1) * PAGE_SIZE)
      .limit(PAGE_SIZE).select(:id, :updated_at, *(@type == "people" ? [ :name ] : []))
    return head :not_found unless @records.exists?

    expires_in 1.hour, public: true
  end

  private

  def records_for(type)
    case type
    when "news" then NewsItem.active
    when "partners" then Company.partners.active
    when "applications" then ServicenowStoreApp.all
    when "people" then Participant.where(hidden: false).where.not(name: [ nil, "" ])
    end
  end
end
