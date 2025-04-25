module Api
  class BaseController < ActionController::API
    include ActionController::MimeResponds
    
    private

    def render_error(message, status = :unprocessable_entity)
      render json: { error: message }, status: status
    end

    def render_success(data, status = :ok)
      render json: data, status: status
    end
  end
end 