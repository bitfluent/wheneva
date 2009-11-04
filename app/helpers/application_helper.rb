# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(page_title, show_title = true)
    @content_for_title = page_title.to_s
    @show_title = show_title
  end

  def current_account
    @current_account ||= Account.find_by_subdomain(current_subdomain)
    raise ActiveRecord::RecordNotFound unless @current_account
    @current_account
  end
end
