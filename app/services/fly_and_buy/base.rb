module FlyAndBuy
  class Base

    protected

    def fly_buy_profile_completed(synapse_pay:, fly_buy_profile:)
      synapse_user = synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)

      if synapse_user.permission == 'SEND-AND-RECEIVE'
        fly_buy_profile.update_attributes(permission_scope_verified: true, kba_questions: {}, error_details: {}, completed: true)

        UserMailer.send_account_verified_notification_to_user(fly_buy_profile).deliver_later
      end
    end

    def encode_attachment(file_tempfile:, file_type:)
      file_content = open(parse_original_path(file_tempfile.gsub(/\?\d+$/, ''))) { |f| f.read }

      encode_64(file_content, file_type)
    end

    def encode_file(file:, type:)
      content = IO.read(file)

      encode_64(content, type)
    end

    def convert_invoice_to_image(fly_buy_order, user)
      html = ActionController::Base.new.send(:render_to_string,
        partial: 'shared/invoice',
        #file: File.join(Rails.root, 'app/views/shared/_invoice.html.slim'),
        locals: { order: fly_buy_order, user: user },
        layouts: 'layouts/print.html.slim'
      )

      kit = IMGKit.new(html)
      img = kit.to_png

      file  = Tempfile.new(['invoice', '.png'], encoding: 'ascii-8bit')
      file.write(img)

      file
    end

    def seller_account_type(fly_buy_profile)
      if fly_buy_profile.outside_the_us?
        'WIRE-INT'
      else
        'WIRE-US'
      end
    end

    def calulate_total_fee(fly_buy_order, per_unit_commission)
      fly_buy_order.count * per_unit_commission.to_f
    end

    private

    def encode_64(content, type)
      encoded = Base64.encode64(content)
      mime_padding = "data:#{type};base64,"

      "#{mime_padding}#{encoded}"
    end

    def parse_original_path(path)
      File.join(Rails.root, 'public', path)
    end
  end
end
