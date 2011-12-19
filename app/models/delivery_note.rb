class DeliveryNote < ActiveRecord::Base

  belongs_to :product

  after_save :update_stock


  def update_stock
    product.amount -= amount
    product.save
  end

end
