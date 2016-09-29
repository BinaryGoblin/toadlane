class PrintController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_terms_of_service
  layout 'print'

  def invoice
    case params[:type]
    when 'stripe'
      @order = StripeOrder.find(params[:id])
    when 'green'
      @order = GreenOrder.find(params[:id])
    when 'amg'
      @order = AmgOrder.find(params[:id])
    when 'emb'
      @order = EmbOrder.find(params[:id])
    when 'fly_buy'
      @order = FlyBuyOrder.find(params[:id])
    else
      @order = StripeOrder.find(params[:id])
    end      
  end

  def print_result_pdf(result)
    html = ac.render_to_string(
        {
            layout: 'layouts/print.html.slim',
            file: Rails.root + '/app/views/shared/_invoice.html.slim',
            locals: {order: FlyBuyOrder.last}
        })
    kit = IMGKit.new(ac.render_to_string(
        {
            layout: 'layouts/print.html.slim',
            file: Rails.root + '/app/views/shared/_invoice.html.slim',
            locals: {order: FlyBuyOrder.last}
        }))

    target_partial_path = Rails.root + '/app/views/drug_tests/_print_result.pdf.slim'
    pdf_template_path = 'layouts/pdf.slim'
    file_name = "print_result_#{Time.now.to_i}.pdf"
    pdf = render_to_string(
        {
            layout: pdf_template_path,
            file: target_partial_path,
            pdf: file_name,
            locals: {result: result}, margin: {top: "1.0mm"}
        })

    send_data pdf, filename: file_name
  end
end