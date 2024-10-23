class Admin::MessagesPackagesController < AdminController
  def create
    result = MessagesPackages::Create.default.call(request.parameters)

    if result.success?
      render json: { data: result.data }, status: :created
    elsif result.component == :contract
      render json: { errors: result.errors }, status: :unprocessable_entity
    else
      render json: { errors: result.errors }, status: :bad_request
    end
  end
end
