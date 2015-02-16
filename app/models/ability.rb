class Ability
  include CanCan::Ability

  def initialize(current_user, params)
    current_user ||= User.new

    # Logged-in Users can
    if current_user.persisted?
      can do |action, subject_class, subject|
        if subject_class == User
          if [:read, :update, :next_services, :previous_services].include? action
            if current_user.admin?
              true
            elsif subject.present? # subject is the user being edited, read, updated...
              subject.id == current_user.id
            elsif params.include? :user_id
              current_user.id == params[:user_id].to_i
            else
              false
            end
          end
        end
      end
    end
  end
end
