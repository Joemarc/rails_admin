module Presenters
  include ApplicationHelper

  module ServicePresenter
    def status_enum
      Service::STATUSES
    end

    def user_link
      user.name
    end
  end
end
