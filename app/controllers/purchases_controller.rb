class PurchasesController < ApplicationController
  before_action :authenticate_user

  def create
    purchaser = Purchaser.new(current_user, purchase_params)

    if purchaser.call
      purchaser.purchase.confirm!
      serialize({})
    else
      error = purchaser.error
      failed_purchase(purchaser.purchase, error)
      handle_error_with_description(:invalid_parameter, error.to_s)
    end
  end

  private

  def failed_purchase(purchase, error)
    purchase.error!(code: error.code,
                    description: error.description,
                    messages: error.messages)
  end

  def purchase_params
    params.permit(:product_id, :token_id, :token_value, :idempotency_key)
  end
end
