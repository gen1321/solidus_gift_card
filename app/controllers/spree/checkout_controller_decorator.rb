Spree::CheckoutController.class_eval do

  Spree::PermittedAttributes.checkout_attributes << :gift_code

  durably_decorate :update, mode: 'soft', sha: '908d25b70eff597d32ddad7876cd89d3683d6734' do
    if @order.update_from_params(params, permitted_checkout_attributes)
      if @order.gift_code.present?
        render :edit and return unless apply_gift_code
      end


      unless @order.next
        flash[:error] = @order.errors.full_messages.join("\n")
        redirect_to checkout_state_path(@order.state) and return
      end

      if @order.completed?
        session[:order_id] = nil
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:commerce_tracking] = "nothing special"
        redirect_to completion_route
      else
        redirect_to checkout_state_path(@order.state)
      end
    else
      render :edit
    end

  end

  private
  def persist_user_address!
    if !self.temporary_address && self.user && self.user.respond_to?(:persist_order_address) && self.bill_address_id
      self.user.persist_order_address(self)
    end
  end

end
