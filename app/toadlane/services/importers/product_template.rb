module Services
  module Importers
    class ProductTemplate

      def self.render
        payment_types = ::Product::PaymentOptions.values
        conditions = ::Product::CONDITIONS.values
        package = Axlsx::Package.new(:author => "Toadlane")
        package.use_shared_strings = true
        wb = package.workbook
        wb.styles do |s|
          caption = s.add_style(bg_color: "2987d8", fg_color: 'F5F5F5', border: Axlsx::STYLE_THIN_BORDER, alignment: { horizontal: :left, vertical: :center }, b: true, sz: 13)
          header = s.add_style(bg_color: "2987d8", fg_color: 'F5F5F5', border: Axlsx::STYLE_THIN_BORDER, alignment: { horizontal: :center, vertical: :center }, b: true, sz: 11)
          example = s.add_style(bg_color: "b3e5fc", border: Axlsx::STYLE_THIN_BORDER, alignment: { horizontal: :center, vertical: :center }, b: false, sz: 11)
          main_header = s.add_style(bg_color: "ffffff", border: { style: :none, color: 'ffffff' }, alignment: { horizontal: :left, vertical: :center }, b: true, sz: 18)
          header_note = s.add_style(bg_color: "ffffff", border: { style: :none, color: 'ffffff' }, alignment: { horizontal: :left, vertical: :center }, b: true, sz: 10)
          value = s.add_style(bg_color: "F5F5F5", border: Axlsx::STYLE_THIN_BORDER, alignment: { horizontal: :left, vertical: :center }, sz: 11)
          input_value = s.add_style(locked: false, bg_color: "F5F5F5", border: Axlsx::STYLE_THIN_BORDER, alignment: { horizontal: :left, vertical: :center, wrap_text: true }, sz: 11)
          input_date_format = s.add_style(:locked => false, :bg_color => "F5F5F5", :border => Axlsx::STYLE_THIN_BORDER, :alignment => { :horizontal => :left, :vertical => :center }, :format_code => 'yyyy-mm-dd', :sz => 11)
          currency = s.add_style(:locked => false, :bg_color => "F5F5F5", :format_code => "$#,##0", :border => Axlsx::STYLE_THIN_BORDER, :alignment => { :horizontal => :right, :vertical => :center }, :sz => 11)
          password = ([*'0'..'9'] + [*'a'..'z'] + [*'A'..'Z']).shuffle.take(8).join

          description = "The Galaxy S6, this beautifully Table137 smartphone has an ultra-fast process and comes with a fingerprint reader, powerful front and rear camera, Samsung Pay, a heart rate monitor, and convenient mobile hotspot. This phone is manufactured with slim and lightweight materials including the 5.1” Corning Gorilla glass screen and polished metal body. This Amazon Certified Refurbished device has been refurbished at our approved repair center and comes with a 90-day return period. The phone may have minor cosmetic wear such as some light scratches on the screen and minor imperfections on sides and/or back. This device is being sold exclusively for use with Verizon. Includes A/C Adapter & Data Cable. Does not include headphones, SIM card, user manual, original box. Manufacturer's warranty is not verified or implied."
          wb.add_worksheet(:name => "Products") do |sheet|
            sheet.sheet_protection.password = password
            sheet.add_row ['Toadlane Bulk Inventory Upload', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],  :style => main_header
            sheet.add_row [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],  :style => main_header
            sheet.add_row ['Version 1.0', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],  :style => header_note
            sheet.add_row ::Product::TEMPLATE_HEADER, :style => header
            sheet.add_row ["Example Phone 32gb", "Samsung", "sm-g920f", "productID-11", "1000", "$100", 'YYYY-MM-DD', 'YYYY-MM-DD', '200', description, "New / Used/Refurbished", 'phone, samsung, galaxy s6, 32gb phone', 'Fly buy'], :style => example

            500.times do |i|
              sheet.add_row [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],  :style => [input_value, input_value, input_value, input_value, input_value, currency, input_date_format, input_date_format, input_value, input_value, input_value, input_value, input_value, input_value]
            end

            sheet.add_data_validation("K4:K505", { :type => :list, :formula1 => "condition", :showDropDown => false, :showErrorMessage => true, :errorTitle => '', :error => 'Please select valid condition', :errorStyle => :stop, :showInputMessage => false })
            sheet.add_data_validation("M4:M505", { :type => :list, :formula1 => "payment_types", :showDropDown => false, :showErrorMessage => true, :errorTitle => '', :error => 'Please select valid payment type', :errorStyle => :stop, :showInputMessage => false })
            # sheet.add_comment :ref => "A3", :author => "Toadlane", :text => "Date format must be like DD-MM-YYYY", :visible => false
            sheet.column_widths(40, 40, 40, 30, 15, 15, 15, 15, 15, 15, 15, 15, 15)
          end

          wb.add_worksheet(:name => "Payment", :state => :hidden) do |sheet|
            sheet.sheet_protection.password = password
            sheet.add_row ["Payment"], :style => [header]
            payment_types.each do |type|
              sheet.add_row [ "#{type}" ]
            end
            wb.add_defined_name("'Payment'!$A$2:$A$#{payment_types.length+1}", :name => 'payment_types')
            sheet.rows.each { |r| r.hidden = true }
          end

          wb.add_worksheet(:name => "Condition", :state => :hidden) do |sheet|
            sheet.sheet_protection.password = password
            sheet.add_row ["Condition"], :style => [header]
            conditions.each do |type|
              sheet.add_row [ "#{type}" ]
            end
            wb.add_defined_name("'Condition'!$A$2:$A$#{conditions.length+1}", :name => 'condition')
            sheet.rows.each { |r| r.hidden = true }
          end
        end
        package
      end
    end
  end
end