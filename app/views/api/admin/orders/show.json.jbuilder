json.order do
  json.id @order.id
  json.href api_admin_order_url(@order)
  json.order_number @order.order_number
  if @order.user
    json.user do
      json.id   @order.user.id
      json.href api_admin_user_url(@order.user)
    end
  end
  json.email_address            @order.email_address
  json.delivery_full_name       @order.delivery_full_name
  json.delivery_address_line_1  @order.delivery_address_line_1
  json.delivery_address_line_2  @order.delivery_address_line_2
  json.delivery_town_city       @order.delivery_town_city
  json.delivery_county          @order.delivery_county
  json.delivery_postcode        @order.delivery_postcode
  json.delivery_phone_number    @order.delivery_phone_number
  json.shipping_amount          @order.shipping_amount
  json.shipping_tax_amount      @order.shipping_tax_amount
  json.shipping_method          @order.shipping_method
  json.status                   @order.api_status_description
  json.total                    @order.total
  json.ip_address               @order.ip_address
  json.processed_at             @order.processed_at
  json.created_at               @order.created_at
  json.updated_at               @order.updated_at
  json.order_lines(@order.order_lines) do |order_line|
    json.id                   order_line.id
    json.href                 api_admin_order_line_url(order_line)
    if order_line.product
      json.product do
        json.id   order_line.product.id
        json.href api_admin_product_url(order_line.product)
      end
    end
    json.product_name         order_line.product_name
    json.product_sku          order_line.product_sku
    json.product_price        order_line.product_price
    json.product_weight       order_line.product_weight
    json.tax_amount           order_line.tax_amount
    json.feature_descriptions order_line.feature_descriptions
    json.shipped              order_line.shipped
    json.created_at           order_line.created_at
    json.updated_at           order_line.updated_at
  end
  json.payments(@order.payments) do |payment|
    json.id               payment.id
    json.href             api_admin_payment_url(payment)
    json.amount           payment.amount
    json.accepted         payment.accepted
    json.service_provider payment.service_provider
  end
end
