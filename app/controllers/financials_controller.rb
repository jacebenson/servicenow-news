class FinancialsController < ApplicationController
  def index
    @show_nav_tabs = true
    @financials = ServicenowInvestment.all
    @types = ServicenowInvestment.where.not(investment_type: [ nil, "" ]).distinct.order(:investment_type).pluck(:investment_type)

    if params[:type].present? && @types.include?(params[:type])
      @financials = @financials.where(investment_type: params[:type])
    end

    if params[:year].present? && params[:year].match?(/\A\d{4}\z/)
      year = params[:year].to_i
      @financials = @financials.where(date: Date.new(year, 1, 1)...Date.new(year + 1, 1, 1))
    end

    if params[:search].present?
      @search = params[:search].strip
      safe_search = sanitize_sql_like(@search)
      query = "%#{safe_search}%"
      @financials = @financials.where(
        "company_name LIKE :query OR summary LIKE :query OR content LIKE :query",
        query: query
      )
    end

    @total_count = ServicenowInvestment.count
    @acquisition_count = ServicenowInvestment.where(investment_type: "Acquisition").count
    @investment_count = ServicenowInvestment.where(investment_type: "Investment").count
    @years = ServicenowInvestment.where.not(date: nil).distinct.order(date: :desc).pluck(:date).filter_map { |date| date&.year }.uniq
    @financials = @financials.order(date: :desc).page(params[:page]).per(50)
  end
end
