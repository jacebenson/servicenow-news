class SlugsController < ApplicationController
  def show
    slug = params[:slug]

    participant = Participant.find_by_slug(slug)
    if participant
      if participant.hidden? && !admin?
        head :not_found
        return
      end
      redirect_to person_path(name: participant.slug), status: :moved_permanently
      return
    end

    # Try to find a company
    company = Company.where("LOWER(name) = ?", slug.downcase).first
    if company&.is_partner? && company.active?
      redirect_to partner_path(company), status: :moved_permanently
      return
    end

    # Not found
    head :not_found
  end
end
